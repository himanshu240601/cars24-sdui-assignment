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

## Future records

Record 3 and later entries will be added only after they occur during approved milestones.

## Verification strategy for AI-assisted changes

- Review every proposed change against Documentation/AI_CONTEXT.md.
- Inspect diffs before accepting changes.
- Build and test on the declared iOS target once code exists.
- Test decoder, actions, fallback, and sheet behaviour with deterministic fixtures.
- Run accessibility checks and manual VoiceOver review for custom controls.
- Measure performance in release configuration before making any claim.
- Record rejected or rewritten AI output with the specific reason.
