---
title: InventoryWindowView
type: reference
updated: 2026-05-12
sources:
  - scenes/ui/inventory_window.tscn
  - scripts/views/inventory_window_view.gd
  - tests/specs/inventory_window_view_test.gd
  - tests/specs/field_scene_test.gd
tags: [architecture, inventory, ui]
---

# InventoryWindowView

## Overview

`InventoryWindowView` is the reusable inventory overlay scene. Gameplay scenes can instance `scenes/ui/inventory_window.tscn`, pass an inventory model to `show_inventory()`, and hide it with `hide_inventory()`.

## API

```gdscript
signal close_requested

func show_inventory(inventory) -> void
func hide_inventory() -> void
```

## Design Decisions

- The window is its own scene under `scenes/ui/`.
- The view renders item stack text only; it does not own item rules.
- `SharedHUDView` opens it from the `Inventory` HUD button and the `I` key.
- It starts hidden and emits `close_requested` when the close button is pressed.

## Test Coverage

- `tests/specs/inventory_window_view_test.gd` covers scene load, hidden default state, title/close button, empty state, and sorted item stack rendering.
- `tests/specs/shared_hud_view_test.gd` covers HUD button and `I` key toggling.

## Related

- [InventoryModel](inventory-model.md)
- [SharedHUDView](shared-hud-view.md)
- [Field Scene](../scenes/field.md)
