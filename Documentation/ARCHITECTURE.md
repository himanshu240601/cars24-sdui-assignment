# Architecture Decision Record

## Purpose

Define a small, production-shaped SDUI system for one iOS assignment screen. The goal is not to build a generic remote UI platform; it is to show a safe, extensible boundary that can render a second related screen with JSON-only changes where existing components apply.

## Chosen reference scope

The visual reference is the supplied Cars24 iOS home/discovery feed. It contributes the branded discovery hierarchy, image-led rails, utility grid, vehicle-card information density, and white content surface.

The written assignment adds the required tenure selector and bottom sheet. Those behaviours are attached to the vehicle card's visible EMI information. This is an assignment-driven interaction; it is not claimed to be a feature specified by the screenshot.

## Architectural flow

Local payload source -> asynchronous repository -> tolerant wire decode -> registry and validation -> immutable typed screen definition -> native SwiftUI renderer.

JSON action -> action dispatcher -> immutable interaction state or native presentation -> SwiftUI update.

The typed screen definition keeps scrollable `sections` separate from declared `presentations`. The finance sheet is a presentation, not an invisible row inside the feed, so the renderer will not require a component-ID-specific skip rule.

The static benchmark screen uses the same content, local assets, and reusable leaf views, but bypasses payload loading, decoding, the registry, and dynamic screen-tree rendering.

## Decisions

| Decision | Why it is appropriate | Deliberately rejected |
|---|---|---|
| iOS 17+ SwiftUI | Modern Swift, Observation, and async/await support a compact native implementation. | UIKit-only implementation and compatibility layers that the brief does not require. |
| One application target | The brief values depth over breadth. | A second platform or premature package/module split. |
| Bundled JSON payloads | Deterministic demos and performance data; no live API is required. | Backend, network retries, cache database, and pagination. |
| Typed render models | Raw JSON never reaches a SwiftUI view; validation is testable. | Untyped dictionaries, force casts, reflection, and parsing in view bodies. |
| Explicit registry plus exhaustive renderer | Server names map to native component kinds without pervasive type erasure. | A plugin runtime or arbitrary AnyView-based renderer. |
| Bounded actions | Server describes intent while the client retains safe behaviour. | Remote scripts, arbitrary expressions, or a generic financial-calculation engine. |
| Screen-level observable state | Loading, content, error, tenure selection, and active sheet have one owner. | Global state, event buses, or a third-party state framework. |
| Manual constructor injection | Dependencies remain explicit and easily testable. | Service locator or dependency-injection framework. |

## Ownership boundaries

| Area | Responsibility |
|---|---|
| App composition | Constructs the repository, registry, and screen store. Selects static or SDUI launch mode for development and benchmarks. |
| Data source | Reads the bundled payload asynchronously. It has no UI knowledge. |
| Decoding and validation | Converts the wire document into safe typed sections/presentations and captures invalid content locally. |
| Component registry | Maps known server component names to component kinds and validation rules. |
| Renderer | Turns a validated component model into a native SwiftUI view. |
| Action dispatcher | Validates and handles a finite JSON action vocabulary. |
| Screen state | Owns load state, selected tenure, and sheet presentation. It never mutates the decoded document. |
| Leaf components | Render immutable content and emit supplied actions. They do not decode JSON or hold page-specific logic. |
| Design system | Provides small shared visual primitives and semantic tokens, not an oversized component library. |

## Visual and HIG guardrails

- Preserve the reference's branded hierarchy, card rhythm, and content emphasis without copying screenshot-only product behaviour.
- Do not recreate the iOS status bar.
- Do not show a nonfunctional search field, profile control, favourite action, or multi-tab navigation.
- Use native buttons and sheets for in-scope controls.
- Support Dynamic Type, VoiceOver, Increase Contrast, Reduce Motion, safe areas, and adequate touch targets.
- Treat decorative media as decorative for accessibility; expose vehicle and finance data in a concise logical order.

## V1 component inventory

The first payload contains only the following scrollable semantic component types:

| Component type | Purpose |
|---|---|
| discoveryHeader | Branded context and noninteractive heading hierarchy. |
| illustratedActionRail | Horizontal cards for high-level discovery actions or promotions. |
| productRail | Horizontal image-and-label product discovery cards. |
| serviceGrid | Vertical utility-card grid. |
| vehicleRail | Horizontal vehicle cards with price and EMI information. |
| highlightedServiceGrid | Visually distinct coloured service grouping or promotional utility section. |
| promoBanner | Optional full-width promotional visual section. |

The assignment-required finance sheet is declared separately as a presentation:

| Presentation type | Purpose |
|---|---|
| financeSheet | Sheet content, tenure options, initial selection, and JSON-defined selection actions. |

This is more than the minimum five visual section types, but intentionally avoids generic containers, arbitrary styles, and unused component families.

## Non-goals

- Reproducing every visible screenshot section.
- Functional search, profile, location, favourites, or tab navigation.
- Networked server, authentication, persistence, analytics, pagination, or remote images.
- Arbitrary layouts, arbitrary style properties, remote code execution, or formula evaluation.
- A second platform before a complete first-platform implementation.

## Current milestone exit criteria

- Scope is written and consistent with the assignment.
- Architecture separates wire content, render models, state, actions, and views.
- The schema boundary and fixture matrix are defined before implementation.
- AI constraints are written down and will be used for later implementation prompts.
