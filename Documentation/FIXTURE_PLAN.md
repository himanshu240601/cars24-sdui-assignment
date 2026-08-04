# Fixture and Demo Plan

## Purpose

Payload fixtures make the SDUI contract testable, support the required recording, and keep the static-versus-SDUI comparison deterministic.

The fixtures below are bundled with the app target in Milestone 3. They contain only local asset tokens, never remote URLs or screenshot-derived image files.

## Planned fixture matrix

| File | Status and purpose | Required proof |
|---|---|---|
| home-v1.json | Implemented canonical assignment composition. | Seven visual section types, horizontal rails, vertical grids, vehicle finance intent, and finance-sheet declaration. |
| home-v1-unknown-component.json | Implemented compatibility fixture. | Unknown component is local while valid siblings remain typed. |
| home-v1-invalid-component.json | Implemented local-validation fixture. | A known node with invalid grid props becomes a local invalid node. |
| home-v1-invalid-root.json | Implemented root-validation fixture. | Duplicate IDs produce a screen-level invalid-document outcome. |
| home-v2-unsupported-major.json | Implemented compatibility-version fixture. | Unsupported schema major produces a screen-level compatibility outcome. |
| malformed JSON data | Implemented inline in a decoder test. | Syntax failure remains distinct from semantic root validation. |
| future-screen-practice.json | Deferred until the coverage exercise. | A deliberately different composition using existing component types. |

## Primary content parity

The static and SDUI screen must use identical:

- Section order and visible content.
- Vehicle/service data.
- Selected initial tenure and displayed EMI.
- Local media assets and aspect ratios.
- Supported user interactions.

The static version may share leaf visual components such as vehicle cards, section headers, and metadata chips. It must not load a JSON document, invoke the registry, or render a dynamic screen tree.

## Asset policy

- Screenshots are visual reference only; they are not application assets.
- Use only locally bundled assets that are appropriate to include in the repository.
- Keep asset dimensions close to displayed dimensions to avoid benchmark distortion.
- Treat decorative assets as decorative for VoiceOver.
- Keep the primary and static variants on the same asset set.

## Required demo sequence

1. Launch the SDUI variant and show the page rendered from the primary JSON fixture.
2. Open the finance sheet from a JSON-defined vehicle/EMI action.
3. Change tenure and show the declared EMI value update.
4. Load the unknown-component fixture and show graceful fallback.
5. Make one visible JSON-only content edit, rerun, and show the page change.
6. Use the static variant only for the performance comparison, not as the SDUI demo.

## Performance invariants

- Release build on the same physical device.
- Same launch state, fixture, media, selected values, and scroll route.
- Record local payload read, decode/map, first render, interaction-ready, and scroll behaviour separately.
- Report repeated-run median and spread, not a cherry-picked best value.
