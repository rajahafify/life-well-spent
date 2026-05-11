## Field — playable Field prototype controller.
## Thin glue: movement/camera, guard dialog, direct gateways, simple combat wiring.
class_name Field
extends Node2D

const TOWN_PATH := "res://scenes/town_scene.tscn"
const CAMERA_OFFSET := Vector2(0, -150)
const FOREST_GUARD_DIALOG := "Stop.\n\nThe Demon King is gone.\nBut old places do not become safe overnight.\n\nThe Forest remembers what we forgot.\nReturn to Town.\nEarn certification from the Swordsman Guild."
const COMBAT_SCRIPT := preload("res://scripts/models/combat_system.gd")
const ENEMY_SCRIPT := preload("res://scripts/models/enemy_definition.gd")

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _objective_prompt: Label = $UI/ObjectivePrompt
@onready var _combat_hud: Label = $UI/CombatHud
@onready var _town_gateway: Area2D = $TownGateway
@onready var _forest_gateway: Area2D = $ForestGateway
@onready var _player: CharacterBody2D = $Player
@onready var _forest_guard: NpcController = $ForestGuard

var requested_scene_path: String = ""
var player_combat_state: Dictionary = {"combat_hp": 20, "attack": 5, "defense": 0, "life": 100, "xp": 0}
var _pending_npc: NpcController
var _combat: Object = COMBAT_SCRIPT.new()


func _ready() -> void:
	_objective_prompt.text = "Objective: Find the Forest path."
	_dialog_view.hide_dialog()
	_connect_dialog()
	_connect_gateways()
	_connect_forest_guard()
	_connect_enemies()
	_initialize_enemy_states()
	_update_combat_hud()
	_update_camera()


func _exit_tree() -> void:
	_cleanup_model_refs()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_cleanup_model_refs()


func _cleanup_model_refs() -> void:
	if _combat:
		_combat.free()
		_combat = null


func _connect_dialog() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.close_requested.is_connected(close_dialog):
		_dialog_view.close_requested.connect(close_dialog)


func _connect_gateways() -> void:
	if _town_gateway and not _town_gateway.body_entered.is_connected(_on_town_gateway_body_entered):
		_town_gateway.body_entered.connect(_on_town_gateway_body_entered)
	if _forest_gateway and not _forest_gateway.body_entered.is_connected(_on_forest_gateway_body_entered):
		_forest_gateway.body_entered.connect(_on_forest_gateway_body_entered)


func _connect_forest_guard() -> void:
	if _forest_guard and not _forest_guard.interacted.is_connected(_on_npc_interacted):
		_forest_guard.interacted.connect(_on_npc_interacted)


func _connect_enemies() -> void:
	for enemy in $Enemies.get_children():
		if enemy is Area2D and not enemy.input_event.is_connected(_on_enemy_input_event):
			enemy.input_event.connect(_on_enemy_input_event.bind(enemy))


func _initialize_enemy_states() -> void:
	for enemy in $Enemies.get_children():
		if not enemy.has_meta("enemy_id"):
			continue
		var definition = _definition_for_enemy(str(enemy.get_meta("enemy_id")))
		if definition:
			enemy.set_meta("hp", definition.hp)
			enemy.set_meta("attack", definition.attack)
			enemy.set_meta("defense", definition.defense)
			enemy.set_meta("xp_reward", definition.xp_reward)
			enemy.set_meta("defeated", false)


func _physics_process(_delta: float) -> void:
	_update_camera()
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		move_player_to(get_global_mouse_position())


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open():
		return false
	var movement := _player_movement()
	if movement == null:
		return false
	movement.move_to(target)
	return true


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
	_dialog_view.show_dialog(npc.display_name, npc.dialog_text, false, false, _npc_portrait_texture(npc))


func close_dialog() -> void:
	_dialog_view.hide_dialog()
	_pending_npc = null


func _on_town_gateway_body_entered(body: Node) -> void:
	if body.name == "Player":
		request_scene(TOWN_PATH)


func _on_forest_gateway_body_entered(body: Node) -> void:
	if body.name == "Player":
		_open_dialog(_forest_guard)


func request_scene(scene_path: String) -> void:
	requested_scene_path = scene_path
	if is_inside_tree():
		get_tree().change_scene_to_file(scene_path)


func _on_enemy_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, enemy: Area2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		attack_enemy(enemy)


func attack_enemy(enemy: Node) -> Dictionary:
	if enemy == null or bool(enemy.get_meta("defeated", false)):
		return {}
	var enemy_state := {
		"enemy_id": enemy.get_meta("enemy_id", ""),
		"hp": int(enemy.get_meta("hp", 1)),
		"attack": int(enemy.get_meta("attack", 1)),
		"defense": int(enemy.get_meta("defense", 0)),
		"xp_reward": int(enemy.get_meta("xp_reward", 0)),
	}
	var result: Dictionary = _combat.player_attack_enemy(player_combat_state, enemy_state)
	var next_enemy: Dictionary = result["enemy_state"]
	enemy.set_meta("hp", next_enemy["hp"])
	if result["enemy_defeated"]:
		enemy.set_meta("defeated", true)
		enemy.visible = false
		player_combat_state["xp"] = int(player_combat_state.get("xp", 0)) + int(result["xp_reward"])
		_update_combat_hud()
		return result

	var counter: Dictionary = _combat.enemy_attack_player(enemy_state, player_combat_state)
	player_combat_state = counter["player_state"]
	result["counter_attack"] = counter
	_update_combat_hud()
	return result


func _definition_for_enemy(enemy_id: String):
	match enemy_id:
		"chick":
			return ENEMY_SCRIPT.chick()
		"rabbit":
			return ENEMY_SCRIPT.rabbit()
		"slime":
			return ENEMY_SCRIPT.slime()
		_:
			return null


func _update_combat_hud() -> void:
	if _combat_hud:
		_combat_hud.text = "Combat HP: %d    XP: %d" % [int(player_combat_state.get("combat_hp", 0)), int(player_combat_state.get("xp", 0))]


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.global_position = _player.global_position + CAMERA_OFFSET


func _npc_portrait_texture(npc: NpcController) -> Texture2D:
	var sprite := npc.get_node_or_null("Sprite") as Sprite2D
	return sprite.texture if sprite else null


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
