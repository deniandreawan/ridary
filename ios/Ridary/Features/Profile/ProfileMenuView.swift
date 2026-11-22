import SwiftUI

struct ProfileMenuView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                profileHeader

                Section {
                    profileLink(
                        icon: "chart.bar.fill",
                        title: "Statistics"
                    ) {
                        StatisticsView()
                    }

                    profileLink(
                        icon: "clock.arrow.circlepath",
                        title: "Ride log"
                    ) {
                        HistoryView()
                    }

                    profileLink(
                        icon: "checkmark.seal.fill",
                        title: "Ridary Proof"
                    ) {
                        CredentialView()
                    }

                    profileLink(
                        icon: "slider.horizontal.3",
                        title: "Settings"
                    ) {
                        SettingsView()
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
        .presentationDetents([.fraction(0.68), .large])
        .presentationDragIndicator(.hidden)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
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
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 76, height: 76)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            Text(settings.displayName)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(app.isLocalDemo ? "Local demo" : "Ridary account")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 8, trailing: 20))
    }

    private func profileLink<Destination: View>(
        icon: String,
        title: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
                .toolbar(.visible, for: .navigationBar)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(RidaryTheme.accent)
                    .frame(width: 32, height: 32)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)
            }
            .padding(.vertical, 3)
        }
        .listRowBackground(RidaryTheme.surface)
    }

    private var privacyFooter: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(
                app.onDeviceAvailability.title,
                systemImage: app.onDeviceAvailability.isAvailable ? "iphone.gen3" : "cloud"
            )
            .font(.system(size: 11, weight: .semibold, design: .default))
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
