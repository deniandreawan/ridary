import XCTest
@testable import Ridary

final class LocalRideStoreTests: XCTestCase {
    func testSaveAndLoadRide() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RidaryTests-\(UUID().uuidString)", isDirectory: true)
        let store = LocalRideStore(rootURL: root)

        let ride = Ride(
            id: UUID(),
            mode: .motorcycle,
            startedAt: Date(timeIntervalSince1970: 100),
            endedAt: Date(timeIntervalSince1970: 200),
            distanceM: 1200,
            durationS: 100,
            avgSpeedKph: 43.2,
            maxSpeedKph: 50,
            score: 92,
            summary: "A clean ride.",
            inferenceSource: .onDevice,
            geohash: "qqguxm",
            routePreview: [[-6.2088, 106.8456]],
            events: [],
            snapshot: nil,
            createdAt: Date(timeIntervalSince1970: 200),
            schemaVersion: 1
        )

        try await store.saveRide(ride)
        let loaded = try await store.loadRides()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, ride.id)
        XCTAssertEqual(loaded.first?.score, 92)
        try? FileManager.default.removeItem(at: root)
    }

    func testDeleteRideRemovesIt() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RidaryTests-\(UUID().uuidString)", isDirectory: true)
        let store = LocalRideStore(rootURL: root)
        let ride = makeRide()

        try await store.saveRide(ride)
        try await store.deleteRide(id: ride.id)

        let loaded = try await store.loadRides()
        XCTAssertTrue(loaded.isEmpty)
        try? FileManager.default.removeItem(at: root)
    }

    func testDeleteIncidentAndEvidence() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RidaryTests-\(UUID().uuidString)", isDirectory: true)
        let store = LocalRideStore(rootURL: root)
        let incident = makeIncident()

        _ = try await store.saveEvidence(Data("evidence".utf8), incidentID: incident.id)
        try await store.saveIncident(incident)
        try await store.deleteEvidence(incidentID: incident.id)
        try await store.deleteIncident(id: incident.id)

        let incidents = try await store.loadIncidents()
        let evidence = try await store.loadEvidence(incidentID: incident.id)
        XCTAssertTrue(incidents.isEmpty)
        XCTAssertNil(evidence)
        try? FileManager.default.removeItem(at: root)
    }

    func testActiveSessionRoundTrip() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RidaryTests-\(UUID().uuidString)", isDirectory: true)
        let store = LocalRideStore(rootURL: root)
        let session = ActiveSession(
            rideID: UUID(),
            mode: .bicycle,
            startedAt: Date()
        )

        try await store.saveActiveSession(session)
        let loaded = await store.loadActiveSession()
        XCTAssertEqual(loaded?.rideID, session.rideID)
        XCTAssertEqual(loaded?.mode, .bicycle)

        await store.clearActiveSession()
        let cleared = await store.loadActiveSession()
        XCTAssertNil(cleared)
        try? FileManager.default.removeItem(at: root)
    }

    private func makeRide() -> Ride {
        Ride(
            id: UUID(),
            mode: .motorcycle,
            startedAt: Date(timeIntervalSince1970: 100),
            endedAt: Date(timeIntervalSince1970: 200),
            distanceM: 1200,
            durationS: 100,
            avgSpeedKph: 43.2,
            maxSpeedKph: 50,
            score: 92,
            summary: "A clean ride.",
            inferenceSource: .onDevice,
            geohash: "qqguxm",
            routePreview: [[-6.2088, 106.8456]],
            events: [],
            snapshot: nil,
            createdAt: Date(timeIntervalSince1970: 200),
            schemaVersion: 1
        )
    }

    private func makeIncident() -> Incident {
        Incident(
            id: UUID(),
            rideID: UUID(),
            eventID: UUID(),
            mode: .motorcycle,
            eventType: .hardBrake,
            severity: 2,
            eventSummary: "Hard brake",
            lockedAt: Date(timeIntervalSince1970: 200),
            hash: "hash",
            summary: "Hard brake",
            status: .locked,
            questions: [],
            answers: [:],
            statement: nil,
            statementSource: nil,
            createdAt: Date(timeIntervalSince1970: 200),
            schemaVersion: 1
        )
    }
}
