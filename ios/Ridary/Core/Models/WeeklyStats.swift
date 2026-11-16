import Foundation

struct WeeklyRideStat: Codable, Identifiable, Sendable {
    let id: String
    let startedAtMs: Double
    let distanceM: Double
    let durationS: Double
    let score: Int
    let summary: String
    let inferenceSource: String
    let geohash: String

    var startedAt: Date {
        Date(timeIntervalSince1970: startedAtMs / 1000)
    }
}

struct WeeklyEventStat: Codable, Sendable {
    let rideId: String
    let type: RideEventType
    let severity: Int
    let confidence: Double
    let occurredAtMs: Double
    let summary: String
    let source: String

    var occurredAt: Date {
        Date(timeIntervalSince1970: occurredAtMs / 1000)
    }
}

struct WeeklyStatsResponse: Codable, Sendable {
    let mode: RideMode
    let periodStart: String
    let periodEnd: String
    let rides: [WeeklyRideStat]
    let events: [WeeklyEventStat]
}

struct WeeklyFeedback: Codable, Sendable {
    let headline: String
    let summary: String
    let insights: [String]
    let action: String
}
