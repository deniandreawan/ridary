import CoreLocation
import SwiftUI

struct RideSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    let ride: Ride
    var isModal = false

    @State private var scrollOffset: CGFloat = 0

    private var headlineText: String {
        ride.snapshot?.headline ?? "Ride captured"
    }

    private var summaryText: String {
        ride.snapshot?.summary ?? ride.summary
    }

    private var scoreBand: String {
        switch ride.score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        default: return "D"
        }
    }

    private var shareText: String {
        "Ridary ride: \(RidaryFormatters.distance(meters: ride.distanceM)) in \(ride.durationText). Safety score \(ride.score)/100 (\(scoreBand) Band)."
    }

    private var mapMarkers: [RideMapMarker] {
        guard !ride.routePreview.isEmpty else { return [] }
        return Array(ride.events.enumerated()).compactMap { index, event in
            let coord = coordinate(for: event, index: index, total: ride.events.count)
            guard let coord else { return nil }
            return RideMapMarker(
                id: event.id,
                coordinate: coord,
                number: index + 1,
                color: eventColor(event)
            )
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    RideMapView(
                        route: ride.routePreview,
                        height: 348,
                        interactive: true,
                        markers: mapMarkers
                    )

                    VStack(spacing: 0) {
                        editorialIntro
                            .padding(.horizontal, 28)
                            .padding(.top, 26)
                            .padding(.bottom, 24)

                        sectionDivider

                        if let snapshot = ride.snapshot {
                            takeawayRow(snapshot)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)

                            sectionDivider
                        }

                        highlightStrip
                            .padding(.horizontal, 24)

                        sectionDivider

                        timelineSection
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)

                        sectionDivider

                        Text("This is a personal record, not a legal or insurance determination.")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(RidaryTheme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
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
                .accessibilityIdentifier("ride-recap-screen")
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }
            .safeAreaInset(edge: .bottom) {
                actionBar
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
                    Image(systemName: isModal ? "xmark" : "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel(isModal ? "Close ride summary" : "Back")

                Spacer()

                if isTopBarSolid {
                    Text("\(ride.mode.title) · \(shortDateText)")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .transition(.opacity)

                    Spacer()
                }

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RidaryTheme.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Share recap")
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

    private var isTopBarSolid: Bool {
        scrollOffset > 190
    }

    private var editorialIntro: some View {
        VStack(spacing: 10) {
            Text(headlineText)
                .font(.system(size: 23, weight: .semibold, design: .default))
                .tracking(-0.35)
                .foregroundStyle(RidaryTheme.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(summaryText)
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(3)
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 5) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)

                Text("\(ride.score) Safety · \(scoreBand) Band")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("· \(ride.inferenceSource.label)")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private func takeawayRow(_ snapshot: RideSnapshot) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(RidaryTheme.sky)
                .frame(width: 40, height: 40)
                .background(RidaryTheme.skySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(snapshot.coachingTip)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(snapshot.scoreRationale)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private var highlightStrip: some View {
        HStack(spacing: 0) {
            CenteredMetric(
                value: "\(ride.score)",
                label: "Safety · \(scoreBand) Band",
                valueColor: RidaryTheme.skyDeep
            )

            metricDivider

            CenteredMetric(
                value: RidaryFormatters.distance(meters: ride.distanceM),
                label: "\(ride.durationText) duration"
            )

            metricDivider

            CenteredMetric(
                value: "\(Int(ride.avgSpeedKph)) km/h",
                label: "Avg · \(Int(ride.maxSpeedKph)) max"
            )
        }
        .padding(.vertical, 18)
    }

    private var metricDivider: some View {
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

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("Ride timeline")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer()

                Text(ride.events.isEmpty ? "Smooth ride" : "\(ride.events.count) moment\(ride.events.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 0) {
                RideTimelineNodeRow(
                    time: "0:00",
                    title: "Ride started",
                    subtitle: "\(ride.mode.title) session · \(RidaryFormatters.rideDate.string(from: ride.startedAt))",
                    badgeText: nil,
                    badgeIcon: ride.mode.icon,
                    badgeFill: RidaryTheme.skySoft,
                    badgeForeground: RidaryTheme.sky,
                    severityText: nil,
                    severityColor: RidaryTheme.sky,
                    showsConnectorBelow: true
                )

                if ride.events.isEmpty {
                    RideTimelineNodeRow(
                        time: formatOffset(max(1, Int(ride.durationS) / 2)),
                        title: "Steady pace maintained",
                        subtitle: "No hard braking, sharp turns, or impact spikes detected.",
                        badgeText: nil,
                        badgeIcon: "checkmark",
                        badgeFill: RidaryTheme.skySoft,
                        badgeForeground: RidaryTheme.sky,
                        severityText: nil,
                        severityColor: RidaryTheme.sky,
                        showsConnectorBelow: true
                    )
                } else {
                    ForEach(Array(ride.events.enumerated()), id: \.element.id) { index, event in
                        let color = eventColor(event)
                        let offsetSec = max(0, Int(event.occurredAt.timeIntervalSince(ride.startedAt)))
                        RideTimelineNodeRow(
                            time: formatOffset(offsetSec),
                            title: event.type.title,
                            subtitle: event.summary,
                            badgeText: "\(index + 1)",
                            badgeIcon: nil,
                            badgeFill: color.opacity(0.14),
                            badgeForeground: color,
                            severityText: "Severity \(event.severity)",
                            severityColor: color,
                            showsConnectorBelow: true
                        )
                    }
                }

                RideTimelineNodeRow(
                    time: ride.durationText,
                    title: "Ride completed",
                    subtitle: "\(RidaryFormatters.distance(meters: ride.distanceM)) recorded · Safety score \(ride.score)/100",
                    badgeText: nil,
                    badgeIcon: "flag.checkered",
                    badgeFill: RidaryTheme.backgroundLifted,
                    badgeForeground: RidaryTheme.textSecondary,
                    severityText: nil,
                    severityColor: RidaryTheme.textSecondary,
                    showsConnectorBelow: false
                )
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(RidaryTheme.border.opacity(0.65))
                .frame(height: 1)

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(ride.score)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(RidaryTheme.textPrimary)

                        Text("/ 100 · \(scoreBand) Band")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }

                    Text("\(RidaryFormatters.distance(meters: ride.distanceM)) · \(ride.durationText)")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(RidaryTheme.textTertiary)
                }

                Spacer()

                ShareLink(item: shareText) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Share recap")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                    }
                    .foregroundStyle(RidaryTheme.onAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(RidaryTheme.sky)
            }
            .padding(.horizontal, 24)
            .padding(.top, 11)
            .padding(.bottom, 8)
        }
        .background(RidaryTheme.surface.ignoresSafeArea(edges: .bottom))
    }

    private var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: ride.startedAt)
    }

    private func eventColor(_ event: RideEvent) -> Color {
        if event.severity >= 4 { return RidaryTheme.danger }
        if event.severity >= 3 { return RidaryTheme.warning }
        return RidaryTheme.skyDeep
    }

    private func coordinate(for event: RideEvent, index: Int, total: Int) -> CLLocationCoordinate2D? {
        let coords = ride.routePreview.compactMap { pair -> CLLocationCoordinate2D? in
            guard pair.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
        }
        guard !coords.isEmpty else { return nil }
        if coords.count == 1 { return coords[0] }

        let offsetSec = max(0, event.occurredAt.timeIntervalSince(ride.startedAt))
        let progress: Double
        if ride.durationS > 0, offsetSec > 0 {
            progress = min(0.92, max(0.08, offsetSec / ride.durationS))
        } else {
            progress = Double(index + 1) / Double(total + 1)
        }
        let targetIndex = min(coords.count - 1, max(0, Int(round(progress * Double(coords.count - 1)))))
        return coords[targetIndex]
    }

    private func formatOffset(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "+%d:%02d", mins, secs)
    }
}

private struct RideTimelineNodeRow: View {
    let time: String
    let title: String
    let subtitle: String
    let badgeText: String?
    let badgeIcon: String?
    let badgeFill: Color
    let badgeForeground: Color
    let severityText: String?
    let severityColor: Color
    let showsConnectorBelow: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(badgeFill)
                        .frame(width: 34, height: 34)

                    if let badgeText {
                        Text(badgeText)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(badgeForeground)
                    } else if let badgeIcon {
                        Image(systemName: badgeIcon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(badgeForeground)
                    }
                }

                if showsConnectorBelow {
                    Rectangle()
                        .fill(RidaryTheme.border.opacity(0.65))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundStyle(RidaryTheme.textPrimary)

                    if let severityText {
                        Text(severityText)
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundStyle(severityColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(severityColor.opacity(0.11))
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 6)

                    Text(time)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundStyle(RidaryTheme.textTertiary)
                }

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, showsConnectorBelow ? 18 : 2)
        }
    }
}

private struct CenteredMetric: View {
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
