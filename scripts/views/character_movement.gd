## CharacterMovement — LPC spritesheet animation + optional physics movement.
## View layer: manages Sprite2D frame rendering, delegates to AnimationController model.
## Generic for Player/NPC: is_static=true skips movement.

class_name CharacterMovement
extends Sprite2D

## Movement speed in pixels per second (ignored if static).
@export var move_speed: float = 200.0

## If true, no movement — static NPC anim only.
@export var is_static: bool = false

## Idle animation cycle length. Set per NPC for subtle RO-style desync.
@export var idle_cycle_interval: float = AnimationController.IDLE_CYCLE_INTERVAL

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
	_ensure_anim()
	_find_marker()
	_apply_frame()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_cleanup_model_refs()


func _cleanup_model_refs() -> void:
	if _anim != null:
		_anim.free()
		_anim = null
	_marker = null


func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D

	_ensure_anim()
	_anim.tick(delta)
	_apply_frame()
	_update_marker_visibility()

	if body:
		if not is_static and moving and can_move:
			var dir := destination - body.global_position
			var dist := dir.length()
			if dist < 5.0:
				_stop_moving(body, true)
			else:
				var vel := dir.normalized() * move_speed
				body.velocity = vel
				if _anim.state != "walking":
					_anim.start_walking()
				_anim.set_direction(_dir_from_vector(dir))
				var collided := body.move_and_slide()
				if collided:
					_stop_moving(body, false)
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
	if marker_path == NodePath(""):
		_marker = null
		return
	_marker = get_node_or_null(marker_path) as Sprite2D


func _update_marker_visibility() -> void:
	if is_static or not _marker:
		return
	_marker.global_position = destination
	_marker.visible = moving


# ── Public API ─────────────────────────────────────────────────────────

func move_to(target: Vector2) -> void:
	if not can_move or is_static:
		return
	_ensure_anim()
	var body := get_parent() as CharacterBody2D
	if body:
		destination = target
		moving = true
		_anim.start_walking()
		_anim.set_direction(_dir_from_vector(target - body.global_position))
		_update_marker_visibility()


func set_facing(dir: String) -> void:
	_ensure_anim()
	_anim.set_direction(dir)
	_apply_frame()


func face_player(target_pos: Vector2) -> void:
	var body := get_parent()
	if body:
		set_facing(_dir_from_vector(target_pos - body.global_position))


func face_target(target_pos: Vector2) -> void:
	face_player(target_pos)


func stop_moving() -> void:
	var body := get_parent() as CharacterBody2D
	if body:
		_stop_moving(body, false)
	else:
		moving = false
		_ensure_anim()
		_anim.stop_walking()
		_apply_frame()
		_update_marker_visibility()


func _stop_moving(body: CharacterBody2D, snap_to_destination: bool) -> void:
	_ensure_anim()
	if snap_to_destination:
		body.global_position = destination
	moving = false
	_anim.stop_walking()
	body.velocity = Vector2.ZERO
	_update_marker_visibility()


func _ensure_anim() -> void:
	if hframes != AnimationController.COLUMNS:
		hframes = AnimationController.COLUMNS
	if vframes != AnimationController.ROWS:
		vframes = AnimationController.ROWS
	if _anim == null:
		_anim = AnimationController.new()
	_anim.idle_cycle_interval = idle_cycle_interval
