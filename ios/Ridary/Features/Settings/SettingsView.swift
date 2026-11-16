import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings

    @State private var showSignOut = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                riderCard
                privacyCard
                aiCard
                firebaseCard
                aboutCard
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Sign out of Ridary?",
            isPresented: $showSignOut,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                app.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Local ride files stay on this device. Cloud credentials stay in your account.")
        }
    }

    private var riderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            RidarySectionHeader(title: "Rider", subtitle: "Used for local labels and ride profiles.")
            TextField("Your name", text: $settings.displayName)
                .textInputAutocapitalization(.words)
                .padding(14)
                .background(RidaryTheme.backgroundLifted)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Picker("Default mode", selection: $settings.mode) {
                ForEach(RideMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .tint(RidaryTheme.accent)
        }
        .ridaryCard()
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            RidarySectionHeader(
                title: "Privacy",
                subtitle: "Raw routes and sensor windows stay on this device."
            )

            Toggle(isOn: $settings.shareDerived) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Share anonymized safety points")
                        .font(.subheadline.weight(.semibold))
                    Text("Sends event type, severity, confidence, and a coarse geohash. No route, no account identity.")
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
            .tint(RidaryTheme.teal)

            Toggle(isOn: $settings.shareRoute) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Share a simplified route with the dashboard")
                        .font(.subheadline.weight(.semibold))
                    Text("Only when the first toggle is on. The web dashboard can then draw your ride preview.")
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
            .tint(RidaryTheme.accent)

            Text("Evidence files, raw samples, and incident notes never leave this iPhone unless you export them.")
                .font(.caption2)
                .foregroundStyle(RidaryTheme.textTertiary)
        }
        .ridaryCard()
    }

    private var aiCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            RidarySectionHeader(title: "Hybrid AI", subtitle: "Private at the edge, collective in the cloud.")
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: app.onDeviceAvailability.isAvailable ? "iphone.gen3" : "cloud")
                    .foregroundStyle(
                        app.onDeviceAvailability.isAvailable
                            ? RidaryTheme.teal
                            : RidaryTheme.accent
                    )
                VStack(alignment: .leading, spacing: 3) {
                    Text(app.onDeviceAvailability.title)
                        .font(.subheadline.weight(.semibold))
                    Text(app.onDeviceAvailability.detail)
                        .font(.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
            }
            Text("Cloud model: \(app.remoteConfig.cloudModelName)")
                .font(.caption2.monospaced())
                .foregroundStyle(RidaryTheme.textTertiary)
            if let message = app.remoteConfig.errorMessage {
                Text("Remote Config: \(message)")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.warning)
            }
        }
        .ridaryCard()
    }

    private var firebaseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            RidarySectionHeader(
                title: "Firebase",
                subtitle: app.isFirebaseConfigured ? "Cloud services are connected." : "Local demo mode."
            )
            Text(app.firebaseStatus.detail)
                .font(.caption)
                .foregroundStyle(RidaryTheme.textSecondary)

            if app.isFirebaseConfigured {
                if let userID = app.userID {
                    Text("User \(userID.prefix(12))…")
                        .font(.caption2.monospaced())
                        .foregroundStyle(RidaryTheme.textTertiary)
                }
                Button("Sign out") {
                    showSignOut = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(RidaryTheme.danger)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("To enable cloud features:")
                        .font(.caption.weight(.semibold))
                    Text("1. Create a Firebase project and add an iOS app with bundle id app.ridary.ios.")
                    Text("2. Download GoogleService-Info.plist into ios/Config/.")
                    Text("3. Run xcodegen generate in ios/ and rebuild.")
                    Text("4. Enable AI Logic and App Check (debug token) in the Firebase console.")
                }
                .font(.caption)
                .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .ridaryCard()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            RidarySectionHeader(title: "About")
            Text("Ridary \(appVersion)")
                .font(.footnote)
            Text("Apache-2.0 · personal ride record, not legal or medical advice.")
                .font(.caption)
                .foregroundStyle(RidaryTheme.textSecondary)
            Text("On-device AI runs only while the app is in the foreground. Background capture records sensors only.")
                .font(.caption2)
                .foregroundStyle(RidaryTheme.textTertiary)
        }
        .ridaryCard()
    }
}
