---
title: QuestManager
type: concept
updated: 2026-05-10
sources:
  - scripts/models/quest_manager.gd
  - tests/specs/quest_manager_test.gd
  - AGENTS.md
tags: [architecture, game-design]
---

# QuestManager

## Overview
Quest catalog and lifecycle management. No hard limit per life — quest pickup blocked by HP affordability.

## Design
- `active_quests` is an **array** — player can have multiple active quests simultaneously
- `take_quest(current_hp)` checks affordability — rejects if `HP < cost`
- `complete_quest()` and `abandon_quest()` remove the **first** active quest (FIFO)
- No hard limit per life — progression scales with HP
- `reset_for_life()` clears active quests and counter for rebirth

## Public API

```gdscript
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary] = []
var active_quests: Array[Dictionary] = []
var quests_taken: int = 0
var last_rejection = null
const QUEST_HP_COST: int = 40

func add_quest(name: String, cost: int, description: String) -> void
func take_quest(current_hp: int) -> bool   # false if HP < cost
func complete_quest() -> bool               # removes first active quest
func abandon_quest() -> bool                # removes first active quest
func reset_for_life() -> void               # clears active quests + counter
```

## Design Decisions

### Why array for active_quests?
Previously `active_quest` was a single quest — taking a second quest would lose the first. Array preserves all active quests. Player can take multiple quests, complete/abandon them in FIFO order.

### Why HP-based affordability?
No hard limit per life. If player gets a permanent +40 HP boost, they can take more quests. The gate is affordability, not a fixed counter. Message on insufficient HP: "You have no more life to sacrifice."

### Why FIFO completion?
`complete_quest()` removes the first (oldest) active quest. `abandon_quest()` does the same. This matches the expectation that you complete quests in the order you started them.

## Test Coverage
14 specs in `tests/specs/quest_manager_test.gd`:
- Catalog starts empty
- Add quest populates catalog
- Catalog supports 50 quests
- Take quest adds to active_quests
- Take quest returns false when no catalog
- Take quest works with many quests (no hard limit)
- Complete quest removes one active
- Two active quests, complete removes first
- Complete quest with no active returns false
- Reset clears quest state
- Take quest checks HP cost
- Take quest succeeds when enough HP
- Take quest fails when HP exactly at cost
- Take quest gives rejection message
- Successful take clears last_rejection

## Related
- `PlayerStats` — HP deduction after successful quest take
- `DemoController` — demo scene input → model calls → view updates
- `spec-driven-dev` — TDD enforcement rules
