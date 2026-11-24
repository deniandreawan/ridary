import CoreLocation
import Foundation

struct LiveRouteTrail: Equatable, Sendable {
    private(set) var segments: [[[Double]]] = []
    private(set) var revision = 0

    var minimumSpacingMeters: Double = 4
    var maximumPoints: Int = 600

    private var lastLatitude: Double?
    private var lastLongitude: Double?
    private var startsNewSegment = true

    var totalPointCount: Int {
        segments.reduce(0) { $0 + $1.count }
    }

    var lastCoordinate: CLLocationCoordinate2D? {
        guard let pair = segments.last?.last, pair.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
    }

    mutating func reset() {
        segments = []
        lastLatitude = nil
        lastLongitude = nil
        startsNewSegment = true
        revision += 1
    }

    mutating func breakSegment() {
        lastLatitude = nil
        lastLongitude = nil
        startsNewSegment = true
    }

    @discardableResult
    mutating func append(latitude: Double, longitude: Double) -> Bool {
        if let lastLatitude, let lastLongitude {
            let moved = GeoMath.distanceMeters(
                latitude1: lastLatitude,
                longitude1: lastLongitude,
                latitude2: latitude,
                longitude2: longitude
            )
            guard moved >= minimumSpacingMeters else { return false }
        }

        let pair = [latitude, longitude]
        if startsNewSegment || segments.isEmpty {
            segments.append([pair])
            startsNewSegment = false
        } else {
            segments[segments.count - 1].append(pair)
        }

        lastLatitude = latitude
        lastLongitude = longitude
        trimIfNeeded()
        revision += 1
        return true
    }

    private mutating func trimIfNeeded() {
        var excess = totalPointCount - maximumPoints
        guard excess > 0 else { return }

        while excess > 0, !segments.isEmpty {
            let firstCount = segments[0].count
            if firstCount <= excess {
                excess -= firstCount
                segments.removeFirst()
            } else {
                segments[0].removeFirst(excess)
                excess = 0
            }
        }
    }
}
