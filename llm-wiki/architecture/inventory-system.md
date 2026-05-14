---
title: InventorySystem
type: reference
updated: 2026-05-14
sources:
  - scripts/managers/inventory_system.gd
  - tests/specs/inventory_system_test.gd
tags: [architecture, inventory, autoload]
---

# InventorySystem

## Overview

`InventorySystem` is the game-wide inventory autoload. It wraps the pure `InventoryModel` so enemy drops, equipment slots, consumable slot state, and shared HUD windows read/write one inventory across scene changes.

## API

```gdscript
func reset() -> void
func model()
func add_item(item_id: String, amount: int = 1) -> bool
func quantity(item_id: String) -> int
func equip_weapon(item_id: String) -> bool
func equip_armor(item_id: String) -> bool
func summary_text() -> String
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- `InventoryModel` stays pure and testable.
- `InventorySystem` is the runtime boundary registered in `project.godot`.
- Field grants enemy drops through `InventorySystem`; Town and Field pass `InventorySystem.model()` to the shared HUD.
- `reset()` clears stack counts and restores empty equipment/consumable/shortcut slots.

## Test Coverage

- `tests/specs/inventory_system_test.gd` covers global stack counts, model access for the shared HUD window, and reset restoring empty slots.
- `tests/specs/field_scene_test.gd` covers Field granting Slime drops into the global inventory.

## Related

- [InventoryModel](inventory-model.md)
- [SharedHUDView](shared-hud-view.md)
