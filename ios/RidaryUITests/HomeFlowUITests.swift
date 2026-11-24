import XCTest

final class HomeFlowUITests: XCTestCase {
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
    }

    func testAskRidaryAndProfileFlows() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40), "Ask Ridary entry bar should be visible on Home")

        let askPage = app.staticTexts["Ask about your rides"]
        ask.tap()
        if !askPage.waitForExistence(timeout: 5) {
            ask.tap()
        }

        XCTAssertTrue(
            askPage.waitForExistence(timeout: 10),
            "Ask Ridary page should open"
        )
        attachScreenshot(named: "ask-ridary")

        app.buttons["Close Ask Ridary"].tap()
        XCTAssertTrue(ask.waitForExistence(timeout: 10), "Closing Ask Ridary should return to Home")

        let profile = app.buttons["Open profile"].firstMatch
        XCTAssertTrue(profile.waitForExistence(timeout: 10), "Profile menu should be available from Home")
        profile.tap()

        XCTAssertTrue(
            app.buttons["Close profile"].waitForExistence(timeout: 10),
            "Profile sheet should open"
        )
        attachScreenshot(named: "profile-menu")

        let statistics = app.staticTexts["Statistics"].firstMatch
        XCTAssertTrue(statistics.waitForExistence(timeout: 5), "Statistics entry should be visible")
        statistics.tap()

        XCTAssertTrue(
            app.buttons["Close statistics"].waitForExistence(timeout: 10),
            "Statistics screen should open from Profile"
        )
        attachScreenshot(named: "statistics")

        app.buttons["Close statistics"].tap()
        XCTAssertTrue(
            app.buttons["Close profile"].waitForExistence(timeout: 10),
            "Profile sheet should return after closing Statistics"
        )

        let incidents = app.staticTexts["Incidents"].firstMatch
        XCTAssertTrue(incidents.waitForExistence(timeout: 5), "Incidents entry should be visible")
        incidents.tap()

        XCTAssertTrue(
            app.buttons["Close incidents"].waitForExistence(timeout: 10),
            "Incidents screen should open from Profile"
        )
        attachScreenshot(named: "incidents")

        app.buttons["Close incidents"].tap()
        XCTAssertTrue(
            app.buttons["Close profile"].waitForExistence(timeout: 10),
            "Profile sheet should return after closing Incidents"
        )

        let settings = app.staticTexts["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5), "Settings entry should be visible")
        settings.tap()

        XCTAssertTrue(
            app.buttons["Close settings"].waitForExistence(timeout: 10),
            "Settings screen should open from Profile"
        )
        attachScreenshot(named: "settings")

        app.buttons["Close settings"].tap()
        XCTAssertTrue(
            app.buttons["Close profile"].waitForExistence(timeout: 10),
            "Profile sheet should return after closing Settings"
        )
    }

    func testAskRidarySendsQuestionWithStub() throws {
        app.terminate()
        app.launchArguments.append("-uiTestAIStub")
        app.launch()

        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40), "Ask Ridary entry bar should be visible on Home")
        ask.tap()

        let field = app.textFields["Ask about your rides"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Ask Ridary composer should be ready")
        field.tap()
        field.typeText("Why was my last ride marked risky?")

        let send = app.buttons["Send question"].firstMatch
        XCTAssertTrue(send.waitForExistence(timeout: 5), "Send button should be available")
        send.tap()

        let answer = app.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", "Your last ride scored 96"))
            .firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 10), "Ask Ridary should show the stub answer")
        XCTAssertTrue(app.staticTexts["On device"].exists, "Answer should show the inference source")
        attachScreenshot(named: "ask-ridary-answer")

        app.buttons["Close Ask Ridary"].tap()
        XCTAssertTrue(ask.waitForExistence(timeout: 10), "Closing Ask Ridary should return to Home")
    }

    func testMapTapCollapsesSheetToPeek() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))

        let mediumY = ask.frame.minY
        attachScreenshot(named: "home-map-medium")

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.22)).tap()
        Thread.sleep(forTimeInterval: 0.9)

        let peekY = ask.frame.minY
        XCTAssertGreaterThan(
            peekY,
            mediumY + 80,
            "Tapping the map should collapse the sheet to peek"
        )
        attachScreenshot(named: "home-map-peek")
    }

    func testStartFlowOpensAndCancelsCountdown() throws {
        let start = app.buttons["Start a ride"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 40), "Start button should be visible on Home")
        start.tap()

        let status = app.staticTexts["ride-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 10), "Start page should open")
        XCTAssertTrue(app.staticTexts["ride-timer"].exists, "Ready timer should be visible")
        attachScreenshot(named: "start-page")

        let startRide = app.buttons["Start ride"].firstMatch
        XCTAssertTrue(startRide.waitForExistence(timeout: 5), "Start ride should be available")
        startRide.tap()

        XCTAssertTrue(
            app.staticTexts["GET READY"].waitForExistence(timeout: 10),
            "Countdown should start"
        )
        attachScreenshot(named: "countdown")

        app.buttons["Cancel"].firstMatch.tap()
        XCTAssertTrue(
            app.staticTexts["ride-status"].waitForExistence(timeout: 5),
            "Cancel should return to the start page"
        )

        app.buttons["Close ride start"].firstMatch.tap()
        XCTAssertTrue(start.waitForExistence(timeout: 5), "Close should return to Home")
    }


    func testActiveRidePauseAndResume() throws {
        let app = XCUIApplication()
        app.launch()

        let startRide = app.buttons["Start a ride"]
        XCTAssertTrue(startRide.waitForExistence(timeout: 40))

        let begin = app.buttons["Start ride"]
        for _ in 0..<3 {
            startRide.tap()
            if begin.waitForExistence(timeout: 4) {
                break
            }
        }
        XCTAssertTrue(begin.exists)
        begin.tap()

        let pause = app.buttons["Pause ride"]
        XCTAssertTrue(pause.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 3)
        attachScreenshot(named: "active-ride")

        pause.tap()

        let resume = app.buttons["Resume ride"]
        XCTAssertTrue(resume.waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Finish ride"].exists)
        attachScreenshot(named: "paused-ride")

        resume.tap()
        XCTAssertTrue(pause.waitForExistence(timeout: 3))

        let minimize = app.buttons["Minimize ride"]
        XCTAssertTrue(minimize.exists)
        minimize.tap()

        let live = app.buttons["Open live ride"]
        XCTAssertTrue(live.waitForExistence(timeout: 4))
        XCTAssertFalse(
            app.staticTexts["ride-timer"].waitForExistence(timeout: 1.5),
            "Minimizing should leave the rider on Home"
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["home-map"].exists,
            "Home map should be visible with the live ride"
        )
        let homeAsk = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(homeAsk.waitForExistence(timeout: 4))
        XCTAssertGreaterThan(
            homeAsk.frame.minY,
            app.frame.height * 0.6,
            "Minimizing should collapse the sheet so the live map is visible"
        )
        attachScreenshot(named: "live-home")
        live.tap()

        let pauseAgain = app.buttons["Pause ride"]
        XCTAssertTrue(pauseAgain.waitForExistence(timeout: 3))
        pauseAgain.tap()

        let finish = app.buttons["Finish ride"]
        XCTAssertTrue(finish.waitForExistence(timeout: 3))
        finish.tap()

        XCTAssertTrue(startRide.waitForExistence(timeout: 12))
    }


    func testModeSheetSelectsActivity() throws {
        let start = app.buttons["Start a ride"]
        XCTAssertTrue(start.waitForExistence(timeout: 40))
        start.tap()

        let status = app.staticTexts["ride-status"]
        if !status.waitForExistence(timeout: 5) {
            start.tap()
        }
        XCTAssertTrue(status.waitForExistence(timeout: 10))

        let mode = app.buttons["mode-control"]
        XCTAssertTrue(mode.waitForExistence(timeout: 10))
        mode.tap()

        let bicycle = app.buttons["Bicycle"]
        XCTAssertTrue(bicycle.waitForExistence(timeout: 5), "Activity sheet should open from the header")
        attachScreenshot(named: "activity-sheet")

        bicycle.tap()

        XCTAssertTrue(mode.waitForExistence(timeout: 3))
        XCTAssertTrue(mode.label.contains("Bicycle"), "Header should show the selected activity")

        app.buttons["Close ride start"].tap()
        XCTAssertTrue(start.waitForExistence(timeout: 5))
    }


    func testHomeSheetExpandsAndKeepsSearchVisible() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))

        let mediumY = ask.frame.minY
        attachScreenshot(named: "home-sheet-medium-initial")

        // 1. Drag down on content from medium -> peek
        let contentMid = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.74))
        let bottomTarget = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92))
        contentMid.press(forDuration: 0.08, thenDragTo: bottomTarget)
        Thread.sleep(forTimeInterval: 0.8)

        let peekY = ask.frame.minY
        XCTAssertGreaterThan(peekY, mediumY + 100, "Dragging down on content should collapse medium to peek")
        attachScreenshot(named: "home-sheet-peek")

        // 2. Drag up from peek -> medium (must stop at medium, not jump to full)
        let peekOrigin = ask.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let midTarget = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55))
        peekOrigin.press(forDuration: 0.08, thenDragTo: midTarget)
        Thread.sleep(forTimeInterval: 0.8)

        let steppedMediumY = ask.frame.minY
        XCTAssertLessThan(abs(steppedMediumY - mediumY), 40, "Dragging up from peek should stop at medium, not jump to full")
        attachScreenshot(named: "home-sheet-medium-from-peek")

        // 3. Drag up on content from medium -> full
        let destination = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.28))
        contentMid.press(forDuration: 0.08, thenDragTo: destination)
        Thread.sleep(forTimeInterval: 0.8)

        let fullY = ask.frame.minY
        XCTAssertGreaterThan(fullY, 50, "Search bar should stay below the status bar")
        XCTAssertLessThan(fullY, 160, "Sheet should expand to full below the status bar")
        attachScreenshot(named: "home-sheet-expanded")

        // 4. Scroll rides list in full detent
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.6)
        XCTAssertTrue(ask.exists)
        attachScreenshot(named: "home-sheet-scrolled")

        // 5. Drag down from header in full -> medium
        let fullHeaderOrigin = ask.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let pullDownTarget = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
        fullHeaderOrigin.press(forDuration: 0.08, thenDragTo: pullDownTarget)
        Thread.sleep(forTimeInterval: 0.8)

        let collapsedMediumY = ask.frame.minY
        XCTAssertLessThan(abs(collapsedMediumY - mediumY), 40, "Dragging down from full should return to medium")
    }

    func testFullSheetScrollsContentBeforeCollapsing() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))

        let mediumY = ask.frame.minY
        let contentMid = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.74))
        let destination = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.28))
        contentMid.press(forDuration: 0.08, thenDragTo: destination)
        Thread.sleep(forTimeInterval: 0.8)

        let fullY = ask.frame.minY
        XCTAssertLessThan(fullY, 160, "Sheet should expand to full below the status bar")

        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.8)
        attachScreenshot(named: "home-sheet-full-scrolled-down")

        app.swipeDown()
        Thread.sleep(forTimeInterval: 0.8)

        XCTAssertLessThan(
            abs(ask.frame.minY - fullY),
            40,
            "Scrolling the content back up should not collapse the full sheet"
        )
        attachScreenshot(named: "home-sheet-full-scrolled-back-up")

        let contentLower = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
        contentLower.press(forDuration: 0.08, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.84)))
        Thread.sleep(forTimeInterval: 0.8)

        XCTAssertLessThan(
            abs(ask.frame.minY - mediumY),
            40,
            "Dragging down at the top of the content should collapse full to medium"
        )
    }

    func testRideSummaryOpensFullScreen() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))

        let row = app.buttons.matching(identifier: "ride-row").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "Ride row should be visible")
        row.tap()

        let recap = app.descendants(matching: .any)
            .matching(identifier: "ride-recap-screen")
            .firstMatch
        XCTAssertTrue(
            recap.waitForExistence(timeout: 5),
            "Ride recap should open full screen"
        )
        attachScreenshot(named: "ride-summary-detail")

        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.8)
        attachScreenshot(named: "ride-summary-detail-scrolled")
    }

    func testCredentialOpensFullScreen() throws {
        let profile = app.buttons["Open profile"].firstMatch
        XCTAssertTrue(profile.waitForExistence(timeout: 40))
        profile.tap()

        let proof = app.buttons["Ridary Proof"].firstMatch
        XCTAssertTrue(proof.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.5)
        proof.tap()

        let proofTitle = app.staticTexts["Proof, not surveillance"].firstMatch
        let emptyTitle = app.staticTexts["Build your proof"].firstMatch
        XCTAssertTrue(
            proofTitle.waitForExistence(timeout: 5) || emptyTitle.exists,
            "Credential detail should open full screen"
        )
        attachScreenshot(named: "credential-detail")
    }

    func testRideSwipeRevealsDelete() throws {
        let ask = app.buttons["Ask Ridary"].firstMatch
        XCTAssertTrue(ask.waitForExistence(timeout: 40))

        let row = app.descendants(matching: .any)
            .matching(identifier: "ride-row")
            .firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "Ride row should be visible")

        let swipeStart = row.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
        let swipeEnd = row.coordinate(withNormalizedOffset: CGVector(dx: 0.55, dy: 0.5))
        swipeStart.press(forDuration: 0.1, thenDragTo: swipeEnd)
        Thread.sleep(forTimeInterval: 0.5)

        let delete = app.buttons["Delete ride"].firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 3), "Swipe should reveal Delete")
        attachScreenshot(named: "ride-swipe-delete")

        delete.tap()
        let confirmation = app.alerts["Delete this ride?"]
        XCTAssertTrue(
            confirmation.waitForExistence(timeout: 3),
            "Delete should ask for confirmation"
        )
        attachScreenshot(named: "ride-delete-confirm")
        confirmation.buttons["Cancel"].tap()
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
