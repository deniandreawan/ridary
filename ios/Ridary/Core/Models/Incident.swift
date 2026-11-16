import Foundation

enum IncidentStatus: String, Codable, Equatable, Sendable {
    case locked
    case draft
    case shared
    case archived

    var title: String {
        switch self {
        case .locked: return "Locked"
        case .draft: return "Draft"
        case .shared: return "Shared"
        case .archived: return "Archived"
        }
    }
}

struct IncidentQuestion: Codable, Identifiable, Sendable {
    let id: String
    let prompt: String
    let kind: String
    let choices: [String]?
}

struct IncidentTimelineItem: Codable, Identifiable, Sendable {
    var id: String {
        "\(atSeconds)-\(text)"
    }

    let atSeconds: Int
    let text: String
}

struct IncidentStatement: Codable, Sendable {
    let title: String
    let timeline: [IncidentTimelineItem]
    let statement: String
    let evidenceChecklist: [String]
}

struct Incident: Codable, Identifiable, Sendable {
    let id: UUID
    let rideID: UUID
    let eventID: UUID
    let mode: RideMode
    let eventType: RideEventType
    let severity: Int
    let eventSummary: String
    let lockedAt: Date
    var hash: String
    var summary: String
    var status: IncidentStatus
    var questions: [IncidentQuestion]
    var answers: [String: String]
    var statement: IncidentStatement?
    var statementSource: InferenceSource?
    let createdAt: Date
    var schemaVersion: Int
}
