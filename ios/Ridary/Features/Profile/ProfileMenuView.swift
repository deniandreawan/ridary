import SwiftUI

struct ProfileMenuView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showCredential = false
    @State private var showStatistics = false
    @State private var showIncidents = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            List {
                profileHeader

                Section {
                    profileAction(
                        icon: "chart.bar.fill",
                        title: "Statistics"
                    ) {
                        showStatistics = true
                    }

                    profileAction(
                        icon: "lock.shield.fill",
                        title: "Incidents"
                    ) {
                        showIncidents = true
                    }

                    profileAction(
                        icon: "checkmark.seal.fill",
                        title: "Ridary Proof"
                    ) {
                        showCredential = true
                    }

                    profileAction(
                        icon: "slider.horizontal.3",
                        title: "Settings"
                    ) {
                        showSettings = true
                    }
                } footer: {
                    privacyFooter
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(14)
            .contentMargins(.top, 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .background(RidaryTheme.background)
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topTrailing) {
                closeButton
            }
        }
        .tint(RidaryTheme.accent)
        .fullScreenCover(isPresented: $showCredential) {
            NavigationStack {
                CredentialView(isModal: true)
            }
        }
        .fullScreenCover(isPresented: $showStatistics) {
            NavigationStack {
                StatisticsView()
            }
        }
        .fullScreenCover(isPresented: $showIncidents) {
            NavigationStack {
                IncidentsView()
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .presentationDetents([.fraction(0.68), .large])
        .presentationDragIndicator(.hidden)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RidaryTheme.textPrimary)
                .frame(width: 34, height: 34)
                .background(RidaryTheme.backgroundLifted)
                .clipShape(Circle())
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close profile")
        .padding(.top, 10)
        .padding(.trailing, 12)
    }

    private var profileHeader: some View {
        VStack(spacing: 7) {
            Text(settings.profileInitials)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 76, height: 76)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            Text(settings.displayName)
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(app.isLocalDemo ? "Local demo" : "Ridary account")
                .font(.system(size: 13, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 8, trailing: 20))
    }

    private func profileAction(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                rowLabel(icon: icon, title: title)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(RidaryTheme.surface)
    }

    private func rowLabel(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 32, height: 32)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            Text(title)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)
        }
        .padding(.vertical, 3)
    }

    private var privacyFooter: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(
                app.onDeviceAvailability.title,
                systemImage: app.onDeviceAvailability.isAvailable ? "iphone.gen3" : "cloud"
            )
            .font(.system(size: 11, weight: .medium, design: .default))
            .foregroundStyle(RidaryTheme.textSecondary)

            Text("Routes and sensor windows stay on this iPhone. Only derived points sync.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
    }
}

extension AppSettings {
    var profileInitials: String {
        let words = displayName
            .split(whereSeparator: { $0.isWhitespace })
            .prefix(2)
        let letters = words.compactMap(\.first).map(String.init).joined()
        return letters.isEmpty ? "R" : letters.uppercased()
    }
}
