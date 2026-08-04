# AI Workflow Evidence

## Status

This is a living evidence log. It records actual prompts, decisions, rejected approaches, and verification work as they occur. It does not invent future prompt histories or failures.

## Tool stack

- Codex desktop for architecture review, repository work, and implementation assistance.
- Local PDF extraction and rendering for assignment review.
- Local image inspection for supplied iOS reference screenshots.
- Official Apple Human Interface Guidelines and SwiftUI documentation for current platform guidance.

## Context and rules files

- Documentation/AI_CONTEXT.md - active scope, architecture, and quality constraints.
- Documentation/ARCHITECTURE.md - current decision record.
- Documentation/SDUI_SCHEMA_V1.md - payload boundary and compatibility policy.

## Prompt-to-outcome record

### Record 1 - architecture before implementation

Prompt intent: act as a senior iOS engineer, analyse the written assignment and screenshots, do not generate code, and wait for milestone approval.

Outcome: a scoped SwiftUI architecture was selected: iOS 17+, bundled JSON, typed SDUI models, explicit registry, bounded actions, native sheet, manual injection, and a separate static benchmark control.

Rejected output or approach: starting from a pixel-copy of the screenshot, building search/profile/tab functionality, a backend, or a generic remote UI engine.

Why rejected: those approaches either add screenshot-only features, dilute the SDUI contract, weaken benchmark fairness, or exceed the assignment timebox.

Verification: compare every decision with the written brief, inspect the reference screenshots separately from the functional scope, and use official Apple guidance for HIG/accessibility recommendations.

### Record 2 - native project foundation

Prompt intent: create only the native Xcode foundation after Milestone 2 approval; do not add the SDUI contract, fixture, renderer, or assignment UI.

Outcome: a buildable iPhone-only SwiftUI application was created with iOS 17.0, Swift 6, no third-party dependencies, a safe root state, unit/UI test targets, and an argument-selectable future static-baseline seam.

Rejected output or approach: hand-writing the Xcode project file, adding a dependency-injection or state-management framework, or putting a temporary hard-coded home screen in the root view.

Why rejected: the native Xcode template is less error-prone; external frameworks do not solve a current assignment requirement; and a fake home screen would blur the approved boundary before the SDUI contract exists.

AI failure caught: the first implementation allowed the pure `AppLaunchMode` value to inherit the target's default `MainActor` isolation. Swift 6 then rejected synchronous unit-test access to that value.

Correction and verification: declare the pure launch-mode type `nonisolated`, preserving main-actor isolation for SwiftUI while keeping argument parsing independently testable. `xcodebuild test` passed on an iPhone 16 simulator after the correction.

### Record 3 - typed SDUI contract and fixtures

Prompt intent: implement only the V1 wire contract, validation outcomes, and deterministic bundled fixtures after Milestone 3 approval; do not create a renderer or assignment screen.

Outcome: the app now decodes a tolerant raw document, maps known types through a typed registry, preserves unknown nodes, isolates invalid known nodes, and distinguishes compatible, unsupported-schema, and invalid-document outcomes. Finance content is a declared presentation rather than an invisible feed section.

Rejected output or approach: direct tagged-enum decoding into view models, raw dictionaries in SwiftUI, a generic layout/style DSL, and an inline `financeSheet` section.

Why rejected: direct tagged-enum decoding makes an unknown future component fail the entire payload; raw dictionaries would leak wire concerns into views; a generic DSL exceeds the assignment; and an inline sheet would force renderer-specific hiding logic.

Verification: ten deterministic decoder tests cover the primary fixture, unknown component, invalid known component, incompatible major version, duplicate root IDs, malformed data, tolerated unknown fields/actions, malformed action shapes, complete action vocabulary, and a missing finance reference. The suite also retains two foundation unit tests and one UI launch test. A simulator build confirmed each JSON fixture is copied into the app bundle.

### Record 4 - local repository and screen-load state

Prompt intent: after Milestone 4 approval, introduce only the asynchronous bundled-load boundary and generic root states. Do not start the SDUI renderer, action dispatcher, or visual assignment screen.

Outcome: a single repository protocol and bundled implementation resolve `home-v1.json`, map source/compatibility/validation outcomes, and feed an `@MainActor` observable screen store. The root view presents a native progress indicator, compatibility fallback, retryable error states, or a renderer-pending host. The static baseline bypasses the load task.

