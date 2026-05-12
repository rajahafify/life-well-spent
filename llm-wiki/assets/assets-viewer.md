---
title: Assets Viewer
type: reference
updated: 2026-05-12
tags: [assets, tools, enemies, characters]
---

# Assets Viewer

## Overview

`assets/assets-viewer.tscn` is an in-project gallery for enemy and character PNG assets. It scans enemy folders, NPC sprites, and the player spritesheet, then builds a scrollable thumbnail grid at runtime/editor time.

## Files

- `assets/assets-viewer.tscn` — gallery scene.
- `assets/assets_viewer.gd` — `AssetsViewer` Control script.
- `tests/specs/assets_viewer_test.gd` — scene/catalog/gallery specs.

## Behavior

- Recursively finds PNG assets under `res://assets/enemies`.
- Includes `res://assets/player.png` and PNGs under `res://assets/npcs`.
- Excludes GIF previews for now.
- Builds:
  - `Scroll`
  - `Scroll/Margin/VBox/Title`
  - `Scroll/Margin/VBox/Summary`
  - `Scroll/Margin/VBox/GalleryGrid`
- Each card stores `asset_path` metadata and shows a thumbnail plus relative path label.

## API

```gdscript
func collect_asset_paths() -> Array
func rebuild_gallery() -> void
```

## Design Decisions

The viewer is a gallery utility, not gameplay UI. It does not select, classify, or instantiate enemies. EnemySystem rebuild should use a separate model/catalog and can reference this viewer only for visual browsing.

## Test Coverage

- `tests/specs/assets_viewer_test.gd` covers scene load/root, recursive PNG collection, known asset inclusion, scroll container, grid, card count, and card metadata.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/field.md`
