## Town — first-slice Town scene controller.
## Thin glue: connects worldbuilding NPC signals to dialog view and exposes portal prompt copy.
class_name Town
extends Node2D

const FIELD_PATH := "res://scenes/field.tscn"
const CAMERA_OFFSET := Vector2(0, -150)
const INVENTORY_SCRIPT := preload("res://scripts/models/inventory_model.gd")
const REBORN_DIALOG := "You have been reborn.\nWill you spend this life well?"

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _hud: CanvasLayer = $UI
@onready var _field_gateway: Area2D = $FieldGateway
@onready var _player: CharacterBody2D = $Player

var requested_scene_path: String = ""
var _pending_npc: NpcController
var _local_inventory_model = null


func _exit_tree() -> void:
	if _local_inventory_model:
		_local_inventory_model.free()
		_local_inventory_model = null


func _ready() -> void:
	QuestSystem.setup_core_quests()
	_connect_hud()
	_update_quest_window()
	_connect_dialog()
	_show_reborn_dialog()
	_connect_portal()
	_connect_worldbuilding_npcs()
	_update_camera()


func _connect_hud() -> void:
	if _hud:
		_hud.ensure_ready()
		_hud.set_inventory_model(_inventory_model_for_hud())
		_hud.set_life(100, 100)


func _connect_dialog() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.close_requested.is_connected(close_dialog):
		_dialog_view.close_requested.connect(close_dialog)


func _show_reborn_dialog() -> void:
	_dialog_view.show_dialog("Reborn", REBORN_DIALOG, false, false)


func _connect_portal() -> void:
	if _field_gateway and not _field_gateway.body_entered.is_connected(_on_field_gateway_body_entered):
		_field_gateway.body_entered.connect(_on_field_gateway_body_entered)


func _connect_worldbuilding_npcs() -> void:
	for npc_name in ["Guildmaster", "Shopkeeper", "Smith"]:
		var npc := get_node_or_null(npc_name) as NpcController
		if npc and not npc.interacted.is_connected(_on_npc_interacted):
			npc.interacted.connect(_on_npc_interacted)


func _physics_process(_delta: float) -> void:
	_update_camera()
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		move_player_to(get_global_mouse_position())


func _on_npc_interacted(npc: NpcController) -> void:
	if not npc.is_player_in_talk_range(_player.global_position):
		_pending_npc = npc
		move_player_to(npc.talk_point_for(_player.global_position))
		return
	_open_dialog(npc)


func _open_dialog(npc: NpcController) -> void:
	var movement := _player_movement()
	if movement:
		movement.stop_moving()
		movement.face_target(npc.global_position)
	npc.face_toward_player(_player.global_position)
	_dialog_view.show_dialog(npc.display_name, _dialog_text_for(npc), false, false, _npc_portrait_texture(npc))


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open():
		return false
	var movement := _player_movement()
	if movement == null:
		return false
	movement.move_to(target)
	return true


func request_field() -> void:
	requested_scene_path = FIELD_PATH
	if is_inside_tree():
		call_deferred("_change_scene_to_file", FIELD_PATH)


func _on_field_gateway_body_entered(body: Node) -> void:
	if body.name == "Player":
		request_field()


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func close_dialog() -> void:
	_dialog_view.hide_dialog()
	_pending_npc = null


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.global_position = _player.global_position + CAMERA_OFFSET


func _npc_portrait_texture(npc: NpcController) -> Texture2D:
	var sprite := npc.get_node_or_null("Sprite") as Sprite2D
	return sprite.texture if sprite else null


func _update_quest_window() -> void:
	if _hud:
		_hud.show_quest("Explore the World", QuestSystem.current_main_objective_text(), QuestSystem.current_main_checkpoint_text())


func _dialog_text_for(npc: NpcController) -> String:
	if npc.role == "guildmaster" and QuestSystem.current_main_objective_id() == "get_swordsman_certification":
		if QuestSystem.has_certification("swordsman_certification"):
			return "You carry Swordsman Certification now.\n\nThe Forest gate will recognize you."
		QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
		return "You found the Forest gate, and now you need Swordsman Certification.\n\nThen you understand why the old rules exist.\n\nHelp rebuild the Swordsman Guild first."
	return npc.dialog_text


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement


func _inventory_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/InventorySystem")


func _inventory_model_for_hud():
	var system := _inventory_system()
	if system:
		return system.model()
	if _local_inventory_model == null:
		_local_inventory_model = INVENTORY_SCRIPT.new()
	return _local_inventory_model
