import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var app: AppEnvironment

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

    private var weekAverageScore: String {
        guard !weekRides.isEmpty else { return "—" }
        return "\(weekRides.reduce(0) { $0 + $1.score } / weekRides.count)"
    }

    private var allAverageScore: String {
        guard !allRides.isEmpty else { return "—" }
        return "\(allRides.reduce(0) { $0 + $1.score } / allRides.count)"
    }

    private var weekOnDeviceCount: Int {
        weekRides.filter { $0.inferenceSource == .onDevice }.count
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                weekSection
                allTimeSection
                modeSection
                if let feedback = app.weeklyFeedback {
                    weeklyNote(feedback)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RidaryTheme.background, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your riding, in numbers")
                .font(RidaryType.display)
                .tracking(-0.7)
                .foregroundStyle(RidaryTheme.textPrimary)
            Text("A quiet record of distance, consistency, and the moments that mattered.")
                .font(RidaryType.body)
                .foregroundStyle(RidaryTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RidarySectionHeader(title: "This week")
            LazyVGrid(columns: columns, spacing: 10) {
                StatTile(
                    icon: "road.lanes",
                    value: "\(weekRides.count)",
                    label: "rides",
                    tint: RidaryTheme.accent
                )
                StatTile(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    value: RidaryFormatters.distance(meters: weekDistance),
                    label: "distance",
                    tint: RidaryTheme.accent
                )
                StatTile(
                    icon: "gauge.with.dots.needle.67percent",
                    value: weekAverageScore,
                    label: "avg score",
                    tint: RidaryTheme.accent
                )
                StatTile(
                    icon: "iphone.gen3",
                    value: "\(weekOnDeviceCount)",
                    label: "on-device",
                    tint: RidaryTheme.accent
                )
            }
        }
    }

    private var allTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RidarySectionHeader(title: "All time")
            LazyVGrid(columns: columns, spacing: 10) {
                StatTile(
                    icon: "clock.arrow.circlepath",
                    value: "\(allRides.count)",
                    label: "rides",
                    tint: RidaryTheme.textPrimary
                )
                StatTile(
                    icon: "map",
                    value: RidaryFormatters.distance(meters: allDistance),
                    label: "distance",
                    tint: RidaryTheme.textPrimary
                )
                StatTile(
                    icon: "gauge.with.dots.needle.67percent",
                    value: allAverageScore,
                    label: "avg score",
                    tint: RidaryTheme.textPrimary
                )
                StatTile(
                    icon: "checkmark.seal.fill",
                    value: "\(app.credentials.count)",
                    label: "proofs",
                    tint: RidaryTheme.textPrimary
                )
            }
        }
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            RidarySectionHeader(title: "By mode")

            VStack(spacing: 0) {
                ForEach(Array(RideMode.allCases.enumerated()), id: \.element.id) { index, mode in
                    let rides = allRides.filter { $0.mode == mode }
                    let distance = rides.reduce(0) { $0 + $1.distanceM }

                    HStack(spacing: 12) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(RidaryTheme.accent)
                            .frame(width: 34, height: 34)
                            .background(RidaryTheme.skySoft)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Text(mode.title)
                            .font(RidaryType.bodyStrong)
                            .foregroundStyle(RidaryTheme.textPrimary)

                        Spacer(minLength: 8)

                        Text("\(rides.count) · \(RidaryFormatters.distance(meters: distance))")
                            .font(RidaryType.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    .padding(.vertical, 9)

                    if index < RideMode.allCases.count - 1 {
                        Divider().overlay(RidaryTheme.border)
                    }
                }
            }
            .padding(.horizontal, 14)
            .background(RidaryTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(RidaryTheme.border, lineWidth: 1)
            )
        }
    }

    private func weeklyNote(_ feedback: WeeklyFeedback) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(RidaryTheme.accent)
                Text("This week’s note")
                    .font(RidaryType.bodyStrong)
                    .foregroundStyle(RidaryTheme.textPrimary)
            }
            Text(feedback.headline)
                .font(RidaryType.body)
                .foregroundStyle(RidaryTheme.textPrimary)
            Text(feedback.action)
                .font(RidaryType.caption)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RidaryTheme.skySoft)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
