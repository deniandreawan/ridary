import SwiftUI

struct SourceBadge: View {
    let source: InferenceSource

    private var tint: Color {
        switch source {
        case .onDevice: return RidaryTheme.skyDeep
        case .inCloud: return RidaryTheme.sky
        case .fallback: return RidaryTheme.warning
        case .deterministic: return RidaryTheme.textSecondary
        }
    }

    var body: some View {
        Label(source.label, systemImage: source.icon)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.30), lineWidth: 1))
    }
}
