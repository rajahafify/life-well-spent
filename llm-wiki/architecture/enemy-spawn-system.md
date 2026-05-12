---
title: Enemy Spawn System
type: reference
updated: 2026-05-12
tags: [architecture, enemies, persistence]
---

# Enemy Spawn System

## Overview

`EnemySpawnSystem` is the pure model for game-wide enemy spawn slots. `EnemySpawnManager` is the autoload runtime owner that advances spawn time across scene changes and persists spawn state to `user://enemy_spawn_state.json` outside headless test runs.

The Field scene uses this system so defeated enemies do not immediately respawn just because the player changes portals. A defeated enemy slot stays unavailable until its respawn timer expires, then Field's live spawn poll can create it again while the player remains in the map.

## API

```gdscript
# scripts/models/enemy_spawn_system.gd
func register_biome(map_id: String, biome_id: String, max_active: int, respawn_delay: float = 60.0) -> void
func register_spawn_slot(slot_id: String, map_id: String, biome_id: String, enemy_id: String) -> void
func active_spawn_slots(map_id: String, biome_id: String = "") -> Array
func mark_defeated(slot_id: String) -> void
func tick(delta: float) -> void
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
func reset() -> void

# scripts/managers/enemy_spawn_manager.gd
func register_biome(map_id: String, biome_id: String, max_active: int, respawn_delay: float = 60.0) -> void
func register_spawn_slot(slot_id: String, map_id: String, biome_id: String, enemy_id: String) -> void
func active_spawn_slots(map_id: String, biome_id: String = "") -> Array
func mark_defeated(slot_id: String) -> void
func save_state(path: String = SAVE_PATH) -> bool
func load_state(path: String = SAVE_PATH) -> bool
```

## Design Decisions

- Spawn slots are persistent identities, such as `field_slime_001`.
- Biomes define `max_active` and `respawn_delay`.
- Field currently registers `field:grassland` with max active `9` and respawn delay `60` seconds.
- Defeated slots are marked dead at enemy defeat and receive `respawn_at = elapsed_time + respawn_delay`.
- Scene changes do not reset dead slots because state lives in `EnemySpawnManager`, not `Field`.
- The autoload clock advances in `_process`, so respawn time continues while the player is in another scene.
- When a slot becomes active again, Field chooses a fresh valid random position in `SpawnZones/Grassland`.
- Field polls active spawn slots once per second while loaded, so enemies can respawn without re-entering the scene.
- Headless tests skip file loading/saving for deterministic runs; runtime builds persist to `user://enemy_spawn_state.json`.

## Field Integration

On `_ready()`, Field registers its grassland biome and known enemy slots, then spawns only slots returned by `EnemySpawnManager.active_spawn_slots("field", "grassland")`.

During `_physics_process()`, Field calls `_tick_enemy_spawns(delta)`. This polls the spawn manager once per second and fills missing active slots up to the biome cap.

On enemy defeat, Field calls:

```gdscript
EnemySpawnManager.mark_defeated(state.instance_id)
```

The visual enemy remains long enough to play death animation, then the Field controller removes the view.

## Test Coverage

- `tests/specs/enemy_spawn_system_test.gd` covers biome max-active caps, defeated slots staying gone across repeated spawn queries, respawn after global time passes, serialization/restore of timers, and autoload registration.
- `tests/specs/field_scene_test.gd` covers that Field references `EnemySpawnManager`, marks defeated enemy slots globally, and respawns eligible enemies while Field remains loaded.

## Related

- `llm-wiki/architecture/enemy-behavior-system.md`
- `llm-wiki/scenes/field.md`
