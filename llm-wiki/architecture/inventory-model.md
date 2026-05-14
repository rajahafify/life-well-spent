---
title: InventoryModel
type: reference
updated: 2026-05-14
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

`InventoryModel` is a pure model for stackable item counts plus the current weapon, armor, and consumable slots. Runtime scenes access it through the game-wide `InventorySystem` autoload.

## API

```gdscript
func reset() -> void
func add_item(item_id: String, amount: int = 1) -> bool
func quantity(item_id: String) -> int
func consume_item(item_id: String, amount: int = 1) -> bool
func equip_weapon(item_id: String) -> bool
func equip_armor(item_id: String) -> bool
func can_equip_weapon(item_id: String) -> bool
func can_equip_armor(item_id: String) -> bool
func equipment_slot_for_item(item_id: String) -> String
func set_consumable(item_id: String) -> bool
func assign_shortcut(slot_number: int, item_id: String) -> bool
func shortcut_item(slot_number: int) -> String
func slot_summary_text() -> String
func items_list() -> Array[Dictionary]
func summary_text() -> String
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- Inventory is model-only: no Node references and no UI ownership.
- Item IDs are plain strings for the first drop slice.
- Invalid item IDs and non-positive quantities are rejected.
- `consume_item()` reduces stacks only when enough quantity exists, erasing stacks that reach zero.
- Starter equipment, consumable, and shortcut slots are empty.
- Shortcut slots map number keys `1` through `9` to item IDs; slot 1 remains empty until a consumable is equipped.
- Weapon, armor, and consumable equip calls require the matching item to exist in inventory. Current equipment IDs are `training_sword` for weapon, `leather_armor` for armor, and `apple` for consumable.
- `items_list()` is the public read model for stack rows. Views must use it instead of reading `item_counts` directly.
- `items_list()` includes `equipment_slot` metadata so inventory UI can render an Equip action without hard-coding item IDs in the view.
- `InventorySystem` owns the runtime instance so drops persist across scene changes.

## Test Coverage

- `tests/specs/inventory_model_test.gd` covers empty state, empty equipment/consumable/shortcut slots, stack adds, consume behavior, invalid add rejection, equipment ownership checks, slot setter rejection, shortcut assignment bounds, save round-trip, slot summary text, public sorted `items_list()` rows, and item summary text.
- `tests/specs/inventory_system_test.gd` covers global stack counts, empty slot access through the shared HUD model, and reset restoring empty slots.
- `tests/specs/field_scene_test.gd` covers Field granting `slime_gel` on a forced successful Slime material-drop roll, consuming Apple through the shortcut bar, and applying Training Sword attack damage through the equipped weapon slot.

## Related

- [Field Scene](../scenes/field.md)
- [InventorySystem](inventory-system.md)
- [enemy-behavior-system](enemy-behavior-system.md)
