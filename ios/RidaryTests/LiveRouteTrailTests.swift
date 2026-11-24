import XCTest
@testable import Ridary

final class LiveRouteTrailTests: XCTestCase {
    func testSpacingFiltersTinyMovements() {
        var trail = LiveRouteTrail()
        trail.minimumSpacingMeters = 10

        XCTAssertTrue(trail.append(latitude: 37.7749, longitude: -122.4194))
        XCTAssertFalse(trail.append(latitude: 37.774905, longitude: -122.4194))
        XCTAssertTrue(trail.append(latitude: 37.7751, longitude: -122.4194))
        XCTAssertEqual(trail.totalPointCount, 2)
    }

    func testCapKeepsNewestPoints() {
        var trail = LiveRouteTrail()
        trail.minimumSpacingMeters = 1
        trail.maximumPoints = 5

        for index in 0..<10 {
            trail.append(latitude: 37.7749 + Double(index) * 0.0001, longitude: -122.4194)
        }

        XCTAssertEqual(trail.totalPointCount, 5)
        XCTAssertEqual(trail.segments.count, 1)
        XCTAssertEqual(trail.segments[0].last?[0] ?? 0, 37.7749 + 9 * 0.0001, accuracy: 0.0000001)
    }

    func testBreakStartsNewSegment() {
        var trail = LiveRouteTrail()
        trail.minimumSpacingMeters = 1

        trail.append(latitude: 37.7749, longitude: -122.4194)
        trail.append(latitude: 37.7750, longitude: -122.4194)
        trail.breakSegment()
        trail.append(latitude: 37.7755, longitude: -122.4194)

        XCTAssertEqual(trail.segments.count, 2)
        XCTAssertEqual(trail.segments[0].count, 2)
        XCTAssertEqual(trail.segments[1].count, 1)
    }

    func testResetClearsTrail() {
        var trail = LiveRouteTrail()
        trail.append(latitude: 37.7749, longitude: -122.4194)
        let revisionBefore = trail.revision

        trail.reset()

        XCTAssertTrue(trail.segments.isEmpty)
        XCTAssertNil(trail.lastCoordinate)
        XCTAssertEqual(trail.revision, revisionBefore + 1)
    }
}
