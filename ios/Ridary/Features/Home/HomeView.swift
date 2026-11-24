import CoreLocation
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
    @State private var swipedRideID: UUID?
    @State private var ridePendingDeletion: Ride?

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
                    height: mapHeight(containerHeight, topInset: geometry.safeAreaInsets.top),
                    interactive: true,
                    focus: homeCoordinate,
                    focusRevision: recenterRevision,
                    showsUserLocation: false,
                    currentCoordinate: homeCoordinate,
                    routeSegments: capture.isRecording ? capture.liveRouteSegments : [],
                    followsLatest: capture.isRecording,
                    followRevision: capture.liveRouteRevision
                )
                .ignoresSafeArea(edges: [.top, .horizontal])
                .accessibilityIdentifier("home-map")
                .simultaneousGesture(
                    TapGesture().onEnded {
                        collapseSheetToPeek()
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(RidaryTheme.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showRideFlow) {
            RideRecorderView(initialMode: settings.mode)
        }
        .fullScreenCover(isPresented: $showAskRidary) {
            AskRidaryView()
        }
        .navigationDestination(isPresented: $showRideSummary) {
            if let selectedRide {
                RideSummaryView(ride: selectedRide)
            }
        }
        .fullScreenCover(item: $app.lastCompletedRide) { ride in
            NavigationStack {
                RideSummaryView(ride: ride, isModal: true)
            }
        }
        .alert(
            "Delete this ride?",
            isPresented: Binding(
                get: { ridePendingDeletion != nil },
                set: { if !$0 { ridePendingDeletion = nil } }
            )
        ) {
            Button("Delete ride", role: .destructive) {
                guard let ride = ridePendingDeletion else { return }
                ridePendingDeletion = nil
                Task { await app.deleteRide(ride) }
            }
            Button("Cancel", role: .cancel) {
                ridePendingDeletion = nil
            }
        } message: {
            Text(deleteConfirmationMessage)
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
        .onChange(of: sheetDetent) { _, _ in
            swipedRideID = nil
        }
        .onChange(of: showRideFlow) { _, presented in
            guard !presented, capture.isRecording else { return }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                sheetDetent = .peek
            }
        }
    }

    private var homeCoordinate: CLLocationCoordinate2D? {
        if capture.isRecording, let live = capture.liveCoordinate {
            return live
        }
        return location.coordinate
    }

    private func mapHeight(_ containerHeight: CGFloat, topInset: CGFloat) -> CGFloat {
        let sheetHeight = RidarySheetMetrics.height(
            for: sheetDetent,
            container: containerHeight
        )
        let visible = containerHeight - sheetHeight
        return max(140, visible + topInset + 24)
    }

    private func collapseSheetToPeek() {
        guard sheetDetent != .peek else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            sheetDetent = .peek
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
                    swipedRideID = nil
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
                    swipedRideID = nil
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
                swipedRideID = nil
                showAskRidary = true
            }

            Button {
                swipedRideID = nil
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
                        SwipeToDeleteRideRow(
                            ride: ride,
                            isOpen: swipedRideID == ride.id,
                            onOpen: {
                                swipedRideID = ride.id
                            },
                            onClose: {
                                if swipedRideID == ride.id {
                                    swipedRideID = nil
                                }
                            },
                            onTap: {
                                swipedRideID = nil
                                selectedRide = ride
                                showRideSummary = true
                            },
                            onDelete: {
                                swipedRideID = nil
                                ridePendingDeletion = ride
                            }
                        )
                        .padding(.horizontal, -20)

                        if index < rides.count - 1 {
                            Divider().overlay(RidaryTheme.border)
                        }
                    }
                }
            }
        }
        .padding(.top, 6)
    }

    private var deleteConfirmationMessage: String {
        guard let ride = ridePendingDeletion else { return "" }
        let incidentCount = app.incidents.filter { $0.rideID == ride.id }.count
        if incidentCount == 0 {
            return "This removes the ride from this iPhone. This can't be undone."
        }
        let records = incidentCount == 1 ? "incident record" : "incident records"
        return "This also removes \(incidentCount) locked \(records) and evidence from this iPhone. This can't be undone."
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
        if capture.isRecording {
            recenterRevision += 1
            return
        }

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

private struct HorizontalPanGesture: UIGestureRecognizerRepresentable {
    let onChanged: (CGFloat) -> Void
    let onEnded: (CGFloat, CGFloat) -> Void

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer()
        pan.delegate = context.coordinator
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        pan.delaysTouchesBegan = false
        pan.delaysTouchesEnded = false
        return pan
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UIPanGestureRecognizer,
        context: Context
    ) {
        let translation = context.converter.translation(in: .global)?.x ?? 0
        let velocity = context.converter.velocity(in: .global)?.x ?? 0

        switch recognizer.state {
        case .began, .changed:
            onChanged(translation)
        case .ended:
            onEnded(translation, velocity)
        case .cancelled, .failed:
            onEnded(translation, 0)
        default:
            break
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            let translation = pan.translation(in: pan.view)
            let velocity = pan.velocity(in: pan.view)
            let horizontal = abs(velocity.x) + abs(translation.x) * 2
            let vertical = abs(velocity.y) + abs(translation.y) * 2
            return horizontal > vertical
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

private struct SwipeToDeleteRideRow: View {
    let ride: Ride
    let isOpen: Bool
    let onOpen: () -> Void
    let onClose: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0

    private let actionWidth: CGFloat = 92
    private let spring = Animation.spring(response: 0.28, dampingFraction: 0.86)

    private var offset: CGFloat {
        let base = isOpen ? -actionWidth : 0
        return min(0, max(-actionWidth, base + dragOffset))
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteAction

            HomeRideRow(ride: ride)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RidaryTheme.surface)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isOpen {
                        onClose()
                    } else {
                        onTap()
                    }
                }
                .gesture(
                    HorizontalPanGesture(
                        onChanged: { translation in
                            let base = isOpen ? -actionWidth : 0
                            dragOffset = min(0, max(-actionWidth, base + translation))
                        },
                        onEnded: { translation, velocity in
                            let predicted = translation + velocity * 0.15

                            if isOpen {
                                if translation > actionWidth * 0.25 || predicted > 60 {
                                    close()
                                } else {
                                    open()
                                }
                            } else if translation < -actionWidth * 0.25 || predicted < -60 {
                                open()
                            } else {
                                close()
                            }
                        }
                    )
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityDescription)
                .accessibilityHint("Swipe left for actions")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("ride-row")
                .accessibilityAction(named: "Delete ride") {
                    onDelete()
                }
                .offset(x: offset)
        }
        .clipped()
        .animation(spring, value: isOpen)
    }

    private var accessibilityDescription: String {
        let date = RidaryFormatters.rideDate.string(from: ride.startedAt)
        let distance = RidaryFormatters.distance(meters: ride.distanceM)
        return "\(date), \(ride.mode.title), \(distance), \(ride.durationText), score \(ride.score)"
    }

    private var deleteAction: some View {
        Button(action: onDelete) {
            VStack(spacing: 4) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14, weight: .bold))
                Text("Delete")
                    .font(.system(size: 12, weight: .semibold, design: .default))
            }
            .foregroundStyle(RidaryTheme.onAccent)
            .frame(width: actionWidth)
            .frame(maxHeight: .infinity)
            .background(RidaryTheme.danger)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isOpen)
        .allowsHitTesting(isOpen)
        .accessibilityHidden(!isOpen)
        .accessibilityLabel("Delete ride")
    }

    private func open() {
        if !isOpen {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        withAnimation(spring) {
            dragOffset = 0
            onOpen()
        }
    }

    private func close() {
        withAnimation(spring) {
            dragOffset = 0
            onClose()
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
