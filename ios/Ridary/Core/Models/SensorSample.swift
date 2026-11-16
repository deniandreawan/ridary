import Foundation

struct SensorSample: Codable, Sendable {
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let speedMps: Double?
    let horizontalAccuracy: Double?
    let accelX: Double
    let accelY: Double
    let accelZ: Double
    let gyroX: Double
    let gyroY: Double
    let gyroZ: Double

    var speedKph: Double? {
        guard let speedMps else { return nil }
        return max(0, speedMps * 3.6)
    }

    var accelMagnitudeG: Double {
        sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ)
    }

    var lateralAccelG: Double {
        sqrt(accelX * accelX + accelY * accelY)
    }

    var gyroMagnitude: Double {
        sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ)
    }

    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
}
