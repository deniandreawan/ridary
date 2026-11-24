import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var scrollOffset: CGFloat = 0

    private var weekRides: [Ride] {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return app.rides.filter { $0.startedAt >= cutoff }
    }

    private var allRides: [Ride] {
        app.rides
    }

    private var weekDistance: Double {
        weekRides.reduce(0) { $0 + $1.distanceM }
    }

    private var allDistance: Double {
        allRides.reduce(0) { $0 + $1.distanceM }
    }

    private var averageScore: String {
        let scored = allRides.filter { $0.distanceM > 0 || $0.score > 0 }
        let source = scored.isEmpty ? allRides : scored
        guard !source.isEmpty else { return "—" }
        return "\(source.reduce(0) { $0 + $1.score } / source.count)"
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
                        highlightStrip
                            .padding(.horizontal, 24)
                            .padding(.top, 10)

                        sectionDivider

                        modeSection
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)

                        if let feedback = app.weeklyFeedback {
                            sectionDivider

                            weeklyNoteRow(feedback)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 22)
                        }
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
                .accessibilityIdentifier("statistics-screen")
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
                .accessibilityLabel("Close statistics")

                Spacer()

                if isTopBarSolid {
                    Text("Statistics")
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
            Text("This week")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(RidaryTheme.skyDeep)

            ZStack {
                Circle()
                    .fill(RidaryTheme.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: RidaryTheme.sky.opacity(0.14), radius: 12, x: 0, y: 4)

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
            }
            .padding(.vertical, 2)

            VStack(spacing: 4) {
                Text(RidaryFormatters.distance(meters: weekDistance))
                    .font(.system(size: 32, weight: .semibold, design: .default))
                    .tracking(-0.7)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("\(weekRides.count) \(weekRides.count == 1 ? "ride" : "rides")")
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

    private var highlightStrip: some View {
        HStack(spacing: 0) {
            CenteredStatMetric(
                value: averageScore,
                label: "Avg safety",
                valueColor: RidaryTheme.skyDeep
            )

            stripDivider

            CenteredStatMetric(
                value: "\(allRides.count)",
                label: "Total rides"
            )

            stripDivider

            CenteredStatMetric(
                value: RidaryFormatters.distance(meters: allDistance),
                label: "All time"
            )
        }
        .padding(.vertical, 20)
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By mode")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)

            VStack(spacing: 14) {
                ForEach(Array(RideMode.allCases.enumerated()), id: \.element.id) { index, mode in
                    let rides = allRides.filter { $0.mode == mode }
                    let distance = rides.reduce(0) { $0 + $1.distanceM }

                    HStack(alignment: .center, spacing: 14) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(RidaryTheme.sky)
                            .frame(width: 34, height: 34)
                            .background(RidaryTheme.skySoft)
                            .clipShape(Circle())

                        Text(mode.title)
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundStyle(RidaryTheme.textPrimary)

                        Spacer(minLength: 8)

                        Text(
                            rides.isEmpty
                                ? "—"
                                : "\(rides.count) · \(RidaryFormatters.distance(meters: distance))"
                        )
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(rides.isEmpty ? RidaryTheme.textTertiary : RidaryTheme.textSecondary)
                    }

                    if index < RideMode.allCases.count - 1 {
                        Divider().overlay(RidaryTheme.border.opacity(0.65))
                    }
                }
            }
        }
    }

    private func weeklyNoteRow(_ feedback: WeeklyFeedback) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RidaryTheme.sky)
                .frame(width: 34, height: 34)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(feedback.headline)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text(feedback.action)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private var stripDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(width: 1, height: 28)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border.opacity(0.65))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }
}

private struct CenteredStatMetric: View {
    let value: String
    let label: String
    var valueColor: Color = RidaryTheme.textPrimary

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
