//
//  AppRootView.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

struct AppRootView: View {
    let launchMode: AppLaunchMode

    var body: some View {
        ContentUnavailableView(
            "Screen unavailable",
            systemImage: "rectangle.3.group",
            description: Text(launchMode.unavailableDescription)
        )
        .accessibilityIdentifier("app-root")
    }
}
