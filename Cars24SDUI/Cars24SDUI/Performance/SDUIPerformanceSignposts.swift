//
//  SDUIPerformanceSignposts.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation
import os

/// Benchmark-only signposts for the local SDUI execution path.
///
/// The instrumentation is active only when the app is launched with
/// `-performance-benchmark`. It contains no user data, emits no benchmark
/// events, and changes no product behavior on normal launches.
nonisolated enum SDUIPerformanceSignposts {
    nonisolated enum Interval: String {
        case bootstrapToFirstRender = "BootstrapToFirstRender"
        case bootstrapToInteractionReady = "BootstrapToInteractionReady"
        case fixtureRead = "FixtureRead"
        case decodeAndValidate = "DecodeAndValidate"
        case contentStateToFirstRender = "ContentStateToFirstRender"
        case bootstrapToFullContent = "BootstrapToFullContent"
    }

    static let subsystem = "com.himanshugoyal.Cars24SDUI"
    static let category = "SDUIBenchmark"

    private static let benchmarkArgument = "-performance-benchmark"
    private static let scrollToEndArgument = "-performance-scroll-to-end"
    private static let log = OSLog(subsystem: subsystem, category: category)
    private static let isEnabled = ProcessInfo.processInfo.arguments.contains(benchmarkArgument)

    /// Enables the benchmark-only full-feed route. Production launches retain
    /// the normal initial scroll position.
    static let shouldScrollToEnd = isEnabled && ProcessInfo.processInfo.arguments.contains(
        scrollToEndArgument
    )

    static func begin(_ interval: Interval) {
        guard isEnabled else {
            return
        }

        os_signpost(.begin, log: log, name: name(for: interval))
    }

    static func end(_ interval: Interval) {
        guard isEnabled else {
            return
        }

        os_signpost(.end, log: log, name: name(for: interval))
    }

    /// Marks the initial SwiftUI screen as present, then waits one main-loop
    /// turn before marking the internal bootstrap phase as ready. The native
    /// `XCTApplicationLaunchMetric` remains the source of truth for cold TTR
    /// and TTI because these app-process intervals begin after process launch.
    static func markInitialScreenReady() {
        guard isEnabled else {
            return
        }

        end(.bootstrapToFirstRender)

        DispatchQueue.main.async {
            end(.bootstrapToInteractionReady)
        }
    }

    private static func name(for interval: Interval) -> StaticString {
        switch interval {
        case .bootstrapToFirstRender:
            "BootstrapToFirstRender"
        case .bootstrapToInteractionReady:
            "BootstrapToInteractionReady"
        case .fixtureRead:
            "FixtureRead"
        case .decodeAndValidate:
            "DecodeAndValidate"
        case .contentStateToFirstRender:
            "ContentStateToFirstRender"
        case .bootstrapToFullContent:
            "BootstrapToFullContent"
        }
    }
}
