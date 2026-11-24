import SwiftUI
import UIKit

struct RideRecorderView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var capture: RideCaptureService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    let initialMode: RideMode

    @State private var selectedMode: RideMode
    @State private var phase: Phase = .ready
    @State private var countdown = 3
    @State private var errorMessage: String?
    @State private var isPreparing = false
    @State private var finishBusy = false
    @State private var lockBusy = false
    @State private var showModePicker = false
    @State private var incident: Incident?
    @State private var prepareTask: Task<Void, Never>?
    @State private var countdownTask: Task<Void, Never>?

    private enum Phase {
        case ready
        case countdown
        case starting
        case finishing
    }

    init(initialMode: RideMode) {
        self.initialMode = initialMode
        _selectedMode = State(initialValue: initialMode)
    }

    var body: some View {
        VStack(spacing: 0) {
            hero
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(heroBackground.ignoresSafeArea(edges: .top))

            bottomPanel
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(heroBackground.ignoresSafeArea())
        .preferredColorScheme(heroIsDark ? .dark : .light)
        .onChange(of: scenePhase) { _, value in
            guard value != .active, phase == .countdown else { return }
            cancelCountdown()
        }
        .onDisappear {
            prepareTask?.cancel()
            countdownTask?.cancel()
        }
        .sheet(isPresented: $showModePicker) {
            RideModeSheet(selection: $selectedMode)
        }
        .fullScreenCover(item: $incident) { created in
            NavigationStack {
                IncidentView(incident: created, isModal: true)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroTopBar

            liveHero
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var liveHero: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 12)

            timerDisplay

            Spacer(minLength: 18)

            VStack(alignment: .leading, spacing: 7) {
                Text("SPEED")
                    .font(RidaryType.micro)
                    .tracking(1.1)
                    .foregroundStyle(heroForeground.opacity(0.75))

                Text(RidaryFormatters.speed(kph: capture.currentSpeedKph))
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(heroForeground)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                RideSpeedTrace(
                    samples: traceSamples,
                    tint: traceTint,
                    onDark: true
                )
                .frame(height: 126)
                .padding(.top, 2)
            }

            Spacer(minLength: 10)
        }
    }

    private var timerDisplay: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(displayedTimer)
                .font(.system(size: 112, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(heroForeground)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityLabel(timerAccessibilityLabel)
                .accessibilityIdentifier("ride-timer")

            Text(timerLabel)
                .font(RidaryType.micro)
                .tracking(1.2)
                .foregroundStyle(heroForeground.opacity(0.7))
                .padding(.top, 3)
                .accessibilityIdentifier("ride-timer-label")
        }
    }

    private var heroTopBar: some View {
        HStack(spacing: 10) {
            Button {
                prepareTask?.cancel()
                countdownTask?.cancel()
                dismiss()
            } label: {
                Image(systemName: capture.isRecording ? "chevron.down" : "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(heroForeground)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.glass(.clear))
            .buttonBorderShape(.circle)
            .disabled(phase == .finishing)
            .accessibilityLabel(capture.isRecording ? "Minimize ride" : "Close ride start")

            HStack(spacing: 7) {
                RideStatusDot(color: statusColor, isPulsing: statusPulses)

                Text(statusTitle)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(heroForeground)
                    .accessibilityIdentifier("ride-status")
            }

            Spacer(minLength: 6)

            modeControl
        }
        .frame(height: 54)
        .colorScheme(.light)
    }

    private var modeControl: some View {
        Button {
            guard canChangeMode else { return }
            showModePicker = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: activeMode.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(heroForeground)

                Text(activeMode.title)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(heroForeground)

                if canChangeMode {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(heroForeground.opacity(0.7))
                }
            }
            .lineLimit(1)
            .padding(.horizontal, 8)
            .frame(height: 28)
        }
        .buttonStyle(.glass(.clear))
        .disabled(!canChangeMode)
        .accessibilityIdentifier("mode-control")
        .accessibilityLabel(canChangeMode ? "Change activity, \(activeMode.title)" : activeMode.title)
    }

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            mainPanel
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(
            TopRoundedRectangle(radius: 30)
                .fill(RidaryTheme.surface)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var mainPanel: some View {
        VStack(spacing: 0) {
            if let errorMessage {
                errorRow(errorMessage)
                    .padding(.bottom, 12)
            }

            statsRow

            permissionRow
                .padding(.top, 12)

            controlRow
                .padding(.top, 16)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statColumn(title: "distance", value: distanceValue)
            statDivider
            statColumn(title: "avg speed", value: averageSpeedValue)
            statDivider
            statColumn(title: "moments", value: momentsValue)
        }
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(RidaryTheme.textPrimary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(RidaryType.micro)
                .tracking(0.65)
                .textCase(.uppercase)
                .foregroundStyle(RidaryTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(RidaryTheme.border)
            .frame(width: 1, height: 30)
    }

    private var permissionRow: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(permissionColor)
                .frame(width: 6, height: 6)

            Text(permissionTitle)
                .font(RidaryType.caption)
                .foregroundStyle(RidaryTheme.textSecondary)

            Spacer(minLength: 8)

            if !isLocationAuthorized {
                Button("Settings") {
                    openSettings()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RidaryTheme.accent)
            }
        }
        .padding(.leading, 2)
    }

    private var controlRow: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                if capture.isRecording {
                    sideControl(
                        icon: "lock.shield.fill",
                        label: "Lock",
                        busy: lockBusy
                    ) {
                        lockLastWindow()
                    }
                    .accessibilityLabel("Lock last 30 seconds")
                } else {
                    sidePlaceholder
                }

                primaryControl

                if capture.isPaused {
                    sideControl(
                        icon: "stop.fill",
                        label: "Finish",
                        busy: finishBusy
                    ) {
                        finishRide()
                    }
                    .accessibilityLabel("Finish ride")
                } else {
                    sidePlaceholder
                }
            }
        }
    }

    private var primaryControl: some View {
        Button {
            primaryAction()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(RidaryTheme.skySoft)
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(.clear)
                        .frame(width: 80, height: 80)
                        .glassEffect(
                            .regular.tint(RidaryTheme.sky),
                            in: Circle()
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)

                    if primaryBusy {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: primaryIcon)
                            .font(.system(size: 23, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(primaryTitle)
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundStyle(RidaryTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(primaryBusy)
        .accessibilityLabel(primaryAccessibilityLabel)
    }

    private func primaryAction() {
        switch phase {
        case .countdown:
            cancelCountdown()
        case .starting, .finishing:
            return
        case .ready:
            if capture.isPaused {
                capture.resume()
            } else if capture.isRecording {
                capture.pause()
            } else {
                prepareAndCountdown()
            }
        }
    }

    private func sideControl(
        icon: String,
        label: String,
        busy: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(RidaryTheme.surface)
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(RidaryTheme.border, lineWidth: 1))

                    if busy {
                        ProgressView()
                            .tint(RidaryTheme.textSecondary)
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }

    private var sidePlaceholder: some View {
        VStack(spacing: 7) {
            Circle()
                .fill(Color.clear)
                .frame(width: 52, height: 52)

            Text(" ")
                .font(.system(size: 10, weight: .semibold, design: .default))
        }
        .frame(maxWidth: .infinity)
    }

    private var primaryBusy: Bool {
        isPreparing || phase == .starting || phase == .finishing
    }

    private var primaryIcon: String {
        if phase == .countdown {
            return "xmark"
        }
        if capture.isPaused || !capture.isRecording {
            return "play.fill"
        }
        return "pause.fill"
    }

    private var primaryTitle: String {
        if phase == .countdown {
            return "Cancel"
        }
        if phase == .starting {
            return "Starting"
        }
        if phase == .finishing {
            return "Saving"
        }
        if capture.isPaused {
            return "Resume"
        }
        if capture.isRecording {
            return "Pause"
        }
        return "Start"
    }

    private var primaryAccessibilityLabel: String {
        if phase == .countdown {
            return "Cancel"
        }
        if phase == .starting {
            return "Starting ride"
        }
        if phase == .finishing {
            return "Saving ride"
        }
        if capture.isPaused {
            return "Resume ride"
        }
        if capture.isRecording {
            return "Pause ride"
        }
        return "Start ride"
    }

    private func errorRow(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12, weight: .bold))
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(RidaryType.caption)
        .foregroundStyle(RidaryTheme.warning)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroIsDark: Bool { true }

    private var heroBackground: Color { RidaryTheme.sky }

    private var heroForeground: Color { .white }

    private var canChangeMode: Bool {
        phase == .ready && !capture.isRecording
    }

    private var activeMode: RideMode {
        capture.isRecording ? capture.currentMode : selectedMode
    }

    private var statusTitle: String {
        if phase == .finishing {
            return "Saving"
        }
        if capture.isPaused {
            return "Paused"
        }
        if capture.isRecording {
            return "Recording"
        }
        if phase == .countdown || phase == .starting {
            return "Starting"
        }
        return "Ready"
    }

    private var statusPulses: Bool {
        capture.isRecording || capture.isPaused
    }

    private var statusColor: Color {
        if phase == .finishing {
            return .white
        }
        if capture.isPaused {
            return RidaryTheme.warning
        }
        if capture.isRecording {
            return RidaryTheme.safety
        }
        return .white
    }

    private var traceTint: Color {
        if capture.isPaused || phase == .finishing {
            return RidaryTheme.warning
        }
        return .white
    }

    private var displayedTimer: String {
        if phase == .countdown {
            return "\(countdown)"
        }
        if capture.isRecording || phase == .finishing {
            return RidaryFormatters.duration(seconds: capture.elapsedS)
        }
        return "0:00"
    }

    private var timerLabel: String {
        if phase == .countdown {
            return "GET READY"
        }
        return "TIME"
    }

    private var timerAccessibilityLabel: String {
        if phase == .countdown {
            return "Starting in \(countdown)"
        }
        if capture.isRecording || phase == .finishing {
            return "Elapsed time \(RidaryFormatters.duration(seconds: capture.elapsedS))"
        }
        return "Timer at zero"
    }

    private var traceSamples: [Double] {
        capture.isRecording || phase == .finishing ? capture.speedHistory : []
    }

    private var showsLiveData: Bool {
        capture.isRecording || phase == .finishing
    }

    private var distanceValue: String {
        showsLiveData ? RidaryFormatters.distance(meters: capture.distanceM) : "0 m"
    }

    private var averageSpeedValue: String {
        guard showsLiveData, capture.elapsedS > 0 else {
            return "0 km/h"
        }
        return RidaryFormatters.speed(kph: capture.distanceM / capture.elapsedS * 3.6)
    }

    private var momentsValue: String {
        showsLiveData ? "\(capture.eventCount)" : "0"
    }

    private var isLocationAuthorized: Bool {
        capture.authorizationStatus == .authorizedWhenInUse ||
            capture.authorizationStatus == .authorizedAlways
    }

    private var permissionColor: Color {
        switch capture.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return RidaryTheme.accent
        case .notDetermined:
            return RidaryTheme.warning
        case .denied, .restricted:
            return RidaryTheme.safety
        @unknown default:
            return RidaryTheme.warning
        }
    }

    private var permissionTitle: String {
        switch capture.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return capture.isRecording ? "GPS active" : "Location ready"
        case .notDetermined:
            return "Location permission needed"
        case .denied, .restricted:
            return "Location is off"
        @unknown default:
            return "Location status unavailable"
        }
    }

    private func prepareAndCountdown() {
        guard !isPreparing, !capture.isRecording else { return }
        errorMessage = nil
        isPreparing = true

        prepareTask?.cancel()
        prepareTask = Task {
            let authorized = await capture.prepareForRecording()
            guard !Task.isCancelled else { return }
            isPreparing = false

            guard authorized else {
                errorMessage = "Location access is off. Enable it in Settings to start a ride."
                return
            }

            beginCountdown()
        }
    }

    private func beginCountdown() {
        errorMessage = nil
        phase = .countdown
        countdown = 3
        countdownTask?.cancel()

        countdownTask = Task {
            for value in stride(from: 3, through: 1, by: -1) {
                guard !Task.isCancelled else { return }
                countdown = value
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                try? await Task.sleep(for: .seconds(1))
            }

            guard !Task.isCancelled else { return }
            await startRide()
        }
    }

    private func cancelCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        countdown = 3
        phase = .ready
    }

    private func startRide() async {
        phase = .starting
        let started = await app.startRide(mode: selectedMode)

        guard started else {
            phase = .ready
            errorMessage = app.errorMessage ?? "Ride couldn't start. Try again."
            return
        }

        phase = .ready
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func finishRide() {
        guard capture.isPaused, !finishBusy else { return }
        finishBusy = true
        phase = .finishing
        errorMessage = nil

        Task {
            let ride = await app.stopRide()
            finishBusy = false

            guard ride != nil else {
                phase = .ready
                errorMessage = app.errorMessage ?? "Couldn't finish the ride. Try again."
                return
            }

            dismiss()
        }
    }

    private func lockLastWindow() {
        guard !lockBusy, capture.isRecording else { return }
        lockBusy = true
        errorMessage = nil

        Task {
            let created = await app.createIncident()
            lockBusy = false
            if let created {
                incident = created
            } else {
                errorMessage = app.errorMessage ?? "No ride samples are available to lock yet."
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct TopRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct RideSpeedTrace: View {
    let samples: [Double]
    let tint: Color
    var onDark: Bool = false

    var body: some View {
        Canvas { context, size in
            drawGrid(context: context, size: size)
            drawBaseline(context: context, size: size)

            guard !samples.isEmpty else {
                drawStartDot(context: context, size: size)
                return
            }

            guard (samples.max() ?? 0) > 0.1 else {
                drawLiveDot(context: context, size: size)
                return
            }

            let points = makePoints(size: size)
            let line = makeSmoothPath(points: points)
            drawArea(context: context, line: line, points: points, size: size)
            context.stroke(
                line,
                with: .color(tint),
                style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round)
            )
            drawEndDot(context: context, point: points.last)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Speed trace")
    }

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        for fraction in [0.25, 0.5, 0.75] {
            var path = Path()
            let y = size.height * fraction
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(
                path,
                with: .color(onDark ? Color.white.opacity(0.2) : RidaryTheme.border.opacity(0.72)),
                lineWidth: 0.75
            )
        }
    }

    private func drawBaseline(context: GraphicsContext, size: CGSize) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height - 1))
        path.addLine(to: CGPoint(x: size.width, y: size.height - 1))
        context.stroke(
            path,
            with: .color(onDark ? Color.white.opacity(0.34) : RidaryTheme.border),
            style: StrokeStyle(lineWidth: 1, dash: [3, 4])
        )
    }

    private func makePoints(size: CGSize) -> [CGPoint] {
        let capacity = 60
        let maxSpeed = max(20, samples.max() ?? 0)
        let verticalPadding = size.height * 0.08
        let horizontalInset: CGFloat = 18
        let graphWidth = max(1, size.width - horizontalInset * 2)

        return samples.enumerated().map { index, speed in
            let slot = CGFloat(index + capacity - samples.count)
            let x = horizontalInset + graphWidth * slot / CGFloat(capacity - 1)
            let normalized = min(1, max(0, speed / maxSpeed))
            let y = size.height - verticalPadding - CGFloat(normalized) * (size.height * 0.78)
            return CGPoint(x: x, y: y)
        }
    }

    private func makeSmoothPath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)

        guard points.count > 1 else { return path }

        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let midpoint = CGPoint(
                x: (previous.x + current.x) / 2,
                y: (previous.y + current.y) / 2
            )
            path.addQuadCurve(to: midpoint, control: previous)
        }

        if let last = points.last {
            path.addLine(to: last)
        }
        return path
    }

    private func drawArea(
        context: GraphicsContext,
        line: Path,
        points: [CGPoint],
        size: CGSize
    ) {
        guard let first = points.first, let last = points.last else { return }

        var area = line
        area.addLine(to: CGPoint(x: last.x, y: size.height))
        area.addLine(to: CGPoint(x: first.x, y: size.height))
        area.closeSubpath()

        context.fill(area, with: .color(tint.opacity(onDark ? 0.16 : 0.10)))
    }

    private func drawStartDot(context: GraphicsContext, size: CGSize) {
        let point = CGPoint(x: 3, y: size.height - 1)
        context.fill(
            Path(ellipseIn: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)),
            with: .color(onDark ? Color.white.opacity(0.55) : RidaryTheme.textTertiary)
        )
    }

    private func drawLiveDot(context: GraphicsContext, size: CGSize) {
        let point = CGPoint(x: size.width - 22, y: size.height - 12)
        context.fill(
            Path(ellipseIn: CGRect(x: point.x - 9, y: point.y - 9, width: 18, height: 18)),
            with: .color(tint.opacity(0.16))
        )
        context.fill(
            Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)),
            with: .color(tint)
        )
    }

    private func drawEndDot(context: GraphicsContext, point: CGPoint?) {
        guard let point else { return }

        context.fill(
            Path(ellipseIn: CGRect(x: point.x - 8, y: point.y - 8, width: 16, height: 16)),
            with: .color(tint.opacity(0.16))
        )
        context.fill(
            Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)),
            with: .color(tint)
        )
    }
}


