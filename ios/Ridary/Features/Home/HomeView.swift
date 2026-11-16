import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var capture: RideCaptureService

    @State private var showActiveRide = false
    @State private var startBusy = false

    private var weekRides: [Ride] {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return app.rides.filter {
            $0.mode == settings.mode && $0.startedAt >= cutoff
        }
    }

    private var weekDistance: Double {
        weekRides.reduce(0) { $0 + $1.distanceM }
    }

    private var weekAverageScore: Int {
        guard !weekRides.isEmpty else { return 0 }
        return weekRides.reduce(0) { $0 + $1.score } / weekRides.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if !app.isFirebaseConfigured {
                    setupBanner
                }
                heroCard
                statsRow
                weeklyCard
                recentSection
                if !app.onDeviceAvailability.isAvailable {
                    onDeviceCard
                }
                privacyNote
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 96)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showActiveRide) {
            ActiveRideView()
        }
        .sheet(item: $app.lastCompletedRide) { ride in
            RideSummaryView(ride: ride)
        }
        .onAppear {
            if capture.isRecording {
                showActiveRide = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("RIDARY")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .tracking(3)
                    .foregroundStyle(RidaryTheme.accent)
                Text("Your ride. Your proof.")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
            Spacer()
            statusPill
        }
    }

    private var subtitle: String {
        if capture.isRecording {
            return "A ride is being recorded privately on this iPhone."
        }
        if !app.isFirebaseConfigured {
            return "Local demo mode. Add Firebase to unlock cloud features."
        }
        return "\(settings.mode.title) mode · \(app.onDeviceAvailability.isAvailable ? "on-device AI ready" : "cloud fallback ready")"
    }

    private var statusPill: some View {
        Group {
            if !app.isFirebaseConfigured {
                Label("Local", systemImage: "iphone")
                    .foregroundStyle(RidaryTheme.warning)
            } else if app.onDeviceAvailability.isAvailable {
                Label("On device", systemImage: "iphone.gen3")
                    .foregroundStyle(RidaryTheme.teal)
            } else {
                Label("Cloud", systemImage: "cloud")
                    .foregroundStyle(RidaryTheme.accent)
            }
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RidaryTheme.cardElevated)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(RidaryTheme.border, lineWidth: 1))
    }

    private var setupBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(RidaryTheme.warning)
            VStack(alignment: .leading, spacing: 4) {
                Text("Local demo mode")
                    .font(.footnote.weight(.semibold))
                Text(app.firebaseStatus.detail)
                    .font(.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .ridaryCard(padding: 14)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            if capture.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(RidaryTheme.danger)
                        .frame(width: 9, height: 9)
                    Text("Ride in progress")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                    Spacer()
                    Text(RidaryFormatters.duration(seconds: capture.elapsedS))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
                Text(RidaryFormatters.speed(kph: capture.currentSpeedKph))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                HStack {
                    Text("\(capture.eventCount) flagged moment(s)")
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.textSecondary)
                    Spacer()
                    Text(RidaryFormatters.distance(meters: capture.distanceM))
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(RidaryTheme.textSecondary)
                }
                Button("Open active ride") {
                    showActiveRide = true
                }
                .buttonStyle(RidaryPrimaryButtonStyle())
            } else {
                Text("Ready to ride?")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("Start a private session. The phone can stay in your pocket; no camera is used.")
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
                Button {
                    Task {
                        startBusy = true
                        let started = await app.startRide()
                        startBusy = false
                        if started {
                            showActiveRide = true
                        }
                    }
                } label: {
                    if startBusy {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Label("Start \(settings.mode.title.lowercased()) ride", systemImage: "play.fill")
                    }
                }
                .buttonStyle(RidaryPrimaryButtonStyle())
                .disabled(startBusy)
            }
        }
        .ridaryCard(padding: 20)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatTile(
                icon: "road.lanes",
                value: "\(weekRides.count)",
                label: "rides this week"
            )
            StatTile(
                icon: "point.topleft.down.to.point.bottomright.curvepath",
                value: RidaryFormatters.distance(meters: weekDistance),
                label: "distance"
            )
            StatTile(
                icon: "checkmark.shield",
                value: weekRides.isEmpty ? "—" : "\(weekAverageScore)",
                label: "avg score",
                tint: RidaryTheme.teal
            )
        }
    }

    private var weeklyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                RidarySectionHeader(
                    title: "This week",
                    subtitle: "A pattern from your recent rides."
                )
                if app.weeklyBusy {
                    ProgressView()
                        .tint(RidaryTheme.accent)
                }
            }

            if let feedback = app.weeklyFeedback {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(feedback.headline)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                        SourceBadge(source: app.weeklySource)
                    }
                    Text(feedback.summary)
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.textSecondary)
                    if !feedback.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(feedback.insights, id: \.self) { insight in
                                Label(insight, systemImage: "sparkle")
                                    .font(.caption)
                                    .foregroundStyle(RidaryTheme.textSecondary)
                            }
                        }
                    }
                    Text(feedback.action)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(RidaryTheme.accent)
                }
                Button("Refresh weekly feedback") {
                    Task { await app.refreshWeeklyFeedback() }
                }
                .buttonStyle(RidarySecondaryButtonStyle())
            } else {
                Text("Generate one clear pattern and one small action from your rides this week.")
                    .font(.footnote)
                    .foregroundStyle(RidaryTheme.textSecondary)
                Button("Generate weekly feedback") {
                    Task { await app.refreshWeeklyFeedback() }
                }
                .buttonStyle(RidarySecondaryButtonStyle())
                .disabled(app.weeklyBusy)
            }
        }
        .ridaryCard()
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RidarySectionHeader(
                title: "Recent rides",
                subtitle: app.rides.isEmpty ? "Your first ride will appear here." : "Private on this device."
            )

            if app.rides.isEmpty {
                RidaryEmptyState(
                    icon: "bicycle",
                    title: "No rides yet",
                    message: "Start a ride, keep the phone in your pocket, and Ridary will build your private record."
                )
                .ridaryCard(padding: 10)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(app.rides.prefix(3))) { ride in
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
    }

    private var onDeviceCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "iphone.slash")
                .foregroundStyle(RidaryTheme.warning)
            VStack(alignment: .leading, spacing: 4) {
                Text(app.onDeviceAvailability.title)
                    .font(.footnote.weight(.semibold))
                Text(app.onDeviceAvailability.detail)
                    .font(.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
            }
        }
        .ridaryCard(padding: 14)
    }

    private var privacyNote: some View {
        Text("Raw routes and sensor windows stay on this iPhone. Only anonymized event points and summaries sync when you turn sharing on.")
            .font(.caption2)
            .foregroundStyle(RidaryTheme.textTertiary)
            .padding(.top, 4)
    }
}
