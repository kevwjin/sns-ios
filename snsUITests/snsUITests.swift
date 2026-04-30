//
//  snsUITests.swift
//  snsUITests
//
//  Created by Kevin Jin on 3/27/26.
//

import XCTest

final class snsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        XCTAssertTrue(app.staticTexts["Weekly Batch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Within 10 mi"].exists)
        XCTAssertTrue(app.staticTexts["Match With"].exists)
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        XCTAssertFalse(app.staticTexts["Eligible Contacts"].exists)

        app.tabBars.buttons["Network"].tap()

        XCTAssertTrue(app.staticTexts["Mail"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Mail Inbox Row"].exists)
        XCTAssertTrue(app.staticTexts["Contacts"].exists)
        scrollToElement(app.buttons["Logbook Row"], in: app)
        XCTAssertTrue(app.buttons["Logbook Row"].exists)
    }

    @MainActor
    func testRootSearchFindsContactAndOpensDetail() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("Ava")

        XCTAssertTrue(app.staticTexts["Ava Thompson"].waitForExistence(timeout: 2))
        app.buttons["Ava Thompson"].tap()

        XCTAssertTrue(app.navigationBars["Ava Thompson"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
    }

    @MainActor
    func testRootSearchFindsGroup() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("Study")

        XCTAssertTrue(app.staticTexts["Study Group"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testRootSearchFindsRadiusPage() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("radius")

        XCTAssertTrue(app.staticTexts["Pages"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Quick Search Page Radius"].exists)
        app.buttons["Quick Search Page Radius"].tap()

        XCTAssertTrue(app.navigationBars["Radius"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
    }

    @MainActor
    func testRootSearchFindsInboxPageByMailKeyword() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("mail")

        XCTAssertTrue(app.staticTexts["Pages"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Quick Search Page Inbox"].exists)
        app.buttons["Quick Search Page Inbox"].tap()

        XCTAssertTrue(app.navigationBars["Inbox"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
    }

    @MainActor
    func testRootSearchShowsNoResults() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("zzzzzz")

        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSearchDismissReturnsToMatchTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("Ava")
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Weekly Batch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Match Criteria"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testSearchDismissReturnsToNetworkTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()
        XCTAssertTrue(app.staticTexts["Mail"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("Ava")
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Mail"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Network"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testEmptySearchDismissReturnsToMatchTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        XCTAssertTrue(app.searchFields["Quick Search"].waitForExistence(timeout: 2))
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Weekly Batch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Match Criteria"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testEmptySearchDismissReturnsToNetworkTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()
        XCTAssertTrue(app.staticTexts["Mail"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Search"].tap()

        XCTAssertTrue(app.searchFields["Quick Search"].waitForExistence(timeout: 2))
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Mail"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Network"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testRadiusEditorOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Within 10 mi"].waitForExistence(timeout: 2))

        app.buttons["Radius Row"].tap()

        XCTAssertTrue(app.navigationBars["Radius"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["People outside this radius are not eligible for matching."].exists)
        XCTAssertTrue(app.switches["Extend if needed"].exists)
        XCTAssertTrue(app.staticTexts["1 mi"].exists)
        XCTAssertTrue(app.staticTexts["50 mi"].exists)
        XCTAssertTrue(app.otherElements["Radius Slider"].exists)

        app.navigationBars["Radius"].buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Within 10 mi"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
    }

    @MainActor
    func testLocationPickerRequiresSuggestionSelection() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Location Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["SoMa"].exists)
        app.buttons["Location Row"].tap()

        XCTAssertTrue(app.navigationBars["Location"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)

        let searchField = app.textFields["Address, neighborhood, or zip"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["Current Matching Location"].label, "SoMa")
        XCTAssertTrue(app.otherElements["Neighborhood Map Preview"].exists)
        XCTAssertTrue(app.staticTexts["Matching uses neighborhood-level location, not your exact address."].exists)
        XCTAssertTrue(app.staticTexts["Choose a suggestion to update your matching location."].exists)

        searchField.tap()
        app.typeText("123 Market")

        XCTAssertEqual(app.staticTexts["Current Matching Location"].label, "SoMa")
        XCTAssertTrue(app.buttons["Location Suggestion 123 Market St, San Francisco, CA"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Maps to Financial District"].exists)

        app.buttons["Location Suggestion 123 Market St, San Francisco, CA"].tap()

        XCTAssertTrue(app.staticTexts["Current Matching Location"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["Current Matching Location"].label, "Financial District")
        app.navigationBars["Location"].buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Financial District"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testBatchInfoExplainsMockActivityAssignment() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Batch Info"].waitForExistence(timeout: 2))
        app.buttons["Batch Info"].tap()

        XCTAssertTrue(app.staticTexts["Batch Info"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["For this MVP mock, matched users are assigned either a cafe or walk activity at a vetted San Francisco spot."].exists)
    }

    @MainActor
    func testLocationPickerShowsNoResultsForUnknownQuery() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Location Row"].waitForExistence(timeout: 2))
        app.buttons["Location Row"].tap()

        let searchField = app.textFields["Address, neighborhood, or zip"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        app.typeText("zzzzzz")

        XCTAssertTrue(app.staticTexts["No locations found"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testMatchWithPreferenceOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Match With Row"].waitForExistence(timeout: 2))
        app.buttons["Match With Row"].tap()

        XCTAssertTrue(app.navigationBars["Match With"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Match With"].exists)
        XCTAssertTrue(app.staticTexts["No preference"].exists)

        app.navigationBars["Match With"].buttons.firstMatch.tap()

        XCTAssertTrue(app.buttons["Match With Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
    }

    @MainActor
    func testAgeRangePreferenceOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Age Range Row"].waitForExistence(timeout: 2))
        app.buttons["Age Range Row"].tap()

        XCTAssertTrue(app.navigationBars["Age Range"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Age Range"].exists)
        XCTAssertTrue(app.staticTexts["21-27"].exists)
        XCTAssertTrue(app.staticTexts["18"].exists)
        XCTAssertTrue(app.staticTexts["99"].exists)
        XCTAssertTrue(app.otherElements["Age Range Slider"].exists)
    }

    @MainActor
    func testMatchPolicyPreferenceOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Match Policy Row"].waitForExistence(timeout: 2))
        app.buttons["Match Policy Row"].tap()

        XCTAssertTrue(app.navigationBars["Match Policy"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Match Policy"].exists)
        XCTAssertTrue(app.staticTexts["Mutuals only"].exists)
    }

    @MainActor
    func testMailInboxAndThreadOpenFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()

        XCTAssertTrue(app.buttons["Mail Inbox Row"].waitForExistence(timeout: 2))
        app.buttons["Mail Inbox Row"].tap()

        XCTAssertTrue(app.navigationBars["Inbox"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Coffee after the batch?"].exists)

        app.buttons["Mail Thread Coffee after the batch?"].tap()

        XCTAssertTrue(app.navigationBars["Mail"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Coffee after the batch?"].exists)
        XCTAssertTrue(app.textFields["Reply"].exists)
    }

    @MainActor
    func testMailInfoExplainsPrivateDelivery() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()

        XCTAssertTrue(app.buttons["Private Mail Info"].waitForExistence(timeout: 2))
        app.buttons["Private Mail Info"].tap()

        XCTAssertTrue(app.alerts["Private Mail"].waitForExistence(timeout: 2))
        let bodyText = "Mail is designed for private, slower messages. Delivery may take longer because messages are routed in a way that avoids exposing direct connection details. Use it like email, not instant chat."
        let bodyPredicate = NSPredicate(format: "label == %@", bodyText)
        XCTAssertTrue(app.alerts["Private Mail"].staticTexts.matching(bodyPredicate).firstMatch.exists)
    }

    @MainActor
    func testGroupsPriorityInfoOpens() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()

        app.buttons["Groups Row"].tap()

        XCTAssertTrue(app.navigationBars["Groups"].waitForExistence(timeout: 2))
        app.buttons["Group Priority Info"].tap()
        XCTAssertTrue(app.staticTexts["Higher-priority groups are favored more when a match is connected through that group."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLogbookOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Network"].tap()

        scrollToElement(app.buttons["Logbook Row"], in: app)
        app.buttons["Logbook Row"].tap()

        XCTAssertTrue(app.navigationBars["Logbook"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Enrolled in this week's batch"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 5) {
        var remainingSwipes = maxSwipes

        while !element.exists && remainingSwipes > 0 {
            app.swipeUp()
            remainingSwipes -= 1
        }
    }

    private func dismissSearch(in app: XCUIApplication) {
        let closeButton = app.buttons["Close"].firstMatch
        if closeButton.waitForExistence(timeout: 1) {
            closeButton.tap()
            return
        }

        let cancelButton = app.buttons["Cancel"].firstMatch
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()
    }

    private func assertRootTabsHidden(in app: XCUIApplication) {
        XCTAssertFalse(app.tabBars.buttons["Match"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.tabBars.buttons["Network"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].exists)
    }
}
