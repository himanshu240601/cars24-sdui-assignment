//
//  AppRootView.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

struct AppRootView: View {
    let launchMode: AppLaunchMode
    let screenStore: SDUIScreenStore

    var body: some View {
        Group {
            switch launchMode {
            case .sdui:
                sduiBootstrapView
                    .task {
                        await screenStore.loadIfNeeded()
                    }
            case .staticBaseline:
                staticBaselinePlaceholder
            }
        }
        .accessibilityIdentifier("app-root")
    }

    @ViewBuilder
    private var sduiBootstrapView: some View {
        switch screenStore.state {
        case .idle, .loading:
            ProgressView("Loading screen")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("sdui-loading")
        case .content(let definition):
            SDUIScreenRenderer(definition: definition)
        case .unsupportedSchema(let major):
            ContentUnavailableView(
                "Unsupported screen version",
                systemImage: "exclamationmark.triangle",
                description: Text("This app supports SDUI version 1, but the loaded screen requires version \(major).")
            )
            .accessibilityIdentifier("sdui-unsupported-schema")
        case .invalidDocument:
            retryableFailureView(
                title: "Unable to load screen",
                description: "The bundled screen definition is invalid."
            )
            .accessibilityIdentifier("sdui-invalid-document")
        case .sourceFailure:
            retryableFailureView(
                title: "Unable to load screen",
                description: "The bundled screen definition could not be read."
            )
            .accessibilityIdentifier("sdui-source-failure")
        }
    }

    private var staticBaselinePlaceholder: some View {
        ContentUnavailableView(
            "Screen unavailable",
            systemImage: "rectangle.3.group",
            description: Text(launchMode.unavailableDescription)
        )
    }

    private func retryableFailureView(
        title: String,
        description: String
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark.triangle")
        } description: {
            Text(description)
        } actions: {
            Button("Retry") {
                Task {
                    await screenStore.retry()
                }
            }
        }
    }
}
