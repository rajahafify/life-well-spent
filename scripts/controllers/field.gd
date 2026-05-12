## Field — playable Field prototype controller.
## Thin glue: movement/camera, guard dialog, direct gateways, first Slime combat flow.
class_name Field
extends Node2D

const TOWN_PATH := "res://scenes/town_scene.tscn"
const CAMERA_OFFSET := Vector2(0, -150)
const FOREST_GUARD_DIALOG := "Stop.\n\nThe Demon King is gone.\nBut old places do not become safe overnight.\n\nThe Forest remembers what we forgot.\nReturn to Town.\nEarn certification from the Swordsman Guild."
const ENEMY_VIEW_SCENE := preload("res://scenes/enemy_view.tscn")
const ENEMY_DEFINITION_SCRIPT := preload("res://scripts/models/enemy_definition.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/models/enemy_state.gd")
const ENEMY_BEHAVIOR_SCRIPT := preload("res://scripts/models/enemy_behavior_system.gd")
const COMBAT_SCRIPT := preload("res://scripts/models/combat_system.gd")

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _objective_prompt: Label = $UI/ObjectivePrompt
@onready var _town_gateway: Area2D = $TownGateway
@onready var _forest_gateway: Area2D = $ForestGateway
@onready var _player: CharacterBody2D = $Player
@onready var _forest_guard: NpcController = $ForestGuard

var requested_scene_path: String = ""
var player_life: int = 100
var player_max_life: int = 100
var player_attack: int = 4
var player_defense: int = 0
var player_attack_interval: float = 1.0
var player_attack_timer: float = 0.0
var player_xp: int = 0
var player_target_enemy_instance_id: String = ""
var enemy_states: Dictionary = {}
var enemy_views: Dictionary = {}
var enemy_definitions: Dictionary = {}

var _pending_npc: NpcController
var _behavior = ENEMY_BEHAVIOR_SCRIPT.new()
var _combat = COMBAT_SCRIPT.new()
var _life_label: Label
var _slime_hp_label: Label
var _player_damage_label: Label
var _player_damage_timer: float = 0.0


func _ready() -> void:
	_objective_prompt.text = "Objective: Find the Forest path."
	_dialog_view.hide_dialog()
	_connect_dialog()
	_connect_gateways()
	_connect_forest_guard()
	_ensure_combat_ui()
	_spawn_initial_slime()
	_update_combat_ui()
	_update_camera()


func _exit_tree() -> void:
	_cleanup_combat_refs()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_cleanup_combat_refs()


func _cleanup_combat_refs() -> void:
	if _behavior:
		_behavior.free()
		_behavior = null
	if _combat:
		_combat.free()
		_combat = null
	enemy_states.clear()
	enemy_views.clear()
	enemy_definitions.clear()


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


func _physics_process(delta: float) -> void:
	_update_camera()
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)
	_tick_player_damage_label(delta)
	_tick_enemies(delta)
	_tick_player_auto_attack(delta)
	_update_combat_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		stop_auto_attack()
		move_player_to(get_global_mouse_position())


func stop_auto_attack() -> void:
	player_target_enemy_instance_id = ""
	player_attack_timer = 0.0


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open():
		return false
	var movement := _player_movement()
	if movement == null:
		return false
	movement.move_to(target)
	return true


func engage_enemy(instance_id: String) -> void:
	if not enemy_states.has(instance_id):
		return
	player_target_enemy_instance_id = instance_id
	var state = enemy_states[instance_id]
	state.is_aggro = true
	if state.behavior_state != "die":
		state.behavior_state = "chase"
	var view := enemy_views.get(instance_id, null) as Node2D
	if view:
		move_player_to(_attack_point_for_enemy(view.global_position))


func _tick_player_auto_attack(delta: float) -> void:
	if player_target_enemy_instance_id == "" or not enemy_states.has(player_target_enemy_instance_id):
		return
	var state = enemy_states[player_target_enemy_instance_id]
	if state.is_defeated:
		player_target_enemy_instance_id = ""
		return
	var distance := _player.global_position.distance_to(state.position)
	var definition = enemy_definitions[state.enemy_id]
	if distance > definition.attack_range:
		move_player_to(_attack_point_for_enemy(state.position))
		return
	var movement := _player_movement()
	if movement:
		movement.stop_moving()
		movement.face_target(state.position)
	player_attack_timer += delta
	if player_attack_timer < player_attack_interval:
		return
	player_attack_timer = 0.0
	var result: Dictionary = _combat.player_attack_enemy(_player_combat_dict(), state.to_combat_dict())
	state.apply_combat_dict(result["enemy_state"])
	if bool(result.get("enemy_defeated", false)):
		if not state.reward_granted:
			player_xp += int(result.get("xp_reward", 0))
			state.reward_granted = true
		_remove_enemy(player_target_enemy_instance_id)
		player_target_enemy_instance_id = ""
	else:
		_update_enemy_view(state)
		var hit_view = enemy_views.get(state.instance_id, null)
		if hit_view and hit_view.has_method("play_hit_feedback"):
			hit_view.play_hit_feedback(int(result.get("damage", 1)))


func _tick_enemies(delta: float) -> void:
	var ids := enemy_states.keys()
	for instance_id in ids:
		if not enemy_states.has(instance_id):
			continue
		var state = enemy_states[instance_id]
		var definition = enemy_definitions[state.enemy_id]
		state.position = (enemy_views[instance_id] as Node2D).global_position
		var result: Dictionary = _behavior.tick(state, definition, {"player_position": _player.global_position}, delta)
		if bool(result.get("enemy_attack", false)):
			var combat_result: Dictionary = _combat.enemy_attack_player(state.to_combat_dict(), _player_combat_dict())
			_apply_player_combat_dict(combat_result["player_state"])
			_show_player_damage(int(combat_result.get("damage", 1)))
			var attack_view = enemy_views.get(instance_id, null)
			if attack_view and attack_view.has_method("play_attack_feedback"):
				attack_view.play_attack_feedback()
		if state.behavior_state == "die" or bool(result.get("died", false)):
			_remove_enemy(instance_id)
		else:
			_update_enemy_view(state)


