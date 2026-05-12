---
title: InventoryModel
type: reference
updated: 2026-05-12
sources:
  - scripts/models/inventory_model.gd
  - tests/specs/inventory_model_test.gd
  - scripts/managers/inventory_system.gd
  - tests/specs/inventory_system_test.gd
  - tests/specs/field_scene_test.gd
tags: [architecture, inventory, field]
---

# InventoryModel

## Overview

`InventoryModel` is a pure model for stackable item counts. Runtime scenes access it through the game-wide `InventorySystem` autoload.

## API

```gdscript
func add_item(item_id: String, amount: int = 1) -> bool
func quantity(item_id: String) -> int
func summary_text() -> String
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- Inventory is model-only: no Node references and no UI ownership.
- Item IDs are plain strings for the first drop slice.
- Invalid item IDs and non-positive quantities are rejected.
- `InventorySystem` owns the runtime instance so drops persist across scene changes.

## Test Coverage

- `tests/specs/inventory_model_test.gd` covers empty state, stack adds, invalid add rejection, save round-trip, and summary text.
- `tests/specs/inventory_system_test.gd` covers global stack counts and shared HUD model access.
- `tests/specs/field_scene_test.gd` covers Field granting `slime_gel` when a Slime is defeated.

## Related

- [Field Scene](../scenes/field.md)
- [InventorySystem](inventory-system.md)
- [enemy-behavior-system](enemy-behavior-system.md)
