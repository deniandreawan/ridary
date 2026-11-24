import Foundation

struct ActiveSession: Codable, Sendable {
    let rideID: UUID
    let mode: RideMode
    let startedAt: Date
}

enum LocalRideStoreError: Error {
    case applicationSupportUnavailable
    case notFound
}

actor LocalRideStore {
    private let fileManager: FileManager
    private let rootURL: URL
    private let ridesURL: URL
    private let incidentsURL: URL
    private let evidenceURL: URL
    private let activeSessionURL: URL

    init(rootURL: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let rootURL {
            self.rootURL = rootURL
        } else {
            let base = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.rootURL = base.appendingPathComponent("Ridary", isDirectory: true)
        }
        self.ridesURL = self.rootURL.appendingPathComponent("rides", isDirectory: true)
        self.incidentsURL = self.rootURL.appendingPathComponent("incidents", isDirectory: true)
        self.evidenceURL = self.rootURL.appendingPathComponent("evidence", isDirectory: true)
        self.activeSessionURL = self.rootURL.appendingPathComponent("active-session.json")
    }

    func prepare() throws {
        try ensureDirectories()
    }

    func saveRide(_ ride: Ride) throws {
        try ensureDirectories()
        let data = try RidaryJSON.data(ride)
        let url = ridesURL.appendingPathComponent("ride-\(ride.id.uuidString).json")
        try writeProtected(data, to: url)
    }

    func loadRides() throws -> [Ride] {
        try ensureDirectories()
        let urls = try fileManager.contentsOfDirectory(
            at: ridesURL,
            includingPropertiesForKeys: nil
        )
        var rides: [Ride] = []
        for url in urls where url.lastPathComponent.hasPrefix("ride-") {
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let ride = try? RidaryJSON.decode(Ride.self, from: data) else { continue }
            rides.append(ride)
        }
        return rides.sorted { $0.startedAt > $1.startedAt }
    }

    func loadRide(id: UUID) throws -> Ride? {
        let url = ridesURL.appendingPathComponent("ride-\(id.uuidString).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try RidaryJSON.decode(Ride.self, from: data)
    }

    func deleteRide(id: UUID) throws {
        let url = ridesURL.appendingPathComponent("ride-\(id.uuidString).json")
        try removeIfExists(at: url)
    }

    func deleteIncident(id: UUID) throws {
        let url = incidentsURL.appendingPathComponent("incident-\(id.uuidString).json")
        try removeIfExists(at: url)
    }

    func deleteEvidence(incidentID: UUID) throws {
        let url = evidenceURL.appendingPathComponent("evidence-\(incidentID.uuidString).json")
        try removeIfExists(at: url)
    }

    func saveIncident(_ incident: Incident) throws {
        try ensureDirectories()
        let data = try RidaryJSON.data(incident)
        let url = incidentsURL.appendingPathComponent(
            "incident-\(incident.id.uuidString).json"
        )
        try writeProtected(data, to: url)
    }

    func loadIncidents() throws -> [Incident] {
        try ensureDirectories()
        let urls = try fileManager.contentsOfDirectory(
            at: incidentsURL,
            includingPropertiesForKeys: nil
        )
        var incidents: [Incident] = []
        for url in urls where url.lastPathComponent.hasPrefix("incident-") {
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let incident = try? RidaryJSON.decode(Incident.self, from: data) else {
                continue
            }
            incidents.append(incident)
        }
        return incidents.sorted { $0.lockedAt > $1.lockedAt }
    }

    func saveEvidence(_ data: Data, incidentID: UUID) throws -> String {
        try ensureDirectories()
        let fileName = "evidence-\(incidentID.uuidString).json"
        let url = evidenceURL.appendingPathComponent(fileName)
        try writeProtected(data, to: url)
        return fileName
    }

    func loadEvidence(incidentID: UUID) throws -> Data? {
        let url = evidenceURL.appendingPathComponent(
            "evidence-\(incidentID.uuidString).json"
        )
        return try? Data(contentsOf: url)
    }

    func saveActiveSession(_ session: ActiveSession) throws {
        try ensureDirectories()
        let data = try RidaryJSON.data(session)
        try writeProtected(data, to: activeSessionURL)
    }

    func loadActiveSession() -> ActiveSession? {
        guard let data = try? Data(contentsOf: activeSessionURL) else { return nil }
        return try? RidaryJSON.decode(ActiveSession.self, from: data)
    }

    func clearActiveSession() {
        try? fileManager.removeItem(at: activeSessionURL)
    }

    private func removeIfExists(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    private func ensureDirectories() throws {
        if !fileManager.fileExists(atPath: rootURL.path) {
            do {
                try fileManager.createDirectory(
                    at: rootURL,
                    withIntermediateDirectories: true
                )
            } catch {
                throw LocalRideStoreError.applicationSupportUnavailable
            }
        }
        for directory in [ridesURL, incidentsURL, evidenceURL] {
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(
                        at: directory,
                        withIntermediateDirectories: true
                    )
                } catch {
                    throw LocalRideStoreError.applicationSupportUnavailable
                }
            }
        }
    }

    private func writeProtected(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: [.atomic])
        try? fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
    }
}
