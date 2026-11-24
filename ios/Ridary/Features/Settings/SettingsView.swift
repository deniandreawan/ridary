import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var showSignOut = false
    @State private var scrollOffset: CGFloat = 0

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var isTopBarSolid: Bool {
        scrollOffset > 120
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    heroCard

                    VStack(spacing: 0) {
                        controlsSection
                            .padding(.horizontal, 24)
                            .padding(.top, 26)
                            .padding(.bottom, 22)

                        if app.isFirebaseConfigured {
                            sectionDivider

                            signOutRow
                                .padding(.horizontal, 24)
                                .padding(.vertical, 18)
                        }

                        sectionDivider

                        Text("Version \(appVersion)")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(RidaryTheme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(RidaryTheme.surface)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 26,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 26
                        )
                    )
                    .padding(.top, -26)
                }
                .accessibilityIdentifier("settings-screen")
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }

            topBar
        }
        .background(RidaryTheme.surface.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Close settings")

                Spacer()

                if isTopBarSolid {
                    Text("Settings")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .transition(.opacity)

                    Spacer()

                    Color.clear
                        .frame(width: 42, height: 28)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)

            if isTopBarSolid {
                Rectangle()
                    .fill(RidaryTheme.border.opacity(0.65))
                    .frame(height: 1)
            }
        }
        .background(
            RidaryTheme.surface
                .opacity(isTopBarSolid ? 1 : 0)
                .ignoresSafeArea(edges: .top)
        )
        .animation(.easeOut(duration: 0.18), value: isTopBarSolid)
    }

    private var heroCard: some View {
        VStack(spacing: 14) {
            Text(app.isLocalDemo ? "Local demo" : "Ridary account")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(RidaryTheme.skyDeep)

            ZStack {
                Circle()
                    .fill(RidaryTheme.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: RidaryTheme.sky.opacity(0.14), radius: 12, x: 0, y: 4)

                Text(settings.profileInitials)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(RidaryTheme.sky)
            }
            .padding(.vertical, 2)

            VStack(spacing: 4) {
                Text(settings.displayName.isEmpty ? "Rider" : settings.displayName)
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .tracking(-0.6)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text(app.onDeviceAvailability.title)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .padding(.top, 88)
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    RidaryTheme.skySoft,
                    RidaryTheme.skySoft.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var controlsSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                Text("Name")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer(minLength: 12)

                TextField("Rider", text: $settings.displayName)
                    .textInputAutocapitalization(.words)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 180)
            }

            Divider().overlay(RidaryTheme.border.opacity(0.65))

            HStack(spacing: 14) {
                Image(systemName: settings.mode.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                Text("Default mode")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer(minLength: 12)

                Menu {
                    ForEach(RideMode.allCases) { mode in
                        Button {
                            settings.mode = mode
                        } label: {
                            Label(mode.title, systemImage: mode.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(settings.mode.title)
                            .font(.system(size: 15, weight: .regular, design: .default))

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(RidaryTheme.textSecondary)
                }
                .accessibilityLabel("Default mode")
            }

            Divider().overlay(RidaryTheme.border.opacity(0.65))

            HStack(spacing: 14) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                Text("Share safety points")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer(minLength: 12)

                Toggle("Share safety points", isOn: $settings.shareDerived)
                    .labelsHidden()
                    .tint(RidaryTheme.sky)
            }

            Divider().overlay(RidaryTheme.border.opacity(0.65))

            HStack(spacing: 14) {
                Image(systemName: "map.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                Text("Share route preview")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer(minLength: 12)

                Toggle("Share route preview", isOn: $settings.shareRoute)
                    .labelsHidden()
                    .tint(RidaryTheme.sky)
            }
        }
    }

    private var signOutRow: some View {
        Button {
            showSignOut = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RidaryTheme.danger)
                    .frame(width: 34, height: 34)
                    .background(RidaryTheme.danger.opacity(0.1))
                    .clipShape(Circle())

                Text("Sign out")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.danger)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }
}
