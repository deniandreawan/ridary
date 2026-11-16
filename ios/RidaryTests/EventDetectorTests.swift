import XCTest
@testable import Ridary

final class EventDetectorTests: XCTestCase {
    private func sample(
        at seconds: TimeInterval,
        speed: Double,
        accelG: Double = 0,
        gyro: Double = 0
    ) -> SensorSample {
        SensorSample(
            timestamp: Date(timeIntervalSince1970: seconds),
            latitude: -6.2088,
            longitude: 106.8456,
            altitude: 10,
            speedMps: speed,
            horizontalAccuracy: 5,
            accelX: accelG,
            accelY: 0,
            accelZ: 0,
            gyroX: 0,
            gyroY: 0,
            gyroZ: gyro
        )
    }

    func testHardBrakeTriggersOnRealSpeedDrop() {
        let detector = EventDetector()
        var emitted: [DetectedEvent] = []

        let samples = [
            sample(at: 0.0, speed: 10),
            sample(at: 1.0, speed: 6),
            sample(at: 2.0, speed: 4)
        ]

        for sample in samples {
            emitted.append(contentsOf: detector.process(sample))
        }

        XCTAssertEqual(emitted.filter { $0.type == .hardBrake }.count, 1)
        XCTAssertEqual(emitted.first?.type, .hardBrake)
    }

    func testHardBrakeWithRepeatedSpeedSamples() {
        let detector = EventDetector()
        var emitted: [DetectedEvent] = []

        for index in 0...9 {
            emitted.append(
                contentsOf: detector.process(
                    sample(at: TimeInterval(index) * 0.1, speed: 10)
                )
            )
        }
        emitted.append(contentsOf: detector.process(sample(at: 1.0, speed: 5)))

        XCTAssertTrue(emitted.contains { $0.type == .hardBrake })
    }

    func testImpactTriggersAtThreshold() {
        let detector = EventDetector()
        let event = detector.process(sample(at: 1, speed: 8, accelG: 3.0))

        XCTAssertTrue(event.contains { $0.type == .impact })
        XCTAssertEqual(event.first?.severity, 5)
    }

    func testLongStop() {
        let detector = EventDetector()
        var emitted: [DetectedEvent] = []

        for second in 0...122 {
            emitted.append(
                contentsOf: detector.process(
                    sample(at: TimeInterval(second), speed: 0)
                )
            )
        }

        XCTAssertTrue(emitted.contains { $0.type == .longStop })
    }

    func testNoEventForSmoothRide() {
        let detector = EventDetector()
        var emitted: [DetectedEvent] = []

        for index in 0...20 {
            emitted.append(
                contentsOf: detector.process(
                    sample(at: TimeInterval(index) * 0.1, speed: 8)
                )
            )
        }

        XCTAssertTrue(emitted.isEmpty)
    }
}
