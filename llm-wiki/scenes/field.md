---
title: Field Scene
type: reference
updated: 2026-05-11
tags: [scenes, field, prototype]
---

# Field Scene

## Overview

`scenes/field.tscn` is playable Field MVP outside Town. Player can click-move, camera follows, enemies are visible/click-attackable, Forest path is blocked by Forest Guard, and Town gateway returns directly to Town.

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
│   ├── Chick
│   ├── Rabbit
│   └── Slime
├── Camera2D
└── UI
    ├── ObjectivePrompt
    ├── CombatHud
    └── DialogPanel (TownDialogView)
```

## Controller

`Field` is thin glue:

- routes ground clicks to `CharacterMovement`
- updates `Camera2D` with RO-style offset
- uses `TownDialogView` for Forest Guard dialog
- handles far-click Guard approach before dialog
- direct Town gateway request to `res://scenes/town_scene.tscn`
- blocks Forest gateway and opens Guard warning
- wires click attacks through `CombatSystem`

## Combat

Field combat uses `CombatSystem`. Enemy clicks damage HP; defeated enemies hide and grant XP. Player Life remains unchanged.

## Enemy Art

Field enemies now use SVG placeholder art:

- Chick: `assets/enemies/chick.svg`
- Rabbit: `assets/enemies/rabbit.svg`
- Slime: `assets/enemies/slime.svg`

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, enemy SVG art, Guard dialog, movement/camera, dialog paging/movement lock, direct Town gateway, blocked Forest gateway, and enemy combat XP.
- Model specs cover gateway, enemy, combat, respawn, NPC placement, and biome systems.

## Related

- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/architecture/combat-system.md`
- `llm-wiki/architecture/gateway-definition.md`
