# SDUI Schema V1 Contract

## Contract goals

V1 must support the chosen assignment screen, a safe unknown-component fallback, JSON-defined tenure and sheet actions, and an honest future-screen coverage discussion.

It must not become a generic layout language or remote code-execution surface.

## Root document

| Field | Meaning | V1 rule |
|---|---|---|
| schemaVersion | Major compatibility version. | Required; V1 accepts major version 1 only. |
| screenID | Stable identifier for the payload/screen. | Required. |
| sections | Ordered top-level SDUI components. | Required; each entry has a stable component ID. |
| metadata | Optional non-rendering payload metadata. | Ignored safely when unknown. |

## Common component fields

| Field | Meaning | V1 rule |
|---|---|---|
| id | Stable component identity. | Required and unique within a document. |
| type | Semantic component type. | Required; must be a declared V1 type or become an unsupported node. |
| props | Type-specific content and presentation data. | Required for known components; validated before rendering. |
| actions | Declared user actions associated with the component or its items. | Optional; only declared action kinds are accepted. |
| variant | Constrained named visual variant. | Optional; no raw colour, font, spacing, or layout expressions. |

## Supported V1 component types

| Type | Purpose | Examples of permitted props |
|---|---|---|
| discoveryHeader | Branded discovery context. | Title, subtitle, icon/image reference, variant. |
| illustratedActionRail | Horizontal image-led action cards. | Title, badge, items with title/image/action. |
| productRail | Horizontal circular or image-led product cards. | Title, items with label/image/action. |
| serviceGrid | Vertical utility cards. | Title, grid items, visual variant, item action. |
| vehicleRail | Horizontal vehicle-card collection. | Title, trailing label, vehicle items, card actions. |
| highlightedServiceGrid | Coloured service grouping. | Title, accent variant, grid items. |
| promoBanner | Full-width promotional visual. | Image reference, accessibility label, optional action. |
| financeSheet | Sheet title, tenure options, selected-state binding, finance display mapping. | Tenure options and display values only; no executable formula. |

## Actions

| Action kind | Valid effect | Explicitly not allowed |
|---|---|---|
| setSelection | Set a validated named selection to a declared option. | Arbitrary state mutation. |
| presentSheet | Present a declared sheet identifier. | Arbitrary view presentation. |
| dismissSheet | Dismiss the active declared sheet. | Dismissing unrelated system UI. |
| navigate | Emit a declared application route if a real route is implemented. | Arbitrary URL or deep link execution. |

The initial required flow is vehicle EMI affordance -> presentSheet -> select tenure -> update the finance display. The renderer never contains a component-ID-specific rule for that behaviour.

## State binding

V1 supports only the small interaction state needed by the assignment:

| State | Owner | Use |
|---|---|---|
| selectedTenure | Screen interaction state | Selects a declared finance display value. |
| activeSheetID | Screen interaction state | Controls the native finance sheet presentation. |
| navigationRoute | Screen interaction state | Stores a declared in-scope navigation intent when used. |

The decoded document is immutable. State never writes back into the payload.

## Validation and fallback policy

| Condition | Required behaviour |
|---|---|
| Unknown component type | Preserve its ID/type for diagnostics and render an unsupported-component fallback. |
| Known component with invalid props | Render a local invalid-content fallback and continue rendering sibling sections. |
| Unknown optional field | Ignore safely. |
| Unknown action type | Safe no-op plus debug diagnostic. |
| Duplicate component ID | Treat the document as invalid. |
| Unsupported schema major version | Present a screen-level compatibility fallback. |
| Invalid root document | Present a screen-level error/retry state. |

## Compatibility policy

- V1 changes are additive only.
- New optional fields must not break V1 clients.
- New component types rely on the unknown-component fallback on older clients.
- Breaking payload changes require a new major schema version.
- A production server would target payload capability by app version; this assignment documents the policy but does not build backend negotiation.

## Coverage policy

No percentage will be claimed before a second-screen exercise. The final coverage report will identify:

1. Which screen patterns map to existing component types through JSON only.
2. Which patterns require a new native component.
3. Why a new component is justified rather than forcing it through an existing type.
