---
title: Slime Asset View
type: reference
updated: 2026-05-11
tags: [assets, tools, enemies, slime]
---

# Slime Asset View

## Overview

`assets/asset-view.tscn` is a focused single-enemy asset viewer for **SLIME**. It builds animated previews from the Slime PNG strips in `res://assets/enemies/Slime`.

## Files

- `assets/asset-view.tscn` — focused Slime viewer scene.
- `assets/asset_view.gd` — `SlimeAssetView` Control script.
- `tests/specs/slime_asset_viewer_test.gd` — scene/path/animation/frame slicing specs.

## Behavior

- Uses 64×64 frame slicing.
- Centers each `AnimatedSprite2D` inside a reserved preview area so sprites do not overlap labels or clip at card origin.
- Builds animated cards for:
  - idle
  - run
  - hit
  - jump
  - death
  - ability
- Each preview uses `AnimatedSprite2D` with generated `SpriteFrames` built from atlas regions.

## API

```gdscript
func slime_animation_paths() -> Dictionary
func rebuild_view() -> void
func frame_count_for_strip(texture_path: String) -> int
```

## Test Coverage

- `tests/specs/slime_asset_viewer_test.gd` covers scene load/root, Slime animation path collection, animated preview construction, centered preview area, active playback, and 64×64 frame slicing counts.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/assets/assets-viewer.md`
