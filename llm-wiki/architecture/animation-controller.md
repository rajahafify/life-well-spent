---
title: AnimationController
type: reference
updated: 2026-05-12
sources:
  - scripts/models/animation_controller.gd
  - tests/specs/animation_controller_test.gd
tags: [architecture, tech]
---

# AnimationController

## Overview
LPC spritesheet animation state machine. Pure model — no Node references. Handles frame coordinate calculation for idle, walking, and attack animations while preserving facing direction.

## Design
- Uses 832px LPC atlas: 13 columns × 21 rows, 64×64 cells
- `frame_coords: Vector2i` — column/row pair for `Sprite2D.frame_coords`
- Idle: cycles calm standing frames from walk rows while preserving direction row
- Walking: advances `walk_frame` (0-8) at 0.1s intervals, maintaining direction
- Attacking: plays LPC `slash` rows 12-15 or `thrust` rows 4-7, then returns to idle
- State guards: `start_walking()`/`stop_walking()` are idempotent (no-op if already in state)

## Public API

```gdscript
class_name AnimationController
extends Object

# Constants (shared with consuming views)
const COLUMNS: int = 13
const ROWS: int = 21
const IDLE_BASE: int = 0
const WALK_BASE: int = 8
const IDLE_FRAME_COUNT: int = 4
const WALK_FRAME_COUNT: int = 9
const IDLE_CYCLE_INTERVAL: float = 0.5
const WALK_FRAME_DURATION: float = 0.1

var state: String            # "idle" | "walking" | "attacking"
var direction: String        # "up" | "left" | "down" | "right"
var frame_coords: Vector2i   # read by sprite
var idle_frame: int          # current idle cycle position
var walk_frame: int          # current walk cycle position

func start_walking() -> void
func stop_walking() -> void
func start_attack(style: String = "slash") -> void
func set_direction(dir: String) -> void
func tick(delta: float) -> void  # advances frame based on state
```

## Design Decisions

### Why own constants instead of GameBalance?
Animation timing (0.5s idle interval, 0.1s walk frame) is animation-specific tuning, not game-level balance. Kept local to avoid coupling.

### Why guard clauses on start/stop?
Prevents resetting `walk_frame` to 0 every `_process` call when already walking. The caller calls `start_walking()` each frame in `_process` when the player is moving — guards prevent frame reset.

## Test Coverage
26 tests in `tests/specs/animation_controller_test.gd`:
- Initial state: idle, direction down, frame_coords (0,2)
- State transitions: start/stop/idle-cycle
- Direction: all 4 cardinal + invalid (defaults to down)
- Frame mapping: idle/walking for each direction
- Idle animation: frame advance after interval, direction preserved, no-change below threshold
- Walking animation: frame advance on tick, no direction cycling
- Attack animation: slash row mapping, frame advance, return to idle
- State+direction combos

## Related
- `CharacterMovement` — consumes this model for sprite animation
- `player_stats_test.gd` — direction and walk/stop logic
