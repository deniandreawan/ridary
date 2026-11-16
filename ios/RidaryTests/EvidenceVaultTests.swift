import XCTest
@testable import Ridary

final class EvidenceVaultTests: XCTestCase {
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
            routePreview: [],
            events: [],
            snapshot: nil,
            createdAt: Date(timeIntervalSince1970: 200),
            schemaVersion: 1
        )
    }

    private func makeEvent(rideID: UUID) -> RideEvent {
        RideEvent(
            id: UUID(),
            rideID: rideID,
            type: .hardBrake,
            severity: 3,
            confidence: 0.85,
            occurredAt: Date(timeIntervalSince1970: 150),
            geohash: "qqguxm",
            summary: "Hard braking detected.",
            source: .deterministic,
            window: []
        )
    }

    func testHashIsStableForSamePacket() throws {
        let ride = makeRide()
        let event = makeEvent(rideID: ride.id)
        let packet = EvidenceVault.makePacket(
            incidentID: UUID(),
            rideID: ride.id,
            mode: ride.mode,
            event: event,
            answers: [:],
            statement: nil
        )

        let first = try EvidenceVault.hash(packet)
        let second = try EvidenceVault.hash(packet)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.count, 64)
        XCTAssertTrue(first.allSatisfy { $0.isHexDigit })
    }

    func testHashChangesWhenAnswersChange() throws {
        let ride = makeRide()
        let event = makeEvent(rideID: ride.id)
        let incidentID = UUID()
        let first = EvidenceVault.makePacket(
            incidentID: incidentID,
            rideID: ride.id,
            mode: ride.mode,
            event: event,
            answers: [:],
            statement: nil
        )
        let second = EvidenceVault.makePacket(
            incidentID: incidentID,
            rideID: ride.id,
            mode: ride.mode,
            event: event,
            answers: ["action": "I braked"],
            statement: nil
        )

        XCTAssertNotEqual(try EvidenceVault.hash(first), try EvidenceVault.hash(second))
    }
}
