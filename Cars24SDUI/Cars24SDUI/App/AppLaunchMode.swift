//
//  AppLaunchMode.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

nonisolated enum AppLaunchMode: Equatable, Sendable {
    case sdui
    case staticBaseline

    static let staticBaselineArgument = "-static-baseline"

    init(arguments: [String]) {
        self = arguments.contains(Self.staticBaselineArgument) ? .staticBaseline : .sdui
    }
}
