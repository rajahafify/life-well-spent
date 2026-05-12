## FieldCameraController - camera follow and hit-shake helper for Field.
class_name FieldCameraController
extends Object

const CAMERA_SHAKE_DURATION := 0.16
const CAMERA_SHAKE_STRENGTH := 8.0

var shake_timer: float = 0.0
var _rng := RandomNumberGenerator.new()


func randomize() -> void:
	_rng.randomize()


func update_camera(camera: Camera2D, player: Node2D, offset: Vector2) -> void:
	if camera and player:
		camera.global_position = player.global_position + offset + camera_shake_offset()


func start_shake() -> void:
	shake_timer = CAMERA_SHAKE_DURATION


func tick_shake(delta: float) -> void:
	if shake_timer <= 0.0:
		return
	shake_timer = maxf(0.0, shake_timer - delta)


func is_shaking() -> bool:
	return shake_timer > 0.0


func camera_shake_offset() -> Vector2:
	if shake_timer <= 0.0:
		return Vector2.ZERO
	var progress := shake_timer / CAMERA_SHAKE_DURATION
	return Vector2(
		_rng.randf_range(-CAMERA_SHAKE_STRENGTH, CAMERA_SHAKE_STRENGTH),
		_rng.randf_range(-CAMERA_SHAKE_STRENGTH, CAMERA_SHAKE_STRENGTH)
	) * progress
