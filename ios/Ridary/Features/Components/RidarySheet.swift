import SwiftUI

enum RidarySheetDetent: Int, CaseIterable, Sendable {
    case peek
    case medium
    case full
}

enum RidarySheetMetrics {
    static func height(
        for detent: RidarySheetDetent,
        container: CGFloat,
        topInset: CGFloat = 0
    ) -> CGFloat {
        switch detent {
        case .peek:
            return 118
        case .medium:
            return min(580, max(340, container * 0.44))
        case .full:
            return max(420, container - 8)
        }
    }
}

struct RidarySheet<Header: View, Content: View>: View {
    @Binding var detent: RidarySheetDetent
    let containerHeight: CGFloat
    let topInset: CGFloat
    let header: Header
    let content: Content

    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var canCollapseFromFullScroll: Bool?

    private var sheetSpring: Animation {
        .spring(response: 0.42, dampingFraction: 0.88)
    }

    init(
        detent: Binding<RidarySheetDetent>,
        containerHeight: CGFloat,
        topInset: CGFloat = 0,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        _detent = detent
        self.containerHeight = containerHeight
        self.topInset = topInset
        self.header = header()
        self.content = content()
    }

    private var peekHeight: CGFloat {
        RidarySheetMetrics.height(for: .peek, container: containerHeight, topInset: topInset)
    }

    private var fullHeight: CGFloat {
        RidarySheetMetrics.height(for: .full, container: containerHeight, topInset: topInset)
    }

    private var baseHeight: CGFloat {
        RidarySheetMetrics.height(for: detent, container: containerHeight, topInset: topInset)
    }

    private var displayedHeight: CGFloat {
        min(fullHeight, max(peekHeight, baseHeight - dragOffset))
    }

    private var extraPeekSpacing: CGFloat {
        let progress = min(1, max(0, (displayedHeight - peekHeight) / 64))
        return (1 - progress) * 36
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                dragHandle
                header
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .contentShape(Rectangle())
            .highPriorityGesture(headerDragGesture)

            scrollBase
                .padding(.top, extraPeekSpacing)
        }
        .frame(height: displayedHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(RidaryTheme.surface)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28
            )
        )
        .overlay(alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28
            )
            .stroke(RidaryTheme.border, lineWidth: 1)
        }
        .shadow(color: RidaryTheme.shadow, radius: 24, x: 0, y: -10)
        .ignoresSafeArea(edges: .bottom)
    }

    private var scrollBase: some View {
        ScrollView {
            content
                .padding(.horizontal, 20)
                .padding(.bottom, RidaryLayout.sheetBottomInset + 20)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDisabled(detent != .full || dragOffset > 0)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            contentDragGesture,
            including: detent == .full ? .none : .all
        )
        .simultaneousGesture(
            fullCollapseDragGesture,
            including: detent == .full ? .all : .none
        )
    }

    private var headerDragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                guard abs(value.translation.height) > abs(value.translation.width) else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                finishDrag(with: value)
            }
    }

    private var contentDragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                guard detent != .full else { return }
                guard abs(value.translation.height) > abs(value.translation.width) else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                guard detent != .full else { return }
                finishDrag(with: value)
            }
    }

    private var fullCollapseDragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { value in
                guard detent == .full else { return }
                if canCollapseFromFullScroll == nil {
                    canCollapseFromFullScroll = scrollOffset <= 4
                }
                if scrollOffset > 4 {
                    canCollapseFromFullScroll = false
                }
                if canCollapseFromFullScroll == true,
                   value.translation.height > 0,
                   abs(value.translation.height) > abs(value.translation.width) {
                    dragOffset = value.translation.height
                } else {
                    dragOffset = 0
                }
            }
            .onEnded { value in
                let wasPullingFullSheet = detent == .full && canCollapseFromFullScroll == true && dragOffset > 0
                canCollapseFromFullScroll = nil

                if wasPullingFullSheet {
                    finishDrag(with: value)
                } else if dragOffset != 0 {
                    withAnimation(sheetSpring) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func finishDrag(with value: DragGesture.Value) {
        let next = nextDetent(for: value)
        withAnimation(sheetSpring) {
            dragOffset = 0
            detent = next
        }
    }

    private func nextDetent(for value: DragGesture.Value) -> RidarySheetDetent {
        let dy = value.translation.height
        let predictedY = value.predictedEndTranslation.height

        if dy < -28 || (dy < -12 && predictedY < -60) {
            switch detent {
            case .peek: return .medium
            case .medium: return .full
            case .full: return .full
            }
        }

        if dy > 28 || (dy > 12 && predictedY > 60) {
            switch detent {
            case .peek: return .peek
            case .medium: return .peek
            case .full: return .medium
            }
        }

        return detent
    }

    private var dragHandle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(RidaryTheme.border)
                .frame(width: 38, height: 4)
                .padding(.top, 9)
                .padding(.bottom, 7)
            Color.clear.frame(height: 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 24)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(sheetSpring) {
                switch detent {
                case .peek: detent = .medium
                case .medium: detent = .full
                case .full: detent = .medium
                }
            }
        }
        .accessibilityLabel("Ride details sheet")
        .accessibilityHint("Drag up or down to expand or collapse")
    }
}
