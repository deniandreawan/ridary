import SwiftUI

enum RidaryTheme {
    static let canvas = Color(hex: 0xFAFAFA)
    static let background = canvas
    static let backgroundLifted = Color(hex: 0xF5F5F5)
    static let surface = Color(hex: 0xFFFFFF)
    static let card = surface
    static let cardElevated = Color(hex: 0xF5F5F5)
    static let border = Color(hex: 0xE5E5E5)
    static let accent = Color(hex: 0x0084D1)
    static let sky = Color(hex: 0x00A6F4)
    static let skyDeep = Color(hex: 0x0084D1)
    static let skySoft = Color(hex: 0xDFF2FE)
    static let safety = Color(hex: 0xFB2C36)
    static let danger = Color(hex: 0xE7000B)
    static let warning = Color(hex: 0xE17100)
    static let textPrimary = Color(hex: 0x171717)
    static let textSecondary = Color(hex: 0x737373)
    static let textTertiary = Color(hex: 0xA1A1A1)
    static let onAccent = Color(hex: 0xFFFFFF)
    static let onSky = Color(hex: 0x171717)
    static let accentSoft = skySoft
    static let shadow = Color(hex: 0x171717).opacity(0.08)
    static let route = skyDeep
    static let heroGradient = LinearGradient(
        colors: [Color(hex: 0x00A6F4), Color(hex: 0x0084D1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum RidaryLayout {
    static let sheetBottomInset: CGFloat = 34
}

enum RidaryType {
    static let hero = Font.system(size: 38, weight: .heavy, design: .default)
    static let display = Font.system(size: 30, weight: .bold, design: .default)
    static let title = Font.system(size: 22, weight: .bold, design: .default)
    static let section = Font.system(size: 18, weight: .bold, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let bodyStrong = Font.system(size: 15, weight: .semibold, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let micro = Font.system(size: 10, weight: .semibold, design: .default)
    static let mono = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let numeral = Font.system(size: 28, weight: .heavy, design: .rounded)
}

extension View {
    func ridaryCard(padding: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .background(RidaryTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(RidaryTheme.border, lineWidth: 1)
            )
            .shadow(color: RidaryTheme.shadow, radius: 18, x: 0, y: 9)
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
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(RidaryType.section)
                .foregroundStyle(RidaryTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(RidaryType.caption)
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
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 52, height: 52)
                .background(RidaryTheme.accentSoft)
                .clipShape(Circle())
            Text(title)
                .font(RidaryType.bodyStrong)
                .foregroundStyle(RidaryTheme.textPrimary)
            Text(message)
                .font(RidaryType.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
    }
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
