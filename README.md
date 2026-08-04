# CARS24 SDUI iOS Assignment

This repository contains a deliberately scoped, native SwiftUI implementation of the CARS24 Server-Driven UI assignment.

## Status

Milestones 8 through 10 are complete: all seven declared V1 feed section types render as focused native SwiftUI views. The typed vehicle rail, native finance sheet, and bounded JSON action flow remain the only interactive assignment flow. The highlighted service grid and promotional banner are static, accessible presentations of their validated payload data; no screenshot-only behaviour or new actions were added.

The `-static-baseline` launch mode renders the same canonical home content from a direct source-code snapshot. It bypasses the SDUI load, decode, registry, validation, renderer, and action paths, and intentionally presents the initial EMI as static text rather than providing a second finance flow.

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
| Static baseline | A direct SwiftUI source snapshot provides the required performance control without exercising the SDUI execution path. |

## Documentation

- Documentation/ARCHITECTURE.md - system boundaries and engineering decisions.
- Documentation/SDUI_SCHEMA_V1.md - proposed contract and compatibility policy.
- Documentation/FIXTURE_PLAN.md - planned deterministic payloads and demo cases.
- Documentation/PROJECT_FOUNDATION.md - Xcode target, language, and launch-mode decisions.
- Documentation/AI_CONTEXT.md - constraints governing AI-assisted work.
- AI_WORKFLOW.md - contemporaneous AI evidence log and verification strategy.

## Milestone policy

Each milestone is reviewed before the next begins. Milestone 11 has not started; it will add a repeatable release-build measurement protocol for the two completed render paths without altering the SDUI contract or product scope.
