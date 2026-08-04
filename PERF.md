# Performance Report

## Status

The performance harness is implemented and release-configured. Submission figures are **pending a connected physical iPhone**: the only detected iPhone was offline when this report was prepared. No simulator figure is presented as an assignment result.

A Release-mode iPhone 17 Pro simulator run is used only to validate the benchmark plumbing: signposts pair correctly, the static and SDUI routes launch, the full-feed route completes, and the test suite executes. Simulator scheduler, GPU, and launch behavior are not comparable to a physical device.

## Comparison scope

Both variants render the same canonical V1 home content, local assets, seven visual section types, and initial Tata NEXON EMI value.

| Variant | Included work | Excluded work |
|---|---|---|
| Static baseline | Direct SwiftUI source snapshot, the same visual primitives, local asset fallback, and the same initial content. | Fixture lookup, data read, wire decode, registry, validation, SDUI screen models, dynamic renderer, action dispatcher, and finance interaction. |
| SDUI | Bundled `home-v1.json` (6,544 bytes), repository read, tolerant decode, typed registry/validation, immutable screen definition, renderer, and bounded finance state. | Network, cache database, remote images, authentication, pagination, and any non-assignment product flow. |

The static view is intentionally duplicated source rather than seeded from decoded models. This keeps the control from exercising the SDUI path.

## Measurement setup

- Shared scheme: `Cars24SDUIPerformance`.
- Build configuration: `Release`; the app uses whole-module optimization.
- Test target: only `Cars24SDUIUITests` is built by the performance scheme, so release app code is not made testable solely to satisfy unit tests.
- One warm-up plus five recorded samples per XCTest measurement.
- Every measurement launches from a terminated app process.
- The canonical fixture, app version, device, orientation, locale, and Dynamic Type setting must remain unchanged within a comparison run.
- Record the median and min–max spread; compute SDUI overhead as `(SDUI median / Static median - 1) × 100`.

For a submission run, connect one physical iPhone, unlock it, keep it on external power, disable Low Power Mode, close unrelated foreground work, and avoid interacting with the device while the suite runs. If a thermal warning, background installation, or large variance occurs, discard that paired run and repeat it after the device stabilizes.

## Metrics and boundaries

| Assignment metric | Primary measurement | Boundary | Notes |
|---|---|---|---|
| Cold TTR | `XCTApplicationLaunchMetric(waitUntilResponsive: false)` | process launch to first responsive frame according to XCTest | This is the source of truth for submission TTR. |
| Cold TTI | `XCTApplicationLaunchMetric(waitUntilResponsive: true)` | process launch to XCTest responsiveness | This is the source of truth for submission TTI. |
| Full page / full-feed content | `BootstrapToFullContent` signpost | app bootstrap to the final canonical section's `onAppear` | A benchmark-only, non-animated `ScrollViewReader` route scrolls to the last section so UI-test swipe latency is excluded. Normal app launches remain at the top of the feed. |
| JSON fetch / parse | `FixtureRead`, `DecodeAndValidate` signposts | `Data(contentsOf:)`; then wire decode, registry and semantic validation | The current assignment uses a local fixture, so “fetch” means bundled-resource read. |
| SDUI view build | `ContentStateToFirstRender` signpost | content state publication to the dynamic renderer's first appearance | It isolates render work after validation. |
| Scroll jank | `XCTOSSignpostMetric.scrollingAndDecelerationMetric` | eight fixed full-feed upward swipes | Capture FPS, hitch count/duration, and frame pacing on the physical device. |

The custom bootstrap intervals deliberately do **not** claim to be cold TTR or TTI: they start inside `App.init`, after process launch. They provide diagnostic phase timing alongside XCTest’s native launch metric.

## Running the physical-device matrix

Replace `<physical-device-udid>` with the connected iPhone identifier shown by `xcrun xctrace list devices`.

```sh
xcodebuild test \
  -project Cars24SDUI/Cars24SDUI.xcodeproj \
  -scheme Cars24SDUIPerformance \
  -configuration Release \
  -destination 'id=<physical-device-udid>' \
  -only-testing:Cars24SDUIUITests/PerformanceBenchmarkTests \
  -resultBundlePath /private/tmp/cars24-sdui-physical-release.xcresult
```

Extract every test’s raw samples before calculating medians:

```sh
xcrun xcresulttool get test-results tests \
  --path /private/tmp/cars24-sdui-physical-release.xcresult

xcrun xcresulttool get test-results metrics \
  --path /private/tmp/cars24-sdui-physical-release.xcresult \
  --test-id 'PerformanceBenchmarkTests/testSDUITimeToFirstRender()'
```

Run the same suite a second time with the static and SDUI test methods selected in the opposite order if the first comparison has an overlapping or unusually wide spread. Retain both result bundles; do not cherry-pick only favorable samples.

## Physical-device results table

Fill this table only from the physical-device result bundle above.

| Metric | Static median (s) | Static spread (s) | SDUI median (s) | SDUI spread (s) | SDUI overhead |
|---|---:|---:|---:|---:|---:|
| Cold TTR | Pending | Pending | Pending | Pending | Pending |
| Cold TTI | Pending | Pending | Pending | Pending | Pending |
| Full-feed content | Pending | Pending | Pending | Pending | Pending |
| Fixture read | N/A | N/A | Pending | Pending | N/A |
| Decode and validate | N/A | N/A | Pending | Pending | N/A |
| Content state to first render | N/A | N/A | Pending | Pending | N/A |
| Scroll frame pacing / hitches | Pending | Pending | Pending | Pending | Qualitative + counts |

## Simulator preflight finding

The current Release simulator suite completed all nine scenarios. It validated the named signposts and the benchmark-only full-feed route. The simulator did not export `XCTApplicationLaunchMetric` or scrolling/deceleration samples reliably, so no simulator medians, comparison percentage, or optimization claim is carried into the table above.

This is intentional reporting discipline: the first three-sample exploratory run showed launch and full-feed variance larger than the small local-fixture decode cost, which would make a simulator-derived “SDUI overhead” misleading.

## Optimization decision

No product optimization is applied before a physical-device baseline shows a repeatable bottleneck.

- Do not cache a decoded screen merely to reduce this one local 6.5 KB fixture’s startup number: that would mask the SDUI path the assignment is asking to compare.
- Do not eagerly build every feed section in the normal app: it would trade ordinary scroll efficiency for a benchmark artifact.
- If physical data shows `DecodeAndValidate` is material and repeatable, first inspect the document size and component count. Only then consider a repository-level immutable decoded-document cache with explicit invalidation semantics.
- If full-feed or scroll data shows rendering pressure, inspect view hierarchy and local media first; preserve `LazyVStack` and reduce unnecessary body invalidations before introducing architecture changes.

## Interview discussion points

- The static control is fair because it shares content and visual leaves, not SDUI execution.
- XCTest launch metrics own user-visible cold-start reporting; signposts explain where SDUI work happens after bootstrap.
- The full-feed route is test-only and symmetric, preventing UI-automation gesture latency from being misreported as renderer time.
- Five measured samples plus a warm-up, median/spread, and retained result bundles are more defensible than one “best” launch.
- A benchmark result should drive an optimization; without connected-device evidence, adding cache or preloading behavior would be premature.
