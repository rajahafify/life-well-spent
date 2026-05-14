---
title: Enemy Behavior System
type: reference
updated: 2026-05-13
tags: [architecture, models, enemies, combat]
---

# Enemy Behavior System

## Overview

`EnemyBehaviorSystem` drives runtime enemy state transitions. Current Field implementation starts Slime, Bat, and Rat instances: idle, wander, chase, attack, die. State lives in `EnemyState`; static tuning, XP, and deterministic item drops are created by `EnemyLibrary` as `EnemyDefinition` resources.

## API

```gdscript
# scripts/models/enemy_definition.gd
func apply_config(config: Dictionary) -> void
func to_enemy_state_dict(hp_override: int = -1) -> Dictionary

# scripts/models/enemy_library.gd
static func for_id(enemy_id: String)
static func from_config(config: Dictionary)

# scripts/models/enemy_state.gd
static func from_definition(instance_id: String, definition, spawn_pos: Vector2)
func to_combat_dict() -> Dictionary
func apply_combat_dict(next_state: Dictionary) -> void

# scripts/models/enemy_behavior_system.gd
func tick(state, definition, context: Dictionary, delta: float) -> void
```

## Design Decisions

- `enemy_id` identifies type; `instance_id` identifies spawned copy.
- Slime starts idle with full HP.
- Enemies spawn from the scene-authored `SpawnZones/Grassland` rect, not fixed coordinates.
- Enemies use per-instance RNG seeds for staggered idle timing and pseudo-random wander targets; random sequencing lives in `EnemyRandomSequence`, not `EnemyState`.
- Targeting/clicking Slime does not aggro it immediately; Slime waits until first player hit.
- Proximity aggro is disabled for now with `aggro_radius = 0.0`; future enemies can enable it by setting radius > 0.
- Aggro Slime chases player until attack range.
- In attack range, Slime attacks on `attack_interval`.
- HP <= 0 enters `die`; Field plays death animation, waits `death_duration`, removes the view, and grants XP plus item drops once.
- Slime, Bat, and Rat each have material drops and Apple drops with `chance_numerator = 1` and `chance_denominator = 5`.
- Current Field balance scales enemy HP and player outgoing attack 10x for readability while leaving player Life and enemy attack values unchanged.
- Slime defense is scaled to 10 so Field player attack 40 produces 30 visible damage, matching the previous 4 attack vs 1 defense damage at 10x.
- Enemy world sprites render at 4x scale, with larger click collision and wider attack ranges so enemies stop outside the player footprint instead of overlapping the player sprite.
- Behavior model is testable without scene tree. It mutates `EnemyState` only; attack/death events are exposed through state flags such as `enemy_attack_ready` and `died_this_tick`.

## Slime Defaults

```text
enemy_id: slime_spiked
display_name: Spiked Slime
hp: 140
attack: 1
defense: 10
xp: 5
move_speed: 45
chase_speed: 65
aggro_radius: 0
idle_min_time: 0.4
idle_max_time: 3.5
attack_range: 96
attack_interval: 1.4
death_duration: 0.8
drops: slime_gel x1 at 1/5 chance, apple x1 at 1/20 chance
```

## Other Field Enemy Defaults

```text
Bat hp: 80
Bat attack: 2
Bat defense: 0
Bat attack_range: 104
Bat drops: bat_wing x1 at 1/5 chance, training_sword x1 at 1/20 chance

Rat hp: 60
Rat attack: 2
Rat defense: 0
Rat attack_range: 96
Rat drops: rat_tail x1 at 1/5 chance, leather_armor x1 at 1/20 chance
```

## Test Coverage

- `tests/specs/enemy_library_test.gd` covers registry lookup, fallback lookup, and keeps factory construction out of `EnemyDefinition`.
- `tests/specs/enemy_state_test.gd` covers `EnemyState` identity, combat stats, combat dict mapping, defeat transition, and deterministic seed setup.
- `tests/specs/enemy_behavior_system_test.gd` covers Slime/Bat/Rat definition defaults including 10x Field HP tuning, 1-in-5 material drops, rare 1-in-20 Slime Apple, Bat weapon, and Rat armor drops, idle state, per-instance wander variation, proximity aggro disabled by default, optional radius aggro, attack interval, chase after target leaves range, and death transition.
- `tests/specs/field_scene_test.gd` covers Field spawning Slimes/Bats/Rats inside `SpawnZones/Grassland`, enlarged enemy sprite/collision footprint, click engage, player approach spacing, player slash auto-attack, RO-style damage numbers, enemy Life damage, chase, death animation delay, removal, and XP reward.

## Related

- `llm-wiki/architecture/combat-system.md`
- `llm-wiki/scenes/field.md`
- `llm-wiki/architecture/biome-definition.md`
