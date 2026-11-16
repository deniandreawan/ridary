import CryptoKit
import Foundation

struct EvidenceVault {
    static func makePacket(
        incidentID: UUID,
        rideID: UUID,
        mode: RideMode,
        event: RideEvent,
        answers: [String: String],
        statement: IncidentStatement?,
        lockedAt: Date = Date()
    ) -> EvidencePacket {
        EvidencePacket(
            version: 1,
            incidentID: incidentID,
            rideID: rideID,
            eventID: event.id,
            eventSummary: event.summary,
            mode: mode,
            lockedAt: lockedAt,
            eventType: event.type,
            severity: event.severity,
            confidence: event.confidence,
            occurredAt: event.occurredAt,
            geohash: event.geohash,
            windowStart: event.windowStart,
            windowEnd: event.windowEnd,
            sampleCount: event.window.count,
            samples: event.window,
            answers: answers,
            statement: statement,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                ?? "1.0"
        )
    }

    static func encode(_ packet: EvidencePacket) throws -> Data {
        try RidaryJSON.data(packet)
    }

    static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func hash(_ packet: EvidencePacket) throws -> String {
        hash(try encode(packet))
    }
}
