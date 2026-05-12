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
const ENEMY_COLLISION_RADIUS := 28.0
const FIELD_MAP_ID := "field"
const FIELD_BIOME_ID := "grassland"
const FIELD_MAX_ACTIVE_ENEMIES := 9
const FIELD_RESPAWN_DELAY := 60.0
const ENEMY_SPAWN_POLL_INTERVAL := 1.0

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _objective_prompt: Label = $UI/ObjectivePrompt
@onready var _quest_window: PanelContainer = $UI/QuestWindow
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
var _enemy_spawn_slots: Dictionary = {}
var _enemy_spawn_poll_timer: float = 0.0
var _spawn_rng := RandomNumberGenerator.new()

var _pending_npc: NpcController
var _behavior = ENEMY_BEHAVIOR_SCRIPT.new()
var _combat = COMBAT_SCRIPT.new()
var _life_label: Label
var _slime_hp_label: Label
var _player_damage_label: Label
var _player_damage_timer: float = 0.0
var _pending_forest_guard_checkpoint: bool = false


func _ready() -> void:
	if _is_test_run():
		EnemySpawnManager.reset()
		QuestSystem.reset()
	QuestSystem.setup_core_quests()
	_objective_prompt.text = "Objective: Find the Forest path."
	_update_quest_window()
	_dialog_view.hide_dialog()
	_connect_dialog()
	_connect_gateways()
	_connect_forest_guard()
	_ensure_combat_ui()
	_spawn_initial_slime()
	_update_combat_ui()
	_update_camera()


func _is_test_run() -> bool:
	for arg in OS.get_cmdline_args():
		if str(arg).contains("tests/test_runner.tscn"):
			return true
	return false


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
	_tick_enemy_spawns(delta)
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
		if not movement.is_attacking():
			movement.stop_moving()
		movement.face_target(state.position)
	player_attack_timer += delta
	if player_attack_timer < player_attack_interval:
		return
	player_attack_timer = 0.0
	movement.play_attack("slash")
	var result: Dictionary = _combat.player_attack_enemy(_player_combat_dict(), state.to_combat_dict())
	state.apply_combat_dict(result["enemy_state"])
	state.is_aggro = true
	if state.behavior_state != "die":
		state.behavior_state = "chase"
	if bool(result.get("enemy_defeated", false)):
		if not state.reward_granted:
			player_xp += int(result.get("xp_reward", 0))
			state.reward_granted = true
			EnemySpawnManager.mark_defeated(state.instance_id)
		state.behavior_state = "die"
		state.is_defeated = true
		_update_enemy_view(state)
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
		var previous_position: Vector2 = state.position
		var result: Dictionary = _behavior.tick(state, definition, {"player_position": _player.global_position}, delta)
		_move_enemy_with_collision(state, state.position, previous_position)
		if bool(result.get("enemy_attack", false)):
			var combat_result: Dictionary = _combat.enemy_attack_player(state.to_combat_dict(), _player_combat_dict())
			_apply_player_combat_dict(combat_result["player_state"])
			_show_player_damage(int(combat_result.get("damage", 1)))
			var attack_view = enemy_views.get(instance_id, null)
			if attack_view and attack_view.has_method("play_attack_feedback"):
				attack_view.play_attack_feedback()
		if state.behavior_state == "die" or bool(result.get("died", false)):
			state.death_timer += delta
			_update_enemy_view(state)
			if state.death_timer >= definition.death_duration:
				_remove_enemy(instance_id)
		else:
			_update_enemy_view(state)


func _attack_point_for_enemy(enemy_position: Vector2) -> Vector2:
	var from_enemy := _player.global_position - enemy_position
	var direction := from_enemy.normalized() if from_enemy != Vector2.ZERO else Vector2.LEFT
	return enemy_position + direction * 44.0


func _move_enemy_with_collision(state, next_position: Vector2, fallback_position: Vector2 = Vector2.INF) -> void:
	var current_position: Vector2 = state.position if fallback_position == Vector2.INF else fallback_position
	if is_enemy_position_blocked(next_position):
		state.position = current_position
		if state.behavior_state == "wander":
			state.behavior_state = "idle"
			state.target_position = current_position
	else:
		state.position = next_position
	_update_enemy_view(state)


func is_enemy_position_blocked(position: Vector2) -> bool:
	var collision_root := get_node_or_null("FieldCollision")
	if collision_root == null:
		return false
	return _position_blocked_by_node(collision_root, position)


func _position_blocked_by_node(node: Node, position: Vector2) -> bool:
	if node is CollisionShape2D and _position_blocked_by_shape(node as CollisionShape2D, position):
		return true
	for child in node.get_children():
		if _position_blocked_by_node(child, position):
			return true
	return false


