import SwiftUI

enum RidaryTheme {
    static let background = Color(red: 0.035, green: 0.050, blue: 0.070)
    static let backgroundLifted = Color(red: 0.055, green: 0.075, blue: 0.100)
    static let card = Color(red: 0.075, green: 0.100, blue: 0.130)
    static let cardElevated = Color(red: 0.095, green: 0.125, blue: 0.160)
    static let border = Color.white.opacity(0.10)
    static let accent = Color(red: 1.00, green: 0.72, blue: 0.30)
    static let teal = Color(red: 0.35, green: 0.85, blue: 0.75)
    static let danger = Color(red: 1.00, green: 0.38, blue: 0.38)
    static let warning = Color(red: 1.00, green: 0.62, blue: 0.25)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textTertiary = Color.white.opacity(0.45)
    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.14, blue: 0.18),
            Color(red: 0.05, green: 0.07, blue: 0.09)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func ridaryCard(padding: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .background(RidaryTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(RidaryTheme.border, lineWidth: 1)
            )
    }

    func ridaryScreenBackground() -> some View {
        self
            .background(RidaryTheme.background.ignoresSafeArea())
            .foregroundStyle(RidaryTheme.textPrimary)
    }
}

struct RidarySectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(RidaryTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RidaryEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(RidaryTheme.accent)
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
            Text(message)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
