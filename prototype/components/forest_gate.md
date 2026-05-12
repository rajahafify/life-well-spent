# Forest Gate

## Core Idea

Visible promise of next adventure, blocked by certification requirement.

## Purpose

- Give player concrete goal: reach Forest.
- Block progress with narrative reason.
- Advance the main quest toward Swordsman Certification.
- Activate the Swordsman Guild side quest chain in Town.

## Objects

- Forest path
- Guard
- Blocker/collision
- Warning sign
- Dark tree line

## Guard Line

```text
The Forest is too strong for an adventurer like you.
Return to Town.
Earn certification from the Swordsman Guild.
```

## Rules

- Forest cannot be entered in prototype.
- First approach triggers Guard dialog.
- Forest Gateway advances `Explore the World` to `Get Swordsman Certification`.
- Forest Gateway activates `Rebuilding Swordsman Guild`.
- Forest remains blocked even after unlock; future build opens it.

## Conditions

- Before guild unlock: block and explain requirement.
- After guild unlock: block with prototype/future-content line TBD.
