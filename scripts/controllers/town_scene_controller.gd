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
const QUEST_DIALOG_FLOW_SCRIPT := preload("res://scripts/models/quest_dialog_flow.gd")
const RUN_SUMMARY_SCRIPT := preload("res://scripts/models/run_summary_model.gd")
const REBORN_DIALOG := "You have been reborn.\nWill you spend this life well?"
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const SWORDSMAN_QUEST_INTRO := "You found the Forest gate, and now you need Swordsman Certification.\n\nCertification is not earned with coin.\nIt is earned with life."
const SWORDSMAN_QUEST_CLAIM := "You have completed this Guildmaster trial.\n\nClaim your reward when you are ready."

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _hud: CanvasLayer = $UI
@onready var _field_gateway: Area2D = $FieldGateway
@onready var _player: CharacterBody2D = $Player

var requested_scene_path: String = ""
var player_stats: PlayerStats = PLAYER_STATS_SCRIPT.new()
var _owns_player_stats: bool = true
var _pending_npc: NpcController
var _local_inventory_model = null
var _progression = null
var _player_aging = PLAYER_AGING_SCRIPT.new()
var _quest_dialog_flow = QUEST_DIALOG_FLOW_SCRIPT.new()
var _run_summary = RUN_SUMMARY_SCRIPT.new()


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
	if _quest_dialog_flow:
		_quest_dialog_flow.free()
		_quest_dialog_flow = null
	if _run_summary:
		_run_summary.free()
		_run_summary = null
	if player_stats and _owns_player_stats:
		player_stats.free()
	player_stats = null


func _ready() -> void:
	_bind_profile_player()
	QuestSystem.setup_core_quests()
	_progression = PROGRESSION_SCRIPT.new(player_stats, QuestSystem.quests, null)
	_connect_hud()
	_update_quest_window()
	_update_player_age_sprite()
	_connect_dialog()
	_show_reborn_dialog_once()
	_connect_portal()
	_connect_worldbuilding_npcs()
	_connect_rebirth_panel()
	_refresh_rebirth_panel()
	_update_camera()


func _bind_profile_player() -> void:
	var profile := _profile_system()
	if profile and profile.has_method("player"):
		if player_stats and _owns_player_stats:
			player_stats.free()
		player_stats = profile.player()
		_owns_player_stats = false


func _connect_hud() -> void:
	if _hud:
		_hud.ensure_ready()
		_hud.set_inventory_model(_inventory_model_for_hud())
		_update_life_hud()
		if _hud.has_signal("equipment_changed") and not _hud.equipment_changed.is_connected(_on_equipment_changed):
			_hud.equipment_changed.connect(_on_equipment_changed)


func _connect_dialog() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.close_requested.is_connected(close_dialog):
		_dialog_view.close_requested.connect(close_dialog)
	if not _dialog_view.complete_quest_requested.is_connected(_on_complete_quest_requested):
		_dialog_view.complete_quest_requested.connect(_on_complete_quest_requested)


func _connect_rebirth_panel() -> void:
	var button := get_node_or_null("UI/RebirthPanel/VBox/RebirthButton") as Button
	if button and not button.pressed.is_connected(_on_rebirth_pressed):
		button.pressed.connect(_on_rebirth_pressed)
	var end_button := get_node_or_null("UI/RebirthPanel/VBox/EndGameButton") as Button
	if end_button and not end_button.pressed.is_connected(_on_end_game_pressed):
		end_button.pressed.connect(_on_end_game_pressed)


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
	_prepare_guildmaster_dialog(npc)
	var panel := _dialog_panel_for(npc)
	_apply_dialog_panel(panel, _npc_portrait_texture(npc))
	_update_quest_window()


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open() or _rebirth_panel_is_open():
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


func _dialog_panel_for(npc: NpcController) -> Dictionary:
	if npc.role == "guildmaster" and QuestSystem.current_main_objective_id() == "get_swordsman_certification":
		if QuestSystem.has_certification("swordsman_certification"):
			return _quest_dialog_flow.normal_panel(npc.display_name, "You carry Swordsman Certification now.\n\nThe Forest gate will recognize you.")
		var objective := QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild")
		return _quest_dialog_flow.quest_panel(npc.display_name, SWORDSMAN_QUEST_INTRO, SWORDSMAN_QUEST_CLAIM, objective, _can_claim_swordsman_reward(npc))
	return _quest_dialog_flow.normal_panel(npc.display_name, npc.dialog_text)


func _apply_dialog_panel(panel: Dictionary, portrait_texture: Texture2D = null) -> void:
	_dialog_view.show_dialog(
		str(panel.get("title", "")),
		str(panel.get("body", "")),
		false,
		bool(panel.get("can_claim_reward", false)),
		portrait_texture
	)
	_dialog_view.set_complete_action_text(str(panel.get("action_text", "Claim Reward")))


func _prepare_guildmaster_dialog(npc: NpcController) -> void:
	if npc.role != "guildmaster":
		return
	if QuestSystem.current_main_objective_id() == "get_swordsman_certification" and not QuestSystem.has_certification("swordsman_certification"):
		QuestSystem.activate_swordsman_guild_chain()
	_sync_swordsman_inventory_objective()


func _can_claim_swordsman_reward(npc: NpcController) -> bool:
	_sync_swordsman_inventory_objective()
	return npc.role == "guildmaster" \
		and QuestSystem.is_side_quest_active("rebuilding_swordsman_guild") \
		and QuestSystem.is_current_side_quest_step_complete("rebuilding_swordsman_guild")


