import XCTest
@testable import Ridary

final class JSONCodingTests: XCTestCase {
    func testExtractsPlainJSONObject() {
        let data = RidaryJSON.extractJSONObject(from: #"{"a":1}"#)
        XCTAssertNotNil(data)
    }

    func testExtractsJSONFromCodeFence() {
        let text = """
        ```json
        {"headline":"ok","summary":"yes"}
        ```
        """
        let data = RidaryJSON.extractJSONObject(from: text)
        XCTAssertNotNil(data)
        let object = try? JSONSerialization.jsonObject(with: data ?? Data())
        XCTAssertNotNil(object)
    }

    func testRoundTripRideSnapshot() throws {
        let snapshot = RideSnapshot(
            headline: "Clean ride",
            summary: "A smooth ride.",
            riskMoments: [],
            score: 98,
            scoreRationale: "No events.",
            coachingTip: "Keep it up."
        )
        let data = try RidaryJSON.data(snapshot)
        let decoded = try RidaryJSON.decode(RideSnapshot.self, from: data)
        XCTAssertEqual(decoded.score, 98)
        XCTAssertEqual(decoded.headline, "Clean ride")
    }
}
