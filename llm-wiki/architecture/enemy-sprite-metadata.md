---
title: Enemy Sprite Metadata
type: reference
updated: 2026-05-12
tags: [architecture, assets, enemies, animation]
---

# Enemy Sprite Metadata

## Overview

Enemy sprite V1 uses RO-ish sprite/action metadata: image strips stay in `assets/enemies`, while JSON describes actions, frame size, timing, loops, facing model, and scale. Gameplay systems can request an action by name without knowing how PNG strips are sliced.

## Files

- `assets/enemies/Slime/slime_spiked.asset.json` — first metadata file.
- `scripts/models/enemy_sprite_catalog.gd` — loads and validates metadata.
- `scripts/views/enemy_sprite_frames_builder.gd` — converts metadata to `SpriteFrames`.
- `tests/specs/enemy_sprite_metadata_test.gd` — loader/validation/builder specs.

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
- Frame size is metadata (`64×64` for Slime), not hardcoded in viewers.
- `death` does not loop; `idle` and `run` loop.
- Two-direction Paper-Mario-style facing is represented by `horizontal_2d` plus horizontal flip support.
- SpriteFrames generation lives in view/tooling layer because it uses Godot texture resources.

## Test Coverage

- `tests/specs/enemy_sprite_metadata_test.gd` covers metadata file/schema, catalog loading, texture/dimension validation, SpriteFrames construction, frame counts, loop flags, and animation speeds.
- `tests/specs/slime_asset_viewer_test.gd` verifies `asset-view.tscn` consumes metadata instead of hardcoded animation paths.

## Related

- `llm-wiki/assets/slime-asset-view.md`
- `assets/assets-catalog.md`
