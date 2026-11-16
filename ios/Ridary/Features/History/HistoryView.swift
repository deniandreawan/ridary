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
            VStack(alignment: .leading, spacing: 18) {
                Picker("History", selection: $segment) {
                    ForEach(Segment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)

                if segment == .rides {
                    ridesSection
                } else {
                    incidentsSection
                }
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var ridesSection: some View {
        if app.rides.isEmpty {
            RidaryEmptyState(
                icon: "clock.arrow.circlepath",
                title: "No rides yet",
                message: "Your private ride history will appear here after your first session."
            )
            .ridaryCard()
        } else {
            VStack(spacing: 10) {
                ForEach(app.rides) { ride in
                    NavigationLink {
                        RideSummaryView(ride: ride)
                    } label: {
                        RideListRow(ride: ride)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var incidentsSection: some View {
        if app.incidents.isEmpty {
            RidaryEmptyState(
                icon: "lock.shield",
                title: "No locked incidents",
                message: "Use “Lock last 30 seconds” during a ride to preserve evidence privately."
            )
            .ridaryCard()
        } else {
            VStack(spacing: 10) {
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
}

private struct IncidentListRow: View {
    let incident: Incident

    private var tint: Color {
        incident.severity >= 4 ? RidaryTheme.danger : RidaryTheme.warning
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: incident.eventType.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(incident.eventType.title)
                    .font(.subheadline.weight(.semibold))
                Text(RidaryFormatters.rideDate.string(from: incident.lockedAt))
                    .font(.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
                Text("Hash \(incident.hash.prefix(12))…")
                    .font(.caption2.monospaced())
                    .foregroundStyle(RidaryTheme.textTertiary)
            }

            Spacer()

            Text(incident.status.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(tint)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(tint.opacity(0.12))
                .clipShape(Capsule())
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
