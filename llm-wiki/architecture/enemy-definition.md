---
title: Enemy Definition
type: reference
updated: 2026-05-11
tags: [architecture, models, combat]
---

# Enemy Definition

## Overview

`EnemyDefinition` defines prototype Field enemies with identity, combat stats, biome tags, and XP rewards.

## API

```gdscript
var enemy_id: String
var display_name: String
var hp: int
var attack: int
var defense: int
var xp_reward: int
var spawn_position: Vector2
var biome_tags: Array

func is_defeated(current_hp: int) -> bool
func to_combat_state() -> Dictionary
static func chick()
static func rabbit()
static func slime()
static func prototype_field_enemies() -> Array
```

## Design Decisions

Chick, Rabbit, and Slime are small grassland enemies. Stats are intentionally simple for MVP tuning.

## Test Coverage

- `tests/specs/enemy_system_test.gd` covers all three enemy definitions and defeat checks.

## Related

- `llm-wiki/architecture/combat-system.md`
- `llm-wiki/scenes/field.md`
