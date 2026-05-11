---
title: PlayerMovement
type: reference
updated: 2026-05-11
sources:
  - scripts/views/character_movement.gd
  - tests/specs/player_movement_test.gd
  - scenes/player.tscn
tags: [architecture, tech]
---

# PlayerMovement

## Overview
Click-to-move/static Sprite2D view. Consumes `AnimationController` model for all frame calculations. Uses `_physics_process` + parent `CharacterBody2D` velocity for physics-compatible movement when not static. Handles destination marker visibility, direction-from-vector math, and cleanup of the owned animation model on `NOTIFICATION_PREDELETE`.

## Architecture
- Lives in `scripts/views/` — view layer (MVC). Manages sprite rendering.
- Delegates frame calculation to `AnimationController` — no duplicated LPC constants.
- Static `_dir_from_vector()` utility for 8-axis direction detection.

## Public API

```gdscript
class_name CharacterMovement
extends Sprite2D

@export var move_speed: float = 200.0
@export var is_static: bool = false
@export var marker_path: NodePath = ^"../../DestinationMarker"

var destination: Vector2
var moving: bool
var can_move: bool

func move_to(target: Vector2) -> void
func set_facing(dir: String) -> void  # safe before _ready; initializes frames/model if needed
func face_player(target_pos: Vector2) -> void
func face_target(target_pos: Vector2) -> void
func stop_moving() -> void

# Static utility (testable without instantiation)
static func _dir_from_vector(v: Vector2) -> String
```

## Design Decisions

### Why view, not controller?
`CharacterMovement` manages sprite frame rendering, physics movement, facing, and marker visibility — all view concerns. It contains no business logic.

### Why consume AnimationController?
Previous version had duplicated LPC constants (COLUMNS, ROWS, WALK_BASE, etc.) and frame calculation logic. Delegating to AnimationController model ensures animation logic is tested once and reusable for other sprite types (NPCs, enemies).

### Why stop on collision or dialog open?
`move_and_slide()` can collide with solid NPCs before reaching the exact click destination. When a collision happens while moving, `CharacterMovement` stops movement and returns to idle so player animation does not walk forever against NPC bodies. `stop_moving()` is public so modal dialogs can immediately clear movement/velocity before locking input.

### Why `_physics_process` and CharacterBody2D?
Using `_physics_process` with `move_and_slide()` on the parent CharacterBody2D gives:
- Collision-aware movement (walls, obstacles, NPCs)
- Physics engine integration for future interactions
- Consistent delta timing via physics tick
- Clean separation: Sprite2D handles visuals, CharacterBody2D handles position/collision

### Why exported NodePath for marker?
Replaces hardcoded `get_node_or_null("DestinationMarker")` / `get_node_or_null("../DestinationMarker")` with an editor-configurable path. Prevents breakage on scene restructuring and follows Godot best practice.

### Why static `_dir_from_vector()`?
Direction-from-vector math is pure logic with no Node dependency. Making it static allows unit testing without instantiating a Sprite2D. Tests cover all 8 cardinal axes plus zero vector edge case.

#### Direction priority (horizontal bias)
```gdscript
if v == Vector2.ZERO:
    return "down"                     # safe default
if abs(v.x) >= abs(v.y):
    return "right" if v.x > 0 else "left"   # horizontal wins ties
return "down" if v.y > 0 else "up"          # vertical
```

## Test Coverage
15 tests in `tests/specs/player_movement_test.gd` plus scene smoke coverage in `tests/specs/scene_smoke_test.gd`:
- Right, left, down, up from vectors
- Equal magnitudes favor horizontal
- Zero vector defaults to down
- Pure vertical/horizontal vectors
- Static characters ignore `move_to()`
- `set_facing()` updates frame direction and initializes sprite frame layout if needed
- `stop_moving()` clears movement and velocity, returning to idle frames
- `face_target()` faces a world target
- `can_move = false` blocks `move_to()` while dialog is open

## Related
- `AnimationController` — model for frame calculation
- `TownSceneController` — calls `move_to()` on mouse click
- `NpcController` — calls `face_player()` on interaction
