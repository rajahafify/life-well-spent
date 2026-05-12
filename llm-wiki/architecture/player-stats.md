---
title: PlayerStats
type: reference
tags: [architecture, models, progression]
sources: [scripts/models/player_stats.gd, tests/specs/player_stats_test.gd]
---

# PlayerStats

## Overview
Pure model for player HP, level, death/rebirth, XP, and unlocked facilities.

## API
```gdscript
var max_hp: int = 100
var level: int = 1
var state: String = "alive"
var xp: int = 0
var unlocked_facilities: Array[String] = []
var game_over_requested: bool = false

func take_quest() -> void
func complete_quest() -> void
func award_xp(amount: int) -> void
func unlock_facility(facility_id: String) -> void
func rebirth() -> void
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions
- Quest acceptance costs no HP.
- Quest completion deducts `GameBalance.QUEST_HP_COST` and can kill player.
- Rebirth resets HP/level/state and clears `game_over_requested`, but preserves facilities and XP.
- Facility unlocks are idempotent through `unlock_facility()`, so persistent achievements such as `swordsman_guild` survive rebirth.
- Serialization supports SaveManager persistence.

## Test Coverage
- `tests/specs/player_stats_test.gd`: initial state, free quest accept, completion HP cost, death, game-over request, rebirth reset, facility preservation, and Swordsman Guild unlock preservation.
- `tests/specs/progression_model_test.gd`: XP award, facility unlock interaction, and Swordsman certification unlock.

## Related
- [QuestManager](quest-manager.md)
- [ProgressionModel](progression-model.md)
