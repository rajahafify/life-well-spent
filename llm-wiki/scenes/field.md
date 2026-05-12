---
title: Field Scene
type: reference
updated: 2026-05-12
tags: [scenes, field, prototype]
---

# Field Scene

## Overview

`scenes/field.tscn` is playable Field outside Town. Current reset slice has click movement, camera follow, Forest Guard blocking the Forest path, and a direct Town gateway. It intentionally contains **no enemies** while EnemySystem is being rebuilt.

## Scene Structure

```text
Field (Node2D, Field)
├── Ground / Paths / ForestEdge / Props
├── Player (player.tscn)
├── TownGateway
├── ForestGateway
├── ForestBlocker
├── ForestGuard (NpcController, forest_guard.png)
├── Camera2D
└── UI
    ├── ObjectivePrompt
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

No enemy/combat APIs are active in the controller during EnemySystem reset.

## EnemySystem Reset

Removed from Field until rebuilt:

- `Enemies` scene node
- Slime/Bat/Rat placements
- Combat HUD
- Field enemy click combat methods
- `EnemyDefinition`, `RandomEnemyRespawnSystem`, `EnemyArtDefinition`, and `EnemyView` implementation files/specs

Enemy art assets remain in `assets/enemies/` and future integration tasks live in `assets/assets-catalog.md`. Current Field enemy target set is Slime (`slime_spiked`), Bat (`bat`), and Rat (`rat`).

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, absence of enemies/combat HUD during reset, Guard dialog, movement/camera, dialog paging/movement lock, deferred direct Town gateway, and blocked Forest gateway.
- Gateway, NPC placement, biome, movement, and dialog systems remain covered by their model/scene specs.

Current validation after gateway defer fix: `204 tests, 204 passed, 0 failed`; MCP main-scene play reports no errors.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/architecture/gateway-definition.md`
