## CharacterMovement — LPC spritesheet animation + optional physics movement.
## View layer: manages Sprite2D frame rendering, delegates to AnimationController model.
## Generic for Player/NPC: is_static=true skips movement.

class_name CharacterMovement
extends Sprite2D

## Movement speed in pixels per second (ignored if static).
@export var move_speed: float = 200.0

## If true, no movement — static NPC anim only.
@export var is_static: bool = false

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

	_anim.tick(delta)
	_apply_frame()
	_update_marker_visibility()

	if body:
		if not is_static and moving and can_move:
			var dir := destination - body.global_position
			var dist := dir.length()
			if dist < 5.0:
				body.global_position = destination
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
	_marker.global_position = destination
	_marker.visible = moving


# ── Public API ─────────────────────────────────────────────────────────

func move_to(target: Vector2) -> void:
	if not can_move or is_static:
		return
	var body := get_parent() as CharacterBody2D
	if body:
		destination = target
		moving = true
		_anim.start_walking()
		_anim.set_direction(_dir_from_vector(target - body.global_position))
		_update_marker_visibility()

func face_player(target_pos: Vector2) -> void:
	var body := get_parent()
	if body:
		_anim.set_direction(_dir_from_vector(target_pos - body.global_position))