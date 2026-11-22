import SwiftUI
import UIKit

struct RideThumbnailView: View {
    let ride: Ride
    var width: CGFloat = 80
    var height: CGFloat = 60

    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            RidaryRouteArt(route: ride.routePreview, lineColor: RidaryTheme.route)
                .frame(width: width, height: height)
                .background(RidaryTheme.skySoft)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .transition(.opacity)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .animation(.easeOut(duration: 0.2), value: image != nil)
        .task(id: ride.id) {
            image = nil
            let pixelSize = CGSize(
                width: width * displayScale,
                height: height * displayScale
            )
            let loaded = await RideMapSnapshotService.shared.image(
                for: ride,
                size: pixelSize,
                scale: 1
            )
            guard !Task.isCancelled else { return }
            image = loaded
        }
        .accessibilityHidden(true)
    }
}
