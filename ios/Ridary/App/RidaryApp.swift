import SwiftUI

@main
struct RidaryApp: App {
    @StateObject private var app = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .environmentObject(app.settings)
                .environmentObject(app.capture)
                .task {
                    await app.bootstrap()
                }
                .preferredColorScheme(.dark)
        }
    }
}
