import SwiftUI

struct RidaryRouteArt: View {
    let route: [[Double]]
    var lineColor: Color = RidaryTheme.accent
    var lineWidth: CGFloat = 3
    var showsEndpoints = true

    private var normalizedRoute: [CGPoint] {
        route.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return CGPoint(x: pair[1], y: pair[0])
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if normalizedRoute.count < 2 {
                fallback(in: geometry.size)
            } else {
                Canvas { context, size in
                    let points = normalized(normalizedRoute, in: size)
                    guard let first = points.first, let last = points.last else {
                        return
                    }

                    var path = Path()
                    path.move(to: first)
                    if points.count > 2 {
                        for index in 1..<(points.count - 1) {
                            let current = points[index]
                            let next = points[index + 1]
                            let midpoint = CGPoint(
                                x: (current.x + next.x) / 2,
                                y: (current.y + next.y) / 2
                            )
                            path.addQuadCurve(to: midpoint, control: current)
                        }
                    }
                    path.addLine(to: last)

                    context.stroke(
                        path,
                        with: .color(lineColor.opacity(0.24)),
                        style: StrokeStyle(
                            lineWidth: lineWidth + 7,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [lineColor, lineColor.opacity(0.72)]),
                            startPoint: first,
                            endPoint: last
                        ),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                    if showsEndpoints {
                        context.fill(
                            Path(ellipseIn: CGRect(x: first.x - 4, y: first.y - 4, width: 8, height: 8)),
                            with: .color(lineColor)
                        )
                        context.fill(
                            Path(ellipseIn: CGRect(x: last.x - 5, y: last.y - 5, width: 10, height: 10)),
                            with: .color(RidaryTheme.onAccent)
                        )
                        context.fill(
                            Path(ellipseIn: CGRect(x: last.x - 3, y: last.y - 3, width: 6, height: 6)),
                            with: .color(lineColor)
                        )
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func normalized(_ points: [CGPoint], in size: CGSize) -> [CGPoint] {
        let inset: CGFloat = 14
        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 1
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 1
        let width = max(maxX - minX, 0.00001)
        let height = max(maxY - minY, 0.00001)
        let scale = min(
            (size.width - inset * 2) / width,
            (size.height - inset * 2) / height
        )
        let offsetX = (size.width - width * scale) / 2
        let offsetY = (size.height - height * scale) / 2

        return points.map { point in
            CGPoint(
                x: offsetX + (point.x - minX) * scale,
                y: offsetY + (point.y - minY) * scale
            )
        }
    }

    private func fallback(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    RidaryTheme.accentSoft,
                    RidaryTheme.skySoft
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Path { path in
                path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.74))
                path.addCurve(
                    to: CGPoint(x: size.width * 0.86, y: size.height * 0.28),
                    control1: CGPoint(x: size.width * 0.34, y: size.height * 0.96),
                    control2: CGPoint(x: size.width * 0.62, y: size.height * 0.06)
                )
            }
            .stroke(
                RidaryTheme.textTertiary.opacity(0.32),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 8])
            )
            .padding(18)
        }
    }
}
