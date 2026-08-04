# Architecture Decision Record

## Purpose

Define a small, production-shaped SDUI system for one iOS assignment screen. The goal is not to build a generic remote UI platform; it is to show a safe, extensible boundary that can render a second related screen with JSON-only changes where existing components apply.

## Chosen reference scope

The visual reference is the supplied Cars24 iOS home/discovery feed. It contributes the branded discovery hierarchy, image-led rails, utility grid, vehicle-card information density, and white content surface.

The written assignment adds the required tenure selector and bottom sheet. Those behaviours are attached to the vehicle card's visible EMI information. This is an assignment-driven interaction; it is not claimed to be a feature specified by the screenshot.

## Architectural flow

Bundled payload -> asynchronous repository -> tolerant wire decode -> registry and validation -> immutable typed screen definition -> main-actor screen state -> native SwiftUI renderer.

JSON action -> action dispatcher -> immutable interaction state or native presentation -> SwiftUI update.

The typed screen definition keeps scrollable `sections` separate from declared `presentations`. The finance sheet is a presentation, not an invisible row inside the feed, so the renderer will not require a component-ID-specific skip rule.

The static benchmark screen uses a direct source-code snapshot of the canonical V1 content and the same local-media tokens. It bypasses the SDUI load task, repository read, decode, registry, validation, dynamic screen-tree rendering, and action dispatch. It may reuse only presentation primitives such as style tokens, local-media fallback rendering, and the section-title leaf; those do not interpret the SDUI document. The source duplication is deliberate: updating the canonical fixture requires an explicit matching baseline update so benchmark work cannot silently exercise the SDUI path.

The bundled repository exposes an `async` API even though the current fixture is local. It runs outside the main actor and keeps view lifecycle code independent of the payload mechanism. A detached task, cache, retry policy, or networking layer is not justified for this small immutable resource.

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
| App composition | Constructs the bundled repository and screen store. Selects static or SDUI launch mode for development and benchmarks. |
| Repository | Resolves the bundled payload, decodes it, and maps source/compatibility/validation outcomes. It has no UI knowledge. |
| Decoding and validation | Converts the wire document into safe typed sections/presentations and captures invalid content locally. |
| Component registry | Maps known server component names to component kinds and validation rules. |
| Renderer | Turns immutable validated models into native SwiftUI views through an exhaustive section switch. It has no loading, decoding, or action-dispatch responsibility. |
| Action dispatcher | Purely resolves the finite JSON action vocabulary against the loaded typed definition. |
| Screen state | Owns load state, selected tenure, and active sheet ID. It applies resolved actions but never mutates the decoded document. |
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

## Milestone 10 exit criteria

- The root injects immutable screen content, bounded interaction state, and a narrow action closure; leaf views do not receive the store.
- The vehicle rail renders only typed vehicle data and a finance button only when its declared finance action can resolve to a declared sheet.
- The visible EMI is a declared `emiText` value selected from the immutable finance presentation; the client performs no finance calculation.
- The native sheet derives presentation from `activeSheetID`; its false binding write dispatches the declared dismissal action so swipe and VoiceOver escape remain synchronized with state.
- Tenure rows are full native buttons with a visible and accessible selected state. They retain no local selection state and emit their own JSON-defined actions.
- The selected tenure persists across native dismissal while active-sheet state is transient.
- The focused UI test covers the user-visible assignment flow: vehicle EMI action, finance sheet, tenure selection, updated EMI, and native dismissal.
- All seven known V1 feed section types now route through the exhaustive renderer to small native leaf views.
- The highlighted service grid uses only its typed title, accent, column count, and item data. It preserves the declared column count at normal text sizes and narrows a three-column payload to two columns only at accessibility Dynamic Type sizes.
- The promo banner uses its typed text, image reference, and accessibility label. Its canonical V1 instance has no action, so the renderer does not fabricate a CTA or make the banner interactive.
- Decorative local-media fallbacks remain hidden from VoiceOver; static tiles and banners expose a concise semantic element with stable identifiers for UI tests.
- `-static-baseline` selects `StaticBaselineHomeView` directly; the SDUI-only `.task` does not run in that branch.
- The static view contains a local snapshot of the canonical V1 content, renders all seven visual sections, and shares only non-SDUI presentation primitives.
- The baseline uses no typed SDUI contract models, repository call, screen definition, registry, validation result, `SDUIScreenRenderer`, store dispatch, button action, or finance sheet.
- The baseline retains the canonical initial EMI as a visual value but intentionally offers no finance interaction, preventing a fake duplicate flow from contaminating the comparison.
- Static sections use accessibility containment so their stable section identifiers do not suppress the cards, tiles, vehicle, or banner identifiers beneath them.
- The focused launch test verifies the static root, canonical vehicle EMI, lower highlighted tile, and promo banner while asserting that neither the SDUI root nor its finance action exists.
- No performance result is claimed yet; release-build instrumentation and a documented measurement protocol remain separate work.

## Milestone 11 performance boundaries

- `Cars24SDUIPerformance` is a dedicated shared scheme that builds the app and UI-test target in Release configuration without enabling testability in app code.
- The benchmark tests compile only for that UI-test target's Release configuration; normal Debug tests and product launches do not carry benchmark test behavior.
- `XCTApplicationLaunchMetric` owns the assignment's cold TTR and TTI measurement. App-process signposts are diagnostic phase measurements, not substitutes for process-launch timing.
- The SDUI path emits named, benchmark-gated signposts around bundled fixture read, decode/validation, content publication-to-first-render, and bootstrap-to-full-content.
- The full-content route uses a private benchmark launch argument to scroll to the last canonical section without animation. It prevents UI automation swipe latency from contaminating the app-process signpost and never changes normal initial scroll position.
- Static and SDUI variants use the same full-content route, canonical content, device destination, and repeated measurement count.
- The scroll test follows eight fixed upward swipes and uses XCTest's scrolling/deceleration metric. It is a device-only result; absence of a simulator export is not a product-performance conclusion.
- `PERF.md` prohibits reporting simulator results as the assignment's physical-device comparison and records the reproducible capture protocol.
