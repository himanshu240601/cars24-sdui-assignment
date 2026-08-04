#if PERFORMANCE_BENCHMARKS
import XCTest

/// Release-only, opt-in comparison tests for the static and SDUI paths.
///
/// The UI-test target compiles this class only for its Release benchmark
/// configuration. Run it through the documented `PERF.md` command so all
/// samples share the same build configuration, device, fixture, and scroll route.
final class PerformanceBenchmarkTests: XCTestCase {
    @MainActor
    func testStaticBaselineTimeToFirstRender() {
        measureLaunch(
            for: .staticBaseline,
            waitUntilResponsive: false,
            signpostName: BenchmarkSignpost.bootstrapToFirstRender
        )
    }

    @MainActor
    func testSDUITimeToFirstRender() {
        measureLaunch(
            for: .sdui,
            waitUntilResponsive: false,
            signpostName: BenchmarkSignpost.bootstrapToFirstRender
        )
    }

    @MainActor
    func testStaticBaselineTimeToInteractive() {
        measureLaunch(
            for: .staticBaseline,
            waitUntilResponsive: true,
            signpostName: BenchmarkSignpost.bootstrapToInteractionReady
        )
    }

    @MainActor
    func testSDUITimeToInteractive() {
        measureLaunch(
            for: .sdui,
            waitUntilResponsive: true,
            signpostName: BenchmarkSignpost.bootstrapToInteractionReady
        )
    }

    @MainActor
    func testStaticBaselineFullScreenRender() {
        measureFullScreenRender(for: .staticBaseline)
    }

    @MainActor
    func testSDUIFullScreenRender() {
        measureFullScreenRender(for: .sdui)
    }

    @MainActor
    func testSDUIExecutionBreakdown() {
        let metrics = BenchmarkSignpost.breakdownIntervals.map {
            XCTOSSignpostMetric(
                subsystem: BenchmarkSignpost.subsystem,
                category: BenchmarkSignpost.category,
                name: $0
            )
        }

        measure(metrics: metrics, options: measurementOptions) {
            let app = makeApplication(for: .sdui, instrumented: true)
            app.launch()

            XCTAssertTrue(
                rootElement(in: app, for: .sdui).waitForExistence(timeout: 5)
            )

            app.terminate()
        }
    }

    @MainActor
    func testStaticBaselineScrollPerformance() {
        measureScrollPerformance(for: .staticBaseline)
    }

    @MainActor
    func testSDUIScrollPerformance() {
        measureScrollPerformance(for: .sdui)
    }

    @MainActor
    private func measureLaunch(
        for variant: BenchmarkVariant,
        waitUntilResponsive: Bool,
        signpostName: String
    ) {
        let metrics: [any XCTMetric] = [
            XCTOSSignpostMetric(
                subsystem: BenchmarkSignpost.subsystem,
                category: BenchmarkSignpost.category,
                name: signpostName
            ),
            XCTApplicationLaunchMetric(waitUntilResponsive: waitUntilResponsive)
        ]

        measure(metrics: metrics, options: measurementOptions) {
            let app = makeApplication(for: variant, instrumented: true)
            app.launch()

            XCTAssertTrue(
                rootElement(in: app, for: variant).waitForExistence(timeout: 5)
            )

            app.terminate()
        }
    }

    @MainActor
    private func measureFullScreenRender(for variant: BenchmarkVariant) {
        let metric = XCTOSSignpostMetric(
            subsystem: BenchmarkSignpost.subsystem,
            category: BenchmarkSignpost.category,
            name: BenchmarkSignpost.bootstrapToFullContent
        )

        measure(metrics: [metric], options: measurementOptions) {
            let app = makeApplication(
                for: variant,
                instrumented: true,
                scrollsToEnd: true
            )
            app.launch()

            let root = rootElement(in: app, for: variant)
            XCTAssertTrue(root.waitForExistence(timeout: 5))

            let completionMarker = app.descendants(matching: .any)[variant.completionIdentifier]
            XCTAssertTrue(completionMarker.waitForExistence(timeout: 5))

            app.terminate()
        }
    }

    @MainActor
    private func measureScrollPerformance(for variant: BenchmarkVariant) {
        measure(
            metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric],
            options: measurementOptions
        ) {
            let app = makeApplication(for: variant)
            app.launch()

            let root = rootElement(in: app, for: variant)
            XCTAssertTrue(root.waitForExistence(timeout: 5))

            let completionMarker = app.descendants(matching: .any)[variant.completionIdentifier]
            scrollToEnd(root)
            XCTAssertTrue(completionMarker.exists)

            app.terminate()
        }
    }

    @MainActor
    private func makeApplication(
        for variant: BenchmarkVariant,
        instrumented: Bool = false,
        scrollsToEnd: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        // Preserve a cold process boundary even if another UI test ran first.
        app.terminate()
        var arguments = variant.launchArguments

        if instrumented {
            arguments.append("-performance-benchmark")
        }

        if scrollsToEnd {
            arguments.append("-performance-scroll-to-end")
        }

        app.launchArguments = arguments
        return app
    }

    @MainActor
    private func rootElement(
        in app: XCUIApplication,
        for variant: BenchmarkVariant
    ) -> XCUIElement {
        app.scrollViews[variant.rootIdentifier]
    }

    @MainActor
    private func scrollToEnd(_ root: XCUIElement) {
        for _ in 0..<8 {
            root.swipeUp()
        }
    }

    private var measurementOptions: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        return options
    }
}

private enum BenchmarkVariant {
    case staticBaseline
    case sdui

    var launchArguments: [String] {
        switch self {
        case .staticBaseline:
            ["-static-baseline"]
        case .sdui:
            []
        }
    }

    var rootIdentifier: String {
        switch self {
        case .staticBaseline:
            "static-baseline-home"
        case .sdui:
            "sdui-screen-cars24-home"
        }
    }

    var completionIdentifier: String {
        switch self {
        case .staticBaseline:
            "static-baseline-section-spotify-promo"
        case .sdui:
            "sdui-promo-spotify-promo"
        }
    }
}

private enum BenchmarkSignpost {
    static let subsystem = "com.himanshugoyal.Cars24SDUI"
    static let category = "SDUIBenchmark"
    static let bootstrapToFirstRender = "BootstrapToFirstRender"
    static let bootstrapToInteractionReady = "BootstrapToInteractionReady"
    static let bootstrapToFullContent = "BootstrapToFullContent"
    static let breakdownIntervals = [
        "FixtureRead",
        "DecodeAndValidate",
        "ContentStateToFirstRender"
    ]
}
#endif
