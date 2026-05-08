---
title: Spec-Driven Development
type: decision
updated: 2026-05-08
sources:
  - AGENTS.md
tags: [architecture]
---

# Spec-Driven Development

## Decision
Every feature starts with a spec. No code is written until the spec is approved. This ensures clarity, prevents scope creep, and keeps the MVC layers properly separated.

## Spec Format
Specs are Godot `Resource` files stored in `resources/specs/`.

### Workflow
1. **Draft** — Write the `acceptance_criteria` first.
2. **Approve** — User confirms the criteria are complete and unambiguous.
3. **Implement** — Model first (pure logic), then Controller (thin glue), then View (UI update).
4. **Verify** — Walk through each acceptance criterion. If any fail, revert and fix.

## Rule
> If the spec doesn't cover it, it doesn't exist. Never add "just one more thing" without updating the spec.

## Rationale
- Specs force you to think through edge cases before implementation.
- They serve as living documentation for each feature.
- They make it trivial to verify "done" — just check each criterion.
- They keep the spec as the single source of truth, not scattered conversation.
