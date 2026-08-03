//
//  AppLaunchMode.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

nonisolated enum AppLaunchMode: Equatable, Sendable {
    case sdui
    case staticBaseline

    static let staticBaselineArgument = "-static-baseline"

    init(arguments: [String]) {
        self = arguments.contains(Self.staticBaselineArgument) ? .staticBaseline : .sdui
    }

    var unavailableDescription: String {
        switch self {
        case .sdui:
            "A server-driven screen definition has not been loaded."
        case .staticBaseline:
            "A static benchmark screen has not been configured."
        }
    }
}
