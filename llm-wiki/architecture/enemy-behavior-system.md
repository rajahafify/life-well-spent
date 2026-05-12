---
title: Enemy Behavior System
type: reference
updated: 2026-05-12
tags: [architecture, models, enemies, combat]
---

# Enemy Behavior System

## Overview

`EnemyBehaviorSystem` drives runtime enemy state transitions. First implementation supports one Field Slime: idle, wander, chase, attack, die. State lives in `EnemyState`; static tuning lives in `EnemyDefinition`.

## API

```gdscript
# scripts/models/enemy_definition.gd
static func slime_spiked()

# scripts/models/enemy_state.gd
static func from_definition(instance_id: String, definition, spawn_pos: Vector2)
func to_combat_dict() -> Dictionary
func apply_combat_dict(next_state: Dictionary) -> void

# scripts/models/enemy_behavior_system.gd
func tick(state, definition, context: Dictionary, delta: float) -> Dictionary
```

## Design Decisions

- `enemy_id` identifies type; `instance_id` identifies spawned copy.
- Slime starts idle with full HP.
- Slime can wander near spawn.
- Slime aggros when player enters radius or Field explicitly engages it.
- Aggro Slime chases player until attack range.
- In attack range, Slime attacks on `attack_interval`.
- HP <= 0 enters `die`; Field removes the view and grants XP once.
- Behavior model is testable without scene tree. Field controller applies resulting actions to combat/UI/views.

## Slime Defaults

```text
enemy_id: slime_spiked
display_name: Spiked Slime
hp: 14
attack: 1
defense: 1
xp: 5
move_speed: 45
chase_speed: 65
aggro_radius: 180
attack_range: 48
attack_interval: 1.4
```

## Test Coverage

- `tests/specs/enemy_behavior_system_test.gd` covers Slime definition defaults, idle state, aggro/chase, attack interval, chase after target leaves range, and death transition.
- `tests/specs/field_scene_test.gd` covers Field spawning one Slime, click engage, player auto-attack, Slime Life damage, chase, death removal, and XP reward.

## Related

- `llm-wiki/architecture/combat-system.md`
- `llm-wiki/scenes/field.md`
- `llm-wiki/architecture/biome-definition.md`
