import MapKit
import SwiftUI

struct RideMapView: View {
    let route: [[Double]]
    var height: CGFloat = 300
    var interactive = false
    var focus: CLLocationCoordinate2D?
    var focusRevision = 0
    var showsUserLocation = false

    @State private var cameraPosition: MapCameraPosition

    init(
        route: [[Double]],
        height: CGFloat = 300,
        interactive: Bool = false,
        focus: CLLocationCoordinate2D? = nil,
        focusRevision: Int = 0,
        showsUserLocation: Bool = false
    ) {
        self.route = route
        self.height = height
        self.interactive = interactive
        self.focus = focus
        self.focusRevision = focusRevision
        self.showsUserLocation = showsUserLocation

        let coordinates = Self.coordinates(for: route)
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

            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.white.opacity(0.95), lineWidth: 9)
                MapPolyline(coordinates: coordinates)
                    .stroke(RidaryTheme.route, lineWidth: 5)
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .frame(height: height)
        .onChange(of: focusRevision) { _, _ in
            guard let focus else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                cameraPosition = .region(Self.region(for: coordinates, focus: focus))
            }
        }
        .accessibilityLabel("Ride route map")
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