func _on_complete_quest_requested() -> void:
	if _progression == null:
		return
	var completed_step := QuestSystem.side_quest_step("rebuilding_swordsman_guild")
	if not _progression.complete_swordsman_certification_step():
		return
	_update_life_hud()
	_update_player_age_sprite()
	_update_quest_window()
	if QuestSystem.has_certification("swordsman_certification"):
		_apply_dialog_panel(_quest_dialog_flow.reward_unlock_panel("Swordsman Guild Unlocked"))
		_save_profile()
		show_rebirth_panel()
		return
	_sync_swordsman_inventory_objective()
	_update_quest_window()
	_show_swordsman_reward_dialog(completed_step)


func _update_life_hud() -> void:
	if _hud:
		_hud.set_life(player_stats.max_hp, player_stats.max_hp)


func show_rebirth_panel() -> void:
	var panel := get_node_or_null("UI/RebirthPanel") as PanelContainer
	if panel:
		_update_game_over_summary()
		panel.visible = true


func _refresh_rebirth_panel() -> void:
	var panel := get_node_or_null("UI/RebirthPanel") as PanelContainer
	if panel:
		panel.visible = player_stats != null and player_stats.game_over_requested


func _rebirth_panel_is_open() -> bool:
	var panel := get_node_or_null("UI/RebirthPanel") as PanelContainer
	return panel != null and panel.visible


func _on_rebirth_pressed() -> void:
	if player_stats == null:
		return
	player_stats.rebirth()
	var inventory_system := _inventory_system()
	if inventory_system and inventory_system.has_method("reset"):
		inventory_system.reset()
	else:
		var inventory_model = _inventory_model_for_hud()
		if inventory_model and inventory_model.has_method("reset"):
			inventory_model.reset()
	_update_life_hud()
	_update_player_age_sprite()
	if _hud and _hud.has_method("set_inventory_model"):
		_hud.set_inventory_model(_inventory_model_for_hud())
	_save_profile()
	_refresh_rebirth_panel()


func _on_end_game_pressed() -> void:
	requested_scene_path = MAIN_MENU_PATH
	if is_inside_tree():
		call_deferred("_change_scene_to_file", MAIN_MENU_PATH)


func _update_game_over_summary() -> void:
	var title := get_node_or_null("UI/RebirthPanel/VBox/TitleLabel") as Label
	if title:
		title.text = "Game Over"
	var message := get_node_or_null("UI/RebirthPanel/VBox/MessageLabel") as Label
	if message:
		message.text = "You spent this life. Choose what comes next."
	var summary_label := get_node_or_null("UI/RebirthPanel/VBox/SummaryLabel") as Label
	if summary_label:
		summary_label.text = _run_summary.summary_text(player_stats, _inventory_model_for_hud())


func _save_profile() -> void:
	var profile := _profile_system()
	if profile and profile.has_method("save_profile"):
		profile.save_profile()


func _update_player_age_sprite() -> void:
	if _player_aging == null:
		return
	var sprite := _player.get_node_or_null("Sprite") as Sprite2D
	if sprite:
		sprite.texture = _load_texture(_player_aging.texture_path_for_max_hp_and_equipment(player_stats.max_hp, _equipped_weapon_id(), _equipped_armor_id()))


func _on_equipment_changed() -> void:
	_update_player_age_sprite()


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


func _profile_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/ProfileSystem")


func _inventory_model_for_hud():
	var system := _inventory_system()
	if system:
		return system.model()
	if _local_inventory_model == null:
		_local_inventory_model = INVENTORY_SCRIPT.new()
	return _local_inventory_model


func _equipped_weapon_id() -> String:
	var inventory_model = _inventory_model_for_hud()
	if inventory_model == null:
		return ""
	return str(inventory_model.weapon_slot)


func _equipped_armor_id() -> String:
	var inventory_model = _inventory_model_for_hud()
	if inventory_model == null:
		return ""
	return str(inventory_model.armor_slot)


func _sync_swordsman_inventory_objective() -> void:
	if QuestSystem.side_quest_step("rebuilding_swordsman_guild") != 1:
		return
	var inventory_model = _inventory_model_for_hud()
	if inventory_model and inventory_model.has_method("quantity"):
		QuestSystem.sync_current_item_objective("bat_wing", int(inventory_model.quantity("bat_wing")))


func _show_swordsman_reward_dialog(completed_step: int) -> void:
	var reward := _swordsman_reward_for_step(completed_step)
	if reward.is_empty():
		_dialog_view.hide_dialog()
		return
	var inventory_model = _inventory_model_for_hud()
	if inventory_model and inventory_model.has_method("add_item"):
		inventory_model.add_item(str(reward["item_id"]), int(reward["quantity"]))
	if _hud and _hud.has_method("set_inventory_model"):
		_hud.set_inventory_model(inventory_model)
	_apply_dialog_panel(_quest_dialog_flow.reward_item_panel(str(reward["display_name"]), int(reward["quantity"])))


func _swordsman_reward_for_step(completed_step: int) -> Dictionary:
	match completed_step:
		0:
			return {"item_id": "training_sword", "display_name": "Training Sword", "quantity": 1}
		1:
			return {"item_id": "leather_armor", "display_name": "Leather Armor", "quantity": 1}
	return {}
