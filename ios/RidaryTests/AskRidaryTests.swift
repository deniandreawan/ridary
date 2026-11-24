import XCTest
@testable import Ridary

final class AskRidaryContextTests: XCTestCase {
    func testContextContainsDerivedDataOnly() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let ride = makeRide(
            startedAt: now.addingTimeInterval(-3600),
            events: [makeEvent(rideID: UUID(), at: now.addingTimeInterval(-3000))]
        )
        let incident = makeIncident(lockedAt: now.addingTimeInterval(-1800))
        let credential = makeCredential()

        let context = AskRidaryContextBuilder().build(
            rides: [ride],
            incidents: [incident],
            credentials: [credential],
            weeklyFeedback: nil,
            now: now
        )
        let json = try RidaryJSON.string(context)

        XCTAssertEqual(context.recentRides.count, 1)
        XCTAssertEqual(context.recentRides.first?.score ?? 0, 96)
        XCTAssertEqual(context.recentRides.first?.events.count ?? 0, 1)
        XCTAssertEqual(context.weekly.rides, 1)
        XCTAssertEqual(context.allTime.rides, 1)
        XCTAssertEqual(context.credential?.band ?? "", "A")

        for forbidden in [
            "routePreview", "geohash", "latitude", "longitude", "window",
            "samples", "signature", "payloadHash", "credentialId", "rideID",
            "statement", "deadbeef", "user-1", "payload-secret", "signature-secret"
        ] {
            XCTAssertFalse(json.contains(forbidden), "Context leaked \(forbidden)")
        }
        XCTAssertTrue(json.contains("\"score\":96"))
    }

    func testContextCapsRidesAndEvents() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let rides = (0..<6).map { offset in
            makeRide(
                startedAt: now.addingTimeInterval(Double(-offset) * 3600),
                events: (0..<4).map { eventOffset in
                    makeEvent(
                        rideID: UUID(),
                        at: now.addingTimeInterval(Double(-eventOffset) * 60)
                    )
                }
            )
        }

        let context = AskRidaryContextBuilder().build(
            rides: rides,
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            now: now
        )

        XCTAssertEqual(context.recentRides.count, 4)
        XCTAssertTrue(context.recentRides.allSatisfy { $0.events.count <= 2 })
    }

    func testWeeklyAggregateUsesLastSevenDays() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let recent = makeRide(
            startedAt: now.addingTimeInterval(-2 * 24 * 3600),
            distanceM: 5_000
        )
        let old = makeRide(
            startedAt: now.addingTimeInterval(-20 * 24 * 3600),
            distanceM: 9_000
        )

        let context = AskRidaryContextBuilder().build(
            rides: [recent, old],
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            now: now
        )

        XCTAssertEqual(context.weekly.rides, 1)
        XCTAssertEqual(context.weekly.distanceM, 5_000, accuracy: 0.1)
        XCTAssertEqual(context.allTime.rides, 2)
        XCTAssertEqual(context.allTime.distanceM, 14_000, accuracy: 0.1)
    }

    private func makeRide(
        startedAt: Date,
        distanceM: Double = 8_200,
        events: [RideEvent] = []
    ) -> Ride {
        Ride(
            id: UUID(),
            mode: .motorcycle,
            startedAt: startedAt,
            endedAt: startedAt.addingTimeInterval(1_500),
            distanceM: distanceM,
            durationS: 1_500,
            avgSpeedKph: 32,
            maxSpeedKph: 58,
            score: 96,
            summary: "A steady ride.",
            inferenceSource: .onDevice,
            geohash: "qqguwx7",
            routePreview: [[-6.2088, 106.828], [-6.2150, 106.835]],
            events: events,
            snapshot: RideSnapshot(
                headline: "A steady ride with one hard brake",
                summary: "You kept a calm pace.",
                riskMoments: [],
                score: 96,
                scoreRationale: "One moderate braking moment.",
                coachingTip: "Leave more following distance."
            ),
            createdAt: startedAt,
            schemaVersion: 1
        )
    }

    private func makeEvent(rideID: UUID, at: Date) -> RideEvent {
        RideEvent(
            id: UUID(),
            rideID: rideID,
            type: .hardBrake,
            severity: 3,
            confidence: 0.8,
            occurredAt: at,
            geohash: "qqguwx7",
            summary: "Hard braking before a junction.",
            source: .deterministic,
            window: []
        )
    }

    private func makeIncident(lockedAt: Date) -> Incident {
        Incident(
            id: UUID(),
            rideID: UUID(),
            eventID: UUID(),
            mode: .motorcycle,
            eventType: .hardBrake,
            severity: 3,
            eventSummary: "Hard braking before a junction.",
            lockedAt: lockedAt,
            hash: "deadbeef",
            summary: "Locked evidence",
            status: .locked,
            questions: [],
            answers: [:],
            statement: IncidentStatement(
                title: "Statement",
                timeline: [],
                statement: "Private statement text",
                evidenceChecklist: []
            ),
            statementSource: .onDevice,
            createdAt: lockedAt,
            schemaVersion: 1
        )
    }

    private func makeCredential() -> Credential {
        Credential(
            credentialId: "cred-1",
            uid: "user-1",
            periodStart: "2026-10-26T00:00:00Z",
            periodEnd: "2026-11-25T00:00:00Z",
            mode: .motorcycle,
            score: 96,
            rideCount: 5,
            eventCount: 3,
            issuedAt: "2026-11-25T00:00:00Z",
            expiresAt: "2027-02-15T00:00:00Z",
            issuer: "Ridary",
            publicKeyId: "ridary-dev-1",
            payloadHash: "payload-secret",
            signature: "signature-secret"
        )
    }
}

