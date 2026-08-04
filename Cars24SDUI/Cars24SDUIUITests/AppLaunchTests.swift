//
//  AppLaunchTests.swift
//  Cars24SDUIUITests
//
//  Created for the CARS24 SDUI assignment.
//

import XCTest

final class AppLaunchTests: XCTestCase {
    @MainActor
    func testAppLoadsItsDefinitionBeforeTheRendererExists() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Screen definition loaded"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStaticBaselineDoesNotLoadTheSDUIFixture() {
        let app = XCUIApplication()
        app.launchArguments = ["-static-baseline"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Screen unavailable"].waitForExistence(timeout: 5))
    }
}
