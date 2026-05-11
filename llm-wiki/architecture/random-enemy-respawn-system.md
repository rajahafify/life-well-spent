---
title: Random Enemy Respawn System
type: reference
updated: 2026-05-11
tags: [architecture, models, spawning]
---

# Random Enemy Respawn System

## Overview

`RandomEnemyRespawnSystem` is a pure spawn-zone timer/cap model for keeping Field populated.

## API

```gdscript
func define_zone(spawn_zone_id: String, enemy_pool: Array, max_active: int, respawn_interval: float, biome_type: String = "") -> Dictionary
func tick_zone(zone: Dictionary, elapsed: float, active_count: int) -> Dictionary
func schedule_after_spawn(zone: Dictionary) -> Dictionary
```

## Design Decisions

MVP spawn rolls are deterministic: first enemy in pool. This keeps tests stable and leaves randomness/tuning for later.

## Test Coverage

- `tests/specs/random_enemy_respawn_test.gd` covers timer elapsed spawn, max active cap, and waiting interval.

## Related

- `llm-wiki/architecture/enemy-definition.md`
- `llm-wiki/architecture/biome-definition.md`
