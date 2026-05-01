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
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        XCTAssertTrue(app.staticTexts["Weekly Batch"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Weekly Batch Row"].exists)
        XCTAssertTrue(app.staticTexts["Set availability"].exists)
        XCTAssertFalse(app.otherElements["Weekly Availability Grid"].exists)
        XCTAssertFalse(app.otherElements["Weekly Batch Enrollment Slider"].exists)
        XCTAssertTrue(app.staticTexts["No match yet"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["No Match Mailbox Icon"].exists)
        XCTAssertFalse(app.staticTexts["Current Match"].exists)
        XCTAssertTrue(app.buttons["Match Criteria Row"].exists)
        XCTAssertFalse(app.buttons["Location Row"].exists)
        XCTAssertFalse(app.staticTexts["Identity"].exists)
        XCTAssertFalse(app.staticTexts["Eligible Contacts"].exists)
        XCTAssertFalse(app.staticTexts["Mail"].exists)
        XCTAssertFalse(app.buttons["Mail Inbox Row"].exists)
        scrollToElement(app.buttons["Contacts Row"], in: app)
        XCTAssertTrue(app.staticTexts["Network"].exists)
        XCTAssertFalse(app.buttons["My Card Row"].exists)
        XCTAssertTrue(app.buttons["Contacts Row"].exists)
        XCTAssertTrue(app.buttons["Groups Row"].exists)
        XCTAssertFalse(app.buttons["Logbook Row"].exists)

        app.tabBars.buttons["Profile"].tap()

        XCTAssertTrue(app.staticTexts["Account"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Substance Use"].exists)
        XCTAssertTrue(app.buttons["My Card Row"].exists)
        XCTAssertTrue(app.buttons["Account Gender Row"].exists)
        scrollToElement(app.buttons["Logbook Row"], in: app)
        XCTAssertTrue(app.buttons["Logbook Row"].exists)
        XCTAssertFalse(app.staticTexts["Match Criteria"].exists)
        XCTAssertFalse(app.buttons["Criteria Drinking Substance Use Row"].exists)
    }

    @MainActor
    func testMatchTabShowsAnonymousMatchProfileWhenMatched() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-snsUITestHasMatch")
        app.launch()

        XCTAssertTrue(app.staticTexts["This week's match"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["26 · they/them · Hayes Valley"].exists)
        XCTAssertTrue(app.staticTexts["Coffee"].exists)
        XCTAssertFalse(app.staticTexts["Alex Rivera"].exists)
        XCTAssertFalse(app.staticTexts["Current Match"].exists)
        XCTAssertFalse(app.buttons["Current Match"].exists)
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
    func testRootSearchDoesNotShowMailPage() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("mail")

        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Quick Search Page Inbox"].exists)
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
        XCTAssertTrue(app.buttons["Weekly Batch Row"].exists)
        XCTAssertFalse(app.otherElements["Weekly Availability Grid"].exists)
        XCTAssertTrue(app.buttons["Match Criteria Row"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testSearchDismissReturnsToProfileTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Identity"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Search"].tap()

        let searchField = app.searchFields["Quick Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        app.typeText("Ava")
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Identity"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Account Gender Row"].exists)
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
        XCTAssertTrue(app.buttons["Weekly Batch Row"].exists)
        XCTAssertFalse(app.otherElements["Weekly Availability Grid"].exists)
        XCTAssertTrue(app.buttons["Match Criteria Row"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testEmptySearchDismissReturnsToProfileTab() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Identity"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Search"].tap()

        XCTAssertTrue(app.searchFields["Quick Search"].waitForExistence(timeout: 2))
        dismissSearch(in: app)

        XCTAssertTrue(app.staticTexts["Identity"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Account Gender Row"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].isSelected)
    }

    @MainActor
    func testWeeklyAvailabilityGridDragUnlocksEnrollment() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Weekly Batch Row"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["Weekly Availability Grid"].exists)
        XCTAssertFalse(app.otherElements["Weekly Batch Enrollment Slider"].exists)
        app.buttons["Weekly Batch Row"].tap()

        let grid = app.otherElements["Weekly Availability Grid"]
        XCTAssertTrue(grid.waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Continue Enrollment"].exists)
        XCTAssertFalse(app.buttons["Continue Enrollment"].isEnabled)
        XCTAssertFalse(app.staticTexts["Slide to Enroll"].exists)

        let mondayColumn = app.otherElements["Availability Day Monday"]
        XCTAssertTrue(mondayColumn.waitForExistence(timeout: 2))
        mondayColumn.swipeUp()
        XCTAssertFalse(app.otherElements["Active Availability Window"].exists)

        app.terminate()
        app.launch()

        XCTAssertTrue(app.buttons["Weekly Batch Row"].waitForExistence(timeout: 2))
        app.buttons["Weekly Batch Row"].tap()

        let cleanGrid = app.otherElements["Weekly Availability Grid"]
        XCTAssertTrue(cleanGrid.waitForExistence(timeout: 2))
        longPressDragWithin(cleanGrid, from: CGVector(dx: 0.23, dy: 0.16), to: CGVector(dx: 0.23, dy: 0.24))

        XCTAssertTrue(app.otherElements["Active Availability Window"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Continue Enrollment"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Continue Enrollment"].isEnabled)

        let tuesdayColumn = app.otherElements["Availability Day Tuesday"]
        XCTAssertTrue(tuesdayColumn.waitForExistence(timeout: 2))
        longPressDragWithin(cleanGrid, from: CGVector(dx: 0.35, dy: 0.28), to: CGVector(dx: 0.35, dy: 0.36))

        XCTAssertTrue(app.otherElements["Filled Availability Window"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["Active Availability Window"].exists)

        XCTAssertTrue(app.buttons["Delete Availability Window"].waitForExistence(timeout: 2))
        app.buttons["Delete Availability Window"].tap()

        XCTAssertTrue(app.staticTexts["1 time window"].waitForExistence(timeout: 2))
        app.buttons["Continue Enrollment"].tap()
        XCTAssertTrue(app.otherElements["Weekly Batch Enrollment Slider"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Enrollment is final."].exists)
    }

    @MainActor
    func testWeeklyAvailabilityReadOnlyAfterEnrollment() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Weekly Batch Row"].waitForExistence(timeout: 2))
        app.buttons["Weekly Batch Row"].tap()

        let mondayColumn = app.otherElements["Availability Day Monday"]
        XCTAssertTrue(mondayColumn.waitForExistence(timeout: 2))
        longPressDragWithin(mondayColumn, from: CGVector(dx: 0.5, dy: 0.10), to: CGVector(dx: 0.5, dy: 0.18))

        XCTAssertTrue(app.buttons["Continue Enrollment"].waitForExistence(timeout: 2))
        app.buttons["Continue Enrollment"].tap()

        let slider = app.otherElements["Weekly Batch Enrollment Slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 2))
        dragWithin(slider, from: CGVector(dx: 0.12, dy: 0.5), to: CGVector(dx: 0.94, dy: 0.5))

        XCTAssertTrue(app.navigationBars["Enrolled"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["You're enrolled for this week."].exists)
        XCTAssertFalse(app.buttons["Delete Availability Window"].exists)
        XCTAssertFalse(app.otherElements["Availability Start Handle"].exists)
        XCTAssertFalse(app.otherElements["Availability End Handle"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["Weekly Batch Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Enrolled"].exists)

        app.buttons["Weekly Batch Row"].tap()
        XCTAssertTrue(app.navigationBars["Enrolled"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Delete Availability Window"].exists)
    }

    @MainActor
    func testRadiusEditorOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        openMatchCriteria(in: app)
        scrollToElement(app.buttons["Radius Row"], in: app)
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

        XCTAssertTrue(app.navigationBars["Match Criteria"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Within 10 mi"].waitForExistence(timeout: 2))
        app.navigationBars["Match Criteria"].buttons.firstMatch.tap()

        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
    }

    @MainActor
    func testLocationPickerRequiresSuggestionSelection() throws {
        let app = XCUIApplication()
        app.launch()

        openMatchCriteria(in: app)
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

        openMatchCriteria(in: app)
        XCTAssertTrue(app.buttons["Location Row"].waitForExistence(timeout: 2))
        app.buttons["Location Row"].tap()

        XCTAssertTrue(app.navigationBars["Location"].waitForExistence(timeout: 2))
        let searchField = app.textFields["Address, neighborhood, or zip"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        app.typeText("zzzzzz")

        XCTAssertTrue(app.staticTexts["No locations found"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testProfileTabShowsAccount() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Profile"].tap()

        XCTAssertTrue(app.buttons["My Card Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["My Name"].exists)
        XCTAssertTrue(app.staticTexts["My Card"].exists)
        XCTAssertTrue(app.staticTexts["Identity"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Substance Use"].exists)
        XCTAssertTrue(app.buttons["Account Age Row"].exists)
        XCTAssertTrue(app.buttons["Account Gender Row"].exists)
        XCTAssertTrue(app.buttons["Account Pronouns Row"].exists)
        XCTAssertTrue(app.buttons["Account Sexuality Row"].exists)
        XCTAssertTrue(app.buttons["Account Vaping Substance Use Row"].exists)
        XCTAssertTrue(app.buttons["Account Smoking Substance Use Row"].exists)
        XCTAssertTrue(app.buttons["Account Marijuana Substance Use Row"].exists)
        XCTAssertTrue(app.buttons["Account Drinking Substance Use Row"].exists)
        XCTAssertTrue(app.buttons["Account Other Substance Use Row"].exists)
        XCTAssertTrue(app.staticTexts["Female"].exists)
        XCTAssertTrue(app.staticTexts["she/her"].exists)
        XCTAssertTrue(app.staticTexts["Not listed"].exists)
        XCTAssertFalse(app.staticTexts["Match Criteria"].exists)
        XCTAssertFalse(app.buttons["Location Row"].exists)
    }

    @MainActor
    func testProfileMyCardEditsNameAndPreferredContact() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-snsUITestDisablePhotoPicker")
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["My Card Row"].waitForExistence(timeout: 2))
        app.buttons["My Card Row"].tap()

        XCTAssertTrue(app.navigationBars["My Card"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertFalse(app.switches["Use for matching"].exists)
        XCTAssertFalse(app.staticTexts["Groups"].exists)
        XCTAssertTrue(app.staticTexts["Email"].exists)

        app.navigationBars["My Card"].buttons["Edit"].tap()
        clearAndEnterText("Kevin", in: app.textFields["My Card First Name Field"])
        clearAndEnterText("Jin", in: app.textFields["My Card Last Name Field"])
        app.buttons["SNS"].tap()
        clearAndEnterText("@kevin", in: app.textFields["My Card Preferred Contact Field"])
        app.navigationBars["My Card"].buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Kevin"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Jin"].exists)
        XCTAssertTrue(app.staticTexts["@kevin"].exists)

        app.navigationBars["My Card"].buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["My Card Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Kevin Jin"].exists)
    }

    @MainActor
    func testContactsPageDoesNotShowMyCardRow() throws {
        let app = XCUIApplication()
        app.launch()

        scrollToElement(app.buttons["Contacts Row"], in: app)
        app.buttons["Contacts Row"].tap()

        XCTAssertTrue(app.navigationBars["Contacts"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["My Card Row"].exists)
        XCTAssertTrue(app.staticTexts["Ava Thompson"].exists)
    }

    @MainActor
    func testMatchTabShowsMatchCriteria() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Match Criteria Row"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Location Row"].exists)

        app.buttons["Match Criteria Row"].tap()
        XCTAssertTrue(app.navigationBars["Match Criteria"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Location"].exists)
        XCTAssertTrue(app.buttons["Location Row"].exists)
        XCTAssertTrue(app.buttons["Radius Row"].exists)
        XCTAssertTrue(app.staticTexts["Demographics"].exists)
        XCTAssertTrue(app.buttons["Age Range Row"].exists)
        XCTAssertTrue(app.buttons["Criteria Gender Row"].exists)

        scrollToElement(app.buttons["Criteria Sexuality Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Sexuality Row"].exists)

        XCTAssertTrue(app.staticTexts["Substance Use"].exists)
        scrollToElement(app.buttons["Criteria Vaping Substance Use Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Vaping Substance Use Row"].exists)

        scrollToElement(app.buttons["Criteria Smoking Substance Use Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Smoking Substance Use Row"].exists)

        scrollToElement(app.buttons["Criteria Marijuana Substance Use Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Marijuana Substance Use Row"].exists)

        scrollToElement(app.buttons["Criteria Drinking Substance Use Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Drinking Substance Use Row"].exists)

        scrollToElement(app.buttons["Criteria Other Substance Use Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Other Substance Use Row"].exists)

        XCTAssertTrue(app.staticTexts["Matching"].exists)
        scrollToElement(app.buttons["Match Policy Row"], in: app)
        XCTAssertTrue(app.buttons["Match Policy Row"].exists)
        XCTAssertTrue(app.buttons["Criteria Other Substance Use Row"].label.contains("Open"))
    }

    @MainActor
    func testAccountProfileOptionsUpdateSummaries() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        app.buttons["Account Pronouns Row"].tap()

        XCTAssertTrue(app.navigationBars["Pronouns"].waitForExistence(timeout: 2))
        app.buttons["they/them"].tap()
        app.navigationBars["Pronouns"].buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["they/them"].waitForExistence(timeout: 2))

        scrollToElement(app.buttons["Account Drinking Substance Use Row"], in: app)
        app.buttons["Account Drinking Substance Use Row"].tap()
        XCTAssertTrue(app.navigationBars["Substance Use"].waitForExistence(timeout: 2))
        app.buttons["Drinking"].tap()
        app.navigationBars["Substance Use"].buttons.firstMatch.tap()

        XCTAssertTrue(app.buttons["Account Drinking Substance Use Row"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Account Drinking Substance Use Row"].label.contains("Listed"))
    }

    @MainActor
    func testMatchCriteriaMultiSelectShowsOptions() throws {
        let app = XCUIApplication()
        app.launch()

        openMatchCriteria(in: app)
        let criteriaSubstanceUseRow = app.buttons["Criteria Drinking Substance Use Row"]
        scrollToElement(criteriaSubstanceUseRow, in: app)
        XCTAssertTrue(criteriaSubstanceUseRow.waitForExistence(timeout: 2))
        XCTAssertTrue(criteriaSubstanceUseRow.label.contains("Open"))
        criteriaSubstanceUseRow.tap()

        XCTAssertTrue(app.navigationBars["Substance Use"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Vaping"].exists)
        XCTAssertTrue(app.buttons["Smoking"].exists)
        XCTAssertTrue(app.buttons["Marijuana"].exists)
        XCTAssertTrue(app.buttons["Drinking"].exists)
        XCTAssertTrue(app.buttons["Other"].exists)
    }

    @MainActor
    func testGenderPreferenceOpensFromProfileTab() throws {
        let app = XCUIApplication()
        app.launch()

        openMatchCriteria(in: app)
        scrollToElement(app.buttons["Criteria Gender Row"], in: app)
        XCTAssertTrue(app.buttons["Criteria Gender Row"].waitForExistence(timeout: 2))
        app.buttons["Criteria Gender Row"].tap()

        XCTAssertTrue(app.navigationBars["Gender"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Gender"].exists)
        XCTAssertTrue(app.buttons["Male"].exists)
        XCTAssertTrue(app.buttons["Female"].exists)
        XCTAssertTrue(app.buttons["Nonbinary"].exists)

        app.navigationBars["Gender"].buttons.firstMatch.tap()

        XCTAssertTrue(app.buttons["Criteria Gender Row"].waitForExistence(timeout: 2))
        app.navigationBars["Match Criteria"].buttons.firstMatch.tap()

        XCTAssertTrue(app.tabBars.buttons["Match"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.tabBars.buttons["Network"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
    }

    @MainActor
    func testAgeRangePreferenceOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        openMatchCriteria(in: app)
        scrollToElement(app.buttons["Age Range Row"], in: app)
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

        openMatchCriteria(in: app)
        scrollToElement(app.buttons["Match Policy Row"], in: app)
        XCTAssertTrue(app.buttons["Match Policy Row"].waitForExistence(timeout: 2))
        app.buttons["Match Policy Row"].tap()

        XCTAssertTrue(app.navigationBars["Match Policy"].waitForExistence(timeout: 2))
        assertRootTabsHidden(in: app)
        XCTAssertTrue(app.staticTexts["Match Policy"].exists)
        XCTAssertTrue(app.staticTexts["Mutuals only"].exists)
    }

    @MainActor
    func testGroupsPriorityInfoOpens() throws {
        let app = XCUIApplication()
        app.launch()

        scrollToElement(app.buttons["Groups Row"], in: app)

        app.buttons["Groups Row"].tap()

        XCTAssertTrue(app.navigationBars["Groups"].waitForExistence(timeout: 2))
        app.buttons["Group Priority Info"].tap()
        XCTAssertTrue(app.staticTexts["Higher-priority groups are favored more when a match is connected through that group."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLogbookOpensFromRoot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Profile"].tap()

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

    private func openMatchCriteria(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["Match Criteria Row"].waitForExistence(timeout: 2))
        app.buttons["Match Criteria Row"].tap()
        XCTAssertTrue(app.navigationBars["Match Criteria"].waitForExistence(timeout: 2))
    }

    private func dragWithin(_ element: XCUIElement, from startOffset: CGVector, to endOffset: CGVector) {
        let start = element.coordinate(withNormalizedOffset: startOffset)
        let end = element.coordinate(withNormalizedOffset: endOffset)
        start.press(forDuration: 0.1, thenDragTo: end)
    }

    private func longPressDragWithin(_ element: XCUIElement, from startOffset: CGVector, to endOffset: CGVector) {
        let start = element.coordinate(withNormalizedOffset: startOffset)
        let end = element.coordinate(withNormalizedOffset: endOffset)
        start.press(forDuration: 0.35, thenDragTo: end)
    }

    private func clearAndEnterText(_ text: String, in element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 2))
        element.tap()

        if let value = element.value as? String, !value.isEmpty {
            element.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }

        element.typeText(text)
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
        XCTAssertFalse(app.tabBars.buttons["Profile"].exists)
        XCTAssertFalse(app.tabBars.buttons["Search"].exists)
    }
}
