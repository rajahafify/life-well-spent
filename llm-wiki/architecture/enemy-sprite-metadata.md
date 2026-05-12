---
title: Enemy Sprite Metadata
type: reference
updated: 2026-05-12
tags: [architecture, assets, enemies, animation]
---

# Enemy Sprite Metadata

## Overview

Enemy sprite V1 uses RO-ish sprite/action metadata plus Godot-native `SpriteFrames` resources. Image strips stay in `assets/enemies`, JSON describes identity/facing/source actions, and `*_sprite_frames.tres` stores editor-tweakable animation timing/loop data. Gameplay systems can request an action by name without knowing how PNG strips are sliced.

## Files

- `assets/enemies/Slime/slime_spiked.asset.json`
- `assets/enemies/Rat/rat.asset.json`
- `assets/enemies/Bat/bat.asset.json`
- `assets/enemies/Crab/crab.asset.json`
- `assets/enemies/Golem/Armored/golem_armored.asset.json`
- `assets/enemies/Golem/No Armor/golem.asset.json`
- `assets/enemies/Pebble/pebble.asset.json`
- `assets/enemies/Skull/skull.asset.json`
- `scripts/models/enemy_sprite_catalog.gd` — loads and validates metadata.
- `scripts/views/enemy_sprite_frames_builder.gd` — loads `SpriteFrames` resources when present, otherwise converts metadata strips to generated `SpriteFrames`.
- `tools/generate_enemy_sprite_frames.gd` — regenerates `*_sprite_frames.tres` resources from metadata strips.
- `tests/specs/enemy_sprite_metadata_test.gd` — loader/validation/builder specs.

## Current Metadata Entries

- `slime_spiked` — display name `Spiked Slime`; actions: idle, run, hit, jump, death, ability.
- `rat` — display name `Rat`; actions: idle, run, hit, attack, death, ability.
- `bat` — display name `Bat`; actions: idle/run via fly, hit, attack, death.
- `crab` — display name `Crab`; actions: idle, run, hit, attack_a/b/c, death, ability.
- `golem_armored` — display name `Armored Golem`; actions: idle, run, hit, attack_a/b/c, ability, death via armor break.
- `golem` — display name `Golem`; actions: idle variants, run, hit variants, attack_a/b/c, death variants, reset, upgrade.
- `pebble` — display name `Pebble`; actions: idle, run, hit, death.
- `skull` — display name `Skull`; actions: idle, run/fly, hit, death.

## Slime V1

Stable ID:

```text
slime_spiked
```

Display name:

```text
Spiked Slime
```

Facing model:

```text
horizontal_2d, supports_flip = true
```

Actions:

- idle
- run
- hit
- jump
- death
- ability

## Design Decisions

- Metadata is separate from combat stats.
- Godot `SpriteFrames` `.tres` resources are the editor-tweakable timing/loop source.
- Frame size is metadata (`64×64` for current assets), not hardcoded in viewers.
- `death` does not loop; `idle` and `run` loop.
- Two-direction Paper-Mario-style facing is represented by `horizontal_2d` plus horizontal flip support.
- SpriteFrames generation lives in view/tooling layer because it uses Godot texture resources.
- Regenerating `.tres` may overwrite Inspector timing changes; only regenerate when source strips/actions change.

## Test Coverage

- `tests/specs/enemy_sprite_metadata_test.gd` covers Spiked Slime metadata file/schema, catalog loading, texture/dimension validation, SpriteFrames construction, frame counts, loop flags, and animation speeds.
- `tests/specs/enemy_sprite_rat_test.gd` covers Rat metadata schema, catalog registration, actions, texture paths, and validation.
- `tests/specs/enemy_sprite_catalog_all_test.gd` covers all imported metadata enemy IDs and validates required actions/textures/frame dimensions.
- `tests/specs/enemy_sprite_frames_resource_test.gd` covers `.tres` SpriteFrames resource references, loadability, required animations, and frame presence.
- `tests/specs/slime_asset_viewer_test.gd` verifies focused `AssetView` single-preview behavior.
- `tests/specs/asset_gallery_test.gd` verifies `assets-gallery.tscn` exposes one editor-visible looping sprite per enemy and each sprite directly references the correct `.tres` resource.

## Related

- `llm-wiki/assets/slime-asset-view.md`
- `assets/assets-catalog.md`
