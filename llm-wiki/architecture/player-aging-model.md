---
title: Player Aging Model
type: reference
tags: [architecture, progression, player]
sources:
  - scripts/models/player_aging_model.gd
  - tests/specs/player_aging_model_test.gd
---

# Player Aging Model

## Overview

`PlayerAgingModel` is a pure presentation rule model that maps the player's Max Life to three LPC player aging sprites: normal hair, grey hair/beard, and white hair/beard. It keeps aging thresholds outside Town and Field scene glue while letting certification sacrifice become visible on the player character.

## API

```gdscript
func stage_for_max_hp(max_hp: int) -> int
func texture_path_for_stage(stage: int) -> String
func texture_path_for_max_hp(max_hp: int) -> String
```

## Design Decisions

- Age stage 1 is the default full-life player sprite at Max Life above `60`.
- Age stage 2 starts at `60` Max Life after the first Swordsman certification spend.
- Age stage 3 starts at `20` Max Life or lower after the second and final certification pressure.
- The model returns texture paths instead of loading resources so it remains pure and easy to test without scene nodes.

## Test Coverage

- `tests/specs/player_aging_model_test.gd` covers stage thresholds and texture path mapping.
- `tests/specs/player_aging_assets_test.gd` covers the visible hair/beard color story for the three generated player sprites.
- `tests/specs/town_scene_dialog_test.gd` covers Town applying age stage 1 on start and updating to stages 2 and 3 after certification.
- `tests/specs/field_scene_test.gd` covers Field applying the default age stage 1 player sprite.

## Related

- [architecture/progression-model](progression-model.md)
- [architecture/player-stats](player-stats.md)
- [scenes/town-hub](../scenes/town-hub.md)
- [scenes/field](../scenes/field.md)
