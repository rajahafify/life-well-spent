## AnimationController — pure animation state management.
## Handles idle/walk states and direction-aware frame selection.
## Uses 4 frames: [down, up, left, right]
class_name AnimationController
extends Object

const FRAME_COUNT: int = 4

var state: String = "idle"
var direction: String = "down"
var current_frame: int = 0
var anim_speed: float = 8.0
var _frame_timer: float = 0.0


func _init() -> void:
	_update_frame()


# ── State Transitions ─────────────────────────────────────────────────

func start_walking() -> void:
	state = "walking"
	_update_frame()


func stop_walking() -> void:
	state = "idle"
	_update_frame()


# ── Direction ─────────────────────────────────────────────────────────

func set_direction(dir: String) -> void:
	if dir in ["down", "up", "left", "right"]:
		direction = dir
	else:
		direction = "down"
	_update_frame()


# ── Animation Update ──────────────────────────────────────────────────

func tick(delta: float) -> void:
	if state == "idle":
		_tick_idle(delta)


func _tick_idle(delta: float) -> void:
	# Idle: cycle through 4 directions slowly
	_frame_timer += delta
	if _frame_timer >= 0.5:
		_frame_timer = 0.0
		_cycle_direction()


func _cycle_direction() -> void:
	var directions := ["down", "up", "left", "right"]
	var current_idx: int = directions.find(direction)
	var next_idx: int = (current_idx + 1) % 4
	direction = directions[next_idx]
	_update_frame()


func _update_frame() -> void:
	match direction:
		"down": current_frame = 0
		"up": current_frame = 1
		"left": current_frame = 2
		"right": current_frame = 3