func _attack_point_for_enemy(enemy_position: Vector2) -> Vector2:
	var from_enemy := _player.global_position - enemy_position
	var direction := from_enemy.normalized() if from_enemy != Vector2.ZERO else Vector2.LEFT
	return enemy_position + direction * 44.0


func _player_combat_dict() -> Dictionary:
	return {
		"life": player_life,
		"max_life": player_max_life,
		"attack": player_attack,
		"defense": player_defense,
		"xp": player_xp,
	}


func _apply_player_combat_dict(next_player: Dictionary) -> void:
	player_life = int(next_player.get("life", player_life))
	player_max_life = int(next_player.get("max_life", player_max_life))
	player_life = clampi(player_life, 0, player_max_life)


func _spawn_initial_slime() -> void:
	if enemy_states.has("field_slime_001"):
		return
	spawn_enemy("slime_spiked", Vector2(900, 610), "field_slime_001", "Slime")


func spawn_enemy(enemy_id: String, position: Vector2, instance_id: String = "", node_name: String = "Enemy") -> Node:
	var enemies := _ensure_enemies_node()
	var definition = ENEMY_DEFINITION_SCRIPT.slime_spiked()
	enemy_definitions[definition.enemy_id] = definition
	var resolved_id := instance_id if instance_id != "" else "%s_%d" % [enemy_id, enemy_states.size() + 1]
	var state = ENEMY_STATE_SCRIPT.from_definition(resolved_id, definition, position)
	enemy_states[resolved_id] = state
	var view = ENEMY_VIEW_SCENE.instantiate()
	view.name = node_name
	enemies.add_child(view)
	view.configure(resolved_id, enemy_id)
	view.global_position = position
	view.clicked.connect(engage_enemy)
	enemy_views[resolved_id] = view
	_update_enemy_view(state)
	return view


func _ensure_enemies_node() -> Node2D:
	var enemies := get_node_or_null("Enemies") as Node2D
	if enemies == null:
		enemies = Node2D.new()
		enemies.name = "Enemies"
		add_child(enemies)
	return enemies


func _remove_enemy(instance_id: String) -> void:
	var view := enemy_views.get(instance_id, null) as Node
	if view:
		var parent := view.get_parent()
		if parent:
			parent.remove_child(view)
		view.free()
		enemy_views.erase(instance_id)
	enemy_states.erase(instance_id)
	if player_target_enemy_instance_id == instance_id:
		player_target_enemy_instance_id = ""


func _update_enemy_view(state) -> void:
	var view = enemy_views.get(state.instance_id, null)
	if view:
		view.update_from_state(state)


func _ensure_combat_ui() -> void:
	_life_label = get_node_or_null("UI/LifeLabel") as Label
	if _life_label == null:
		_life_label = Label.new()
		_life_label.name = "LifeLabel"
		_life_label.offset_left = 28.0
		_life_label.offset_top = 76.0
		_life_label.offset_right = 340.0
		_life_label.offset_bottom = 112.0
		_life_label.add_theme_font_size_override("font_size", 26)
		$UI.add_child(_life_label)
	_slime_hp_label = get_node_or_null("UI/SlimeHpLabel") as Label
	if _slime_hp_label == null:
		_slime_hp_label = Label.new()
		_slime_hp_label.name = "SlimeHpLabel"
		_slime_hp_label.offset_left = 28.0
		_slime_hp_label.offset_top = 116.0
		_slime_hp_label.offset_right = 360.0
		_slime_hp_label.offset_bottom = 152.0
		_slime_hp_label.add_theme_font_size_override("font_size", 26)
		$UI.add_child(_slime_hp_label)
	_player_damage_label = _player.get_node_or_null("DamageLabel") as Label
	if _player_damage_label == null:
		_player_damage_label = Label.new()
		_player_damage_label.name = "DamageLabel"
		_player_damage_label.position = Vector2(-10, -96)
		_player_damage_label.add_theme_font_size_override("font_size", 24)
		_player_damage_label.visible = false
		_player.add_child(_player_damage_label)


func _show_player_damage(damage: int) -> void:
	if _player_damage_label:
		_player_damage_label.text = str(damage)
		_player_damage_label.visible = true
		_player_damage_timer = 0.75


func _tick_player_damage_label(delta: float) -> void:
	if _player_damage_timer <= 0.0:
		return
	_player_damage_timer -= delta
	if _player_damage_timer <= 0.0 and _player_damage_label:
		_player_damage_label.visible = false


func _update_combat_ui() -> void:
	if _life_label:
		_life_label.text = "Life: %d/%d" % [player_life, player_max_life]
	if _slime_hp_label:
		if enemy_states.has("field_slime_001"):
			var slime = enemy_states["field_slime_001"]
			_slime_hp_label.text = "Slime: %d/%d" % [slime.hp, slime.max_hp]
		else:
			_slime_hp_label.text = "Slime: defeated"


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
		call_deferred("_change_scene_to_file", scene_path)


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.global_position = _player.global_position + CAMERA_OFFSET


func _npc_portrait_texture(npc: NpcController) -> Texture2D:
	var sprite := npc.get_node_or_null("Sprite") as Sprite2D
	return sprite.texture if sprite else null


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
