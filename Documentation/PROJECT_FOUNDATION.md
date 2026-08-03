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

The app currently displays a native, accessible unavailable-content state. This is a safe placeholder while the renderer does not yet exist.

The application accepts the launch argument -static-baseline. It selects the future static comparison variant; without it, the future SDUI variant is the default. The switch is a developer and benchmark harness, not a user-facing setting.

`AppLaunchMode` is explicitly `nonisolated`. Argument resolution is pure value logic and must stay independently testable even though this Swift 6 target defaults application code to the main actor. SwiftUI presentation remains main-actor-bound.

## Why this boundary exists

- It keeps the target buildable before the payload and renderer are introduced.
- It gives the required static-versus-SDUI comparison a testable launch seam.
- It establishes iOS 17+ and Swift 6 before concurrent code is added.
- It avoids third-party generators, packages, storage, networking, or state-management frameworks.

## Deferred work

- SDUI models, decoding, validation, registry, payload resources, and renderer.
- Design tokens and reusable visual components.
- Static baseline composition.
- Assignment UI and its JSON-defined finance interaction.
- Performance instrumentation and release benchmark scenarios.
