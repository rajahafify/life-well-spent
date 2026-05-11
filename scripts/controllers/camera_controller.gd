## CameraController — thin glue for Camera2D + CameraModel.
class_name CameraController
extends Camera2D

@export var player_path: NodePath
@export var lerp_speed: float = 5.0
@export var deadzone: Rect2 = Rect2()
@export var bound_left: float = 0.0
@export var bound_right: float = 0.0
@export var bound_top: float = 0.0
@export var bound_bottom: float = 0.0
@export var zoom_level: float = 1.0

var model: CameraModel
var player


func _ready() -> void:
	self.make_current()
	
	model = CameraModel.new()
	model.lerp_speed = lerp_speed
	model.deadzone = deadzone
	model.bound_left = bound_left
	model.bound_right = bound_right
	model.bound_top = bound_top
	model.bound_bottom = bound_bottom
	model.zoom_level = zoom_level
	
	player = get_node(player_path)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if model != null:
			model.free()
			model = null
		player = null


func _physics_process(delta: float) -> void:
	if not player:
		return
		
	model.target_position = player.global_position
	model.update(delta)
	self.offset = model.position
	self.zoom = Vector2(model.zoom_level, model.zoom_level)
