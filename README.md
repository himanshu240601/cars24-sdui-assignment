# CARS24 SDUI iOS Assignment

This repository contains a deliberately scoped, native SwiftUI implementation of the CARS24 Server-Driven UI assignment.

## Status

Milestone 5 is complete: the app now renders the typed discovery header, illustrated-action rail, and product rail through a pure SwiftUI SDUI renderer. Unknown and invalid nodes have local fallbacks; remaining known V1 section renderers are deliberately deferred to later milestones.

## Source of truth

The written assignment is authoritative. The supplied CARS24 iOS screenshots inform visual hierarchy, card language, spacing, and navigation context only. They do not add product requirements.

## Chosen scope

The target is a Cars24-style iOS home/discovery screen with:

- At least five visually distinct SDUI section types.
- A horizontal content rail and a vertical service grid.
- A vehicle card that displays an EMI value.
- An assignment-required finance bottom sheet with a tenure selector that updates the displayed EMI through JSON-defined actions.
- An explicit unsupported-component fallback.

The implementation intentionally excludes live APIs, authentication, search, profile, location selection, favourites, full tab navigation, pagination, remote image loading, and a second platform.

## Technical direction

| Decision | Rationale |
|---|---|
| SwiftUI on iOS 17+ | Modern Observation and structured concurrency keep the implementation compact and native. |
| Local JSON fixture | The assignment permits it; it produces deterministic demos and fair performance measurements. |
| Typed SDUI contract | Component capability, validation, and fallback behavior remain explicit and testable. |
| Manual dependency injection | Dependencies remain visible and explainable without framework overhead. |
| Native sheet | The required bottom sheet remains accessible and aligned with iOS behavior. |
| Static baseline | A direct SwiftUI equivalent provides the required performance control. |

## Documentation

- Documentation/ARCHITECTURE.md - system boundaries and engineering decisions.
- Documentation/SDUI_SCHEMA_V1.md - proposed contract and compatibility policy.
- Documentation/FIXTURE_PLAN.md - planned deterministic payloads and demo cases.
- Documentation/PROJECT_FOUNDATION.md - Xcode target, language, and launch-mode decisions.
- Documentation/AI_CONTEXT.md - constraints governing AI-assisted work.
- AI_WORKFLOW.md - contemporaneous AI evidence log and verification strategy.

## Milestone policy

Each milestone is reviewed before the next begins. The next milestone may add the service-grid renderer and supporting visual primitives, but will not add screenshot-only product behaviour.
