import SwiftUI

struct AskRidaryEntryBar: View {
    let onAsk: () -> Void

    var body: some View {
        Button(action: onAsk) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RidaryTheme.accent)

                Text("Ask Ridary")
                    .font(RidaryType.body)
                    .foregroundStyle(RidaryTheme.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(RidaryTheme.backgroundLifted)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ask Ridary")
        .accessibilityHint("Opens Ask Ridary")
    }
}
