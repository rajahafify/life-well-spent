---
title: Slime Asset View
type: reference
updated: 2026-05-11
tags: [assets, tools, enemies, slime]
---

# Slime Asset View

## Overview

`assets/asset-view.tscn` is a focused single-enemy asset viewer for **Spiked Slime**. It loads `slime_spiked` sprite metadata, shows one `AnimatedSprite2D`, defaults to `idle`, and exposes buttons for each supported animation.

## Files

- `assets/asset-view.tscn` — focused Slime viewer scene.
- `assets/asset_view.gd` — `SlimeAssetView` Control script.
- `assets/enemies/Slime/slime_spiked.asset.json` — sprite/action metadata.
- `tests/specs/slime_asset_viewer_test.gd` — scene/path/animation/frame slicing specs.

## Behavior

- Uses frame size from metadata (`64×64` for `slime_spiked`).
- Centers each `AnimatedSprite2D` inside a reserved preview area so sprites do not overlap labels or clip at card origin.
- Shows one centered animated sprite.
- Defaults to `idle`.
- Builds buttons for supported animations:
  - ability
  - death
  - hit
  - idle
  - jump
  - run
- Each preview uses `AnimatedSprite2D` with generated `SpriteFrames` built from atlas regions.

## API

```gdscript
func load_sprite_set() -> Dictionary
func rebuild_view() -> void
func frame_count_for_animation(animation_name: String) -> int
```

## Test Coverage

- `tests/specs/slime_asset_viewer_test.gd` covers scene load/root, Slime metadata loading, single-sprite idle default, animation buttons, button-driven animation switching, and metadata-driven frame slicing counts.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/assets/assets-viewer.md`
