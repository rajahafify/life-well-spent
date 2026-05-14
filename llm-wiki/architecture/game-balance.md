---
title: GameBalance
type: reference
updated: 2026-05-14
sources:
  - scripts/models/game_balance.gd
  - tests/specs/game_balance_test.gd
tags: [architecture, game-design]
---

# GameBalance

## Overview
Pure constants model for shared game tuning values. Keeps quest HP cost, animation timings, Field spacing, Field feedback timing, and item healing in one place.

## API
```gdscript
class_name GameBalance
extends Object

const QUEST_HP_COST: int = 40
const WALK_ANIM_SPEED: float = 8.0
const IDLE_CYCLE_INTERVAL: float = 0.5
const WALK_FRAME_DURATION: float = 0.1
const FIELD_ENEMY_COLLISION_RADIUS: float = 56.0
const FIELD_ENEMY_APPROACH_DISTANCE: float = 96.0
const FIELD_PLAYER_ATTACK_READY_RANGE: float = 112.0
const FIELD_PLAYER_ATTACK_LEASH_RANGE: float = 192.0
const FIELD_LOOT_TOAST_DURATION: float = 1.4
const APPLE_HEAL_AMOUNT: int = 20
```

## Design Decisions
- No Node references.
- No mutable state.
- Models/controllers preload this instead of duplicating tuning constants.
- Field combat spacing, enemy collision padding, loot toast timing, and apple healing are centralized so Field scene glue does not own tuning numbers.

## Test Coverage
`tests/specs/game_balance_test.gd` covers:
- Quest HP cost value.
- Animation timing constants remain positive.
- Field tuning constants remain centralized and explicit.

## Related
- [quest-manager.md](quest-manager.md)
- [animation-controller.md](animation-controller.md)
