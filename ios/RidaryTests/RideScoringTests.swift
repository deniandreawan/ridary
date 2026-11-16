import XCTest
@testable import Ridary

final class RideScoringTests: XCTestCase {
    private func event(
        type: RideEventType,
        severity: Int,
        confidence: Double
    ) -> RideEvent {
        RideEvent(
            id: UUID(),
            rideID: UUID(),
            type: type,
            severity: severity,
            confidence: confidence,
            occurredAt: Date(),
            geohash: "qqguxm",
            summary: "test",
            source: .deterministic,
            window: []
        )
    }

    func testCleanRideScores100() {
        XCTAssertEqual(RideScoring.rideScore(events: []), 100)
    }

    func testHardBrakeReducesScore() {
        let score = RideScoring.rideScore(
            events: [event(type: .hardBrake, severity: 3, confidence: 0.85)]
        )
        XCTAssertLessThan(score, 100)
        XCTAssertGreaterThan(score, 80)
    }

    func testCrashCandidateReducesScoreMore() {
        let brake = RideScoring.rideScore(
            events: [event(type: .hardBrake, severity: 3, confidence: 0.85)]
        )
        let crash = RideScoring.rideScore(
            events: [event(type: .crashCandidate, severity: 5, confidence: 0.8)]
        )
        XCTAssertLessThan(crash, brake)
    }

    func testBands() {
        XCTAssertEqual(RideScoring.band(for: 95), "A")
        XCTAssertEqual(RideScoring.band(for: 80), "B")
        XCTAssertEqual(RideScoring.band(for: 65), "C")
        XCTAssertEqual(RideScoring.band(for: 20), "D")
    }
}
