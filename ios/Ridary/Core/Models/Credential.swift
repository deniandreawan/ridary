import Foundation

struct Credential: Codable, Identifiable, Sendable {
    let credentialId: String
    let uid: String
    let periodStart: String
    let periodEnd: String
    let mode: RideMode
    let score: Int
    let rideCount: Int
    let eventCount: Int
    let issuedAt: String
    let expiresAt: String
    let issuer: String
    let publicKeyId: String
    let payloadHash: String
    let signature: String

    var id: String { credentialId }

    var band: String {
        if score >= 90 { return "A" }
        if score >= 75 { return "B" }
        if score >= 60 { return "C" }
        return "D"
    }

    var periodText: String {
        guard let start = CredentialDateParser.date(from: periodStart),
              let end = CredentialDateParser.date(from: periodEnd) else {
            return periodStart
        }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return "\(display.string(from: start)) – \(display.string(from: end))"
    }
}

enum CredentialDateParser {
    private static let fractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let standard = ISO8601DateFormatter()

    static func date(from raw: String) -> Date? {
        fractional.date(from: raw) ?? standard.date(from: raw)
    }
}

struct InsurerView: Codable, Identifiable, Sendable {
    let token: String
    let url: String

    var id: String { token }
}

struct CredentialVerification: Codable, Sendable {
    let valid: Bool
    let credential: Credential?
    let reason: String?
}
