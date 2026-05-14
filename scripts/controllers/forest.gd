## Forest - prototype endpoint scene controller.
class_name Forest
extends Node2D

const FIELD_PATH := "res://scenes/field.tscn"
const CAMERA_OFFSET := Vector2(0, -150)

@onready var _player: CharacterBody2D = $Player
@onready var _field_gateway: Area2D = $FieldGateway
@onready var _hud: CanvasLayer = $UI

var requested_scene_path: String = ""


func _ready() -> void:
	if _field_gateway and not _field_gateway.body_entered.is_connected(_on_field_gateway_body_entered):
		_field_gateway.body_entered.connect(_on_field_gateway_body_entered)
	if _hud and _hud.has_method("show_quest"):
		_hud.show_quest("Explore the World", "Enter the Forest.")
	if _hud and _hud.has_method("set_life"):
		_hud.set_life(100, 100)
	_update_camera()


func _physics_process(_delta: float) -> void:
	_update_camera()


func _on_field_gateway_body_entered(body: Node) -> void:
	if body.name == "Player":
		request_scene(FIELD_PATH)


func request_scene(scene_path: String) -> void:
	requested_scene_path = scene_path
	if is_inside_tree():
		call_deferred("_change_scene_to_file", scene_path)


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and _player:
		camera.global_position = _player.global_position + CAMERA_OFFSET
