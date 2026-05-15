---
title: Player Aging Model
type: reference
tags: [architecture, progression, player]
sources:
  - scripts/models/player_aging_model.gd
  - tests/specs/player_aging_model_test.gd
  - tests/specs/player_aging_assets_test.gd
---

# Player Aging Model

## Overview

`PlayerAgingModel` is a pure presentation rule model that maps the player's Max Life to three LPC player aging sprites: normal hair, grey hair/beard, and white hair/beard. It also chooses equipment variants when the Training Sword and Leather Armor are equipped. It keeps aging thresholds and equipment texture selection outside Town and Field scene glue while letting certification sacrifice and equipment become visible on the player character.

## API

```gdscript
func stage_for_max_hp(max_hp: int) -> int
func texture_path_for_stage(stage: int) -> String
func texture_path_for_max_hp(max_hp: int) -> String
func texture_path_for_stage_with_weapon(stage: int, weapon_id: String) -> String
func texture_path_for_max_hp_and_weapon(max_hp: int, weapon_id: String) -> String
func texture_path_for_stage_with_equipment(stage: int, weapon_id: String, armor_id: String) -> String
func texture_path_for_max_hp_and_equipment(max_hp: int, weapon_id: String, armor_id: String) -> String
```

## Design Decisions

- Age stage 1 is the default full-life player sprite at Max Life above `60`.
- Age stage 2 starts at `60` Max Life after the first Swordsman certification spend.
- Age stage 3 starts at `20` Max Life or lower after the second and final certification pressure.
- The model returns texture paths instead of loading resources so it remains pure and easy to test without scene nodes.
- Bare sprites stay weaponless and armorless.
- Equipping `training_sword` switches to `player_age_1_sword.png`, `player_age_2_sword.png`, or `player_age_3_sword.png`.
- Equipping both `training_sword` and `leather_armor` switches to `player_age_1_sword_armor.png`, `player_age_2_sword_armor.png`, or `player_age_3_sword_armor.png`. These sheets use a brown leather armor palette instead of the LPC generator's default grey armor output.
- Training Sword variants include sword pixels on all four LPC thrust attack rows (`up`, `left`, `down`, `right`) so equipped combat does not fall back visually to hand-only attack frames.

## Test Coverage

- `tests/specs/player_aging_model_test.gd` covers stage thresholds, bare texture path mapping, Training Sword texture path mapping, and sword+armor texture path mapping.
- `tests/specs/player_aging_assets_test.gd` covers the visible hair/beard color story, verifies the generated bare aging sheets do not include a sword layer, verifies the sword and sword+armor variants include equipment pixels on every thrust attack direction, and verifies the armor palette reads as brown leather.
- `tests/specs/town_scene_dialog_test.gd` covers Town applying age stage 1 on start and updating to stages 2 and 3 after certification.
- `tests/specs/field_scene_test.gd` covers Field applying the default age stage 1 player sprite.

## Related

- [architecture/progression-model](progression-model.md)
- [architecture/player-stats](player-stats.md)
- [scenes/town-hub](../scenes/town-hub.md)
- [scenes/field](../scenes/field.md)
