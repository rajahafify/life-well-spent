## PlayerMovement — click-to-move with full LPC spritesheet animation.
## Uses 832px LPC atlas: 13 columns x 21 rows, 64x64 cells.
## Walk rows: 8-11 (up/left/down/right). Idle: spellcast rows 0-3.
extends Sprite2D

## Movement speed in pixels per second.
@export var move_speed: float = 200.0

var destination: Vector2 = Vector2.ZERO
var moving: bool = false

var _marker: Sprite2D
var _frame_timer: float = 0.0
var _walk_frame: int = 0
var _idle_frame: int = 0
var _idle_direction: int = 2  # start facing down (row 2)

# LPC atlas grid
const COLUMNS := 13
const ROWS := 21

# Animation row offsets (row = base + direction)
const IDLE_BASE := 0  # spellcast rows 0-3 serve as idle
const WALK_BASE := 8  # walk rows 8-11

# Animation frame counts
const IDLE_FRAME_COUNT := 4
const WALK_FRAME_COUNT := 9


func _ready() -> void:
	hframes = COLUMNS
	vframes = ROWS
	destination = position
	_marker = get_node_or_null("/root/TestRunnerScene/DestinationMarker") as Sprite2D
	# Start facing down
	_apply_frame()


func _process(delta: float) -> void:
	# ── Position interpolation ──────────────────────────────────────────
	if moving:
		var dir := destination - position
		var dist := dir.length()
		if dist < move_speed * delta:
			position = destination
			destination = position
			moving = false
		else:
			position += dir.normalized() * move_speed * delta

	# ── Animation ───────────────────────────────────────────────────────
	if moving:
		_handle_walking(delta)
	else:
		_handle_idle(delta)

	_apply_frame()
	_update_marker()


# ── Animation helpers ──────────────────────────────────────────────────

func _handle_walking(delta: float) -> void:
	# Advance walk frame based on timer
	_frame_timer += delta
	if _frame_timer >= 0.1:
		_frame_timer -= 0.1
		_walk_frame = (_walk_frame + 1) % WALK_FRAME_COUNT
	_apply_walk_frame()


func _handle_idle(delta: float) -> void:
	# Idle breathing: slowly cycle between frames 0-1 for a subtle sway
	_frame_timer += delta
	if _frame_timer >= 1.5:
		_frame_timer = 0.0
		_idle_frame = 0 if _idle_frame == 1 else 1
	_apply_idle_frame()


func _apply_walk_frame() -> void:
	var row := WALK_BASE + _idle_direction
	frame_coords = Vector2i(_walk_frame, row)


func _apply_idle_frame() -> void:
	frame_coords = Vector2i(_idle_frame, _idle_direction)


func _set_direction(dir: String) -> void:
	match dir:
		"up":    _idle_direction = 0
		"left":  _idle_direction = 1
		"down":  _idle_direction = 2
		"right": _idle_direction = 3


func _set_direction_from_destination() -> void:
	var dir_vec := destination - position
	if abs(dir_vec.x) > abs(dir_vec.y):
		_set_direction("right" if dir_vec.x > 0.0 else "left")
	else:
		_set_direction("down" if dir_vec.y > 0.0 else "up")


func _apply_frame() -> void:
	if moving:
		_apply_walk_frame()
	else:
		_apply_idle_frame()


# ── Marker ─────────────────────────────────────────────────────────────

func _update_marker() -> void:
	if not _marker:
		return
	_marker.position = destination
	_marker.visible = moving


# ── Public API ─────────────────────────────────────────────────────────

func move_to(target: Vector2) -> void:
	destination = target
	moving = true
	_walk_frame = 0
	_set_direction_from_destination()
	_update_marker()
