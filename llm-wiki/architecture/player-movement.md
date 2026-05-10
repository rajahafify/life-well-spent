---
title: PlayerMovement
type: reference
updated: 2026-05-11
sources:
  - scripts/views/player_movement.gd
  - tests/specs/player_movement_test.gd
  - scenes/player.tscn
tags: [architecture, tech]
---

# PlayerMovement

## Overview
Click-to-move Sprite2D view. Consumes `AnimationController` model for all frame calculations. Uses `_physics_process` + parent `CharacterBody2D` velocity for physics-compatible movement. Handles destination marker visibility, and direction-from-vector math.

## Architecture
- Lives in `scripts/views/` — view layer (MVC). Manages sprite rendering.
- Delegates frame calculation to `AnimationController` — no duplicated LPC constants.
- Static `_dir_from_vector()` utility for 8-axis direction detection.

## Public API

```gdscript
class_name PlayerMovement
extends Sprite2D

@export var move_speed: float = 200.0
@export var marker_path: NodePath = ^"../../DestinationMarker"

var destination: Vector2
var moving: bool
var can_move: bool

func move_to(target: Vector2) -> void

# Static utility (testable without instantiation)
static func _dir_from_vector(v: Vector2) -> String
```

## Design Decisions

### Why view, not controller?
`PlayerMovement` manages sprite frame rendering, physics movement, and marker visibility — all view concerns. It contains no business logic.

### Why consume AnimationController?
Previous version had duplicated LPC constants (COLUMNS, ROWS, WALK_BASE, etc.) and frame calculation logic. Delegating to AnimationController model ensures animation logic is tested once and reusable for other sprite types (NPCs, enemies).

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
10 tests in `tests/specs/player_movement_test.gd`:
- Right, left, down, up from vectors
- Equal magnitudes favor horizontal
- Zero vector defaults to down
- Pure vertical/horizontal vectors

## Related
- `AnimationController` — model for frame calculation
- `TownSceneController` — calls `move_to()` on mouse click
- `DemoController` — calls `move_to()` on mouse click and debug key F
