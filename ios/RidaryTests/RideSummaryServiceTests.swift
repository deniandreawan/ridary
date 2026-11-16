import XCTest
@testable import Ridary

final class RideSummaryServiceTests: XCTestCase {
    private func makeRide(events: [RideEvent]) -> Ride {
        Ride(
            id: UUID(),
            mode: .motorcycle,
            startedAt: Date(timeIntervalSince1970: 100),
            endedAt: Date(timeIntervalSince1970: 700),
            distanceM: 4200,
            durationS: 600,
            avgSpeedKph: 25.2,
            maxSpeedKph: 48,
            score: 88,
            summary: "Test ride.",
            inferenceSource: .deterministic,
            geohash: "qqguxm",
            routePreview: [[-6.2088, 106.8456]],
            events: events,
            snapshot: nil,
            createdAt: Date(timeIntervalSince1970: 700),
            schemaVersion: 1
        )
    }

    func testDeterministicSnapshotForCleanRide() {
        let ride = makeRide(events: [])
        let snapshot = RideSummaryService().deterministicSnapshot(for: ride)

        XCTAssertEqual(snapshot.score, 100)
        XCTAssertTrue(snapshot.riskMoments.isEmpty)
        XCTAssertFalse(snapshot.headline.isEmpty)
        XCTAssertFalse(snapshot.summary.isEmpty)
        XCTAssertFalse(snapshot.coachingTip.isEmpty)
    }

    func testDeterministicSnapshotIncludesRiskMoments() {
        let event = RideEvent(
            id: UUID(),
            rideID: UUID(),
            type: .hardBrake,
            severity: 4,
            confidence: 0.9,
            occurredAt: Date(timeIntervalSince1970: 220),
            geohash: "qqguxm",
            summary: "Hard braking detected.",
            source: .deterministic,
            window: []
        )
        let ride = makeRide(events: [event])
        let snapshot = RideSummaryService().deterministicSnapshot(for: ride)

        XCTAssertLessThan(snapshot.score, 100)
        XCTAssertEqual(snapshot.riskMoments.count, 1)
        XCTAssertEqual(snapshot.riskMoments.first?.type, .hardBrake)
        XCTAssertEqual(snapshot.riskMoments.first?.atSeconds, 120)
    }
}
