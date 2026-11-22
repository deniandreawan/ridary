import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var app: AppEnvironment
    @State private var segment: Segment = .rides

    private enum Segment: String, CaseIterable, Identifiable {
        case rides = "Rides"
        case incidents = "Incidents"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                segmentedControl
                if segment == .rides {
                    ridesSection
                } else {
                    incidentsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 32)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("Rides")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(RidaryTheme.background, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ride log")
                .font(RidaryType.display)
                .tracking(-0.8)
                .foregroundStyle(RidaryTheme.textPrimary)
            Text("Every session, kept close and easy to find.")
                .font(RidaryType.caption)
                .foregroundStyle(RidaryTheme.textSecondary)
        }
    }

    private var segmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(Segment.allCases) { item in
                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        segment = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .foregroundStyle(
                            segment == item
                                ? RidaryTheme.textPrimary
                                : RidaryTheme.textTertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            segment == item
                                ? RidaryTheme.card
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(RidaryTheme.backgroundLifted)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    @ViewBuilder
    private var ridesSection: some View {
        if app.rides.isEmpty {
            RidaryEmptyState(
                icon: "point.topleft.down.to.point.bottomright.curvepath",
                title: "Your log is ready",
                message: "Start a ride from Home. The phone stays in your pocket and the route stays on this device."
            )
            .ridaryCard()
        } else {
            ForEach(app.rides) { ride in
                NavigationLink {
                    RideSummaryView(ride: ride)
                } label: {
                    RideCard(ride: ride)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var incidentsSection: some View {
        if app.incidents.isEmpty {
            RidaryEmptyState(
                icon: "lock.shield",
                title: "No locked incidents",
                message: "Use “Lock last 30 seconds” during a ride to preserve a private evidence window."
            )
            .ridaryCard()
        } else {
            ForEach(app.incidents) { incident in
                NavigationLink {
                    IncidentView(incident: incident)
                } label: {
                    IncidentListRow(incident: incident)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct IncidentListRow: View {
    let incident: Incident

    private var tint: Color {
        incident.severity >= 4 ? RidaryTheme.danger : RidaryTheme.warning
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: incident.eventType.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(incident.eventType.title)
                    .font(RidaryType.bodyStrong)
                    .foregroundStyle(RidaryTheme.textPrimary)
                Text(RidaryFormatters.rideDate.string(from: incident.lockedAt))
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
                Text("Hash \(incident.hash.prefix(12))…")
                    .font(RidaryType.mono)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }

            Spacer()

            Text(incident.status.title)
                .font(RidaryType.micro)
                .foregroundStyle(tint)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(tint.opacity(0.12))
                .clipShape(Capsule())
        }
        .ridaryCard(padding: 14)
    }
}
