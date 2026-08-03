//
//  AppLaunchModeTests.swift
//  Cars24SDUITests
//
//  Created for the CARS24 SDUI assignment.
//

import Testing
@testable import Cars24SDUI

struct AppLaunchModeTests {
    @Test("The SDUI variant is the default launch mode")
    func defaultsToSDUI() {
        #expect(AppLaunchMode(arguments: []) == .sdui)
    }

    @Test("The static-baseline argument selects the benchmark variant")
    func selectsStaticBaseline() {
        #expect(
            AppLaunchMode(arguments: [AppLaunchMode.staticBaselineArgument]) == .staticBaseline
        )
    }
}
