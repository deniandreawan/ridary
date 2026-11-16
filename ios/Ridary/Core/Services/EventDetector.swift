import Foundation

struct DetectedEvent: Sendable {
    let type: RideEventType
    let severity: Int
    let confidence: Double
    let occurredAt: Date
    let summary: String
}

final class EventDetector {
    private let thresholds: EventThresholds
    private var previousSample: SensorSample?
    private var lastSpeedSample: (timestamp: Date, speed: Double)?
    private var lastHardBrakeAt: Date?
    private var lastImpactAt: Date?
    private var lastSwerveAt: Date?
    private var lastLongStopAt: Date?
    private var longStopStart: Date?
    private var pendingImpact: (at: Date, speedBefore: Double)?
    private var stillnessStart: Date?
    private var emittedCount = 0

    init(thresholds: EventThresholds = .default) {
        self.thresholds = thresholds
    }

    func process(_ sample: SensorSample) -> [DetectedEvent] {
        guard emittedCount < thresholds.maxEventsPerRide else {
            previousSample = sample
            return []
        }

        var events: [DetectedEvent] = []
        let previousSpeed = previousSample?.speedMps
        let currentSpeed = sample.speedMps

        if let event = detectHardBrake(sample: sample) {
            events.append(event)
        }

        if let event = detectImpact(sample: sample, previousSpeed: previousSpeed) {
            events.append(event)
        }

        if let event = detectCrashCandidate(
            sample: sample,
            previousSpeed: previousSpeed,
            currentSpeed: currentSpeed
        ) {
            events.append(event)
        }

        if let event = detectSwerve(sample: sample, currentSpeed: currentSpeed) {
            events.append(event)
        }

        if let event = detectLongStop(sample: sample, currentSpeed: currentSpeed) {
            events.append(event)
        }

        emittedCount += events.count
        previousSample = sample
        return events
    }

    private func detectHardBrake(sample: SensorSample) -> DetectedEvent? {
        guard let currentSpeed = sample.speedMps else {
            return nil
        }

        guard let previous = lastSpeedSample else {
            lastSpeedSample = (sample.timestamp, currentSpeed)
            return nil
        }

        let dt = sample.timestamp.timeIntervalSince(previous.timestamp)
        guard dt >= max(0.2, thresholds.hardBrakeMinDurationS * 0.5) else {
            return nil
        }

        let deceleration = (previous.speed - currentSpeed) / dt

        if abs(currentSpeed - previous.speed) > 0.1 || dt >= 1.0 {
            lastSpeedSample = (sample.timestamp, currentSpeed)
        }

        guard deceleration >= thresholds.hardBrakeDecelMps2,
              cooldownPassed(lastHardBrakeAt, now: sample.timestamp, seconds: 5) else {
            return nil
        }

        lastHardBrakeAt = sample.timestamp

        let severity: Int
        if deceleration >= 6.0 {
            severity = 5
        } else if deceleration >= 4.5 {
            severity = 4
        } else {
            severity = 3
        }

        return DetectedEvent(
            type: .hardBrake,
            severity: severity,
            confidence: 0.85,
            occurredAt: sample.timestamp,
            summary: String(
                format: "Hard braking detected (%.1f m/s² deceleration).",
                deceleration
            )
        )
    }

    private func detectImpact(
        sample: SensorSample,
        previousSpeed: Double?
    ) -> DetectedEvent? {
        guard sample.accelMagnitudeG >= thresholds.impactG,
              cooldownPassed(lastImpactAt, now: sample.timestamp, seconds: 10) else {
            return nil
        }

        lastImpactAt = sample.timestamp
        pendingImpact = (
            at: sample.timestamp,
            speedBefore: previousSpeed ?? sample.speedMps ?? 0
        )
        stillnessStart = nil

        return DetectedEvent(
            type: .impact,
            severity: 5,
            confidence: 0.9,
            occurredAt: sample.timestamp,
            summary: String(
                format: "Impact detected (%.1f g).",
                sample.accelMagnitudeG
            )
        )
    }

    private func detectCrashCandidate(
        sample: SensorSample,
        previousSpeed: Double?,
        currentSpeed: Double?
    ) -> DetectedEvent? {
        guard let pendingImpact else {
            return nil
        }

        if sample.timestamp.timeIntervalSince(pendingImpact.at) > 10 {
            self.pendingImpact = nil
            self.stillnessStart = nil
            return nil
        }

        let speed = currentSpeed ?? previousSpeed ?? pendingImpact.speedBefore
        let speedDrop = pendingImpact.speedBefore > 0
            ? (pendingImpact.speedBefore - speed) / pendingImpact.speedBefore
            : 0

        if speed < thresholds.longStopSpeedMps,
           speedDrop >= thresholds.crashSpeedDropRatio {
            if stillnessStart == nil {
                stillnessStart = sample.timestamp
            }
            if let stillnessStart,
               sample.timestamp.timeIntervalSince(stillnessStart) >= thresholds.crashStillnessS {
                self.pendingImpact = nil
                self.stillnessStart = nil
                return DetectedEvent(
                    type: .crashCandidate,
                    severity: 5,
                    confidence: 0.8,
                    occurredAt: sample.timestamp,
                    summary: "Impact followed by a sudden stop and stillness."
                )
            }
        } else {
            stillnessStart = nil
        }

        return nil
    }

    private func detectSwerve(
        sample: SensorSample,
        currentSpeed: Double?
    ) -> DetectedEvent? {
        guard let currentSpeed,
              currentSpeed > 5,
              sample.lateralAccelG >= thresholds.swerveLateralMps2 || sample.gyroMagnitude >= 1.8,
              cooldownPassed(lastSwerveAt, now: sample.timestamp, seconds: 5) else {
            return nil
        }

        lastSwerveAt = sample.timestamp
        return DetectedEvent(
            type: .sharpSwerve,
            severity: 3,
            confidence: 0.7,
            occurredAt: sample.timestamp,
            summary: "Sharp lateral movement detected."
        )
    }

    private func detectLongStop(
        sample: SensorSample,
        currentSpeed: Double?
    ) -> DetectedEvent? {
        guard let currentSpeed else {
            return nil
        }

        if currentSpeed >= thresholds.longStopSpeedMps {
            longStopStart = nil
            return nil
        }

        if longStopStart == nil {
            longStopStart = sample.timestamp
        }

        guard let longStopStart,
              sample.timestamp.timeIntervalSince(longStopStart) >= thresholds.longStopDurationS,
              cooldownPassed(lastLongStopAt, now: sample.timestamp, seconds: 300) else {
            return nil
        }

        lastLongStopAt = sample.timestamp
        self.longStopStart = nil
        return DetectedEvent(
            type: .longStop,
            severity: 1,
            confidence: 0.9,
            occurredAt: sample.timestamp,
            summary: "A long stationary period was recorded."
        )
    }

    private func cooldownPassed(
        _ last: Date?,
        now: Date,
        seconds: TimeInterval
    ) -> Bool {
        guard let last else { return true }
        return now.timeIntervalSince(last) >= seconds
    }
}
