---
title: Field Scene
type: reference
updated: 2026-05-12
tags: [scenes, field, prototype]
---

# Field Scene

## Overview

`scenes/field.tscn` is the playable Field outside Town. Current slice has click movement, camera follow, generated Tiny Town field art/collision, Forest Guard blocking the southeast Forest path, a direct Town gateway centered on the north road entry, and the first Slime/Bat/Rat combat flow.

## Scene Structure

```text
Field (Node2D, Field)
├── FieldMap (instance: scenes/maps/field_map.tscn)
├── FieldCollision (instance: scenes/maps/field_collision.tscn)
├── SpawnZones
│   └── Grassland (hidden ColorRect enemy spawn region)
├── SpawnPoints
│   ├── FromTownGateway (Marker2D)
│   └── Default (Marker2D)
├── Player (player.tscn, starts at FromTownGateway, south of TownGateway trigger)
├── TownGateway (north road entry)
├── ForestGateway (southeast road end)
├── ForestGuard (NpcController, forest_guard.png, southeast road end)
├── Enemies
│   ├── Slime*5 (EnemyView, spawned by Field controller)
│   ├── Bat*2 (EnemyView, spawned by Field controller)
│   └── Rat*2 (EnemyView, spawned by Field controller)
├── Camera2D
└── UI
    ├── ObjectivePrompt
    ├── LifeLabel
    ├── SlimeHpLabel
    └── DialogPanel (TownDialogView)
```

## Generated Map

`FieldMap` and `FieldCollision` are generated from:

```text
D:\godot\kenney_tiny-town\field.tmj
```

The field map is `96x68` tiles at `32x32` pixels. It uses Tiny Town visual layers, with collision generated only from tile layers whose names start with `C-` such as `C-Trees` and `C-Fence`. It is imported with:

```powershell
python tools\import_tiny_town_tmj.py --tmj D:\godot\kenney_tiny-town\field.tmj --map-scene scenes\maps\field_map.tscn --collision-scene scenes\maps\field_collision.tscn --update-scene scenes\field.tscn --map-node-name FieldMap --collision-node-name FieldCollision --insert-before SpawnZones --position "0, 0" --scale "1, 1"
```

Legacy primitive Field art nodes (`Ground`, `Paths`, `ForestEdge`, and `Props`) have been removed; imported map layers now own terrain visuals. The previous visible `ForestBlocker` bar under the Forest Guard was removed; blockers now come from the generated `FieldCollision` scene.

## Controller

`Field` is thin glue:

- starts Player at named spawn point `SpawnPoints/FromTownGateway`, near TownGateway
- keeps Player outside the TownGateway trigger on scene load
- routes ground clicks to `CharacterMovement`
- updates `Camera2D` with RO-style offset
- uses `TownDialogView` for Forest Guard dialog
- handles far-click Guard approach before dialog
- direct Town gateway request to `res://scenes/town_scene.tscn`, with the scene-tree change deferred outside the physics callback
- blocks Forest gateway at the southeast road end and opens Guard warning
- samples initial enemy positions from `SpawnZones/Grassland`, rejecting points inside `FieldCollision`
- spawns five Slimes, two Bats, and two Rats from `EnemyDefinition.for_id()`
- routes enemy click to player approach + auto-attack
- ticks enemy behavior: idle/wander/chase/attack/die, then rejects enemy movement that would enter `FieldCollision`
- applies `CombatSystem` damage to enemy HP and player Life
- plays enemy death animation before removal and grants XP once when HP reaches zero

## Enemy Combat Slice

Current Field combat scope is five Slimes, two Bats, and two Rats.

- Slime id: `slime_spiked`
- Bat id: `bat`
- Rat id: `rat`
- UI: simple text `Life: x/y` and `Slime: x/y`
- RO-style damage numbers appear above Player and enemies.
- Player click targets an enemy and moves toward it without aggroing immediately.
- Player auto-attacks with LPC `slash` animation while in range.
- First player hit aggros the enemy.
- Aggro enemy chases if player moves away.
- Enemy attacks current Life on its attack interval.
- Enemy death plays `death`, waits `death_duration`, removes the node, and awards XP.
- Initial spawn positions are random inside `SpawnZones/Grassland`, avoiding Player, Town portal, Forest Guard, imported collision blockers, and nearby enemy overlap.

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, generated `FieldMap` and `FieldCollision`, north TownGateway placement, removal of legacy primitive Field art and the old visible ForestBlocker bar, southeast Forest Guard/gateway placement, enemy collision rejection, spawn zone, Slime/Bat/Rat spawn/UI, click targeting without immediate aggro, player auto-attack, first-hit aggro, enemy Life damage, chase, death removal/XP, Guard dialog, movement/camera, dialog paging/movement lock, deferred direct Town gateway, and blocked Forest gateway.
- Gateway, NPC placement, biome, movement, enemy behavior, combat, and dialog systems remain covered by their model/scene specs.

Current validation: `250 tests, 250 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/assets/tiny-town-map-import.md`
- `llm-wiki/architecture/gateway-definition.md`
- `llm-wiki/architecture/enemy-behavior-system.md`
