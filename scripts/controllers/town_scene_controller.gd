## Town — first-slice Town scene controller.
## Thin glue: connects worldbuilding NPC signals to dialog view and exposes portal prompt copy.
class_name Town
extends Node2D

const FIELD_PATH := "res://scenes/field.tscn"
const CAMERA_OFFSET := Vector2(0, -150)
const INVENTORY_SCRIPT := preload("res://scripts/models/inventory_model.gd")
const PLAYER_STATS_SCRIPT := preload("res://scripts/models/player_stats.gd")
const PROGRESSION_SCRIPT := preload("res://scripts/models/progression_model.gd")
const PLAYER_AGING_SCRIPT := preload("res://scripts/models/player_aging_model.gd")
const REBORN_DIALOG := "You have been reborn.\nWill you spend this life well?"

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _hud: CanvasLayer = $UI
@onready var _field_gateway: Area2D = $FieldGateway
@onready var _player: CharacterBody2D = $Player

var requested_scene_path: String = ""
var player_stats: PlayerStats = PLAYER_STATS_SCRIPT.new()
var _pending_npc: NpcController
var _local_inventory_model = null
var _progression = null
var _player_aging = PLAYER_AGING_SCRIPT.new()


func _exit_tree() -> void:
	if _local_inventory_model:
		_local_inventory_model.free()
		_local_inventory_model = null
	if _progression:
		_progression.free()
		_progression = null
	if _player_aging:
		_player_aging.free()
		_player_aging = null
	if player_stats:
		player_stats.free()
		player_stats = null


func _ready() -> void:
	QuestSystem.setup_core_quests()
	_progression = PROGRESSION_SCRIPT.new(player_stats, QuestSystem.quests, null)
	_connect_hud()
	_update_quest_window()
	_update_player_age_sprite()
	_connect_dialog()
	_show_reborn_dialog_once()
	_connect_portal()
	_connect_worldbuilding_npcs()
	_update_camera()


func _connect_hud() -> void:
	if _hud:
		_hud.ensure_ready()
		_hud.set_inventory_model(_inventory_model_for_hud())
		_update_life_hud()


func _connect_dialog() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.close_requested.is_connected(close_dialog):
		_dialog_view.close_requested.connect(close_dialog)
	if not _dialog_view.complete_quest_requested.is_connected(_on_complete_quest_requested):
		_dialog_view.complete_quest_requested.connect(_on_complete_quest_requested)


func _show_reborn_dialog_once() -> void:
	if QuestSystem.mark_town_reborn_intro_seen():
		_dialog_view.show_dialog("Reborn", REBORN_DIALOG, false, false)
		return
	_dialog_view.hide_dialog()


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
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		follow_held_mouse(get_global_mouse_position(), get_viewport().get_mouse_position())
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _hud_blocks_world_mouse(event.position):
			return
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
	_dialog_view.show_dialog(npc.display_name, _dialog_text_for(npc), false, _can_complete_swordsman_step(npc), _npc_portrait_texture(npc))


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open():
		return false
	var movement := _player_movement()
	if movement == null:
		return false
	movement.move_to(target)
	return true


func follow_held_mouse(target: Vector2, screen_position: Vector2 = Vector2.INF) -> bool:
	var pointer_position := target if screen_position == Vector2.INF else screen_position
	if _hud_blocks_world_mouse(pointer_position):
		return false
	return move_player_to(target)


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
		_hud.show_quest("Explore the World", _current_quest_objective_text(), QuestSystem.current_main_checkpoint_text())


func _current_quest_objective_text() -> String:
	var objective := QuestSystem.current_main_objective_text()
	if QuestSystem.is_side_quest_active("rebuilding_swordsman_guild"):
		objective += "\n" + QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild")
	return objective


func _dialog_text_for(npc: NpcController) -> String:
	if npc.role == "guildmaster" and QuestSystem.current_main_objective_id() == "get_swordsman_certification":
		if QuestSystem.has_certification("swordsman_certification"):
			return "You carry Swordsman Certification now.\n\nThe Forest gate will recognize you."
		QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
		var objective := QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild")
		return "You found the Forest gate, and now you need Swordsman Certification.\n\nCertification is not earned with coin.\nIt is earned with life.\n\n%s" % objective
	return npc.dialog_text


func _can_complete_swordsman_step(npc: NpcController) -> bool:
	return npc.role == "guildmaster" \
		and QuestSystem.is_side_quest_active("rebuilding_swordsman_guild") \
		and QuestSystem.is_current_side_quest_step_complete("rebuilding_swordsman_guild")


func _on_complete_quest_requested() -> void:
	if _progression == null:
		return
	if not _progression.complete_swordsman_certification_step():
		return
	_update_life_hud()
	_update_player_age_sprite()
	_update_quest_window()
	if QuestSystem.has_certification("swordsman_certification"):
		_dialog_view.set_body("SWORDSMAN GUILD UNLOCKED\n\nYou spent this life well.\n\nTo be continued.")
		_dialog_view.configure_buttons(false, false)
		return
	var objective := QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild")
	_dialog_view.set_body("Life given. The old halls remember.\n\n%s" % objective)
	_dialog_view.configure_buttons(false, true)


func _update_life_hud() -> void:
	if _hud:
		_hud.set_life(player_stats.max_hp, player_stats.max_hp)


func _update_player_age_sprite() -> void:
	if _player_aging == null:
		return
	var sprite := _player.get_node_or_null("Sprite") as Sprite2D
	if sprite:
		sprite.texture = _load_texture(_player_aging.texture_path_for_max_hp(player_stats.max_hp))


func _load_texture(texture_path: String) -> Texture2D:
	if ResourceLoader.exists(texture_path):
		var imported := load(texture_path) as Texture2D
		if imported:
			return imported
	var image := Image.new()
	if image.load(texture_path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	texture.resource_path = texture_path
	return texture


func _hud_blocks_world_mouse(screen_position: Vector2) -> bool:
	return _hud != null and _hud.has_method("blocks_world_mouse_at") and _hud.blocks_world_mouse_at(screen_position)


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
