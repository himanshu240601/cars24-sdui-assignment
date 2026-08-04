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
        let app = launchApp()

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
    func testStaticBaselineRendersCanonicalContentWithoutTheSDUIPath() {
        let app = launchApp(arguments: ["-static-baseline"])

        XCTAssertTrue(app.staticTexts["Find your next car"].waitForExistence(timeout: 5))

        let baseline = app.scrollViews["static-baseline-home"]
        XCTAssertTrue(baseline.waitForExistence(timeout: 5))
        XCTAssertFalse(app.scrollViews["sdui-screen-cars24-home"].exists)
        XCTAssertFalse(app.buttons["sdui-action-finance-2020-tata-nexon"].exists)

        let vehicle = app.descendants(matching: .any)[
            "static-baseline-item-used-cars-youll-love-2020-tata-nexon"
        ]
        reveal(vehicle, in: baseline)
        XCTAssertTrue(vehicle.exists)
        XCTAssertTrue(vehicle.label.contains("EMI ₹16,008/month"))

        let highlightedService = app.descendants(matching: .any)[
            "static-baseline-item-manage-your-vehicle-pay-challan"
        ]
        reveal(highlightedService, in: baseline)
        XCTAssertTrue(highlightedService.exists)

        let promoBanner = app.descendants(matching: .any)["static-baseline-promo-spotify-promo"]
        reveal(promoBanner, in: baseline, maxAttempts: 10)
        XCTAssertTrue(promoBanner.exists)
    }

    @MainActor
    func testFinanceSheetUpdatesTheDeclaredVehicleEMI() {
        let app = launchApp()

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
    private func reveal(
        _ element: XCUIElement,
        in screen: XCUIElement,
        maxAttempts: Int = 5
    ) {
        for _ in 0..<maxAttempts where !element.isHittable {
            screen.swipeUp()
        }
    }

    @MainActor
    private func launchApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.terminate()
        app.launchArguments = arguments
        app.launch()
        return app
    }
}
