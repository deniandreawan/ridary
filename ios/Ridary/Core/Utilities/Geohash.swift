import Foundation

enum Geohash {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")

    static func encode(
        latitude: Double,
        longitude: Double,
        precision: Int = 6
    ) -> String? {
        guard latitude.isFinite, latitude >= -90, latitude <= 90,
              longitude.isFinite, longitude >= -180, longitude <= 180,
              precision >= 1, precision <= 12 else {
            return nil
        }

        var latMin = -90.0
        var latMax = 90.0
        var lonMin = -180.0
        var lonMax = 180.0
        var hash = ""
        var bits = 0
        var bitValue = 0
        var even = true

        while hash.count < precision {
            if even {
                let mid = (lonMin + lonMax) / 2
                if longitude >= mid {
                    bitValue = bitValue * 2 + 1
                    lonMin = mid
                } else {
                    bitValue *= 2
                    lonMax = mid
                }
            } else {
                let mid = (latMin + latMax) / 2
                if latitude >= mid {
                    bitValue = bitValue * 2 + 1
                    latMin = mid
                } else {
                    bitValue *= 2
                    latMax = mid
                }
            }

            even.toggle()

            if bits < 4 {
                bits += 1
            } else {
                hash.append(base32[bitValue])
                bits = 0
                bitValue = 0
            }
        }

        return hash
    }
}
