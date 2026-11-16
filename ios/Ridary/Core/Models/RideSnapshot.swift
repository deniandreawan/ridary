import Foundation

struct RiskMoment: Codable, Identifiable, Sendable {
    var id: String {
        "\(atSeconds)-\(type.rawValue)-\(severity)"
    }

    let type: RideEventType
    let atSeconds: Int
    let severity: Int
    let explanation: String
}

struct RideSnapshot: Codable, Sendable {
    let headline: String
    let summary: String
    let riskMoments: [RiskMoment]
    let score: Int
    let scoreRationale: String
    let coachingTip: String
}
