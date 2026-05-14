---
title: Profile System
type: reference
updated: 2026-05-14
tags: [architecture, managers, persistence, progression]
sources: [scripts/managers/profile_system.gd, scripts/managers/save_manager.gd, scripts/controllers/town_scene_controller.gd, tests/specs/profile_system_test.gd, tests/specs/save_manager_test.gd, tests/specs/town_scene_dialog_test.gd]
---

# Profile System

## Overview

`ProfileSystem` is the autoload boundary for persistent player profile state. The current profile stores `PlayerStats`, including persistent facility unlocks such as `swordsman_guild`.

## API

```gdscript
ProfileSystem.player() -> PlayerStats
ProfileSystem.set_profile_path(path: String) -> void
ProfileSystem.current_profile_path() -> String
ProfileSystem.save_profile(path := "") -> bool
ProfileSystem.load_profile(path := "") -> bool
ProfileSystem.reset_for_tests() -> void
```

## Design Decisions

- `PlayerStats` remains the model for Life, game-over request, rebirth, XP, and unlocked facilities.
- `SaveManager` owns JSON/FileAccess serialization helpers.
- `ProfileSystem` owns the runtime profile instance and default path: `user://life_well_spent_profile.json`.
- Tests and future profile slots can redirect persistence through `set_profile_path()`. The stored path is private and exposed through `current_profile_path()`.
- Town uses the autoload player when inside the scene tree, but tests can still instantiate Town directly with a local `PlayerStats`.

## Test Coverage

- `tests/specs/save_manager_test.gd` covers profile data preserving `swordsman_guild`.
- `tests/specs/profile_system_test.gd` covers redirected profile save/load paths and default path reset.
- `tests/specs/town_scene_dialog_test.gd` covers Rebirth button reset behavior preserving the guild unlock.

## Related

- [PlayerStats](player-stats.md)
- [ProgressionModel](progression-model.md)
