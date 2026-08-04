//
//  AppLaunchTests.swift
//  Cars24SDUIUITests
//
//  Created for the CARS24 SDUI assignment.
//

import XCTest

final class AppLaunchTests: XCTestCase {
    @MainActor
    func testAppShowsItsSafeRootWhileNoScreenIsConfigured() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Screen unavailable"].waitForExistence(timeout: 5))
    }
}
