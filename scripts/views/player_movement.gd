## PlayerMovement — click-to-move with LPC spritesheet animation via AnimationController.
## View layer: manages Sprite2D frame rendering, delegates animation logic to model.
class_name PlayerMovement
extends Sprite2D

## Movement speed in pixels per second.
@export var move_speed: float = 200.0

var destination: Vector2 = Vector2.ZERO
var moving: bool = false
var can_move: bool = true

var _anim: AnimationController
var _marker: Sprite2D
var _marker_paths: Array[String] = []


func _ready() -> void:
	hframes = AnimationController.COLUMNS
	vframes = AnimationController.ROWS
	destination = position
	_anim = AnimationController.new()
	_find_marker()
	_apply_frame()


func _process(delta: float) -> void:
	# Position interpolation
	if moving and can_move:
		var dir := destination - position
		var dist := dir.length()
		if dist < move_speed * delta:
			position = destination
			moving = false
			_anim.stop_walking()
		else:
			position += dir.normalized() * move_speed * delta
			if _anim.state != "walking":
				_anim.start_walking()
			_anim.set_direction(_dir_from_vector(dir))

	_anim.tick(delta)
	_apply_frame()
	_update_marker_visibility()


# ── Frame Application ─────────────────────────────────────────────────

func _apply_frame() -> void:
	frame_coords = _anim.frame_coords


# ── Direction ─────────────────────────────────────────────────────────

static func _dir_from_vector(v: Vector2) -> String:
	if v == Vector2.ZERO:
		return "down"
	if abs(v.x) >= abs(v.y):
		return "right" if v.x > 0.0 else "left"
	return "down" if v.y > 0.0 else "up"


# ── Marker ─────────────────────────────────────────────────────────────

func _find_marker() -> void:
	# Try common marker locations
	_marker = get_node_or_null("DestinationMarker") as Sprite2D
	if not _marker:
		_marker = get_node_or_null("../DestinationMarker") as Sprite2D


func _update_marker_visibility() -> void:
	if not _marker:
		return
	_marker.position = destination
	_marker.visible = moving


# ── Public API ─────────────────────────────────────────────────────────

func move_to(target: Vector2) -> void:
	if not can_move:
		return
	destination = target
	moving = true
	_anim.start_walking()
	_anim.set_direction(_dir_from_vector(target - position))
	_update_marker_visibility()
