import Foundation

struct EvidencePacket: Codable, Sendable {
    let version: Int
    let incidentID: UUID
    let rideID: UUID
    let eventID: UUID
    let eventSummary: String
    let mode: RideMode
    let lockedAt: Date
    let eventType: RideEventType
    let severity: Int
    let confidence: Double
    let occurredAt: Date
    let geohash: String
    let windowStart: Date?
    let windowEnd: Date?
    let sampleCount: Int
    let samples: [SensorSample]
    let answers: [String: String]
    let statement: IncidentStatement?
    let appVersion: String
}


extension EvidencePacket {
    func asRideEvent() -> RideEvent {
        RideEvent(
            id: eventID,
            rideID: rideID,
            type: eventType,
            severity: severity,
            confidence: confidence,
            occurredAt: occurredAt,
            geohash: geohash,
            summary: eventSummary,
            source: .deterministic,
            window: samples
        )
    }
}
