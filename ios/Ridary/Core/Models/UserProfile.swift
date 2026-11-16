import Foundation

struct UserProfile: Codable, Identifiable, Sendable {
    var id: String { uid }

    let uid: String
    var displayName: String
    var mode: RideMode
    var consentShareDerived: Bool
    var consentShareRoute: Bool
    let createdAt: Date
    var updatedAt: Date
    var schemaVersion: Int
}