Rejected output or approach: direct bundle reads in a SwiftUI view, a separate source/use-case layer, a dependency-injection framework, automatic retry, cache, networking, `Task.detached`, or a premature component renderer.

Why rejected: direct reads would couple I/O, parsing, and UI lifecycle; extra layers would exceed the small test seam required here; retries/caching/networking have no local-fixture requirement; and a renderer would cross the approved milestone boundary.

Verification: `xcodebuild build-for-testing` compiled the application and test targets under Swift 6. A host-side execution of the production repository read `home-v1.json` from the built app bundle, preserved a typed missing-resource error, and drove the main-actor store to content. Simulator XCTest execution remains pending because the local CoreSimulator service is unavailable before tests start.

### Record 5 - first native SDUI renderer subset

Prompt intent: after Milestone 5 approval, render only the typed discovery header, illustrated-action rail, and product rail, plus local unknown/invalid fallbacks. Do not build the remaining section types, actions, finance sheet, navigation, or screenshot-only controls.

Outcome: `SDUIScreenRenderer` owns one vertical `ScrollView` with an exhaustive typed-section switch. The approved sections have small semantic SwiftUI leaf views and horizontally lazy rails with stable server IDs. Local asset tokens use a decorative SF Symbol placeholder while original media is absent. Known-but-deferred V1 types are not incorrectly presented as unsupported.

Rejected output or approach: a second renderer registry, `AnyView`, a generic rail/layout engine, hard-coded screenshot images, fake tappable cards, a fixture-selection application feature, and a complete seven-section renderer.

Why rejected: the existing typed model registry is the only registry needed; generic visual abstractions would obscure two distinct rail layouts; screenshot media is not assignment source; no JSON action is executable yet; and the remaining renderers exceed the approved milestone size.

Verification: `xcodebuild build-for-testing` compiled the application and test targets under Swift 6 after the renderer was introduced. The UI smoke test now asserts decoded header and rail text rather than a renderer-pending placeholder. Simulator XCTest execution remains pending because the local CoreSimulator service is unavailable before tests start.

### Record 6 - standard service-grid renderer

Prompt intent: after Milestone 6 approval, render only the typed `serviceGrid` section with a small native tile primitive. Do not change the contract/data layers or add the highlighted grid, vehicle rail, promotions, actions, finance sheet, navigation, or screenshot-only controls.

Outcome: the typed renderer now routes `serviceGrid` to a `LazyVGrid` driven by the already validated two-or-three-column payload value. At accessibility Dynamic Type sizes, a three-column grid narrows to two columns so labels can remain readable. Tiles use stable item IDs, semantic system surfaces, deterministic local-media placeholders, and no interaction before the approved action dispatcher exists.

Rejected output or approach: a generic grid engine, an adaptive layout that ignored the payload column count, another schema or validation layer, a fixture-selection launch feature, fake tappable tiles, and rendering the visually related highlighted grid in the same milestone.

Why rejected: the existing typed contract is sufficient; the normal layout must honor server configuration; the renderer has no need to mutate its input; test-only launch configuration is not product scope; and larger visual/action increments would make the review boundary unclear.

Verification: `xcodebuild build-for-testing` compiled the application and test targets under Swift 6. The primary fixture test now asserts the exact typed service-grid input, while the existing invalid-grid fixture continues to prove invalid column counts localize safely. The UI smoke test adds the grid title and first item. An `xcodebuild test` run began on an iPhone 16 test clone, but the local CoreSimulator service crashed before Xcode finalized its result bundle; no runtime XCTest pass is claimed.

### Record 7 - bounded finance action/state foundation

Prompt intent: after Milestone 7 approval, implement the finite JSON action reducer and screen interaction state needed by the finance flow. Do not add a vehicle renderer, native sheet, any action-emitting view, navigation, persistence, or a generic event system.

Outcome: `SDUIActionDispatcher` is a pure reducer over the immutable typed definition and a two-field interaction value (`selectedTenureOptionID` and `activeSheetID`). The main-actor screen store owns that value, seeds the default tenure when content loads, and exposes a narrow action-dispatch method. Known actions can only target declared finance-sheet/option data; unsupported, unavailable, unresolved, and pre-content actions leave state unchanged.

Rejected output or approach: a generic command/reducer framework, event bus, mutable payload model, selection dictionary, persistence, analytics, finance calculation, action logic in a SwiftUI view, or requiring a sheet to be visible before the contractually valid selection action may run.

