import MapKit
import SwiftUI

struct RideSummaryView: View {
    let ride: Ride
    @Environment(\.dismiss) private var dismiss

    private var coordinates: [CLLocationCoordinate2D] {
        ride.routePreview.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
        }
    }

    private var region: MKCoordinateRegion {
        guard let first = coordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let minLat = lats.min() ?? first.latitude
        let maxLat = lats.max() ?? first.latitude
        let minLon = lons.min() ?? first.longitude
        let maxLon = lons.max() ?? first.longitude
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max(0.002, (maxLat - minLat) * 1.6),
                longitudeDelta: max(0.002, (maxLon - minLon) * 1.6)
            )
        )
    }

    private var shareText: String {
        "Ridary ride: \(RidaryFormatters.distance(meters: ride.distanceM)) in \(ride.durationText). Safety score \(ride.score)/100."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Ride summary")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(RidaryTheme.accent)
                }

                HStack(spacing: 16) {
                    ScoreRing(score: ride.score, size: 94)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ride.snapshot?.headline ?? "Ride captured")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(ride.mode.title) · \(RidaryFormatters.rideDate.string(from: ride.startedAt))")
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                        SourceBadge(source: ride.inferenceSource)
                    }
                }

                if let summary = ride.snapshot?.summary {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(RidaryTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(ride.summary)
                        .font(.subheadline)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }

                HStack(spacing: 10) {
                    StatTile(
                        icon: "point.topleft.down.to.point.bottomright.curvepath",
                        value: RidaryFormatters.distance(meters: ride.distanceM),
                        label: "distance"
                    )
                    StatTile(
                        icon: "clock",
                        value: ride.durationText,
                        label: "duration"
                    )
                }
                HStack(spacing: 10) {
                    StatTile(
                        icon: "speedometer",
                        value: String(format: "%.0f", ride.avgSpeedKph),
                        label: "avg km/h"
                    )
                    StatTile(
                        icon: "gauge.with.dots.needle.67percent",
                        value: String(format: "%.0f", ride.maxSpeedKph),
                        label: "max km/h"
                    )
                }

                if !coordinates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        RidarySectionHeader(title: "Route")
                        Map(initialPosition: .region(region)) {
                            MapPolyline(coordinates: coordinates)
                                .stroke(RidaryTheme.accent, lineWidth: 4)
                        }
                        .mapStyle(.standard(elevation: .flat))
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(RidaryTheme.border, lineWidth: 1)
                        )
                    }
                }

                if let snapshot = ride.snapshot {
                    if !snapshot.riskMoments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            RidarySectionHeader(
                                title: "Risk moments",
                                subtitle: "Explained by the private snapshot."
                            )
                            ForEach(snapshot.riskMoments) { moment in
                                RiskMomentRow(moment: moment)
                            }
                        }
                        .ridaryCard()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Coaching tip", systemImage: "lightbulb.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(RidaryTheme.accent)
                        Text(snapshot.coachingTip)
                            .font(.subheadline)
                        Text(snapshot.scoreRationale)
                            .font(.caption)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                    .ridaryCard()
                }

                if !ride.events.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        RidarySectionHeader(
                            title: "All flagged moments",
                            subtitle: "Deterministic detector + AI explanation."
                        )
                        ForEach(ride.events) { event in
                            EventRow(event: event)
                        }
                    }
                    .ridaryCard()
                }

                HStack(spacing: 10) {
                    ShareLink(item: shareText) {
                        Label("Share summary", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(RidarySecondaryButtonStyle())
                }

                Text("This is a personal record, not a legal or insurance determination.")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
    }
}
