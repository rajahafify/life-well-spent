## PlayerMovement — click-to-move for the player sprite.
extends Sprite2D

@export var move_speed: float = 200.0
var destination: Vector2 = Vector2.ZERO
var moving: bool = false
var _marker: Sprite2D


func _ready() -> void:
	destination = position
	_marker = get_node("/root/TestRunnerScene/DestinationMarker")
	_update_marker()


func _process(delta: float) -> void:
	if not moving:
		return
	
	var direction = destination - position
	var distance = direction.length()
	
	if distance < 2.0:
		position = destination
		moving = false
		_update_marker()
		return
	
	position += direction.normalized() * move_speed * delta
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