final class AskRidaryServiceTests: XCTestCase {
    func testHybridAnswerReturnsTextAndSource() async {
        let ai = FakeAIService(
            result: .success(
                AIResult(
                    text: "Your last ride was calm.",
                    modelVersion: "apple-foundation-models",
                    source: .onDevice
                )
            )
        )
        let service = AskRidaryService()

        let reply = await service.ask(
            question: "Why was my last ride marked risky?",
            history: [],
            rides: [makeRide()],
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            ai: ai
        )

        XCTAssertEqual(reply.text, "Your last ride was calm.")
        XCTAssertEqual(reply.source, .onDevice)
        XCTAssertTrue(ai.lastPrompt?.contains("Why was my last ride marked risky?") == true)
        XCTAssertTrue(ai.lastPrompt?.contains("recentRides") == true)
        XCTAssertFalse(ai.lastPrompt?.contains("routePreview") == true)
    }

    func testNotConfiguredFallsBackToRules() async {
        let ai = FakeAIService(result: .failure(AIError.notConfigured))
        let service = AskRidaryService()

        let reply = await service.ask(
            question: "Why was my last ride marked risky?",
            history: [],
            rides: [makeRide()],
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            ai: ai
        )

        XCTAssertEqual(reply.source, .deterministic)
        XCTAssertTrue(reply.text.contains("last ride"))
        XCTAssertTrue(reply.text.contains("96/100"))
    }

    func testOtherAIErrorFallsBack() async {
        let ai = FakeAIService(result: .failure(NSError(domain: "test", code: 1)))
        let service = AskRidaryService()

        let reply = await service.ask(
            question: "How did my week look?",
            history: [],
            rides: [makeRide()],
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            ai: ai
        )

        XCTAssertEqual(reply.source, .fallback)
        XCTAssertTrue(reply.text.contains("This week"))
    }

    func testEmptyResponseFallsBack() async {
        let ai = FakeAIService(
            result: .success(
                AIResult(text: "   ", modelVersion: "model", source: .inCloud)
            )
        )
        let service = AskRidaryService()

        let reply = await service.ask(
            question: "What is Ridary Proof?",
            history: [],
            rides: [],
            incidents: [],
            credentials: [],
            weeklyFeedback: nil,
            ai: ai
        )

        XCTAssertEqual(reply.source, .fallback)
        XCTAssertFalse(reply.text.isEmpty)
        XCTAssertTrue(reply.text.contains("Ridary Proof"))
    }

    private func makeRide() -> Ride {
        Ride(
            id: UUID(),
            mode: .motorcycle,
            startedAt: Date(timeIntervalSince1970: 1_800_000_000),
            endedAt: Date(timeIntervalSince1970: 1_800_001_500),
            distanceM: 8_200,
            durationS: 1_500,
            avgSpeedKph: 32,
            maxSpeedKph: 58,
            score: 96,
            summary: "A steady ride.",
            inferenceSource: .onDevice,
            geohash: "qqguwx7",
            routePreview: [[-6.2088, 106.828], [-6.2150, 106.835]],
            events: [],
            snapshot: RideSnapshot(
                headline: "A steady ride",
                summary: "You kept a calm pace.",
                riskMoments: [],
                score: 96,
                scoreRationale: "One moderate braking moment.",
                coachingTip: "Leave more following distance."
            ),
            createdAt: Date(timeIntervalSince1970: 1_800_001_500),
            schemaVersion: 1
        )
    }
}

private final class FakeAIService: AIService {
    let result: Result<AIResult, Error>
    private(set) var lastPrompt: String?

    init(result: Result<AIResult, Error>) {
        self.result = result
    }

    func onDeviceAvailability() async -> OnDeviceAvailability {
        .available
    }

    func generate(prompt: String, mode: AIMode) async throws -> AIResult {
        lastPrompt = prompt
        return try result.get()
    }
}
