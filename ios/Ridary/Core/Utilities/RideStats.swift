import Foundation

struct RideStats: Sendable {
    let distanceM: Double
    let durationS: Double
    let avgSpeedKph: Double
    let maxSpeedKph: Double
    let routePreview: [[Double]]
    let geohash: String
}

enum RideStatsCalculator {
    static func compute(
        samples: [SensorSample],
        startedAt: Date,
        endedAt: Date,
        mode: RideMode,
        pausedDurationS: TimeInterval = 0
    ) -> RideStats {
        let durationS = max(0, endedAt.timeIntervalSince(startedAt) - pausedDurationS)
        let locationSamples = samples.filter(\.hasLocation)

        var distanceM = 0.0
        var previous: SensorSample?
        for sample in locationSamples {
            guard let lat = sample.latitude, let lon = sample.longitude else { continue }
            if let previous,
               let prevLat = previous.latitude,
               let prevLon = previous.longitude {
                distanceM += GeoMath.distanceMeters(
                    latitude1: prevLat,
                    longitude1: prevLon,
                    latitude2: lat,
                    longitude2: lon
                )
            }
            previous = sample
        }

        let maxSpeedKph = samples.compactMap(\.speedKph).max() ?? 0
        let avgSpeedKph = durationS > 0 ? (distanceM / durationS) * 3.6 : 0

        let preview: [[Double]]
        if locationSamples.isEmpty {
            preview = []
        } else {
            let stride = max(1, locationSamples.count / 128)
            var points: [[Double]] = []
            for index in Swift.stride(from: 0, to: locationSamples.count, by: stride) {
                let sample = locationSamples[index]
                if let lat = sample.latitude, let lon = sample.longitude {
                    points.append([lat, lon])
                }
            }
            if let last = locationSamples.last,
               let lat = last.latitude,
               let lon = last.longitude,
               points.last != [lat, lon],
               points.count < 128 {
                points.append([lat, lon])
            }
            preview = points
        }

        let geohash: String
        if let first = locationSamples.first,
           let lat = first.latitude,
           let lon = first.longitude,
           let hash = Geohash.encode(latitude: lat, longitude: lon) {
            geohash = hash
        } else {
            geohash = "s00000"
        }

        _ = mode
        return RideStats(
            distanceM: distanceM,
            durationS: durationS,
            avgSpeedKph: avgSpeedKph,
            maxSpeedKph: maxSpeedKph,
            routePreview: preview,
            geohash: geohash
        )
    }
}
