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

## Future records

Records 2 and 3, plus one genuine AI failure and its detection method, will be added only after they occur during later approved milestones.

## Verification strategy for AI-assisted changes

- Review every proposed change against Documentation/AI_CONTEXT.md.
- Inspect diffs before accepting changes.
- Build and test on the declared iOS target once code exists.
- Test decoder, actions, fallback, and sheet behaviour with deterministic fixtures.
- Run accessibility checks and manual VoiceOver review for custom controls.
- Measure performance in release configuration before making any claim.
- Record rejected or rewritten AI output with the specific reason.
