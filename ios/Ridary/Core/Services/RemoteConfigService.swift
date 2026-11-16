import Combine
import FirebaseRemoteConfig
import Foundation

@MainActor
final class RemoteConfigService: ObservableObject {
    @Published private(set) var thresholds: EventThresholds = .default
    @Published private(set) var cloudModelName = "gemini-3.5-flash-lite"
    @Published private(set) var errorMessage: String?

    private let isConfigured: Bool
    private enum Key {
        static let thresholds = "event_thresholds_json"
        static let cloudModel = "cloud_model_name"
    }

    init(isConfigured: Bool) {
        self.isConfigured = isConfigured
    }

    func fetch() async {
        guard isConfigured else {
            return
        }

        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Key.thresholds: "" as NSObject,
            Key.cloudModel: "gemini-3.5-flash-lite" as NSObject
        ])

        do {
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        thresholds = EventThresholds.decode(
            from: remoteConfig.configValue(forKey: Key.thresholds).stringValue
        )
        let modelName = remoteConfig.configValue(forKey: Key.cloudModel).stringValue
        if !modelName.isEmpty {
            cloudModelName = modelName
        }
        errorMessage = nil
    }
}
