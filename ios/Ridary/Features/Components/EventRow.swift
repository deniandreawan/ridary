import SwiftUI

struct EventRow: View {
    let event: RideEvent

    private var tint: Color {
        if event.severity >= 4 { return RidaryTheme.danger }
        if event.severity >= 3 { return RidaryTheme.warning }
        return RidaryTheme.skyDeep
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.type.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    SourceBadge(source: event.source)
                }
                Text(event.summary)
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(RidaryFormatters.rideDate.string(from: event.occurredAt))
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
        }
    }
}

struct RiskMomentRow: View {
    let moment: RiskMoment

    private var tint: Color {
        if moment.severity >= 4 { return RidaryTheme.danger }
        if moment.severity >= 3 { return RidaryTheme.warning }
        return RidaryTheme.skyDeep
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: moment.type.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(moment.type.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("+\(moment.atSeconds)s")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(RidaryTheme.textTertiary)
                }
                Text(moment.explanation)
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
