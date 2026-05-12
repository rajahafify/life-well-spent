---
title: ProgressionModel
type: reference
tags: [architecture, models, progression]
sources: [scripts/models/progression_model.gd, tests/specs/progression_model_test.gd]
---

# ProgressionModel

## Overview
Pure orchestration model for completing life tasks, awarding player XP, completing linked quests, spending HP, unlocking facilities, and completing the Swordsman Guild certification chain.

## API
```gdscript
ProgressionModel.new(player_stats, quest_manager, life_tracker)
add_unlock_rule(facility_id, xp_required)
complete_life_task(task_id, date) -> bool
complete_swordsman_certification_step() -> bool
```

## Design Decisions
- Coordinates existing models instead of duplicating state.
- Life task XP flows to `LifeTracker.xp` and `PlayerStats.xp`.
- Linked quests complete by `life_task_id`; quest completion still delegates HP cost to `PlayerStats.complete_quest()`.
- Swordsman certification is objective-backed: each Guildmaster step first requires the current `Rebuilding Swordsman Guild` kill objective to be complete, then advances the side-chain step and calls `PlayerStats.complete_quest()`.
- Step 3 completes the side chain, grants `swordsman_certification`, advances the main objective to `Enter the Forest.`, unlocks `swordsman_guild`, and leaves `PlayerStats.game_over_requested` true via Max Life reaching zero.

## Test Coverage
- `tests/specs/progression_model_test.gd`: XP award, linked quest completion, facility unlock once, inactive certification rejection, incomplete objective rejection, certification steps 1-3, Guild unlock, Forest endpoint objective, and game-over request.

## Related
- [LifeTracker](life-tracker.md)
- [QuestManager](quest-manager.md)
