import Foundation

struct AskRidaryTurn: Equatable, Sendable {
    enum Role: String, Sendable {
        case user
        case assistant
    }

    let role: Role
    let text: String
}

struct AskRidaryMessage: Identifiable, Sendable {
    let id: UUID
    let role: AskRidaryTurn.Role
    let text: String
    let source: InferenceSource?

    init(
        id: UUID = UUID(),
        role: AskRidaryTurn.Role,
        text: String,
        source: InferenceSource? = nil
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.source = source
    }
}

struct AskRidaryReply: Sendable {
    let text: String
    let source: InferenceSource
}

struct AskRidaryContext: Codable, Equatable, Sendable {
    struct Weekly: Codable, Equatable, Sendable {
        let rides: Int
        let distanceM: Double
        let avgScore: Int?
        let onDevice: Int
        let topEvent: String?
    }

    struct ModeSummary: Codable, Equatable, Sendable {
        let mode: String
        let rides: Int
        let distanceM: Double
    }

    struct AllTime: Codable, Equatable, Sendable {
        let rides: Int
        let distanceM: Double
        let avgScore: Int?
        let proofs: Int
        let modes: [ModeSummary]
    }

    struct EventSummary: Codable, Equatable, Sendable {
        let type: String
        let severity: Int
        let atSeconds: Int
        let summary: String
    }

    struct RideSummary: Codable, Equatable, Sendable {
        let when: Date
        let mode: String
        let distanceM: Double
        let durationS: Double
        let avgSpeedKph: Double
        let maxSpeedKph: Double
        let score: Int
        let band: String
        let headline: String
        let summary: String
        let coachingTip: String
        let rationale: String
        let events: [EventSummary]
    }

    struct IncidentSummary: Codable, Equatable, Sendable {
        let when: Date
        let type: String
        let severity: Int
        let status: String
    }

    struct CredentialSummary: Codable, Equatable, Sendable {
        let band: String
        let score: Int
        let rides: Int
        let events: Int
        let period: String
        let expiresAt: String
        let issuer: String
    }

    struct WeeklyNote: Codable, Equatable, Sendable {
        let headline: String
        let action: String
    }

    let generatedAt: Date
    let weekly: Weekly
    let allTime: AllTime
    let recentRides: [RideSummary]
    let recentIncidents: [IncidentSummary]
    let credential: CredentialSummary?
    let weeklyNote: WeeklyNote?
}
