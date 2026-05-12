---
title: Field Controller Boundaries
type: reference
updated: 2026-05-13
sources:
  - scripts/controllers/field.gd
  - scripts/controllers/field_camera_controller.gd
  - scripts/controllers/field_enemy_spawn_controller.gd
  - scripts/controllers/field_combat_controller.gd
  - tests/specs/field_scene_test.gd
tags: [architecture, field, controllers]
---

# Field Controller Boundaries

## Overview

`Field` remains the scene glue for `scenes/field.tscn`, while extracted helper controllers own the heavier runtime loops that previously lived directly in the scene controller.

## API

```gdscript
# scripts/controllers/field_camera_controller.gd
func update_camera(camera: Camera2D, player: Node2D, offset: Vector2) -> void
func start_shake() -> void
func tick_shake(delta: float) -> void
func is_shaking() -> bool

# scripts/controllers/field_enemy_spawn_controller.gd
func setup(owner) -> void
func tick(owner, delta: float) -> void
func spawn_active_slots(owner) -> void

# scripts/controllers/field_combat_controller.gd
func tick_player_auto_attack(owner, delta: float) -> void
func tick_enemies(owner, delta: float) -> void
```

## Design Decisions

- `FieldCameraController` owns camera follow offset application and hit shake.
- `FieldEnemySpawnController` owns spawn slot registration, live respawn polling, and valid random spawn placement.
- `FieldCombatController` owns player auto-attack and enemy behavior/combat tick orchestration.
- `Field` exposes narrow query/glue methods such as `enemy_state()`, `enemy_view()`, `player_target_id()`, and `is_camera_shaking()` so tests do not need to read internal dictionaries directly.

## Test Coverage

- `tests/specs/field_scene_test.gd` splits the previous broad Field scene assertions into behavior-named specs for player/camera, gateways, HUD, enemy setup, spawn zones, combat feedback, death, drops, and dialog flow.

## Related

- [Field Scene](../scenes/field.md)
- [EnemyBehaviorSystem](enemy-behavior-system.md)
- [CombatSystem](combat-system.md)
