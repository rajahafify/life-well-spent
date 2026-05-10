## AnimationController — LPC spritesheet animation state management.
## Uses 832px LPC atlas: 13 columns x 21 rows, 64x64 cells.
## Frame is a Vector2i(column, row) into the full atlas grid.
class_name AnimationController
extends Object

const COLUMNS: int = 13
const ROWS: int = 21

# Animation row offsets
const IDLE_BASE := 0   # spellcast rows 0-3 serve as idle
const WALK_BASE := 8   # walk rows 8-11

# Animation frame counts
const IDLE_FRAME_COUNT: int = 4
const WALK_FRAME_COUNT: int = 9

# Timing (animation-local tuning, not game-balance)
const IDLE_CYCLE_INTERVAL: float = 0.5
const WALK_FRAME_DURATION: float = 0.1

# Direction → row offset mapping
const _DIRECTION_ROW: Dictionary = {
	"up": 0,
	"left": 1,
	"down": 2,
	"right": 3,
}

var state: String = "idle"
var direction: String = "down"
var frame_coords: Vector2i = Vector2i(0, 2)  # column 0, row 2 (idle down)
var walk_frame: int = 0

var _frame_timer: float = 0.0



func _init() -> void:
	_update_frame_coords()


# ── State Transitions ─────────────────────────────────────────────────

func start_walking() -> void:
	if state == "walking":
		return
	state = "walking"
	walk_frame = 0
	_frame_timer = 0.0
	_update_frame_coords()


func stop_walking() -> void:
	if state == "idle":
		return
	state = "idle"
	_frame_timer = 0.0
	_update_frame_coords()


# ── Direction ─────────────────────────────────────────────────────────

func set_direction(dir: String) -> void:
	if dir in ["up", "left", "down", "right"]:
		direction = dir
	else:
		direction = "down"
	_update_frame_coords()


# ── Animation Update ──────────────────────────────────────────────────

func tick(delta: float) -> void:
	if state == "idle":
		_tick_idle(delta)
	elif state == "walking":
		_tick_walking(delta)


func _tick_idle(_delta: float) -> void:
	pass  # static neutral idle


func _tick_walking(delta: float) -> void:
	_frame_timer += delta
	if _frame_timer >= WALK_FRAME_DURATION:
		_frame_timer -= WALK_FRAME_DURATION
		walk_frame = (walk_frame + 1) % WALK_FRAME_COUNT
		_update_frame_coords()


# _cycle_direction commented out

func _update_frame_coords() -> void:
	var dir_row: int = _DIRECTION_ROW.get(direction, 0)
	if state == "walking":
		frame_coords = Vector2i(walk_frame, WALK_BASE + dir_row)
	else:
		frame_coords = Vector2i(0, IDLE_BASE + dir_row)
