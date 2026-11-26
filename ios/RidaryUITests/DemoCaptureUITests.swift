import XCTest

final class DemoCaptureUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        addUIInterruptionMonitor(withDescription: "Location permission") { alert in
            let allow = alert.buttons["Allow While Using App"]
            if allow.exists {
                allow.tap()
                return true
            }
            return false
        }
        app.launch()
        enterLocalDemo()
    }

    func testCaptureHome() throws {
        XCTAssertTrue(app.buttons["Ask Ridary"].firstMatch.waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 2.5)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.22)).tap()
        Thread.sleep(forTimeInterval: 2.5)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82)).tap()
        Thread.sleep(forTimeInterval: 3.0)
    }

    func testCaptureRideSummary() throws {
        let row = app.buttons.matching(identifier: "ride-row").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 1.2)
        row.tap()

        let recap = app.descendants(matching: .any)
            .matching(identifier: "ride-recap-screen")
            .firstMatch
        XCTAssertTrue(recap.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 3.0)
        app.swipeUp()
        Thread.sleep(forTimeInterval: 3.0)
    }

    func testCaptureAskRidary() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 1.2)
        ask.tap()

        let field = app.textFields["Ask about your rides"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 1.5)
        field.tap()
        field.typeText("How was my last ride?")
        Thread.sleep(forTimeInterval: 1.0)

        let send = app.buttons["Send question"].firstMatch
        XCTAssertTrue(send.waitForExistence(timeout: 5))
        send.tap()
        Thread.sleep(forTimeInterval: 45.0)
    }

    func testCaptureActiveRide() throws {
        let start = app.buttons["Start a ride"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 1.0)
        start.tap()

        let begin = app.buttons["Start ride"].firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 1.0)
        begin.tap()

        let pause = app.buttons["Pause ride"].firstMatch
        XCTAssertTrue(pause.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 6.0)

        let minimize = app.buttons["Minimize ride"].firstMatch
        if minimize.exists {
            minimize.tap()
            Thread.sleep(forTimeInterval: 4.0)
            let live = app.buttons["Open live ride"].firstMatch
            if live.waitForExistence(timeout: 4) {
                live.tap()
                Thread.sleep(forTimeInterval: 2.0)
            }
        }

        let finish = app.buttons["Finish ride"].firstMatch
        if finish.waitForExistence(timeout: 4) {
            pause.tap()
            Thread.sleep(forTimeInterval: 1.0)
            finish.tap()
            Thread.sleep(forTimeInterval: 4.0)
        }
    }

    func testCaptureTimerAndLock() throws {
        let start = app.buttons["Start a ride"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 1.0)
        start.tap()

        let begin = app.buttons["Start ride"].firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 1.0)
        begin.tap()

        let pause = app.buttons["Pause ride"].firstMatch
        XCTAssertTrue(pause.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 8.0)

        let lock = app.buttons["Lock last 30 seconds"].firstMatch
        if lock.waitForExistence(timeout: 5) {
            lock.tap()
            Thread.sleep(forTimeInterval: 5.0)
        }
    }

    func testCaptureLiveMap() throws {
        let start = app.buttons["Start a ride"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 40))
        start.tap()

        let begin = app.buttons["Start ride"].firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 8))
        begin.tap()

        let pause = app.buttons["Pause ride"].firstMatch
        XCTAssertTrue(pause.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 5.0)

        let minimize = app.buttons["Minimize ride"].firstMatch
        XCTAssertTrue(minimize.waitForExistence(timeout: 4))
        minimize.tap()
        Thread.sleep(forTimeInterval: 8.0)
    }

    private func enterLocalDemo() {
        let demo = app.buttons["Explore local demo"].firstMatch
        if demo.waitForExistence(timeout: 8) {
            demo.tap()
        }
    }
}
