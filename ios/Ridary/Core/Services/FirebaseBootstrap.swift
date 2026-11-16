import FirebaseAppCheck
import FirebaseCore
import Foundation

struct FirebaseStatus: Sendable {
    let isConfigured: Bool
    let detail: String
}

enum FirebaseBootstrap {
    static func configure() -> FirebaseStatus {
        if FirebaseApp.app() != nil {
            return FirebaseStatus(
                isConfigured: true,
                detail: "Firebase is configured."
            )
        }

        guard let path = Bundle.main.path(
            forResource: "GoogleService-Info",
            ofType: "plist"
        ) else {
            return FirebaseStatus(
                isConfigured: false,
                detail: "GoogleService-Info.plist is missing. Local demo mode is active."
            )
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            return FirebaseStatus(
                isConfigured: false,
                detail: "GoogleService-Info.plist could not be read. Local demo mode is active."
            )
        }

        guard let apiKey = options.apiKey,
              apiKey != "REPLACE_ME",
              options.googleAppID != "REPLACE_ME" else {
            return FirebaseStatus(
                isConfigured: false,
                detail: "Add your real Firebase configuration to enable cloud features."
            )
        }

        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        FirebaseApp.configure(options: options)
        return FirebaseStatus(
            isConfigured: true,
            detail: "Firebase is configured."
        )
    }
}
