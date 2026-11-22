import SwiftUI

struct ScoreRing: View {
    let score: Int
    var size: CGFloat = 112
    var lineWidth: CGFloat = 10

    private var fraction: CGFloat {
        CGFloat(min(100, max(0, score))) / 100
    }

    private var tint: Color {
        if score >= 90 { return RidaryTheme.sky }
        if score >= 75 { return RidaryTheme.accent }
        if score >= 60 { return RidaryTheme.warning }
        return RidaryTheme.danger
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(RidaryTheme.border, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.30, weight: .bold, design: .rounded))
                Text("score")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Safety score \(score) out of 100")
    }
}
