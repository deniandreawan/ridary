import SwiftUI
import UIKit

@main
struct RidaryApp: App {
    @StateObject private var app = AppEnvironment()

    init() {
        UIScrollView.appearance().bounces = false
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .environmentObject(app.settings)
                .environmentObject(app.capture)
                .task {
                    await app.bootstrap()
                }
                .preferredColorScheme(.light)
        }
    }
}
