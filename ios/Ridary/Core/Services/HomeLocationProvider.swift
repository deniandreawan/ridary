import Combine
import CoreLocation
import Foundation
import MapKit

@MainActor
final class HomeLocationProvider: NSObject, ObservableObject {
    @Published private(set) var label: String
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var isLocating = false
    @Published private(set) var revision = 0

    private let manager = CLLocationManager()
    private let defaults: UserDefaults
    private var hasStarted = false
    private var lastGeocodedLocation: CLLocation?
    private var geocodeTask: Task<Void, Never>?

    private static let labelKey = "ridary.homeLocationLabel"
    private static let latitudeKey = "ridary.homeLocationLatitude"
    private static let longitudeKey = "ridary.homeLocationLongitude"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let latitude = defaults.object(forKey: Self.latitudeKey) as? Double
        let longitude = defaults.object(forKey: Self.longitudeKey) as? Double
        let cachedCoordinate: CLLocationCoordinate2D?
        if let latitude, let longitude {
            cachedCoordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
        } else {
            cachedCoordinate = nil
        }

        self.coordinate = cachedCoordinate
        self.label = cachedCoordinate == nil
            ? "Your area"
            : (defaults.string(forKey: Self.labelKey) ?? "Your area")
        self.authorizationStatus = .notDetermined
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        updateAuthorization(manager.authorizationStatus)
    }

    func requestCurrentLocation() {
        updateAuthorization(manager.authorizationStatus)
    }

    private func updateAuthorization(_ status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            requestOneShot()
        case .denied, .restricted:
            isLocating = false
        @unknown default:
            isLocating = false
        }
    }

    private func requestOneShot() {
        guard CLLocationManager.locationServicesEnabled() else {
            isLocating = false
            return
        }

        isLocating = true
        manager.requestLocation()
    }

    private func handleLocation(_ location: CLLocation) {
        isLocating = false
        coordinate = location.coordinate
        revision += 1

        let coarseLatitude = (location.coordinate.latitude * 100).rounded() / 100
        let coarseLongitude = (location.coordinate.longitude * 100).rounded() / 100
        defaults.set(coarseLatitude, forKey: Self.latitudeKey)
        defaults.set(coarseLongitude, forKey: Self.longitudeKey)

        if let lastGeocodedLocation,
           lastGeocodedLocation.distance(from: location) < 500 {
            return
        }
        lastGeocodedLocation = location

        geocodeTask?.cancel()
        geocodeTask = Task { [weak self] in
            await self?.reverseGeocode(location)
        }
    }

    private func reverseGeocode(_ location: CLLocation) async {
        do {
            guard let request = MKReverseGeocodingRequest(location: location) else {
                return
            }
            let items = try await request.mapItems
            guard !Task.isCancelled else { return }

            let name = items.first?.addressRepresentations?.cityName
            let city = name?.trimmingCharacters(in: .whitespacesAndNewlines)

            guard let city, !city.isEmpty else { return }
            label = city
            defaults.set(city, forKey: Self.labelKey)
        } catch {
            // Keep the cached label. Home should never block on geocoding.
        }
    }
}

extension HomeLocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.updateAuthorization(status)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.handleLocation(location)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError _: Error
    ) {
        Task { @MainActor in
            self.isLocating = false
        }
    }
}
