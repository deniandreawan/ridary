import Combine
import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var mode: RideMode {
        didSet { save() }
    }

    @Published var shareDerived: Bool {
        didSet { save() }
    }

    @Published var shareRoute: Bool {
        didSet { save() }
    }

    @Published var displayName: String {
        didSet { save() }
    }

    private let defaults: UserDefaults

    private enum Key {
        static let mode = "ridary.mode"
        static let shareDerived = "ridary.shareDerived"
        static let shareRoute = "ridary.shareRoute"
        static let displayName = "ridary.displayName"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.mode = RideMode(rawValue: defaults.string(forKey: Key.mode) ?? "")
            ?? .motorcycle
        self.shareDerived = defaults.bool(forKey: Key.shareDerived)
        self.shareRoute = defaults.bool(forKey: Key.shareRoute)
        let storedName = defaults.string(forKey: Key.displayName)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = (storedName?.isEmpty == false ? storedName : nil) ?? "Rider"
    }

    func save() {
        defaults.set(mode.rawValue, forKey: Key.mode)
        defaults.set(shareDerived, forKey: Key.shareDerived)
        defaults.set(shareRoute, forKey: Key.shareRoute)
        defaults.set(displayName, forKey: Key.displayName)
    }
}
