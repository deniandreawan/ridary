import SwiftUI

struct RootView: View {
    @EnvironmentObject private var app: AppEnvironment

    var body: some View {
        Group {
            if !app.isReady {
                SplashView()
            } else if app.userID == nil {
                AuthView()
            } else {
                MainView()
            }
        }
        .ridaryScreenBackground()
        .alert(
            "Ridary",
            isPresented: Binding(
                get: { app.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        app.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(app.errorMessage ?? "")
        }
    }
}

private struct SplashView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(RidaryTheme.accent)
            Text("RIDARY")
                .font(.system(.title2, design: .rounded, weight: .black))
                .tracking(4)
            Text("Every ride, on record.")
                .font(.footnote)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
    }
}
