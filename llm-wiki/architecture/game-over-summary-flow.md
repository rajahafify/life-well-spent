---
title: Game Over Summary Flow
type: reference
updated: 2026-05-15
sources:
  - scripts/controllers/game_over_controller.gd
  - scripts/controllers/summary_scene_controller.gd
  - scenes/game_over.tscn
  - scenes/summary_scene.tscn
  - tests/specs/game_over_summary_flow_test.gd
tags: [architecture, prototype, flow]
---

# Game Over Summary Flow

## Overview

The completed first-life loop now uses two dedicated scenes after final certification: `GameOver` for the end beat and `SummaryScene` for run results and restart choices.

## API

```gdscript
# GameOverController
func _on_continue_pressed() -> void

# SummarySceneController
func render_summary(profile_system, inventory_system) -> void
func rebirth_to_town(profile_system, inventory_system) -> bool
func end_game_to_main_menu(profile_system, inventory_system) -> bool
```

## Design Decisions

- Town final certification still shows the Guildmaster reward panel, saves profile state, and then requests `res://scenes/game_over.tscn`.
- `GameOverController` owns the short transition beat and routes `Continue` to `res://scenes/summary_scene.tscn`.
- `SummarySceneController` renders `RunSummaryModel` output from `ProfileSystem.player()` and `InventorySystem.model()`.
- Summary actions are `Rebirth` and `End Game`.
- `Rebirth` resets the ended run, clears runtime inventory through `InventorySystem.reset()`, saves the profile, and enters Town.
- `End Game` saves the profile and returns to Main Menu without rebirth; Main Menu `Continue` is responsible for auto-rebirth from an ended saved run while preserving unlocks.
- SFX are requested for Game Over, Summary open, Rebirth, and End Game through `FeedbackSystem`.

## Test Coverage

- `tests/specs/game_over_summary_flow_test.gd` covers Game Over continuation, Summary rendering, Summary rebirth reset, and Summary End Game routing without rebirth.
- `tests/specs/town_scene_dialog_test.gd` covers final certification routing to Game Over.
- `tests/specs/run_summary_model_test.gd` covers Life spent, readable item names, and unlock text.

## Related

- [Run Summary Model](run-summary-model.md)
- [Main Menu Flow](main-menu-flow.md)
- [Quest System](quest-system.md)
- [Feedback Components](feedback-components.md)
