import Combine
import FirebaseFirestore
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let firebaseStatus: FirebaseStatus
    let store: LocalRideStore
    let auth: AuthService
    let settings: AppSettings
    let remoteConfig: RemoteConfigService
    let capture: RideCaptureService

    @Published private(set) var isReady = false
    @Published private(set) var userID: String?
    @Published private(set) var authBusy = false
    @Published private(set) var authError: String?
    @Published private(set) var isLocalDemo = false
    @Published private(set) var onDeviceAvailability: OnDeviceAvailability = .unknown(
        "Checking on-device AI…"
    )
    @Published private(set) var rides: [Ride] = []
    @Published private(set) var incidents: [Incident] = []
    @Published private(set) var credentials: [Credential] = []
    @Published private(set) var weeklyFeedback: WeeklyFeedback?
    @Published private(set) var weeklySource: InferenceSource = .deterministic
    @Published private(set) var weeklyBusy = false
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?
    @Published var lastCompletedRide: Ride?

    private(set) var aiService: AIService
    private let backend: BackendFunctions?
    private let sync: RideSyncService?
    private let summaryService = RideSummaryService()
    private let incidentService = IncidentInterviewService()
    private let weeklyService = WeeklyFeedbackService()
    private var cancellables: Set<AnyCancellable> = []
    private var lastCloudModelName = "gemini-3.5-flash-lite"
    private var didBootstrap = false

    init() {
        let status = FirebaseBootstrap.configure()
        self.firebaseStatus = status
        self.store = LocalRideStore()
        self.settings = AppSettings()
        self.auth = AuthService(isConfigured: status.isConfigured)
        self.remoteConfig = RemoteConfigService(isConfigured: status.isConfigured)
        self.capture = RideCaptureService(store: store)

        if status.isConfigured {
            self.aiService = FirebaseAIService()
            self.backend = BackendFunctions()
            self.sync = RideSyncService()
        } else {
            self.aiService = MockAIService()
            self.backend = nil
            self.sync = nil
        }

        bindAuth()

        if !status.isConfigured {
            auth.enterLocalDemo()
            self.userID = "local-demo-user"
            self.isLocalDemo = true
        }
    }

    var isFirebaseConfigured: Bool {
        firebaseStatus.isConfigured
    }

    func bootstrap() async {
        guard !didBootstrap else { return }
        didBootstrap = true

        try? await store.prepare()
        rides = (try? await store.loadRides()) ?? []
        incidents = (try? await store.loadIncidents()) ?? []

        await remoteConfig.fetch()
        if firebaseStatus.isConfigured,
           remoteConfig.cloudModelName != lastCloudModelName {
            aiService = FirebaseAIService(cloudModelName: remoteConfig.cloudModelName)
            lastCloudModelName = remoteConfig.cloudModelName
        }

        if let firebaseAI = aiService as? FirebaseAIService {
            onDeviceAvailability = await firebaseAI.onDeviceAvailability()
        } else {
            onDeviceAvailability = .deviceNotEligible
        }

        if await store.loadActiveSession() != nil {
            await store.clearActiveSession()
            errorMessage = "A previous ride was interrupted. Start a new ride when you are ready."
        }

        if backend != nil, userID != nil {
            await loadCredentials()
        }

        isReady = true
    }

    func startRide() async -> Bool {
        guard !capture.isRecording else {
            return false
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            try await capture.start(
                mode: settings.mode,
                thresholds: remoteConfig.thresholds
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func stopRide() async -> Ride? {
        guard capture.isRecording else {
            return nil
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            var ride = try await capture.stop()
            ride = await summaryService.enrich(ride, ai: aiService)
            try await store.saveRide(ride)
            rides.insert(ride, at: 0)
            lastCompletedRide = ride

            if let sync {
                await sync.syncRide(
                    ride,
                    shareDerived: settings.shareDerived,
                    shareRoute: settings.shareRoute
                )
            }
            return ride
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func createIncident() async -> Incident? {
        guard let event = capture.lockLastWindow() else {
            errorMessage = "No ride samples are available to lock yet."
            return nil
        }

        let incidentID = UUID()
        let packet = EvidenceVault.makePacket(
            incidentID: incidentID,
            rideID: capture.currentRideID,
            mode: capture.currentMode,
            event: event,
            answers: [:],
            statement: nil
        )

        do {
            let data = try EvidenceVault.encode(packet)
            let hash = EvidenceVault.hash(data)
            _ = try await store.saveEvidence(data, incidentID: incidentID)

            let incident = Incident(
                id: incidentID,
                rideID: event.rideID,
                eventID: event.id,
                mode: capture.currentMode,
                eventType: event.type,
                severity: event.severity,
                eventSummary: event.summary,
                lockedAt: packet.lockedAt,
                hash: hash,
                summary: event.summary,
                status: .locked,
                questions: IncidentInterviewService.defaultQuestions,
                answers: [:],
                statement: nil,
                statementSource: nil,
                createdAt: Date(),
                schemaVersion: 1
            )
            try await store.saveIncident(incident)
            incidents.insert(incident, at: 0)
            return incident
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func draftStatement(
        incident: Incident,
        answers: [String: String]
    ) async -> (Incident, InferenceSource)? {
        do {
            guard let existingData = try await store.loadEvidence(incidentID: incident.id) else {
                errorMessage = "The evidence file for this incident is missing."
                return nil
            }
            let packet = try RidaryJSON.decode(EvidencePacket.self, from: existingData)
            let event = packet.asRideEvent()
            let (statement, source) = await incidentService.statement(
                for: event,
                answers: answers,
                ai: aiService
            )
            let updated = try await finalize(
                incident: incident,
                packet: packet,
                answers: answers,
                statement: statement,
                source: source
            )
            return (updated, source)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func refreshWeeklyFeedback() async {
        guard !weeklyBusy else { return }
        weeklyBusy = true
        defer { weeklyBusy = false }

        let stats: WeeklyStatsResponse
        if let backend, userID != nil {
            do {
                stats = try await backend.weeklyStats(mode: settings.mode)
            } catch {
                stats = localWeeklyStats()
            }
        } else {
            stats = localWeeklyStats()
        }

        let (feedback, source) = await weeklyService.generate(stats: stats, ai: aiService)
        weeklyFeedback = feedback
        weeklySource = source

        if let sync, settings.shareDerived {
            await sync.saveFeedback(feedback, weekStart: Date(), source: source)
        }
    }

    func issueCredential() async -> Credential? {
        guard let backend else {
            errorMessage = "Credential issuance needs a configured Firebase project."
            return nil
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let credential = try await backend.issueCredential(
                mode: settings.mode,
                days: 30
            )
            credentials.insert(credential, at: 0)
            return credential
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func createInsurerView(credentialID: String) async -> InsurerView? {
        guard let backend else {
            errorMessage = "Sharing needs a configured Firebase project."
            return nil
        }
        do {
            return try await backend.createInsurerView(credentialID: credentialID)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func verifyCredential(credentialID: String) async -> CredentialVerification? {
        guard let backend else {
            errorMessage = "Verification needs a configured Firebase project."
            return nil
        }
        do {
            return try await backend.verifyCredential(credentialID: credentialID)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func signOut() {
        auth.signOut()
        credentials = []
        weeklyFeedback = nil
        weeklySource = .deterministic
    }

    func enterLocalDemo() {
        auth.enterLocalDemo()
        isLocalDemo = true
    }

    private func finalize(
        incident: Incident,
        packet: EvidencePacket,
        answers: [String: String],
        statement: IncidentStatement,
        source: InferenceSource
    ) async throws -> Incident {
        let updatedPacket = EvidencePacket(
            version: packet.version,
            incidentID: packet.incidentID,
            rideID: packet.rideID,
            eventID: packet.eventID,
            eventSummary: packet.eventSummary,
            mode: packet.mode,
            lockedAt: packet.lockedAt,
            eventType: packet.eventType,
            severity: packet.severity,
            confidence: packet.confidence,
            occurredAt: packet.occurredAt,
            geohash: packet.geohash,
            windowStart: packet.windowStart,
            windowEnd: packet.windowEnd,
            sampleCount: packet.sampleCount,
            samples: packet.samples,
            answers: answers,
            statement: statement,
            appVersion: packet.appVersion
        )

        let data = try EvidenceVault.encode(updatedPacket)
        let hash = EvidenceVault.hash(data)
        _ = try await store.saveEvidence(data, incidentID: incident.id)

        var updated = incident
        updated.answers = answers
        updated.statement = statement
        updated.statementSource = source
        updated.hash = hash
        updated.summary = statement.statement
        updated.status = .draft

        try await store.saveIncident(updated)
        if let index = incidents.firstIndex(where: { $0.id == updated.id }) {
            incidents[index] = updated
        } else {
            incidents.insert(updated, at: 0)
        }
        return updated
    }

    private func localWeeklyStats() -> WeeklyStatsResponse {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let recent = rides.filter {
            $0.mode == settings.mode && $0.startedAt >= cutoff
        }
        let events = recent.flatMap(\.events)
        let periodStart = ISO8601DateFormatter().string(from: cutoff)
        let periodEnd = ISO8601DateFormatter().string(from: Date())

        return WeeklyStatsResponse(
            mode: settings.mode,
            periodStart: periodStart,
            periodEnd: periodEnd,
            rides: recent.map {
                WeeklyRideStat(
                    id: $0.id.uuidString,
                    startedAtMs: $0.startedAt.timeIntervalSince1970 * 1000,
                    distanceM: $0.distanceM,
                    durationS: $0.durationS,
                    score: $0.score,
                    summary: $0.summary,
                    inferenceSource: $0.inferenceSource.rawValue,
                    geohash: $0.geohash
                )
            },
            events: events.map {
                WeeklyEventStat(
                    rideId: $0.rideID.uuidString,
                    type: $0.type,
                    severity: $0.severity,
                    confidence: $0.confidence,
                    occurredAtMs: $0.occurredAt.timeIntervalSince1970 * 1000,
                    summary: $0.summary,
                    source: $0.source.rawValue
                )
            }
        )
    }

    private func loadCredentials() async {
        guard let userID else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("credentials")
                .whereField("uid", isEqualTo: userID)
                .order(by: "issuedAt", descending: true)
                .limit(to: 20)
                .getDocuments()
            credentials = snapshot.documents.compactMap { document in
                guard let json = try? JSONSerialization.data(
                    withJSONObject: document.data()
                ) else {
                    return nil
                }
                return try? RidaryJSON.decode(Credential.self, from: json)
            }
        } catch {
            RidaryLog.app.error(
                "Credential load failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private func bindAuth() {
        auth.$userID
            .sink { [weak self] id in
                Task { @MainActor in
                    self?.userID = id
                }
            }
            .store(in: &cancellables)

        auth.$isBusy
            .sink { [weak self] busy in
                Task { @MainActor in
                    self?.authBusy = busy
                }
            }
            .store(in: &cancellables)

        auth.$errorMessage
            .sink { [weak self] message in
                Task { @MainActor in
                    self?.authError = message
                }
            }
            .store(in: &cancellables)

        auth.$isLocalDemo
            .sink { [weak self] local in
                Task { @MainActor in
                    self?.isLocalDemo = local
                }
            }
            .store(in: &cancellables)
    }
}
