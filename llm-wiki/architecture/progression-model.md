---
title: ProgressionModel
type: reference
tags: [architecture, models, progression]
sources: [scripts/models/progression_model.gd, tests/specs/progression_model_test.gd]
---

# ProgressionModel

## Overview
Pure orchestration model for completing life tasks, awarding player XP, completing linked quests, spending HP, and unlocking facilities.

## API
```gdscript
ProgressionModel.new(player_stats, quest_manager, life_tracker)
add_unlock_rule(facility_id, xp_required)
complete_life_task(task_id, date) -> bool
```

## Design Decisions
- Coordinates existing models instead of duplicating state.
- Life task XP flows to `LifeTracker.xp` and `PlayerStats.xp`.
- Linked quests complete by `life_task_id`; quest completion still delegates HP cost to `PlayerStats.complete_quest()`.

## Test Coverage
- `tests/specs/progression_model_test.gd`: XP award, linked quest completion, facility unlock once.

## Related
- [LifeTracker](life-tracker.md)
- [QuestManager](quest-manager.md)