private struct RideStatusDot: View {
    let color: Color
    let isPulsing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0,
                paused: !isPulsing || reduceMotion
            )
        ) { context in
            let phase = pulsePhase(at: context.date)

            ZStack {
                if isPulsing {
                    Circle()
                        .fill(color.opacity(0.30))
                        .frame(width: 16, height: 16)
                        .scaleEffect(0.8 + phase * 0.55)
                        .opacity(0.9 * (1 - phase))
                }

                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
                    .scaleEffect(isPulsing ? 1 - phase * 0.1 : 1)
            }
            .frame(width: 16, height: 16)
        }
        .accessibilityHidden(true)
    }

    private func pulsePhase(at date: Date) -> Double {
        guard isPulsing, !reduceMotion else { return 0 }
        let cycle = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: 0.9) / 0.9
        return (sin(cycle * .pi * 2 - .pi / 2) + 1) / 2
    }
}

private struct RideModeSheet: View {
    @Binding var selection: RideMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 8) {
                ForEach(RideMode.allCases) { mode in
                    let selected = selection == mode

                    Button {
                        selection = mode
                        UISelectionFeedbackGenerator().selectionChanged()
                        dismiss()
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(selected ? RidaryTheme.accent : RidaryTheme.textTertiary)
                                .frame(width: 38, height: 38)
                                .background(selected ? RidaryTheme.surface : RidaryTheme.backgroundLifted)
                                .clipShape(Circle())

                            Text(mode.title)
                                .font(.system(size: 15, weight: selected ? .semibold : .medium, design: .default))
                                .foregroundStyle(RidaryTheme.textPrimary)

                            Spacer()

                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(RidaryTheme.accent)
                                    .frame(width: 22, height: 22)
                                    .background(RidaryTheme.surface)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(selected ? RidaryTheme.skySoft : RidaryTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(
                                    selected ? RidaryTheme.sky.opacity(0.42) : RidaryTheme.border.opacity(0.82),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mode.title)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)
        }
        .background(RidaryTheme.surface)
        .presentationBackground(RidaryTheme.surface)
        .presentationDetents([.height(390)])
        .presentationDragIndicator(.visible)
    }
}
