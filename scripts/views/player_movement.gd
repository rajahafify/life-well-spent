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
@export var marker_path: NodePath = ^"../../DestinationMarker"


func _ready() -> void:
	hframes = AnimationController.COLUMNS
	vframes = AnimationController.ROWS
	destination = position
	_anim = AnimationController.new()
	_find_marker()
	_apply_frame()


func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if not body:
		return
	# Position/velocity update
	if moving and can_move:
		var dir := destination - body.position
		var dist := dir.length()
		if dist < 5.0:  # snap threshold
			body.position = destination
			moving = false
			_anim.stop_walking()
			body.velocity = Vector2.ZERO
		else:
			var vel := dir.normalized() * move_speed
			body.velocity = vel
			if _anim.state != "walking":
				_anim.start_walking()
			_anim.set_direction(_dir_from_vector(dir))
		body.move_and_slide()
	else:
		body.velocity = Vector2.ZERO

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
	_marker = get_node_or_null(marker_path) as Sprite2D


func _update_marker_visibility() -> void:
	if not _marker:
		return
	_marker.position = destination
	_marker.visible = moving


# ── Public API ─────────────────────────────────────────────────────────

func move_to(target: Vector2) -> void:
	if not can_move:
		return
	var body := get_parent() as CharacterBody2D
	if body:
		destination = target
		moving = true
		_anim.start_walking()
		_anim.set_direction(_dir_from_vector(target - body.position))
		_update_marker_visibility()
