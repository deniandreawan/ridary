import XCTest
@testable import Ridary

final class RidarySheetMetricsTests: XCTestCase {
    func testDetentsIncreaseInOrder() {
        let container: CGFloat = 812
        let peek = RidarySheetMetrics.height(for: .peek, container: container)
        let medium = RidarySheetMetrics.height(for: .medium, container: container)
        let full = RidarySheetMetrics.height(for: .full, container: container)

        XCTAssertGreaterThan(peek, 0)
        XCTAssertLessThan(peek, medium)
        XCTAssertLessThan(medium, full)
    }

    func testFullDetentStaysInsideContainer() {
        let container: CGFloat = 667
        XCTAssertLessThanOrEqual(
            RidarySheetMetrics.height(for: .full, container: container),
            container
        )
    }
}