Why rejected: V1 has one finite selection key and three action kinds; the document already declares display values and targets; UI lifecycle is not a contract condition for `setSelection`; and the remaining approaches add unsupported state or obscure the small, testable boundary.

Verification: deterministic main-actor store tests cover initial tenure seeding, valid selection/present/dismiss transitions, document immutability, and no-op behavior before content or for unresolved/nonexecutable actions. `xcodebuild build-for-testing` compiled the application and test targets under Swift 6. On an iPhone 16 simulator, `xcodebuild test -only-testing:Cars24SDUITests` passed all 23 unit tests and `xcodebuild test -only-testing:Cars24SDUIUITests` passed both UI smoke tests.

### Record 8 - vehicle rail and native finance presentation

Prompt intent: after Milestone 8 approval, implement only the typed vehicle rail and assignment-required finance interaction: declared EMI action, native sheet, tenure options, and visible EMI update. Do not add vehicle detail navigation, favourite actions, finance calculation, local sheet state, highlighted service content, promotions, search, or screenshot-only controls.

Outcome: the root injects immutable content, the bounded interaction value, and one action closure into the renderer. The vehicle rail resolves only declared finance-sheet data, renders the selected declared `emiText`, and emits the exact vehicle action. One native SwiftUI sheet derives its visibility from `activeSheetID`; interactive dismissal routes through the reducer. Finance rows are full-size native buttons with visible/VoiceOver selected state, while their values stay in the decoded payload rather than a client calculator.

Rejected output or approach: passing the observable store into leaf views, a generic presentation router, a `selectedVehicleID`, a selection dictionary, a local `@State` tenure value, a custom modal, a finance calculator, vehicle navigation, or making every action-bearing payload field interactive.

Why rejected: V1 declares one bounded tenure binding and one presentation type. The decoder already validates references, and native SwiftUI sheet behavior gives accessible, expected dismissal without more product surface or architecture.

AI issue caught: the first UI test queried a title that appears both in the finance CTA and in the sheet. The test was tightened to scope title, option, EMI, and dismissal assertions to the identified native sheet, so it verifies the presented surface rather than an ambiguous duplicate label.

Verification: `xcodebuild build-for-testing` compiled the Swift 6 application and both test targets. The simulator unit suite passed all 23 tests. The focused UI path passed after the selector correction: tap declared EMI action, open the native sheet, select 36 months, observe the declared EMI value, swipe the sheet down, and retain the updated vehicle EMI. The final serial UI suite passed all three UI tests on an iPhone 17 Pro simulator.

### Record 9 - highlighted service grid and promotional banner

Prompt intent: after Milestones 8 and 9 approval, render only the remaining typed `highlightedServiceGrid` and `promoBanner` feed sections. Do not change the contract, repository, action vocabulary, finance flow, navigation, or introduce screenshot-only controls.

Outcome: the renderer now routes the two existing component types to separate, focused SwiftUI leaves because their visual structures differ materially. The highlighted grid honors its typed title, accent, column count, and items; it retains the declared layout at normal Dynamic Type sizes and uses a two-column readability fallback at accessibility sizes. The promo banner uses its typed title, optional subtitle, image reference, and accessibility label. Both use deterministic decorative media fallbacks while original artwork is absent. The V1 banner declares no executable action, so it remains static rather than gaining a fabricated CTA.

Rejected output or approach: a generic configurable section engine, a new action handler for every optional model action, a promotional CTA, screenshot-derived navigation, remote image loading, additional fixtures, and a static-baseline implementation in the same milestone.

Why rejected: the existing typed contract already distinguishes the two layouts; an abstraction would hide their simple semantics. An optional action field is not authorization to add client behaviour, and the assignment does not require remote media, extra flows, or benchmark implementation in this increment.

AI issue caught: the initial UI assertion incorrectly expected child labels inside accessibility-grouped static tiles and banners to remain individually queryable. The test was corrected to scroll the identified feed and assert the single semantic accessibility elements using their stable identifiers. This matches the VoiceOver hierarchy instead of testing an implementation detail of `Text` subviews.

Verification: `xcodebuild build-for-testing` compiled the Swift 6 app and both test targets. The unit suite passed all 23 tests, including the canonical fixture's typed highlighted-grid and promo-banner assertions. The focused UI test passed after the accessibility correction, and the final serial UI suite passed all three UI tests on an iPhone 17 Pro simulator.

### Record 10 - direct static performance baseline

