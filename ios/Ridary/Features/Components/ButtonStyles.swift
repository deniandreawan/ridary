import SwiftUI

struct RidaryPrimaryButtonStyle: ButtonStyle {
    var tint: Color = RidaryTheme.sky

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .default))
            .foregroundStyle(RidaryTheme.onSky)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(tint.opacity(configuration.isPressed ? 0.82 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .shadow(
                color: tint.opacity(configuration.isPressed ? 0 : 0.18),
                radius: 16,
                x: 0,
                y: 8
            )
    }
}

struct RidarySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundStyle(RidaryTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(
                RidaryTheme.cardElevated.opacity(configuration.isPressed ? 0.72 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(RidaryTheme.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

struct RidaryCompactButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundStyle(RidaryTheme.textPrimary)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(RidaryTheme.cardElevated)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(RidaryTheme.border, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

struct RidaryRecordButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .default))
            .foregroundStyle(RidaryTheme.onSky)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(RidaryTheme.sky.opacity(configuration.isPressed ? 0.82 : 1))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(
                color: RidaryTheme.sky.opacity(configuration.isPressed ? 0 : 0.24),
                radius: 14,
                x: 0,
                y: 6
            )
    }
}
