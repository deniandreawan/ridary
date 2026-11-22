import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var capture: RideCaptureService

    @StateObject private var location = HomeLocationProvider()
    @State private var showProfile = false
    @State private var showRideFlow = false
    @State private var sheetDetent: RidarySheetDetent = .medium
    @State private var recenterRevision = 0
    @State private var showAskRidary = false
    @State private var selectedRide: Ride?
    @State private var showRideSummary = false

    var body: some View {
        GeometryReader { geometry in
            let containerHeight = geometry.size.height
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(RidaryTheme.surface)
                        .frame(height: 80)
                        .ignoresSafeArea(edges: .bottom)
                }
                .allowsHitTesting(false)

                actionBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, actionBarBottomPadding(containerHeight))
                    .opacity(sheetDetent == .full ? 0 : 1)
                    .animation(.spring(response: 0.42, dampingFraction: 0.88), value: sheetDetent)
                    .allowsHitTesting(sheetDetent != .full)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                RidarySheet(
                    detent: $sheetDetent,
                    containerHeight: containerHeight,
                    topInset: geometry.safeAreaInsets.top
                ) {
                    sheetHeader
                } content: {
                    sheetContent
                }
            }
            .frame(width: geometry.size.width, height: containerHeight, alignment: .bottom)
            .background(alignment: .top) {
                RideMapView(
                    route: [],
                    height: containerHeight + geometry.safeAreaInsets.top + 90,
                    interactive: true,
                    focus: location.coordinate,
                    focusRevision: recenterRevision,
                    showsUserLocation: location.isAuthorized
                )
                .ignoresSafeArea(edges: [.top, .horizontal])
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(RidaryTheme.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showRideFlow) {
            RideRecorderView(initialMode: settings.mode)
        }
        .navigationDestination(isPresented: $showAskRidary) {
            AskRidaryView()
        }
        .navigationDestination(isPresented: $showRideSummary) {
            if let selectedRide {
                RideSummaryView(ride: selectedRide)
            }
        }
        .sheet(item: $app.lastCompletedRide) { ride in
            NavigationStack {
                RideSummaryView(ride: ride)
            }
        }
        .onAppear {
            location.start()
            if capture.isRecording {
                showRideFlow = true
                sheetDetent = .peek
            }
        }
        .onChange(of: location.revision) { _, _ in
            recenterRevision += 1
        }
    }

    private func actionBarBottomPadding(_ containerHeight: CGFloat) -> CGFloat {
        let mediumHeight = RidarySheetMetrics.height(for: .medium, container: containerHeight)
        let currentHeight = RidarySheetMetrics.height(for: sheetDetent, container: containerHeight)
        return min(mediumHeight, currentHeight) + 12
    }

    private var actionBar: some View {
        HStack {
            Button(action: recenterMap) {
                Image(systemName: "location.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(RidaryTheme.accent)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .offset(x: -5)
            .accessibilityLabel("Current location, \(location.label)")
            .accessibilityHint("Recenters the map. Opens Settings if location access is off.")

            Spacer(minLength: 0)

            if capture.isRecording {
                Button {
                    showRideFlow = true
                } label: {
                    HStack(spacing: 7) {
                        LiveDot()
                        Text("Live")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundStyle(RidaryTheme.textPrimary)
                    }
                    .padding(.horizontal, 11)
                    .frame(height: 28)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Open live ride")
            } else {
                Button {
                    showRideFlow = true
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("Start")
                            .font(.system(size: 14, weight: .bold, design: .default))
                    }
                    .foregroundStyle(RidaryTheme.onAccent)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                }
                .buttonStyle(.glass(.regular.tint(RidaryTheme.sky)))
                .accessibilityLabel("Start a ride")
            }
        }
    }

    private var sheetHeader: some View {
        HStack(spacing: 10) {
            AskRidaryEntryBar {
                showAskRidary = true
            }

            Button {
                showProfile = true
            } label: {
                Text(settings.profileInitials)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(RidaryTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(RidaryTheme.skySoft)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
        .sheet(isPresented: $showProfile) {
            ProfileMenuView()
        }
    }

    private var sheetContent: some View {
        let rides = app.rides

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Rides")
                    .font(RidaryType.section)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Spacer()

                Text(rides.isEmpty ? "No rides yet" : "\(app.rides.count) total")
                    .font(RidaryType.micro)
                    .foregroundStyle(RidaryTheme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .padding(.bottom, 4)

            if rides.isEmpty {
                emptyActivityState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(rides.enumerated()), id: \.element.id) { index, ride in
                        HomeRideRow(ride: ride)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRide = ride
                                showRideSummary = true
                            }
                            .accessibilityAddTraits(.isButton)

                        if index < rides.count - 1 {
                            Divider().overlay(RidaryTheme.border)
                        }
                    }
                }
            }
        }
        .padding(.top, 6)
    }

    private var emptyActivityState: some View {
        HStack(spacing: 14) {
            RidaryRouteArt(route: [], lineColor: RidaryTheme.route)
                .frame(width: 66, height: 66)
                .background(RidaryTheme.skySoft)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text("Your first ride starts here")
                    .font(RidaryType.bodyStrong)
                    .foregroundStyle(RidaryTheme.textPrimary)
                Text("Keep the phone in your pocket. Ridary builds the record while you ride.")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RidaryTheme.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func recenterMap() {
        switch location.authorizationStatus {
        case .denied, .restricted:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways:
            location.requestCurrentLocation()
            recenterRevision += 1
        @unknown default:
            location.requestCurrentLocation()
        }
    }
}

private struct LiveDot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RidaryTheme.safety.opacity(0.20))
                .frame(width: 16, height: 16)
                .scaleEffect(isPulsing ? 1.3 : 0.75)
                .opacity(isPulsing ? 0 : 0.8)

            Circle()
                .fill(RidaryTheme.safety)
                .frame(width: 8, height: 8)
                .opacity(isPulsing ? 0.45 : 1)
        }
        .frame(width: 16, height: 16)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .accessibilityHidden(true)
    }
}

private struct HomeRideRow: View {
    let ride: Ride

    var body: some View {
        HStack(spacing: 13) {
            RideThumbnailView(ride: ride)

            VStack(alignment: .leading, spacing: 4) {
                Text(RidaryFormatters.rideDate.string(from: ride.startedAt))
                    .font(RidaryType.bodyStrong)
                    .foregroundStyle(RidaryTheme.textPrimary)

                Text("\(ride.mode.title) · \(RidaryFormatters.distance(meters: ride.distanceM)) · \(ride.durationText)")
                    .font(RidaryType.caption)
                    .foregroundStyle(RidaryTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(spacing: 1) {
                Text("\(ride.score)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(RidaryTheme.accent)
                Text("score")
                    .font(RidaryType.micro)
                    .foregroundStyle(RidaryTheme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
