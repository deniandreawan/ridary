import MapKit
import UIKit

@MainActor
final class RideMapSnapshotService {
    static let shared = RideMapSnapshotService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let directory: URL?
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    private init(fileManager: FileManager = .default) {
        memoryCache.countLimit = 128
        memoryCache.totalCostLimit = 8 * 1024 * 1024

        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        let dir = base?.appendingPathComponent("RideThumbnails", isDirectory: true)
        if let dir {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        directory = dir
    }

    func image(for ride: Ride, size: CGSize, scale: CGFloat) async -> UIImage? {
        let coordinates = Self.coordinates(for: ride.routePreview)
        guard coordinates.count > 1 else { return nil }

        let key = cacheKey(
            for: ride,
            size: size,
            scale: scale
        )
        let cacheKey = key as NSString

        if let cached = memoryCache.object(forKey: cacheKey) {
            return cached
        }

        if let diskImage = loadFromDisk(key: key) {
            memoryCache.setObject(
                diskImage,
                forKey: cacheKey,
                cost: cost(for: diskImage)
            )
            return diskImage
        }

        if let existing = inFlight[key] {
            return await existing.value
        }

        let task = Task { [weak self] in
            await self?.generateImage(
                key: key,
                coordinates: coordinates,
                size: size,
                scale: scale
            )
        }
        inFlight[key] = task
        let image = await task.value
        inFlight[key] = nil

        if let image {
            memoryCache.setObject(
                image,
                forKey: cacheKey,
                cost: cost(for: image)
            )
            saveToDisk(image, key: key)
        }

        return image
    }

    private func generateImage(
        key: String,
        coordinates: [CLLocationCoordinate2D],
        size: CGSize,
        scale: CGFloat
    ) async -> UIImage? {
        let options = MKMapSnapshotter.Options()
        options.mapRect = Self.mapRect(for: coordinates, size: size)
        options.size = size
        options.traitCollection = UITraitCollection(displayScale: scale)

        let configuration = MKStandardMapConfiguration(elevationStyle: .flat)
        options.preferredConfiguration = configuration

        let snapshotter = MKMapSnapshotter(options: options)
        let snapshot: MKMapSnapshotter.Snapshot
        do {
            snapshot = try await withCheckedThrowingContinuation { continuation in
                snapshotter.start { snapshot, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let snapshot {
                        continuation.resume(returning: snapshot)
                    } else {
                        continuation.resume(throwing: SnapshotError.empty)
                    }
                }
            }
        } catch {
            return nil
        }

        return draw(
            snapshot: snapshot,
            coordinates: coordinates,
            size: size,
            scale: scale
        )
    }

    private func draw(
        snapshot: MKMapSnapshotter.Snapshot,
        coordinates: [CLLocationCoordinate2D],
        size: CGSize,
        scale: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let bounds = CGRect(origin: .zero, size: size)
            snapshot.image.draw(in: bounds)

            let points = coordinates.map { snapshot.point(for: $0) }
            guard let first = points.first, points.count > 1 else {
                return
            }

            let path = UIBezierPath()
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }

            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)

            let lineScale = max(1, size.height / 60)

            UIColor.white.withAlphaComponent(0.95).setStroke()
            path.lineWidth = 4 * lineScale
            path.stroke()

            UIColor(red: 0, green: 132 / 255, blue: 209 / 255, alpha: 1).setStroke()
            path.lineWidth = 2.5 * lineScale
            path.stroke()
        }
    }

    private func cacheKey(for ride: Ride, size: CGSize, scale: CGFloat) -> String {
        let dimensions = "\(Int(size.width))x\(Int(size.height))@\(String(format: "%.2f", scale))"
        let fingerprint = Self.fingerprint(ride.routePreview)
        return "v6-\(ride.id.uuidString)-\(dimensions)-\(String(fingerprint, radix: 16))"
    }

    private func loadFromDisk(key: String) -> UIImage? {
        guard let directory else { return nil }
        let url = directory.appendingPathComponent(key).appendingPathExtension("png")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func saveToDisk(_ image: UIImage, key: String) {
        guard let directory, let data = image.pngData() else { return }
        let url = directory.appendingPathComponent(key).appendingPathExtension("png")
        try? data.write(to: url, options: .atomic)
    }

    private func cost(for image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }

    private static func coordinates(for route: [[Double]]) -> [CLLocationCoordinate2D] {
        route.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
        }
    }

    private static func mapRect(
        for coordinates: [CLLocationCoordinate2D],
        size: CGSize
    ) -> MKMapRect {
        let points = coordinates.map(MKMapPoint.init)
        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 0

        var rect = MKMapRect(
            x: minX,
            y: minY,
            width: max(maxX - minX, 1),
            height: max(maxY - minY, 1)
        )

        let padding = max(rect.width, rect.height) * 0.35
        rect = rect.insetBy(dx: -padding, dy: -padding)

        let targetAspect = size.width / size.height
        if rect.width / rect.height < targetAspect {
            let width = rect.height * targetAspect
            rect = MKMapRect(
                x: rect.midX - width / 2,
                y: rect.origin.y,
                width: width,
                height: rect.height
            )
        } else {
            let height = rect.width / targetAspect
            rect = MKMapRect(
                x: rect.origin.x,
                y: rect.midY - height / 2,
                width: rect.width,
                height: height
            )
        }

        return rect
    }

    private static func fingerprint(_ route: [[Double]]) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for pair in route {
            for value in pair {
                var bits = value.bitPattern
                withUnsafeBytes(of: &bits) { bytes in
                    for byte in bytes {
                        hash ^= UInt64(byte)
                        hash &*= 1_099_511_628_211
                    }
                }
            }
        }
        return hash
    }
}

private enum SnapshotError: Error {
    case empty
}
