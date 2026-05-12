---
title: Enemy Asset Tools
type: reference
updated: 2026-05-12
tags: [assets, tools, enemies, animation]
---

# Enemy Asset Tools

## Overview

Enemy/character animation tooling is split into two scenes. `assets/asset-view.tscn` is the focused `AssetView` single-preview tool for selecting one enemy or LPC character and one animation. `assets/assets-gallery.tscn` is the `AssetGallery` editor scene that keeps every enemy sprite node visible and looping and appends Player/Forest Guard LPC previews.

## Files

- `assets/asset-view.tscn` - focused single-preview enemy animation scene.
- `assets/asset_view.gd` - `AssetView` Control script.
- `assets/assets-gallery.tscn` - all-enemy looping SpriteFrames gallery.
- `assets/asset_gallery.gd` - `AssetGallery` root Control script for all gallery sprites.
- `assets/enemies/**/**.asset.json` - sprite/action metadata.
- `assets/enemies/**/**_sprite_frames.tres` - Godot-native `SpriteFrames` resources for Inspector timing/loop tweaks.
- `tests/specs/slime_asset_viewer_test.gd` - focused `AssetView` specs.
- `scripts/views/lpc_sprite_frames_builder.gd` - builds `SpriteFrames` from full 13x21 LPC character sheets.
- `tests/specs/asset_gallery_test.gd` - looping `AssetGallery` specs.

## Behavior

- `AssetView` shows one selected enemy or character at a time and builds playback buttons for supported animations.
- Character options include `Player` and `Forest Guard`.
- LPC character previews expose `idle`, `walk`, `slash`, `thrust`, `shoot`, `spellcast`, and `hurt`.
- `AssetGallery` shows all V1 metadata enemies at once, loops each enemy `idle`, and appends Player/Forest Guard idle previews.
- `AssetGallery` uses one root Control script for all sprites.
- Each gallery sprite directly references its own `.tres` resource:
  - `SlimeSprite`
  - `RatSprite`
  - `BatSprite`
  - `CrabSprite`
  - `ArmoredGolemSprite`
  - `GolemSprite`
  - `PebbleSprite`
  - `SkullSprite`
- Select `BatSprite` or another gallery sprite in `assets-gallery.tscn` to edit that enemy's SpriteFrames timing.

## API

```gdscript
# AssetView
func load_sprite_set() -> Dictionary
func rebuild_view() -> void
func select_enemy(selected_enemy_id: String) -> void
func play_animation(animation_name: String) -> void
func frame_count_for_animation(animation_name: String) -> int

# AssetGallery
func rebuild_gallery() -> void
func sprite_node_for_enemy(enemy_id: String) -> AnimatedSprite2D
func sprite_node_for_character(character_id: String) -> AnimatedSprite2D
```

## Test Coverage

- `tests/specs/slime_asset_viewer_test.gd` covers `AssetView` scene load/root, single preview nodes, selected enemy metadata loading, selector options, animation buttons, animation switching, Rat switching, Player LPC switching, slash/thrust/hurt frame counts, and metadata frame counts.
- `tests/specs/asset_gallery_test.gd` covers `AssetGallery` scene load/root, one editor-visible sprite per enemy, direct `.tres` references, character preview nodes, and looping idle playback.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/assets/assets-viewer.md`
