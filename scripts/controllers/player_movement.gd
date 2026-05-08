## PlayerMovement — click-to-move with animation.
## Manages movement to destination and sprite animation via AnimationController.
extends Sprite2D

@export var move_speed: float = 200.0
var destination: Vector2 = Vector2.ZERO
var moving: bool = false
var _marker: Sprite2D
var _animation: AnimationController = AnimationController.new()


func _ready() -> void:
	destination = position
	_marker = get_node("/root/TestRunnerScene/DestinationMarker")
	_update_marker()
	# Set initial direction
	_animation.set_direction("down")


func _process(delta: float) -> void:
	if moving:
		_animation.start_walking()
		# Update direction based on destination
		_set_direction_from_destination()
	else:
		_animation.stop_walking()
		# When idle, use current direction and let idle cycling handle changes
		_animation.set_direction(_animation.direction)
	
	_animation.tick(delta)
	_update_sprite_frame()
	_update_marker()


func move_to(target: Vector2) -> void:
	destination = target
	moving = true
	_update_marker()


func _update_marker() -> void:
	if not _marker:
		return
	_marker.position = destination
	_marker.visible = moving


func _set_direction_from_destination() -> void:
	var dir_vec = destination - position
	if abs(dir_vec.x) > abs(dir_vec.y):
		_animation.set_direction("right" if dir_vec.x > 0 else "left")
	else:
		_animation.set_direction("down" if dir_vec.y > 0 else "up")


func _update_sprite_frame() -> void:
	frame = _animation.current_frame
