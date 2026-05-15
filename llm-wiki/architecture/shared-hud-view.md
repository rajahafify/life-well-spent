---
title: SharedHUDView
type: reference
updated: 2026-05-15
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

`SharedHUDView` is the reusable gameplay HUD scene for Town, Field, and future gameplay scenes. It owns the common player-facing HUD: player Life, Inventory button/window, Options modal, Quest Tracker, and the 1-9 shortcut bar.

## API

```gdscript
signal shortcut_pressed(slot_number: int, item_id: String)
signal equipment_changed
signal end_game_requested
signal game_speed_changed(speed_id: String)

func ensure_ready() -> void
func set_inventory_model(inventory_model) -> void
func set_life(current_life: int, max_life: int) -> void
func show_quest(quest_title: String, objective_text: String, checkpoint_text: String = "") -> void
func toggle_inventory_window() -> void
func close_inventory_window() -> void
func toggle_options_panel() -> void
func close_options_panel() -> void
```

## Design Decisions

- Gameplay scenes instance `scenes/ui/shared_hud.tscn` as their `UI` CanvasLayer.
- Scene controllers feed the HUD current Life and quest text; the HUD does not query gameplay state directly.
- The HUD receives the global inventory model from `InventorySystem` and opens `InventoryWindowView` from the Inventory button or `I` key.
- The Options button sits below Inventory and opens a modal with Game Speed, `End Game`, and `Close`; pressing `End Game` emits `end_game_requested` and lets the active scene decide how to route.
- Game Speed offers `Normal`, `Fast`, and `Ultra`; selecting one emits `game_speed_changed("normal"|"fast"|"ultra")` so active scene controllers can apply `Engine.time_scale`.
- Options modal supports controller navigation: D-pad up/down changes the selected row, left/right cycles Game Speed when selected, `A` activates the selected control, and `B` closes Options.
- Equipment requests emitted by the inventory window are applied to the inventory model, then the slot list is refreshed in place. Successful equipment changes emit `equipment_changed` so Town and Field can refresh the player sprite immediately.
- The shortcut bar renders 9 inventory-backed slots with high-contrast white slot boxes and dark borders. Number keys `1` through `9` emit `shortcut_pressed(slot_number, item_id)`; gameplay controllers decide what mapped items do.
- `blocks_world_mouse_at()` includes the Options button and modal so HUD clicks do not move the player.
- Scene-specific objective/inventory labels are removed from Field; reusable HUD owns those common surfaces.

## Test Coverage

- `tests/specs/shared_hud_view_test.gd` covers scene structure, Life updates, quest rendering, Inventory button, Options modal, controller Options navigation, Game Speed options and signal emission, End Game signal emission, `I` key toggle, echo-key rejection, equipment button application, `equipment_changed`, shortcut bar rendering, visible shortcut styling, shortcut number mapping, and `1` key signal emission.
- `tests/specs/field_scene_test.gd` covers Field using the shared HUD, blocking Options clicks from world movement, handling Apple shortcut consumption, routing Options End Game to Main Menu, and applying Game Speed to `Engine.time_scale`.
- `tests/specs/town_scene_dialog_test.gd` covers Town using the shared HUD, routing Options End Game to Main Menu, and applying Game Speed to `Engine.time_scale`.

## Related

- [InventorySystem](inventory-system.md)
- [InventoryWindowView](inventory-window-view.md)
- [QuestWindowView](quest-window-view.md)
