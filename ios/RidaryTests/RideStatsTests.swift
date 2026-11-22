import XCTest
@testable import Ridary

final class RideStatsTests: XCTestCase {
    func testDistanceAndPreview() {
        let start = Date(timeIntervalSince1970: 100)
        let samples = [
            SensorSample(
                timestamp: start,
                latitude: 0,
                longitude: 0,
                altitude: 0,
                speedMps: 10,
                horizontalAccuracy: 5,
                accelX: 0,
                accelY: 0,
                accelZ: 0,
                gyroX: 0,
                gyroY: 0,
                gyroZ: 0
            ),
            SensorSample(
                timestamp: start.addingTimeInterval(10),
                latitude: 0,
                longitude: 0.001,
                altitude: 0,
                speedMps: 12,
                horizontalAccuracy: 5,
                accelX: 0,
                accelY: 0,
                accelZ: 0,
                gyroX: 0,
                gyroY: 0,
                gyroZ: 0
            )
        ]

        let stats = RideStatsCalculator.compute(
            samples: samples,
            startedAt: start,
            endedAt: start.addingTimeInterval(10),
            mode: .motorcycle
        )

        XCTAssertGreaterThan(stats.distanceM, 100)
        XCTAssertLessThan(stats.distanceM, 120)
        XCTAssertEqual(stats.avgSpeedKph, (stats.distanceM / 10) * 3.6, accuracy: 0.01)
        XCTAssertEqual(stats.maxSpeedKph, 43.2, accuracy: 0.01)
        XCTAssertEqual(stats.routePreview.count, 2)
        XCTAssertEqual(stats.geohash, "s00000")
    }


    func testPausedDurationIsExcluded() {
        let start = Date(timeIntervalSince1970: 0)
        let stats = RideStatsCalculator.compute(
            samples: [],
            startedAt: start,
            endedAt: start.addingTimeInterval(120),
            mode: .car,
            pausedDurationS: 30
        )

        XCTAssertEqual(stats.durationS, 90, accuracy: 0.01)
    }

    func testEmptySamples() {
        let start = Date(timeIntervalSince1970: 0)
        let stats = RideStatsCalculator.compute(
            samples: [],
            startedAt: start,
            endedAt: start.addingTimeInterval(60),
            mode: .bicycle
        )

        XCTAssertEqual(stats.distanceM, 0)
        XCTAssertEqual(stats.maxSpeedKph, 0)
        XCTAssertTrue(stats.routePreview.isEmpty)
        XCTAssertEqual(stats.geohash, "s00000")
    }
}
