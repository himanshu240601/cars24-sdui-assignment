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
    @State private var screenStore: SDUIScreenStore

    init() {
        launchMode = AppLaunchMode(arguments: ProcessInfo.processInfo.arguments)
        let repository = BundledSDUIScreenRepository()
        _screenStore = State(initialValue: SDUIScreenStore(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(launchMode: launchMode, screenStore: screenStore)
        }
    }
}
