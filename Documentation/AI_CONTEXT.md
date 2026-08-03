# AI Working Context

## Mission

Build a narrow, production-quality native SwiftUI SDUI assignment submission that can be explained line by line in a senior iOS interview.

## Source-of-truth rules

1. The written assignment overrides screenshots, prior assumptions, and convenience.
2. Screenshots inform visual hierarchy and reusable patterns only.
3. Do not add features because they appear in screenshots.
4. Do not implement code before the user approves the next milestone.

## Engineering constraints

- Use modern Swift and SwiftUI with an iOS 17+ target unless a later constraint requires a change.
- Prefer async/await and structured concurrency.
- Use manual constructor injection.
- Use local JSON fixtures; do not introduce a backend, networking stack, cache database, or pagination.
- Keep the schema typed and finite; do not build a generic layout, style, expression, or code-execution engine.
- Preserve a clean static benchmark control.
- Use native accessible controls and Apple HIG-aligned sheet behaviour.

## Required SDUI capabilities

- Component registry.
- JSON-defined actions.
- Unknown-component fallback.
- Versioning story.
- Tenure selector that updates displayed EMI.
- Bottom sheet.
- Horizontal rail and vertical list/grid.
- At least five visually distinct section types.

## Quality bar

- Readability over cleverness.
- No force casts, raw JSON in views, or component-ID-specific business rules.
- Every user-visible state has a loading, valid, or safe failure path where applicable.
- Every new component has a clear reason to exist and a defined test seam.
- Performance claims require repeatable release-build evidence.
- AI-generated output must be reviewed, challenged, and verified.

## Review questions before accepting a change

- Does this satisfy an explicit assignment requirement?
- Does it preserve the architecture boundary?
- Can the user explain it in an interview?
- Does it add an unnecessary dependency or abstraction?
- Does it make the static baseline less fair?
- Does it remain accessible and testable?
