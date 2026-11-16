import Foundation

struct EventThresholds: Codable, Sendable {
    var hardBrakeDecelMps2: Double
    var hardBrakeMinDurationS: Double
    var impactG: Double
    var swerveLateralMps2: Double
    var longStopSpeedMps: Double
    var longStopDurationS: Double
    var crashSpeedDropRatio: Double
    var crashStillnessS: Double
    var sampleWindowSeconds: Double
    var maxEventsPerRide: Int

    static let `default` = EventThresholds(
        hardBrakeDecelMps2: 3.2,
        hardBrakeMinDurationS: 0.4,
        impactG: 2.5,
        swerveLateralMps2: 2.2,
        longStopSpeedMps: 1.0,
        longStopDurationS: 120,
        crashSpeedDropRatio: 0.7,
        crashStillnessS: 4.0,
        sampleWindowSeconds: 8,
        maxEventsPerRide: 40
    )

    static func decode(from jsonString: String?) -> EventThresholds {
        guard let jsonString,
              let data = jsonString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(EventThresholds.self, from: data) else {
            return .default
        }
        return decoded
    }
}
