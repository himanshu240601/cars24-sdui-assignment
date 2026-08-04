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
    }

    @MainActor
    func testStaticBaselineDoesNotLoadTheSDUIFixture() {
        let app = XCUIApplication()
        app.launchArguments = ["-static-baseline"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Screen unavailable"].waitForExistence(timeout: 5))
    }
}
