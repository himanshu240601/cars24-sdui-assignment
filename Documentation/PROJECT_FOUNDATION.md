# Native iOS Project Foundation

## Project facts

| Item | Decision |
|---|---|
| Xcode project | Cars24SDUI/Cars24SDUI.xcodeproj |
| Xcode template | Native iOS App, SwiftUI interface, Swift language, no storage layer. |
| Deployment target | iOS 17.0. |
| Device family | iPhone only. The assignment and supplied visual reference are iPhone-focused; an iPad-specific experience is not inferred. |
| Language mode | Swift 6. |
| App target | Cars24SDUI. |
| Unit tests | Swift Testing target. |
| UI tests | XCTest UI test target. |
| Dependencies | None. |
| Source-control strategy | The repository root owns Git history; Xcode did not create a nested repository. |

## Foundation behaviour

The default SDUI launch path reads the bundled V1 fixture through a typed repository and main-actor screen store. It renders all seven declared feed section types: discovery header, two horizontal rails, standard service grid, vehicle rail, highlighted service grid, and promo banner. It preserves native loading, compatibility, retryable-error, and bounded interaction states. The declared finance presentation is a native sheet whose options update the selected declared EMI value through the bounded action dispatcher; the remaining V1 sections are static unless an approved executable action is explicitly implemented.

The application accepts the launch argument `-static-baseline`. It selects `StaticBaselineHomeView`, a direct SwiftUI source snapshot of the canonical V1 home content; without it, the SDUI variant is the default. The static branch does not attach the SDUI load task, so it does not read the fixture or invoke its decode, registry, validation, renderer, or action-dispatch path. It reuses only visual primitives (tokens, local-media fallback, and section title) and intentionally leaves the initial EMI noninteractive. The switch is a developer and benchmark harness, not a user-facing setting.

`AppLaunchMode` is explicitly `nonisolated`. Argument resolution is pure value logic and must stay independently testable even though this Swift 6 target defaults application code to the main actor. SwiftUI presentation remains main-actor-bound.

## Why this boundary exists

- It keeps the target buildable before the payload and renderer are introduced.
- It gives the required static-versus-SDUI comparison a testable launch seam.
- It establishes iOS 17+ and Swift 6 before concurrent code is added.
- It avoids third-party generators, packages, storage, networking, or state-management frameworks.

## Deferred work

- Performance instrumentation and release benchmark scenarios.
- Additional design tokens or reusable visual components only when a demonstrated fidelity or maintainability need justifies them.
