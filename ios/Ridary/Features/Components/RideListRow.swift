import SwiftUI

struct RideListRow: View {
    let ride: Ride

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: ride.mode.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(RidaryTheme.accent)
                .frame(width: 38, height: 38)
                .background(RidaryTheme.accent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(RidaryFormatters.rideDate.string(from: ride.startedAt))
                    .font(.subheadline.weight(.semibold))
                Text("\(RidaryFormatters.distance(meters: ride.distanceM)) · \(ride.durationText) · \(ride.events.count) moments")
                    .font(.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }

            Spacer()

            ScoreRing(score: ride.score, size: 46, lineWidth: 5)
        }
        .padding(14)
        .background(RidaryTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(RidaryTheme.border, lineWidth: 1)
        )
    }
}
