# Forest Gate

## Core Idea

Visible promise of next adventure, blocked by certification requirement.

## Purpose

- Give player concrete goal: reach Forest.
- Block progress with narrative reason.
- Unlock Swordsman Guild quest in Town.

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
- Guard dialog sets `forest_gate_seen = true`.
- Guard dialog unlocks Swordsman Guild quest.
- Forest remains blocked even after unlock; future build opens it.

## Conditions

- Before guild unlock: block and explain requirement.
- After guild unlock: block with prototype/future-content line TBD.
