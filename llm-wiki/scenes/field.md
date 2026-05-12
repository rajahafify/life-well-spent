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
├── Player (player.tscn)
├── TownGateway
├── ForestGateway
├── ForestBlocker
├── ForestGuard (NpcController, forest_guard.png)
├── Enemies
│   └── Slime (EnemyView, spawned by Field controller)
├── Camera2D
└── UI
    ├── ObjectivePrompt
    ├── LifeLabel
    ├── SlimeHpLabel
    └── DialogPanel (TownDialogView)
```

## Controller

`Field` is thin glue:

- routes ground clicks to `CharacterMovement`
- updates `Camera2D` with RO-style offset
- uses `TownDialogView` for Forest Guard dialog
- handles far-click Guard approach before dialog
- direct Town gateway request to `res://scenes/town_scene.tscn`, with the scene-tree change deferred outside the physics callback
- blocks Forest gateway and opens Guard warning
- spawns one Slime from `EnemyDefinition.slime_spiked()`
- routes Slime click to player approach + auto-attack
- ticks Slime behavior: idle/wander/chase/attack/die
- applies `CombatSystem` damage to enemy HP and player Life
- removes Slime and grants XP once when HP reaches zero

## Slime Combat Slice

Current Field combat scope is one Slime only.

- Slime id: `slime_spiked`
- UI: simple text `Life: x/y` and `Slime: x/y`
- Player click engages Slime and moves toward it.
- Player auto-attacks while in range.
- Aggro Slime chases if player moves away.
- Slime attacks current Life on its attack interval.
- Slime death removes the node and awards XP.

Bat/Rat remain target enemies for the later EnemySystem expansion.

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, Slime spawn/UI, click engage, player auto-attack, Slime Life damage, Slime chase, Slime death removal/XP, Guard dialog, movement/camera, dialog paging/movement lock, deferred direct Town gateway, and blocked Forest gateway.
- Gateway, NPC placement, biome, movement, enemy behavior, combat, and dialog systems remain covered by their model/scene specs.

Current validation: `232 tests, 232 passed, 0 failed`.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/architecture/gateway-definition.md`
- `llm-wiki/architecture/enemy-behavior-system.md`
