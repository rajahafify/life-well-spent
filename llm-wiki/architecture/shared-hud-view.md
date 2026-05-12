---
title: SharedHUDView
type: reference
updated: 2026-05-12
sources:
  - scenes/ui/shared_hud.tscn
  - scripts/views/shared_hud_view.gd
  - tests/specs/shared_hud_view_test.gd
  - tests/specs/field_scene_test.gd
  - tests/specs/town_scene_dialog_test.gd
tags: [architecture, ui, hud]
---

# SharedHUDView

## Overview

`SharedHUDView` is the reusable gameplay HUD scene for Town, Field, and future gameplay scenes. It owns the common player-facing HUD: player Life, Inventory button/window, and Quest Tracker.

## API

```gdscript
func ensure_ready() -> void
func set_inventory_model(inventory_model) -> void
func set_life(current_life: int, max_life: int) -> void
func show_quest(quest_title: String, objective_text: String, checkpoint_text: String = "") -> void
func toggle_inventory_window() -> void
func close_inventory_window() -> void
```

## Design Decisions

- Gameplay scenes instance `scenes/ui/shared_hud.tscn` as their `UI` CanvasLayer.
- Scene controllers feed the HUD current Life and quest text; the HUD does not query gameplay state directly.
- The HUD receives the global inventory model from `InventorySystem` and opens `InventoryWindowView` from the Inventory button or `I` key.
- Scene-specific objective/inventory labels are removed from Field; reusable HUD owns those common surfaces.

## Test Coverage

- `tests/specs/shared_hud_view_test.gd` covers scene structure, Life updates, quest rendering, Inventory button, and `I` key toggle.
- `tests/specs/field_scene_test.gd` covers Field using the shared HUD.
- `tests/specs/town_scene_dialog_test.gd` covers Town using the shared HUD.

## Related

- [InventorySystem](inventory-system.md)
- [InventoryWindowView](inventory-window-view.md)
- [QuestWindowView](quest-window-view.md)
