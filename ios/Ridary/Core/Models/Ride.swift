import Foundation

struct Ride: Codable, Identifiable, Sendable {
    let id: UUID
    var mode: RideMode
    let startedAt: Date
    var endedAt: Date
    var distanceM: Double
    var durationS: Double
    var avgSpeedKph: Double
    var maxSpeedKph: Double
    var score: Int
    var summary: String
    var inferenceSource: InferenceSource
    var geohash: String
    var routePreview: [[Double]]
    var events: [RideEvent]
    var snapshot: RideSnapshot?
    let createdAt: Date
    var schemaVersion: Int

    var durationText: String {
        let seconds = max(0, Int(durationS))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var distanceText: String {
        if distanceM >= 1000 {
            return String(format: "%.1f km", distanceM / 1000)
        }
        return String(format: "%.0f m", distanceM)
    }
}
