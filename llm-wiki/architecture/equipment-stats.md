---
title: EquipmentStats
type: reference
updated: 2026-05-14
sources:
  - scripts/models/equipment_stats.gd
  - tests/specs/equipment_stats_test.gd
  - tests/specs/field_scene_test.gd
tags: [architecture, inventory, combat]
---

# EquipmentStats

## Overview

`EquipmentStats` is the pure model that maps equipped item IDs to combat bonuses. Field asks this model for the current weapon and armor bonuses when building the player combat dictionary.

## API

```gdscript
func attack_bonus_for_weapon(item_id: String) -> int
func defense_bonus_for_armor(item_id: String) -> int
```

## Design Decisions

- Equipment effects stay outside `InventoryModel`; inventory owns slot state, while this model owns combat meaning.
- `training_sword` adds `20` attack.
- `leather_armor` adds `1` defense.
- Unknown or empty equipment IDs return `0` so unequipped slots are safe defaults.

## Test Coverage

- `tests/specs/equipment_stats_test.gd` covers known and unknown weapon/armor bonuses.
- `tests/specs/field_scene_test.gd` covers equipped Training Sword increasing player damage in Field combat.

## Related

- [InventoryModel](inventory-model.md)
- [InventorySystem](inventory-system.md)
- [Field Scene](../scenes/field.md)
