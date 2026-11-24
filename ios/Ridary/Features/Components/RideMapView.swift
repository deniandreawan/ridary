import MapKit
import SwiftUI

struct RideMapMarker: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let number: Int
    let color: Color
}

struct RideMapView: View {
    let route: [[Double]]
    var height: CGFloat = 300
    var interactive = false
    var focus: CLLocationCoordinate2D?
    var focusRevision = 0
    var showsUserLocation = false
    var currentCoordinate: CLLocationCoordinate2D?
    var routeSegments: [[[Double]]] = []
    var followsLatest = false
    var followRevision = 0
    var followLatitudeDelta: CLLocationDegrees = 0.005
    var markers: [RideMapMarker] = []
    var onMarkerTap: ((UUID) -> Void)?

    @State private var cameraPosition: MapCameraPosition
    @State private var lastFollowAt = Date.distantPast

    init(
        route: [[Double]],
        height: CGFloat = 300,
        interactive: Bool = false,
        focus: CLLocationCoordinate2D? = nil,
        focusRevision: Int = 0,
        showsUserLocation: Bool = false,
        currentCoordinate: CLLocationCoordinate2D? = nil,
        routeSegments: [[[Double]]] = [],
        followsLatest: Bool = false,
        followRevision: Int = 0,
        followLatitudeDelta: CLLocationDegrees = 0.005,
        markers: [RideMapMarker] = [],
        onMarkerTap: ((UUID) -> Void)? = nil
    ) {
        self.route = route
        self.height = height
        self.interactive = interactive
        self.focus = focus
        self.focusRevision = focusRevision
        self.showsUserLocation = showsUserLocation
        self.currentCoordinate = currentCoordinate
        self.routeSegments = routeSegments
        self.followsLatest = followsLatest
        self.followRevision = followRevision
        self.followLatitudeDelta = followLatitudeDelta
        self.markers = markers
        self.onMarkerTap = onMarkerTap

        let coordinates = Self.coordinates(for: route)
            + routeSegments.flatMap(Self.coordinates(for:))
        _cameraPosition = State(
            initialValue: .region(Self.region(for: coordinates, focus: focus))
        )
    }

    private var coordinates: [CLLocationCoordinate2D] {
        Self.coordinates(for: route)
    }

    var body: some View {
        Map(
            position: $cameraPosition,
            interactionModes: interactive ? .all : []
        ) {
            if showsUserLocation {
                UserAnnotation()
            }

            if let currentCoordinate {
                Annotation("", coordinate: currentCoordinate) {
                    ZStack {
                        Circle()
                            .fill(RidaryTheme.sky.opacity(0.18))
                            .frame(width: 34, height: 34)

                        Circle()
                            .fill(RidaryTheme.surface)
                            .frame(width: 18, height: 18)
                            .shadow(color: .black.opacity(0.14), radius: 5, x: 0, y: 2)

                        Circle()
                            .fill(RidaryTheme.sky)
                            .frame(width: 12, height: 12)
                    }
                    .accessibilityLabel("Your location")
                }
            }

            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.white.opacity(0.95), lineWidth: 8)
                MapPolyline(coordinates: coordinates)
                    .stroke(RidaryTheme.sky, lineWidth: 4.5)
            }

            ForEach(Array(displayedRouteSegments.enumerated()), id: \.offset) { _, segment in
                let segmentCoordinates = Self.coordinates(for: segment)

                if segmentCoordinates.count > 1 {
                    MapPolyline(coordinates: segmentCoordinates)
                        .stroke(.white.opacity(0.95), lineWidth: 8)
                    MapPolyline(coordinates: segmentCoordinates)
                        .stroke(RidaryTheme.sky, lineWidth: 4.5)
                }
            }

            ForEach(markers) { marker in
                Annotation("", coordinate: marker.coordinate) {
                    Button {
                        onMarkerTap?(marker.id)
                    } label: {
                        Text("\(marker.number)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(marker.color)
                            .frame(width: 26, height: 26)
                            .background(RidaryTheme.surface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(marker.color.opacity(0.35), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Moment \(marker.number)")
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .frame(height: height)
        .onChange(of: focusRevision) { _, _ in
            guard let focus else { return }
            let delta = followsLatest ? followLatitudeDelta : 0.025
            withAnimation(.easeInOut(duration: 0.35)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: focus,
                        span: MKCoordinateSpan(
                            latitudeDelta: delta,
                            longitudeDelta: delta
                        )
                    )
                )
            }
        }
        .onChange(of: followRevision) { _, _ in
            followLatestPointIfNeeded()
        }
        .accessibilityLabel("Ride route map")
    }

    private var displayedRouteSegments: [[[Double]]] {
        guard let currentCoordinate,
              var lastSegment = routeSegments.last,
              let lastPair = lastSegment.last,
              lastPair.count == 2 else {
            return routeSegments
        }

        let moved = GeoMath.distanceMeters(
            latitude1: lastPair[0],
            longitude1: lastPair[1],
            latitude2: currentCoordinate.latitude,
            longitude2: currentCoordinate.longitude
        )
        guard moved > 0.5 else { return routeSegments }

        lastSegment.append([currentCoordinate.latitude, currentCoordinate.longitude])
        var segments = routeSegments
        segments[segments.count - 1] = lastSegment
        return segments
    }

    private var latestTrailCoordinate: CLLocationCoordinate2D? {
        if let currentCoordinate {
            return currentCoordinate
        }
        if let pair = routeSegments.last?.last, pair.count == 2 {
            return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
        }
        return nil
    }

    private func followLatestPointIfNeeded() {
        guard followsLatest else { return }

        let now = Date()
        guard now.timeIntervalSince(lastFollowAt) > 1.5 else { return }
        guard let latest = latestTrailCoordinate else { return }

        lastFollowAt = now
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: latest,
                    span: MKCoordinateSpan(
                        latitudeDelta: followLatitudeDelta,
                        longitudeDelta: followLatitudeDelta
                    )
                )
            )
        }
    }

    private static func coordinates(for route: [[Double]]) -> [CLLocationCoordinate2D] {
        route.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
        }
    }

    private static func region(
        for coordinates: [CLLocationCoordinate2D],
        focus: CLLocationCoordinate2D?
    ) -> MKCoordinateRegion {
        if let focus {
            return MKCoordinateRegion(
                center: focus,
                span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
            )
        }

        guard let first = coordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
                span: MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
            )
        }

        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let minLat = lats.min() ?? first.latitude
        let maxLat = lats.max() ?? first.latitude
        let minLon = lons.min() ?? first.longitude
        let maxLon = lons.max() ?? first.longitude

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max(0.006, (maxLat - minLat) * 2.2),
                longitudeDelta: max(0.006, (maxLon - minLon) * 2.2)
            )
        )
    }
}
