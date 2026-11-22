import SwiftUI

struct RideCard: View {
    let ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RidaryTheme.cardElevated

                RidaryRouteArt(
                    route: ride.routePreview,
                    lineColor: RidaryTheme.route,
                    lineWidth: 2.5
                )
                .frame(height: 108)
                .padding(6)

                HStack(alignment: .top) {
                    SourceBadge(source: ride.inferenceSource)
                    Spacer()
                    Text(ride.mode.title.uppercased())
                        .font(RidaryType.micro)
                        .tracking(1.1)
                        .foregroundStyle(RidaryTheme.textTertiary)
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(RidaryFormatters.rideDate.string(from: ride.startedAt))
                        .font(RidaryType.bodyStrong)
                        .foregroundStyle(RidaryTheme.textPrimary)
                    Text(ride.summary.isEmpty ? ride.mode.title : ride.summary)
                        .font(RidaryType.caption)
                        .foregroundStyle(RidaryTheme.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                ScoreRing(score: ride.score, size: 46, lineWidth: 5)
            }
            .padding(14)

            HStack(spacing: 16) {
                RideMetric(value: RidaryFormatters.distance(meters: ride.distanceM), label: "distance")
                RideMetric(value: ride.durationText, label: "time")
                RideMetric(value: "\(ride.events.count)", label: "moments")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 15)
        }
        .background(RidaryTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(RidaryTheme.border, lineWidth: 1)
        )
        .shadow(color: RidaryTheme.shadow, radius: 18, x: 0, y: 9)
    }
}

private struct RideMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(RidaryTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(RidaryType.micro)
                .foregroundStyle(RidaryTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.8)
        }
    }
}
