import FirebaseFunctions
import Foundation

enum BackendError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unreadable response."
        }
    }
}

final class BackendFunctions {
    private let functions: Functions

    init(region: String = "us-central1") {
        self.functions = Functions.functions(region: region)
    }

    func issueCredential(mode: RideMode, days: Int) async throws -> Credential {
        let result = try await functions
            .httpsCallable("issueCredential")
            .call(["mode": mode.rawValue, "days": days])
        return try decode(result.data, as: Credential.self)
    }

    func createInsurerView(credentialID: String) async throws -> InsurerView {
        let result = try await functions
            .httpsCallable("createInsurerView")
            .call(["credentialId": credentialID])
        return try decode(result.data, as: InsurerView.self)
    }

    func verifyCredential(credentialID: String) async throws -> CredentialVerification {
        let result = try await functions
            .httpsCallable("verifyCredential")
            .call(["credentialId": credentialID])
        return try decode(result.data, as: CredentialVerification.self)
    }

    func weeklyStats(mode: RideMode, days: Int = 7) async throws -> WeeklyStatsResponse {
        let result = try await functions
            .httpsCallable("getWeeklyStats")
            .call(["mode": mode.rawValue, "days": days])
        return try decode(result.data, as: WeeklyStatsResponse.self)
    }

    private func decode<T: Decodable>(_ data: Any?, as type: T.Type) throws -> T {
        guard let data else {
            throw BackendError.invalidResponse
        }
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            return try RidaryJSON.decode(type, from: json)
        } catch {
            throw BackendError.invalidResponse
        }
    }
}
