//
//  Cars24SDUIApp.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

@main
struct Cars24SDUIApp: App {
    private let launchMode: AppLaunchMode

    init() {
        launchMode = AppLaunchMode(arguments: ProcessInfo.processInfo.arguments)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(launchMode: launchMode)
        }
    }
}
