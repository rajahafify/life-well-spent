---
title: GameBalance
type: reference
updated: 2026-05-11
sources:
  - scripts/models/game_balance.gd
  - tests/specs/game_balance_test.gd
tags: [architecture, game-design]
---

# GameBalance

## Overview
Pure constants model for shared game tuning values. Keeps quest HP cost and animation timings in one place.

## API
```gdscript
class_name GameBalance
extends Object

const QUEST_HP_COST: int = 40
const WALK_ANIM_SPEED: float = 8.0
const IDLE_CYCLE_INTERVAL: float = 0.5
const WALK_FRAME_DURATION: float = 0.1
```

## Design Decisions
- No Node references.
- No mutable state.
- Models/controllers preload this instead of duplicating tuning constants.

## Test Coverage
`tests/specs/game_balance_test.gd` covers:
- Quest HP cost value.
- Animation timing constants remain positive.

## Related
- [quest-manager.md](quest-manager.md)
- [animation-controller.md](animation-controller.md)
