import Combine
import CoreLocation
import CoreMotion
import Foundation

enum CaptureError: LocalizedError {
    case locationServicesDisabled
    case locationDenied
    case alreadyRecording
    case notRecording
    case noData
    case motionUnavailable

    var errorDescription: String? {
        switch self {
        case .locationServicesDisabled:
            return "Location services are off. Turn them on to record a ride."
        case .locationDenied:
            return "Ridary needs location access while a ride is active. Enable it in Settings."
        case .alreadyRecording:
            return "A ride is already being recorded."
        case .notRecording:
            return "There is no active ride to stop."
        case .noData:
            return "This ride did not capture enough data."
        case .motionUnavailable:
            return "Motion sensors are unavailable on this device. Route capture will continue."
        }
    }
}

private struct MotionSnapshot: Sendable {
    let timestamp: Date
    let accelX: Double
    let accelY: Double
    let accelZ: Double
    let gyroX: Double
    let gyroY: Double
    let gyroZ: Double
}

private struct LocationSnapshot: Sendable {
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let speedMps: Double?
    let horizontalAccuracy: Double
}

@MainActor
final class RideCaptureService: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var isPaused = false
    @Published private(set) var startedAt: Date?
    @Published private(set) var elapsedS: TimeInterval = 0
    @Published private(set) var distanceM: Double = 0
    @Published private(set) var currentSpeedKph: Double = 0
    @Published private(set) var sampleCount: Int = 0
    @Published private(set) var eventCount: Int = 0
    @Published private(set) var lastEventTitle: String?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var errorMessage: String?
    @Published private(set) var isMotionActive = false
    @Published private(set) var liveRouteSegments: [[[Double]]] = []
    @Published private(set) var liveRouteRevision = 0
    @Published private(set) var liveCoordinate: CLLocationCoordinate2D?
    @Published private(set) var speedHistory: [Double] = []

    private let store: LocalRideStore
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var timer: Timer?
    private var samples: [SensorSample] = []
    private var events: [RideEvent] = []
    private var detector = EventDetector()
    private var thresholds = EventThresholds.default
    private var rideID = UUID()
    private var mode: RideMode = .motorcycle
    private var lastLocation: LocationSnapshot?
    private var lastMotion: MotionSnapshot?
    private var liveTrail = LiveRouteTrail()
    private var pausedAt: Date?
    private var pausedDurationS: TimeInterval = 0
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    init(store: LocalRideStore) {
        self.store = store
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        authorizationStatus = locationManager.authorizationStatus
    }

    var currentRideID: UUID { rideID }
    var currentMode: RideMode { mode }

    func prepareForRecording() async -> Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }
        let status = await ensureAuthorization()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    func start(mode: RideMode, thresholds: EventThresholds) async throws {
        guard !isRecording else {
            throw CaptureError.alreadyRecording
        }

        guard CLLocationManager.locationServicesEnabled() else {
            throw CaptureError.locationServicesDisabled
        }

        let status = await ensureAuthorization()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw CaptureError.locationDenied
        }

        self.mode = mode
        self.thresholds = thresholds
        self.detector = EventDetector(thresholds: thresholds)
        self.rideID = UUID()
        self.samples = []
        self.events = []
        self.lastLocation = nil
        self.lastMotion = nil
        self.distanceM = 0
        self.currentSpeedKph = 0
        self.sampleCount = 0
        self.eventCount = 0
        self.lastEventTitle = nil
        self.errorMessage = nil
        self.startedAt = Date()
        self.elapsedS = 0
        self.isRecording = true
        self.isPaused = false
        self.pausedAt = nil
        self.pausedDurationS = 0
        self.liveTrail.reset()
        self.liveRouteSegments = liveTrail.segments
        self.liveRouteRevision = liveTrail.revision
        self.liveCoordinate = nil
        self.speedHistory = []

        locationManager.activityType = activityType(for: mode)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()

        startMotion()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshElapsed()
            }
        }

        if let startedAt {
            try? await store.saveActiveSession(
                ActiveSession(rideID: rideID, mode: mode, startedAt: startedAt)
            )
        }
    }

    func pause() {
        guard isRecording, !isPaused else { return }
        isPaused = true
        pausedAt = Date()
        refreshElapsed()
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        motionManager.stopDeviceMotionUpdates()
        isMotionActive = false
    }

    func resume() {
        guard isRecording, isPaused else { return }
        if let pausedAt {
            pausedDurationS += Date().timeIntervalSince(pausedAt)
        }
        self.pausedAt = nil
        isPaused = false

        lastLocation = nil
        lastMotion = nil
        liveTrail.breakSegment()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        startMotion()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshElapsed()
            }
        }
        refreshElapsed()
    }

    func stop() async throws -> Ride {
        guard isRecording else {
            throw CaptureError.notRecording
        }

        isRecording = false
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        motionManager.stopDeviceMotionUpdates()
        isMotionActive = false

        let endedAt = Date()
        guard let startedAt else {
            throw CaptureError.noData
        }

        let currentPause = pausedAt.map { endedAt.timeIntervalSince($0) } ?? 0
        let totalPausedS = pausedDurationS + currentPause
        isPaused = false
        pausedAt = nil
        pausedDurationS = 0

        let stats = RideStatsCalculator.compute(
            samples: samples,
            startedAt: startedAt,
            endedAt: endedAt,
            mode: mode,
            pausedDurationS: totalPausedS
        )
        let score = RideScoring.rideScore(events: events)
        let ride = Ride(
            id: rideID,
            mode: mode,
            startedAt: startedAt,
            endedAt: endedAt,
            distanceM: stats.distanceM,
            durationS: stats.durationS,
            avgSpeedKph: stats.avgSpeedKph,
            maxSpeedKph: stats.maxSpeedKph,
            score: score,
            summary: "Ride captured. Your private snapshot is ready to generate.",
            inferenceSource: .deterministic,
            geohash: stats.geohash,
            routePreview: stats.routePreview,
            events: events.sorted { $0.occurredAt < $1.occurredAt },
            snapshot: nil,
            createdAt: Date(),
            schemaVersion: 1
        )

        samples = []
        events = []
        liveTrail.reset()
        liveRouteSegments = liveTrail.segments
        liveRouteRevision = liveTrail.revision
        liveCoordinate = nil
        await store.clearActiveSession()
        return ride
    }

    func lockLastWindow(seconds: TimeInterval = 30) -> RideEvent? {
        guard isRecording, !samples.isEmpty else {
            return nil
        }

        let count = max(10, Int(seconds * 10))
        let window = Array(samples.suffix(count))
        guard let last = window.last else {
            return nil
        }

        let geohash = geohash(for: last) ?? lastEventGeohash() ?? "s00000"
        let event = RideEvent(
            id: UUID(),
            rideID: rideID,
            type: .manual,
            severity: 2,
            confidence: 1.0,
            occurredAt: Date(),
            geohash: geohash,
            summary: "Manual evidence lock. The last \(Int(seconds)) seconds were preserved.",
            source: .deterministic,
            window: window
        )
        events.append(event)
        eventCount = events.count
        lastEventTitle = event.type.title
        return event
    }

    func refreshElapsed() {
        guard let startedAt else { return }
        let reference = pausedAt ?? Date()
        elapsedS = max(0, reference.timeIntervalSince(startedAt) - pausedDurationS)

        guard isRecording, !isPaused else { return }
        speedHistory.append(currentSpeedKph)
        if speedHistory.count > 60 {
            speedHistory.removeFirst(speedHistory.count - 60)
        }
    }

    private func ensureAuthorization() async -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        authorizationStatus = status

        if status != .notDetermined {
            return status
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func startMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            isMotionActive = false
            errorMessage = CaptureError.motionUnavailable.localizedDescription
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            let snapshot = motion.map {
                MotionSnapshot(
                    timestamp: Date(),
                    accelX: $0.userAcceleration.x,
                    accelY: $0.userAcceleration.y,
                    accelZ: $0.userAcceleration.z,
                    gyroX: $0.rotationRate.x,
                    gyroY: $0.rotationRate.y,
                    gyroZ: $0.rotationRate.z
                )
            }
            let message = error?.localizedDescription
            Task { @MainActor in
                self?.isMotionActive = snapshot != nil
                self?.handleMotion(snapshot, error: message)
            }
        }
        isMotionActive = true
    }

    private func handleMotion(_ snapshot: MotionSnapshot?, error: String?) {
        if snapshot == nil, error != nil {
            errorMessage = CaptureError.motionUnavailable.localizedDescription
        }
        if let snapshot {
            lastMotion = snapshot
            appendSample(timestamp: snapshot.timestamp)
        }
    }

    private func handleLocations(_ snapshots: [LocationSnapshot]) {
        guard let latest = snapshots.last else { return }

        var trailChanged = false
        for snapshot in snapshots {
            if let previous = lastLocation {
                distanceM += GeoMath.distanceMeters(
                    latitude1: previous.latitude,
                    longitude1: previous.longitude,
                    latitude2: snapshot.latitude,
                    longitude2: snapshot.longitude
                )
            }
            lastLocation = snapshot
            if liveTrail.append(
                latitude: snapshot.latitude,
                longitude: snapshot.longitude
            ) {
                trailChanged = true
            }
        }
        if trailChanged {
            liveRouteSegments = liveTrail.segments
            liveRouteRevision = liveTrail.revision
        }
        liveCoordinate = CLLocationCoordinate2D(
            latitude: latest.latitude,
            longitude: latest.longitude
        )

        if latest.speedMps != nil {
            currentSpeedKph = max(0, (latest.speedMps ?? 0) * 3.6)
        }

        if !isMotionActive {
            appendSample(timestamp: latest.timestamp)
        }
    }

    private func appendSample(timestamp: Date) {
        let motion = lastMotion
        let sample = SensorSample(
            timestamp: timestamp,
            latitude: lastLocation?.latitude,
            longitude: lastLocation?.longitude,
            altitude: lastLocation?.altitude,
            speedMps: lastLocation?.speedMps,
            horizontalAccuracy: lastLocation?.horizontalAccuracy,
            accelX: motion?.accelX ?? 0,
            accelY: motion?.accelY ?? 0,
            accelZ: motion?.accelZ ?? 0,
            gyroX: motion?.gyroX ?? 0,
            gyroY: motion?.gyroY ?? 0,
            gyroZ: motion?.gyroZ ?? 0
        )

        samples.append(sample)
        if samples.count > 80_000 {
            samples.removeFirst(samples.count - 80_000)
        }
        sampleCount = samples.count
        if let speed = sample.speedKph {
            currentSpeedKph = speed
        }

        let detected = detector.process(sample)
        for event in detected {
            let windowCount = max(10, Int(thresholds.sampleWindowSeconds * 10))
            let window = Array(samples.suffix(windowCount))
            guard let geohash = geohash(for: sample) ?? lastEventGeohash() else {
                continue
            }
            let rideEvent = RideEvent(
                id: UUID(),
                rideID: rideID,
                type: event.type,
                severity: event.severity,
                confidence: event.confidence,
                occurredAt: event.occurredAt,
                geohash: geohash,
                summary: event.summary,
                source: .deterministic,
                window: window
            )
            events.append(rideEvent)
            eventCount = events.count
            lastEventTitle = rideEvent.type.title
        }
    }

    private func geohash(for sample: SensorSample) -> String? {
        guard let latitude = sample.latitude, let longitude = sample.longitude else {
            return nil
        }
        return Geohash.encode(latitude: latitude, longitude: longitude)
    }

    private func lastEventGeohash() -> String? {
        events.last?.geohash
    }

    private func activityType(for mode: RideMode) -> CLActivityType {
        switch mode {
        case .motorcycle, .car:
            return .automotiveNavigation
        case .bicycle, .running:
            return .fitness
        case .transit:
            return .other
        }
    }
}

extension RideCaptureService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if let continuation = self.authorizationContinuation {
                self.authorizationContinuation = nil
                continuation.resume(returning: status)
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let snapshots = locations.map { location in
            LocationSnapshot(
                timestamp: location.timestamp,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                speedMps: location.speed >= 0 ? location.speed : nil,
                horizontalAccuracy: location.horizontalAccuracy
            )
        }
        Task { @MainActor in
            self.handleLocations(snapshots)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        guard let clError = error as? CLError else { return }

        switch clError.code {
        case .locationUnknown:
            return
        case .denied:
            Task { @MainActor in
                self.errorMessage = CaptureError.locationDenied.localizedDescription
            }
        default:
            return
        }
    }
}
