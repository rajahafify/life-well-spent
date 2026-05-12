## AnimationController — LPC spritesheet animation state management.
## Uses 832px LPC atlas: 13 columns x 21 rows, 64x64 cells.
## Frame is a Vector2i(column, row) into the full atlas grid.
class_name AnimationController
extends Object

const COLUMNS: int = 13
const ROWS: int = 21

# Animation row offsets
const WALK_BASE := 8   # walk rows 8-11
const SLASH_BASE := 12  # slash rows 12-15
const THRUST_BASE := 4  # thrust rows 4-7

# Animation frame counts
const IDLE_FRAME_COUNT: int = 2
const WALK_FRAME_COUNT: int = 9
const SLASH_FRAME_COUNT: int = 6
const THRUST_FRAME_COUNT: int = 8

# Timing (animation-local tuning, not game-balance)
const IDLE_CYCLE_INTERVAL: float = 0.85
const WALK_FRAME_DURATION: float = 0.1
const ATTACK_FRAME_DURATION: float = 0.08
const IDLE_START_FRAME: int = 1

# Direction → row offset mapping
const _DIRECTION_ROW: Dictionary = {
	"up": 0,
	"left": 1,
	"down": 2,
	"right": 3,
}

var state: String = "idle"
var direction: String = "down"
var frame_coords: Vector2i = Vector2i(IDLE_START_FRAME, WALK_BASE + 2)
var idle_frame: int = 0
var idle_cycle_interval: float = IDLE_CYCLE_INTERVAL
var walk_frame: int = 0
var attack_style: String = "slash"
var attack_frame: int = 0

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
	idle_frame = 0
	_frame_timer = 0.0
	_update_frame_coords()


func start_attack(style: String = "slash") -> void:
	attack_style = style if style in ["slash", "thrust"] else "slash"
	state = "attacking"
	attack_frame = 0
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
	elif state == "attacking":
		_tick_attacking(delta)


func _tick_idle(delta: float) -> void:
	_frame_timer += delta
	if _frame_timer >= idle_cycle_interval:
		_frame_timer -= idle_cycle_interval
		idle_frame = (idle_frame + 1) % IDLE_FRAME_COUNT
		_update_frame_coords()


func _tick_walking(delta: float) -> void:
	_frame_timer += delta
	if _frame_timer >= WALK_FRAME_DURATION:
		_frame_timer -= WALK_FRAME_DURATION
		walk_frame = (walk_frame + 1) % WALK_FRAME_COUNT
		_update_frame_coords()


func _tick_attacking(delta: float) -> void:
	_frame_timer += delta
	while _frame_timer >= ATTACK_FRAME_DURATION and state == "attacking":
		_frame_timer -= ATTACK_FRAME_DURATION
		attack_frame += 1
		if attack_frame >= _attack_frame_count():
			state = "idle"
			idle_frame = 0
			_frame_timer = 0.0
		_update_frame_coords()


func _attack_frame_count() -> int:
	return THRUST_FRAME_COUNT if attack_style == "thrust" else SLASH_FRAME_COUNT


# _cycle_direction commented out

func _update_frame_coords() -> void:
	var dir_row: int = _DIRECTION_ROW.get(direction, 0)
	if state == "walking":
		frame_coords = Vector2i(walk_frame, WALK_BASE + dir_row)
	elif state == "attacking":
		var base_row := THRUST_BASE if attack_style == "thrust" else SLASH_BASE
		frame_coords = Vector2i(attack_frame, base_row + dir_row)
	else:
		frame_coords = Vector2i(IDLE_START_FRAME + idle_frame, WALK_BASE + dir_row)
