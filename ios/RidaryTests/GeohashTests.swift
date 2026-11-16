import XCTest
@testable import Ridary

final class GeohashTests: XCTestCase {
    func testOrigin() {
        XCTAssertEqual(Geohash.encode(latitude: 0, longitude: 0), "s00000")
    }

    func testKnownCoordinates() {
        XCTAssertEqual(
            Geohash.encode(latitude: -6.2088, longitude: 106.8456),
            "qqguxm"
        )
        XCTAssertEqual(
            Geohash.encode(latitude: 37.7749, longitude: -122.4194),
            "9q8yyk"
        )
        XCTAssertEqual(
            Geohash.encode(latitude: 51.5074, longitude: -0.1278),
            "gcpvj0"
        )
    }

    func testInvalidCoordinatesReturnNil() {
        XCTAssertNil(Geohash.encode(latitude: 91, longitude: 0))
        XCTAssertNil(Geohash.encode(latitude: 0, longitude: 181))
        XCTAssertNil(Geohash.encode(latitude: 0, longitude: 0, precision: 0))
    }
}
