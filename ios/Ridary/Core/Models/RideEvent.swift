import Foundation

struct RideEvent: Codable, Identifiable, Sendable {
    let id: UUID
    let rideID: UUID
    let type: RideEventType
    let severity: Int
    let confidence: Double
    let occurredAt: Date
    let geohash: String
    var summary: String
    var source: InferenceSource
    var window: [SensorSample]

    var windowStart: Date? {
        window.first?.timestamp
    }

    var windowEnd: Date? {
        window.last?.timestamp
    }
}
