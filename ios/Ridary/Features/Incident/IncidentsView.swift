import SwiftUI

struct IncidentsView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Incident?
    @State private var scrollOffset: CGFloat = 0

    private var isTopBarSolid: Bool {
        scrollOffset > 120
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    heroCard

                    VStack(spacing: 0) {
                        if app.incidents.isEmpty {
                            emptyState
                                .padding(.horizontal, 28)
                                .padding(.vertical, 48)
                        } else {
                            incidentsListSection
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
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
                .accessibilityIdentifier("incidents-screen")
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
        .fullScreenCover(item: $selected) { incident in
            NavigationStack {
                IncidentView(incident: incident, isModal: true)
            }
        }
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
                .accessibilityLabel("Close incidents")

                Spacer()

                if isTopBarSolid {
                    Text("Incidents")
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
            Text("Evidence vault")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(RidaryTheme.skyDeep)

            ZStack {
                Circle()
                    .fill(RidaryTheme.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: RidaryTheme.sky.opacity(0.14), radius: 12, x: 0, y: 4)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(RidaryTheme.sky)
            }
            .padding(.vertical, 2)

            VStack(spacing: 4) {
                Text("Incidents")
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .tracking(-0.6)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text(
                    app.incidents.isEmpty
                        ? "No locked moments"
                        : "\(app.incidents.count) locked"
                )
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

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No incidents recorded")
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(RidaryTheme.textPrimary)

            Text("Tap Lock during a ride to save a 30-second sensor window.")
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundStyle(RidaryTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var incidentsListSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(app.incidents.enumerated()), id: \.element.id) { index, incident in
                Button {
                    selected = incident
                } label: {
                    incidentRow(incident)
                }
                .buttonStyle(.plain)

                if index < app.incidents.count - 1 {
                    Divider()
                        .overlay(RidaryTheme.border.opacity(0.65))
                }
            }
        }
    }

    private func incidentRow(_ incident: Incident) -> some View {
        let tint = incident.severity >= 4 ? RidaryTheme.danger : RidaryTheme.warning

        return HStack(spacing: 14) {
            Image(systemName: incident.eventType.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(incident.eventType.title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text(RidaryFormatters.rideDate.string(from: incident.lockedAt))
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(RidaryTheme.textSecondary)
            }

            Spacer(minLength: 8)

            Text(incident.status.title)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(tint)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(tint.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
