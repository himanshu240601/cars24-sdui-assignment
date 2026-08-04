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
