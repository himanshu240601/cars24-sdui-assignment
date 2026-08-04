//
//  AppLaunchTests.swift
//  Cars24SDUIUITests
//
//  Created for the CARS24 SDUI assignment.
//

import XCTest

final class AppLaunchTests: XCTestCase {
    @MainActor
    func testAppRendersTheAvailableV1Sections() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Find your next car"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Cars24 discovery"].exists)
        XCTAssertTrue(app.staticTexts["Buy car"].exists)
        XCTAssertTrue(app.staticTexts["All used cars"].exists)
        XCTAssertTrue(app.staticTexts["Get loans"].exists)
        XCTAssertTrue(app.staticTexts["Used car loan"].exists)
        XCTAssertTrue(app.staticTexts["Car check services"].exists)
        XCTAssertTrue(app.staticTexts["New car PDI"].exists)

        let screen = app.scrollViews["sdui-screen-cars24-home"]
        XCTAssertTrue(screen.waitForExistence(timeout: 5))

        let highlightedGridTitle = app.staticTexts["Manage your vehicle"]
        reveal(highlightedGridTitle, in: screen)
        XCTAssertTrue(highlightedGridTitle.exists)

        let highlightedService = app.descendants(matching: .any)[
            "sdui-item-manage-your-vehicle-pay-challan"
        ]
        reveal(highlightedService, in: screen)
        XCTAssertTrue(highlightedService.exists)

        let promoBanner = app.descendants(matching: .any)["sdui-promo-spotify-promo"]
        reveal(promoBanner, in: screen)
        XCTAssertTrue(promoBanner.exists)
    }

    @MainActor
    func testStaticBaselineDoesNotLoadTheSDUIFixture() {
        let app = XCUIApplication()
        app.launchArguments = ["-static-baseline"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Screen unavailable"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testFinanceSheetUpdatesTheDeclaredVehicleEMI() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Find your next car"].waitForExistence(timeout: 5))

        let screen = app.scrollViews["sdui-screen-cars24-home"]
        XCTAssertTrue(screen.waitForExistence(timeout: 5))

        let financeAction = app.buttons["sdui-action-finance-2020-tata-nexon"]
        reveal(financeAction, in: screen)
        XCTAssertTrue(financeAction.exists)
        XCTAssertTrue(financeAction.label.contains("EMI ₹16,008/month"))

        financeAction.tap()

        let financeSheet = app.scrollViews["sdui-sheet-finance-options"]
        XCTAssertTrue(financeSheet.waitForExistence(timeout: 5))

        let sheetTitle = financeSheet.staticTexts["Choose your loan tenure"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(financeSheet.staticTexts["EMI ₹16,008/month"].exists)

        let thirtySixMonths = financeSheet.buttons["sdui-finance-option-finance-options-36-months"]
        XCTAssertTrue(thirtySixMonths.exists)
        thirtySixMonths.tap()

        XCTAssertTrue(financeSheet.staticTexts["EMI ₹20,598/month"].waitForExistence(timeout: 5))

        financeSheet.swipeDown()
        XCTAssertFalse(financeSheet.waitForExistence(timeout: 3))
        XCTAssertTrue(financeAction.waitForExistence(timeout: 3))
        XCTAssertTrue(financeAction.label.contains("EMI ₹20,598/month"))
    }

    @MainActor
    private func reveal(_ element: XCUIElement, in screen: XCUIElement) {
        for _ in 0..<5 where !element.exists {
            screen.swipeUp()
        }
    }
}
