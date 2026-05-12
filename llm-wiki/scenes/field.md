---
title: Field Scene
type: reference
updated: 2026-05-12
tags: [scenes, field, prototype]
---

# Field Scene

## Overview

`scenes/field.tscn` is playable Field outside Town. Current slice has click movement, camera follow, Forest Guard blocking the Forest path, a direct Town gateway, and the first Slime combat flow.

## Scene Structure

```text
Field (Node2D, Field)
├── Ground / Paths / ForestEdge / Props
├── SpawnZones
│   └── Grassland (hidden ColorRect enemy spawn region)
├── SpawnPoints
│   ├── FromTownGateway (Marker2D)
│   └── Default (Marker2D)
├── Player (player.tscn, starts at FromTownGateway)
├── TownGateway
├── ForestGateway
├── ForestBlocker
├── ForestGuard (NpcController, forest_guard.png)
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

## Controller

`Field` is thin glue:

- starts Player at named spawn point `SpawnPoints/FromTownGateway`, near TownGateway
- routes ground clicks to `CharacterMovement`
- updates `Camera2D` with RO-style offset
- uses `TownDialogView` for Forest Guard dialog
- handles far-click Guard approach before dialog
- direct Town gateway request to `res://scenes/town_scene.tscn`, with the scene-tree change deferred outside the physics callback
- blocks Forest gateway and opens Guard warning
- samples initial enemy positions from `SpawnZones/Grassland`
- spawns five Slimes, two Bats, and two Rats from `EnemyDefinition.for_id()`
- routes Slime click to player approach + auto-attack
- ticks Slime behavior: idle/wander/chase/attack/die
- applies `CombatSystem` damage to enemy HP and player Life
- plays Slime death animation before removal and grants XP once when HP reaches zero

## Enemy Combat Slice

Current Field combat scope is five Slimes, two Bats, and two Rats.

- Slime id: `slime_spiked`
- Bat id: `bat`
- Rat id: `rat`
- UI: simple text `Life: x/y` and `Slime: x/y`
- RO-style damage numbers appear above Player and Slime.
- Player click targets Slime and moves toward it without aggroing immediately.
- Player auto-attacks with LPC `slash` animation while in range.
- First player hit aggros Slime.
- Aggro enemy chases if player moves away.
- Enemy attacks current Life on its attack interval.
- Enemy death plays `death`, waits `death_duration`, removes the node, and awards XP.
- Initial spawn positions are random inside `SpawnZones/Grassland`, avoiding Player, Town portal, Forest Guard, and nearby enemy overlap.

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, spawn zone, Slime/Bat/Rat spawn/UI, click targeting without immediate aggro, player auto-attack, first-hit aggro, enemy Life damage, chase, death removal/XP, Guard dialog, movement/camera, dialog paging/movement lock, deferred direct Town gateway, and blocked Forest gateway.
- Gateway, NPC placement, biome, movement, enemy behavior, combat, and dialog systems remain covered by their model/scene specs.

Current validation: `241 tests, 241 passed, 0 failed`.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/architecture/gateway-definition.md`
- `llm-wiki/architecture/enemy-behavior-system.md`
