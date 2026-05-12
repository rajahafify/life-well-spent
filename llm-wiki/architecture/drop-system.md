---
title: DropSystem
type: reference
updated: 2026-05-13
sources:
  - scripts/models/drop_system.gd
  - tests/specs/drop_system_test.gd
  - scripts/controllers/field.gd
tags: [architecture, drops, field]
---

# DropSystem

## Overview

`DropSystem` is a pure model helper for chance-based enemy drops. Field keeps loot granting and UI feedback, while drop probability rules live outside the scene controller.

## API

```gdscript
func succeeds(drop: Dictionary, roll: int = -1, rng: RandomNumberGenerator = null) -> bool
```

## Design Decisions

- Drops without chance fields are guaranteed.
- `chance_numerator` is clamped between `0` and `chance_denominator`.
- A zero numerator always fails.
- Tests can pass an explicit `roll`; runtime callers can pass an RNG for random rolls.
- Field still owns item grant side effects and delegates only the probability decision.

## Test Coverage

- `tests/specs/drop_system_test.gd` covers guaranteed drops, zero numerator failure, success at the numerator boundary, failure above the numerator, and numerator clamping above denominator.
- `tests/specs/field_scene_test.gd` still covers Field's integration helper for chance-based drops.

## Related

- [Field Scene](../scenes/field.md)
- [InventoryModel](inventory-model.md)
- [EnemyBehaviorSystem](enemy-behavior-system.md)