func _position_blocked_by_shape(shape_node: CollisionShape2D, position: Vector2) -> bool:
	if shape_node.disabled or shape_node.shape == null:
		return false
	var shape := shape_node.shape
	if shape is RectangleShape2D:
		var rect_shape := shape as RectangleShape2D
		var scaled_size := rect_shape.size * shape_node.global_scale.abs()
		var rect := Rect2(shape_node.global_position - scaled_size * 0.5, scaled_size).grow(ENEMY_COLLISION_RADIUS)
		return rect.has_point(position)
	if shape is CircleShape2D:
		var circle_shape := shape as CircleShape2D
		var radius_scale: float = max(absf(shape_node.global_scale.x), absf(shape_node.global_scale.y))
		return shape_node.global_position.distance_to(position) <= circle_shape.radius * radius_scale + ENEMY_COLLISION_RADIUS
	return false


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
	_spawn_rng.randomize()
	var spawns := [
		{"enemy_id": "slime_spiked", "id": "field_slime_001", "name": "Slime"},
		{"enemy_id": "slime_spiked", "id": "field_slime_002", "name": "Slime2"},
		{"enemy_id": "slime_spiked", "id": "field_slime_003", "name": "Slime3"},
		{"enemy_id": "slime_spiked", "id": "field_slime_004", "name": "Slime4"},
		{"enemy_id": "slime_spiked", "id": "field_slime_005", "name": "Slime5"},
		{"enemy_id": "bat", "id": "field_bat_001", "name": "Bat"},
		{"enemy_id": "bat", "id": "field_bat_002", "name": "Bat2"},
		{"enemy_id": "rat", "id": "field_rat_001", "name": "Rat"},
		{"enemy_id": "rat", "id": "field_rat_002", "name": "Rat2"},
	]
	EnemySpawnManager.register_biome(FIELD_MAP_ID, FIELD_BIOME_ID, FIELD_MAX_ACTIVE_ENEMIES, FIELD_RESPAWN_DELAY)
	_enemy_spawn_slots.clear()
	for spawn in spawns:
		EnemySpawnManager.register_spawn_slot(spawn["id"], FIELD_MAP_ID, FIELD_BIOME_ID, spawn["enemy_id"])
		_enemy_spawn_slots[spawn["id"]] = spawn
	_spawn_active_enemy_slots()


func _tick_enemy_spawns(delta: float) -> void:
	_enemy_spawn_poll_timer += delta
	if _enemy_spawn_poll_timer < ENEMY_SPAWN_POLL_INTERVAL:
		return
	_enemy_spawn_poll_timer = 0.0
	_spawn_active_enemy_slots()


func _spawn_active_enemy_slots() -> void:
	var occupied: Array[Vector2] = _current_enemy_positions()
	for active_slot in EnemySpawnManager.active_spawn_slots(FIELD_MAP_ID, FIELD_BIOME_ID):
		var slot_id := str(active_slot.get("slot_id", ""))
		if enemy_states.has(slot_id):
			continue
		var spawn: Dictionary = _enemy_spawn_slots.get(slot_id, {})
		if spawn.is_empty():
			continue
		var position := _random_enemy_spawn_position(occupied)
		occupied.append(position)
		spawn_enemy(spawn["enemy_id"], position, spawn["id"], spawn["name"])


func _current_enemy_positions() -> Array[Vector2]:
	var occupied: Array[Vector2] = []
	for view in enemy_views.values():
		if view is Node2D:
			occupied.append((view as Node2D).global_position)
	return occupied


func _random_enemy_spawn_position(occupied: Array[Vector2]) -> Vector2:
	var rect := enemy_spawn_rect()
	for attempt in range(24):
		var candidate := Vector2(_spawn_rng.randf_range(rect.position.x, rect.end.x), _spawn_rng.randf_range(rect.position.y, rect.end.y))
		if _is_spawn_position_clear(candidate, occupied):
			return candidate
	return Vector2(_spawn_rng.randf_range(rect.position.x, rect.end.x), _spawn_rng.randf_range(rect.position.y, rect.end.y))


func enemy_spawn_rect() -> Rect2:
	var zone := get_node_or_null("SpawnZones/Grassland") as ColorRect
	if zone == null:
		return Rect2(Vector2(380, 300), Vector2(1260, 620))
	return Rect2(Vector2(zone.offset_left, zone.offset_top), Vector2(zone.offset_right - zone.offset_left, zone.offset_bottom - zone.offset_top))


func _is_spawn_position_clear(candidate: Vector2, occupied: Array[Vector2]) -> bool:
	if is_enemy_position_blocked(candidate):
		return false
	if candidate.distance_to(_player.global_position) < 260.0:
		return false
	if candidate.distance_to(_town_gateway.global_position) < 260.0:
		return false
	if candidate.distance_to(_forest_guard.global_position) < 180.0:
		return false
	for point in occupied:
		if candidate.distance_to(point) < 120.0:
			return false
	return true


func spawn_enemy(enemy_id: String, position: Vector2, instance_id: String = "", node_name: String = "Enemy") -> Node:
	var enemies := _ensure_enemies_node()
	var definition = ENEMY_DEFINITION_SCRIPT.for_id(enemy_id)
	enemy_definitions[definition.enemy_id] = definition
	var resolved_id := instance_id if instance_id != "" else "%s_%d" % [enemy_id, enemy_states.size() + 1]
	var state = ENEMY_STATE_SCRIPT.from_definition(resolved_id, definition, position)
	enemy_states[resolved_id] = state
	var view = ENEMY_VIEW_SCENE.instantiate()
	view.name = node_name
	view.configure(resolved_id, enemy_id)
	enemies.add_child(view)
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
	if npc.role == "forest_guard":
		_pending_forest_guard_checkpoint = true
	_dialog_view.show_dialog(npc.display_name, npc.dialog_text, false, false, _npc_portrait_texture(npc))


func close_dialog() -> void:
	if _pending_forest_guard_checkpoint:
		_reach_forest_guard_checkpoint()
	_dialog_view.hide_dialog()
	_pending_npc = null
	_pending_forest_guard_checkpoint = false


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


func _update_quest_window() -> void:
	if _quest_window and _quest_window.has_method("show_main_objective"):
		_quest_window.show_main_objective("Explore the World", QuestSystem.current_main_objective_text(), QuestSystem.current_main_checkpoint_text())


func _reach_forest_guard_checkpoint() -> void:
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	_update_quest_window()


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
