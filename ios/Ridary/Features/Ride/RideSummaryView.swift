import SwiftUI

struct RideSummaryView: View {
    let ride: Ride
    @Environment(\.dismiss) private var dismiss

    private var shareText: String {
        "Ridary ride: \(RidaryFormatters.distance(meters: ride.distanceM)) in \(ride.durationText). Safety score \(ride.score)/100."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                mapHero
                VStack(alignment: .leading, spacing: 18) {
                    statsStrip
                    insightCard
                    if !ride.events.isEmpty {
                        timelineCard
                    }
                    shareRow
                    disclaimer
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var mapHero: some View {
        ZStack(alignment: .top) {
            RideMapView(route: ride.routePreview, height: 330, interactive: true)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(RidaryFormatters.rideDate.string(from: ride.startedAt))
                            .font(.system(size: 13, weight: .bold, design: .default))
                        Text("\(ride.mode.title) · \(ride.durationText)")
                            .font(RidaryType.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 10)
                    .background(RidaryTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(RidaryTheme.border, lineWidth: 1)
                    )
                    .shadow(color: RidaryTheme.shadow, radius: 10, x: 0, y: 4)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RidaryTheme.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(RidaryTheme.border, lineWidth: 1))
                    .shadow(color: RidaryTheme.shadow, radius: 10, x: 0, y: 4)
                }
                .padding(16)

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ride.snapshot?.headline ?? "Ride captured")
                            .font(.system(size: 26, weight: .heavy, design: .default))
                            .tracking(-0.6)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text("Private snapshot")
                            .font(RidaryType.caption)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    Spacer(minLength: 12)
                    ScoreRing(score: ride.score, size: 78, lineWidth: 7)
                        .padding(8)
                        .background(.white)
                        .clipShape(Circle())
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.58)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var statsStrip: some View {
        HStack(spacing: 0) {
            SummaryMetric(value: RidaryFormatters.distance(meters: ride.distanceM), label: "distance")
            summaryDivider
            SummaryMetric(value: ride.durationText, label: "time")
            summaryDivider
            SummaryMetric(value: "\(Int(ride.avgSpeedKph))", label: "avg km/h")
            summaryDivider
            SummaryMetric(value: "\(Int(ride.maxSpeedKph))", label: "max km/h")
        }
        .ridaryCard(padding: 16)
    }

    private var summaryDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border)
            .frame(width: 1, height: 34)
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                RidarySectionHeader(
                    title: "What your phone noticed",
                    subtitle: "A short explanation from the private snapshot."
                )
                SourceBadge(source: ride.inferenceSource)
            }

            Text(ride.snapshot?.summary ?? ride.summary)
                .font(RidaryType.body)
                .foregroundStyle(RidaryTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let snapshot = ride.snapshot {
                VStack(alignment: .leading, spacing: 5) {
                    Text(snapshot.coachingTip)
                        .font(RidaryType.bodyStrong)
                    Text(snapshot.scoreRationale)
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textTertiary)
                }
                .padding(13)
                .background(RidaryTheme.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .ridaryCard(padding: 18)
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            RidarySectionHeader(
                title: "Ride timeline",
                subtitle: "The moments the detector flagged."
            )

            ForEach(Array(ride.events.enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(eventColor(event))
                            .frame(width: 9, height: 9)
                            .padding(.top, 5)
                        if index < ride.events.count - 1 {
                            Rectangle()
                                .fill(RidaryTheme.border)
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 10)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(event.type.title)
                                .font(RidaryType.bodyStrong)
                            Spacer()
                            Text("+\(max(0, Int(event.occurredAt.timeIntervalSince(ride.startedAt))))s")
                                .font(RidaryType.mono)
                                .foregroundStyle(RidaryTheme.textTertiary)
                        }
                        Text(event.summary)
                            .font(RidaryType.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, index == ride.events.count - 1 ? 0 : 6)
                }
            }
        }
        .ridaryCard(padding: 18)
    }

    private var shareRow: some View {
        HStack(spacing: 10) {
            ShareLink(item: shareText) {
                Label("Share recap", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(RidaryPrimaryButtonStyle())

            if !ride.events.isEmpty {
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("All moments", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(RidarySecondaryButtonStyle())
            }
        }
    }

    private var disclaimer: some View {
        Text("This is a personal record, not a legal or insurance determination.")
            .font(RidaryType.micro)
            .foregroundStyle(RidaryTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func eventColor(_ event: RideEvent) -> Color {
        if event.severity >= 4 { return RidaryTheme.danger }
        if event.severity >= 3 { return RidaryTheme.warning }
        return RidaryTheme.skyDeep
    }
}

private struct SummaryMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(RidaryTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(RidaryType.micro)
                .foregroundStyle(RidaryTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
    }
}