Prompt intent: after Milestone 10 approval, implement only a direct native SwiftUI baseline for the required SDUI comparison. It must display the canonical home content while bypassing the SDUI load/decode/render/action path. Do not add a second finance interaction, a generic shared renderer, or new product capability.

Outcome: `-static-baseline` now selects a feature-local `StaticBaselineHomeView` with a direct source-code snapshot of the canonical V1 values and local media tokens. It renders the same seven visual sections, exposes stable baseline-only accessibility identifiers, and keeps the initial Tata NEXON EMI as static text. The branch returns this view directly, so the SDUI load task does not run; the repository read, decoding, registry, validation, renderer, and action dispatcher are not exercised. Small visual primitives are shared only where they do not interpret the SDUI document.

Rejected output or approach: reusing `SDUIScreenRenderer`, decoding the fixture to seed the baseline, duplicating the finance sheet or action state, making the whole screen one hard-coded view body, or adding a generic static-screen framework.

Why rejected: any renderer or decoded model reuse would invalidate the comparison control; a second interactive flow would add unsupported product behavior; and both a monolithic view and a new framework would make a small fixed screen harder to review and maintain.

AI issue caught: the first baseline UI test could not discover the promo banner because the root section identifier replaced the grouped banner identifier. Adding the same accessibility containment boundary used by the SDUI renderer preserves both section and leaf identifiers without altering content or interaction.

Verification: `xcodebuild test -only-testing:Cars24SDUITests` passed all 23 unit tests on an iPhone 17 Pro simulator. The final serial `xcodebuild test -only-testing:Cars24SDUIUITests` run passed all three UI tests: full SDUI feed, finance-sheet update/dismissal, and isolated static baseline.

### Record 11 - release performance harness and reporting protocol

Prompt intent: after Milestone 11 approval, add only the assignment-required, release-mode performance instrumentation, comparison scheme, benchmark scenarios, and report. Do not tune product behavior, manufacture physical-device figures, or add caching/preloading in advance of measured evidence.

Outcome: a Release-only UI-test configuration compares the direct static baseline and SDUI path through native launch metrics, paired `os_signpost` intervals, a symmetric test-only full-feed route, and the system scrolling/deceleration metric. The report fixes the fixture, launch, sampling, median/spread, and physical-device protocol and leaves the required result table explicitly pending until a connected iPhone is available. Normal launches never receive the benchmark-only scroll route or emitted signposts.

Rejected output or approach: naming app-init signposts as cold TTR/TTI, using simulator timings as submission figures, timing full-feed rendering around UI-test swipes, caching the decoded fixture before a bottleneck is observed, or making Release app code testable just for the unit target.

Why rejected: custom markers begin after process launch; simulator scheduling and launch behavior are not physical-device evidence; automation gesture latency is not renderer latency; an optimization would contaminate the comparison before data exists; and the performance scheme needs only the UI-test target.

AI issue caught: the first implementation treated the app-process signposts as launch metrics and used the UI test's scroll gestures inside the full-feed interval. The markers were renamed to diagnostic bootstrap intervals, `XCTApplicationLaunchMetric` became the documented source of truth for cold TTR/TTI, and the benchmark-only `ScrollViewReader` route now reaches the final section without measuring XCTest gesture overhead. Review also exposed an unmatched full-content signpost in non-full-feed scenarios and a first benchmark iteration that could inherit a running app; the signpost now starts only for the matching route and every benchmark launch terminates first. A serial UI run also exposed a finance test that reused a prior app instance and attempted to tap an offscreen existing element; its helper now terminates before launch and reveals elements only once they are hittable.

Verification: `xcodebuild -list` discovers both `Cars24SDUI` and `Cars24SDUIPerformance`. The normal Release app build succeeded. The final Debug regression suite passed all 26 tests. A Release iPhone 17 Pro simulator preflight passed the seven non-scroll benchmark scenarios; after the deterministic fixed-swipe refinement, both Release scroll scenarios passed separately, and the hardened full-feed route passed again. No physical-device result or optimization claim is made because the only detected physical iPhone was offline.

## Future records

Future records will be added only after they occur during approved milestones.

## Verification strategy for AI-assisted changes

- Review every proposed change against Documentation/AI_CONTEXT.md.
- Inspect diffs before accepting changes.
- Build and test on the declared iOS target once code exists.
- Test decoder, actions, fallback, and sheet behaviour with deterministic fixtures.
- Run accessibility checks and manual VoiceOver review for custom controls.
- Measure performance in release configuration before making any claim.
- Record rejected or rewritten AI output with the specific reason.
