---
title: Tiny Town Map Import
type: reference
updated: 2026-05-12
tags: [assets, maps, tooling, town]
---

# Tiny Town Map Import

## Overview

`tools/import_tiny_town_tmj.py` converts external layered Tiny Town Tiled maps into native Godot visual and collision scenes. Gameplay nodes, gateways, spawn points, NPCs, camera, and UI stay owned by the target scene.

## Source

```text
D:\godot\kenney_tiny-town\town_layout_build_32.tmj
D:\godot\kenney_tiny-town\field.tmj
D:\godot\kenney_tiny-town\Tilemap\tilemap_packed_2x.png
```

The TMJ is a `28x24` orthogonal map using `32x32` tiles and the learned Tiny Town layer order:

```text
Ground, Paths, Fences, Houses, Castle, Trees, Bushes, Props
```

## Output

```text
assets/tiny_town/tilemap_packed_2x.png
scenes/maps/town_map.tscn
scenes/maps/town_collision.tscn
scenes/maps/field_map.tscn
scenes/maps/field_collision.tscn
```

`*_map.tscn` contains one `Node2D` per source layer and generated `Sprite2D` tile nodes using texture regions from the copied tileset.

`*_collision.tscn` contains generated `StaticBody2D` blockers. The importer builds a solid tile mask from:

```text
Fences, Houses, Castle, Trees, Bushes, Props
```

Adjacent solid tiles are merged into larger `RectangleShape2D` blockers so the scene avoids one collision body per tile.

## Command

```powershell
python tools\import_tiny_town_tmj.py --update-town-scene
```

The command regenerates the map/collision scenes, copies the tileset, and adds `TownMap` plus `TownCollision` to `scenes/town_scene.tscn` if they are missing. The current Town placement is:

```gdscript
position = Vector2(64, -180)
scale = Vector2(2, 2)
```

`TownCollision` uses the same position and scale so its blockers line up with `TownMap`.

Field import:

```powershell
python tools\import_tiny_town_tmj.py --tmj D:\godot\kenney_tiny-town\field.tmj --map-scene scenes\maps\field_map.tscn --collision-scene scenes\maps\field_collision.tscn --update-scene scenes\field.tscn --map-node-name FieldMap --collision-node-name FieldCollision --insert-before SpawnZones --position "0, 0" --scale "1, 1"
```

## Design Decisions

- Keep Tiled as the editable source for the layered Tiny Town map.
- Keep Godot as the owner of runtime behavior and generated collision.
- Use generated `Sprite2D` tiles first because the project has no existing TileMapLayer or Tiled importer pipeline.
- Generate collision as a separate native scene so it can be tuned or regenerated independently from visuals.

## Test Coverage

- `tests/specs/town_prototype_test.gd` asserts that Town instances `res://scenes/maps/town_map.tscn` as `TownMap` with the expected position and scale.
- `tests/specs/town_prototype_test.gd` asserts that Town instances `res://scenes/maps/town_collision.tscn` as `TownCollision` and that it contains `StaticBody2D` blockers with `CollisionShape2D`.
- `tests/specs/field_scene_test.gd` asserts that Field instances `res://scenes/maps/field_map.tscn` as `FieldMap` and `res://scenes/maps/field_collision.tscn` as `FieldCollision`.

## Related

- `scenes/town_scene.tscn`
- `scenes/field.tscn`
- `scenes/maps/town_map.tscn`
- `scenes/maps/town_collision.tscn`
- `scenes/maps/field_map.tscn`
- `scenes/maps/field_collision.tscn`
- `tools/import_tiny_town_tmj.py`
- `llm-wiki/scenes/town-hub.md`
