class_name CameraModel
extends Object

var position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var lerp_speed: float = 5.0
var deadzone: Rect2 = Rect2()
var bound_left: float = 0.0
var bound_right: float = 0.0
var bound_top: float = 0.0
var bound_bottom: float = 0.0
var zoom_level: float = 1.0

func update(delta: float) -> void:
	if not deadzone.size.is_zero_approx() and deadzone.has_point(target_position):
		return

	var factor: float = min(1.0, lerp_speed * delta)
	position = position.lerp(target_position, factor)
	
	_apply_bounds()


func _apply_bounds() -> void:
	if bound_left > 0.0:
		position.x = max(position.x, -bound_left)
	if bound_right > 0.0:
		position.x = min(position.x, bound_right)
	if bound_top > 0.0:
		position.y = max(position.y, -bound_top)
	if bound_bottom > 0.0:
		position.y = min(position.y, bound_bottom)
