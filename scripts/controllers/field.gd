## Field — playable Field prototype controller.
## Thin glue: movement/camera, guard dialog, direct gateways, first Slime combat flow.
class_name Field
extends Node2D

const TOWN_PATH := "res://scenes/town_scene.tscn"
const FOREST_PATH := "res://scenes/forest.tscn"
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const FOREST_TO_BE_CONTINUED := "The path to forest is open."
const CAMERA_OFFSET := Vector2(0, -150)
const FOREST_GUARD_DIALOG := "Stop.\n\nThe Demon King is gone.\nBut old places do not become safe overnight.\n\nThe Forest remembers what we forgot.\nReturn to Town.\nEarn certification from the Swordsman Guild."
const ENEMY_VIEW_SCENE := preload("res://scenes/enemy_view.tscn")
const ENEMY_LIBRARY_SCRIPT := preload("res://scripts/models/enemy_library.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/models/enemy_state.gd")
const INVENTORY_SCRIPT := preload("res://scripts/models/inventory_model.gd")
const FIELD_RUNTIME_CONTEXT_SCRIPT := preload("res://scripts/controllers/field_runtime_context.gd")
const GAME_BALANCE_SCRIPT := preload("res://scripts/models/game_balance.gd")
const SETTINGS_SCRIPT := preload("res://scripts/models/settings_model.gd")
const DAMAGE_TEXT_SCRIPT := preload("res://scripts/views/damage_text_component.gd")
const ENEMY_COLLISION_RADIUS := GAME_BALANCE_SCRIPT.FIELD_ENEMY_COLLISION_RADIUS
const ENEMY_APPROACH_DISTANCE := GAME_BALANCE_SCRIPT.FIELD_ENEMY_APPROACH_DISTANCE
const PLAYER_ATTACK_READY_RANGE := GAME_BALANCE_SCRIPT.FIELD_PLAYER_ATTACK_READY_RANGE
const PLAYER_ATTACK_LEASH_RANGE := GAME_BALANCE_SCRIPT.FIELD_PLAYER_ATTACK_LEASH_RANGE
const LOOT_TOAST_DURATION := GAME_BALANCE_SCRIPT.FIELD_LOOT_TOAST_DURATION
const APPLE_HEAL_AMOUNT := GAME_BALANCE_SCRIPT.APPLE_HEAL_AMOUNT

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _hud: CanvasLayer = $UI
@onready var _town_gateway: Area2D = $TownGateway
@onready var _forest_gateway: Area2D = $ForestGateway
@onready var _player: CharacterBody2D = $Player
@onready var _forest_guard: NpcController = $ForestGuard

var requested_scene_path: String = ""
var player_life: int = 100
var player_max_life: int = 100
var player_attack: int = 40
var player_defense: int = 0
var player_attack_interval: float = 1.0
var player_attack_timer: float = 0.0
var player_xp: int = 0
var player_target_enemy_instance_id: String = ""
var player_target_attack_ready: bool = false
var inventory = null
var enemy_states: Dictionary = {}
var enemy_views: Dictionary = {}
var enemy_definitions: Dictionary = {}
var forced_drop_roll: int = -1
var _drop_rng := RandomNumberGenerator.new()

var _pending_npc: NpcController
var _runtime = FIELD_RUNTIME_CONTEXT_SCRIPT.new()
var _local_inventory_model = null
var _player_damage_label: Label
var _player_damage_text
var _player_damage_timer: float = 0.0
var _loot_toast_label: Label
var _loot_toast_timer: float = 0.0
var _pending_forest_guard_checkpoint: bool = false


func _ready() -> void:
	if _is_test_run():
		EnemySpawnManager.reset()
		QuestSystem.reset()
		var test_feedback_system := _feedback_system()
		if test_feedback_system:
			test_feedback_system.reset()
		var test_inventory_system := _inventory_system()
		if test_inventory_system:
			test_inventory_system.reset()
	inventory = _inventory_system()
	if inventory == null:
		_local_inventory_model = INVENTORY_SCRIPT.new()
		inventory = _local_inventory_model
	_bind_profile_player()
	QuestSystem.setup_core_quests()
	_connect_hud()
	_update_quest_window()
	_update_player_age_sprite()
	_dialog_view.hide_dialog()
	_connect_dialog()
	_connect_gateways()
	_connect_forest_guard()
	_ensure_combat_ui()
	_runtime.randomize_runtime()
	_drop_rng.randomize()
	_spawn_initial_slime()
	_update_combat_ui()
	_update_camera()


func _is_test_run() -> bool:
	for arg in OS.get_cmdline_args():
		if str(arg).contains("tests/test_runner.tscn"):
			return true
	return false


func _bind_profile_player() -> void:
	var profile := _profile_system()
	if profile == null or not profile.has_method("player"):
		return
	var profile_player = profile.player()
	if profile_player == null:
		return
	player_life = int(profile_player.max_hp)
	player_max_life = int(profile_player.max_hp)


func _exit_tree() -> void:
	_cleanup_combat_refs()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_cleanup_combat_refs()


func _cleanup_combat_refs() -> void:
	if _runtime:
		_runtime.dispose()
		_runtime.free()
		_runtime = null
	if _local_inventory_model:
		_local_inventory_model.free()
		_local_inventory_model = null
	inventory = null
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


func _connect_hud() -> void:
	if _hud:
		_hud.ensure_ready()
		_hud.set_inventory_model(_inventory_model_for_hud())
		_hud.set_life(player_life, player_max_life)
		if _hud.has_signal("shortcut_pressed") and not _hud.shortcut_pressed.is_connected(_on_shortcut_pressed):
			_hud.shortcut_pressed.connect(_on_shortcut_pressed)
		if _hud.has_signal("equipment_changed") and not _hud.equipment_changed.is_connected(_on_equipment_changed):
			_hud.equipment_changed.connect(_on_equipment_changed)
		if _hud.has_signal("end_game_requested") and not _hud.end_game_requested.is_connected(_on_options_end_game_requested):
			_hud.end_game_requested.connect(_on_options_end_game_requested)
		if _hud.has_signal("game_speed_changed") and not _hud.game_speed_changed.is_connected(_on_game_speed_changed):
			_hud.game_speed_changed.connect(_on_game_speed_changed)


func _physics_process(delta: float) -> void:
	_update_camera()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		follow_held_mouse(get_global_mouse_position(), get_viewport().get_mouse_position())
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)
	_tick_player_damage_label(delta)
	_tick_loot_toast(delta)
	_tick_camera_shake(delta)
	_tick_enemies(delta)
	_tick_enemy_spawns(delta)
	_tick_player_auto_attack(delta)
	_update_combat_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _hud_blocks_world_mouse(event.position):
			return
		stop_auto_attack()
		move_player_to(get_global_mouse_position())


func toggle_inventory_window() -> void:
	if _hud:
		_hud.toggle_inventory_window()


func close_inventory_window() -> void:
	if _hud:
		_hud.close_inventory_window()


func stop_auto_attack() -> void:
	player_target_enemy_instance_id = ""
	player_target_attack_ready = false
	player_attack_timer = 0.0


func player_target_id() -> String:
	return player_target_enemy_instance_id


func has_enemy(instance_id: String) -> bool:
	return enemy_states.has(instance_id)


func enemy_ids() -> Array:
	return enemy_states.keys()


func enemy_state(instance_id: String):
	return enemy_states.get(instance_id, null)


func enemy_view(instance_id: String):
	return enemy_views.get(instance_id, null)


func enemy_definition(enemy_id: String):
	return enemy_definitions[enemy_id]


func player_node() -> CharacterBody2D:
	return _player


func behavior_system():
	return _runtime.behavior


func combat_system():
	return _runtime.combat


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


func engage_enemy(instance_id: String) -> void:
	if not enemy_states.has(instance_id):
		return
	player_target_enemy_instance_id = instance_id
	player_target_attack_ready = false
	var state = enemy_states[instance_id]
	var view := enemy_views.get(instance_id, null) as Node2D
	if view:
		move_player_to(_attack_point_for_enemy(view.global_position))


func _tick_player_auto_attack(delta: float) -> void:
	_runtime.combat_controller.tick_player_auto_attack(self, delta)


func _tick_enemies(delta: float) -> void:
	_runtime.combat_controller.tick_enemies(self, delta)


func _attack_point_for_enemy(enemy_position: Vector2) -> Vector2:
	return attack_point_for_enemy(enemy_position)


func attack_point_for_enemy(enemy_position: Vector2) -> Vector2:
	var from_enemy := _player.global_position - enemy_position
	var direction := from_enemy.normalized() if from_enemy != Vector2.ZERO else Vector2.LEFT
	return enemy_position + direction * ENEMY_APPROACH_DISTANCE


func _move_enemy_with_collision(state, next_position: Vector2, fallback_position: Vector2 = Vector2.INF) -> void:
	move_enemy_with_collision(state, next_position, fallback_position)


func move_enemy_with_collision(state, next_position: Vector2, fallback_position: Vector2 = Vector2.INF) -> void:
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
	return player_combat_dict()


func player_combat_dict() -> Dictionary:
	return {
		"life": player_life,
		"max_life": player_max_life,
		"attack": player_attack + _runtime.equipment_stats.attack_bonus_for_weapon(_equipped_weapon_id()),
		"defense": player_defense + _runtime.equipment_stats.defense_bonus_for_armor(_equipped_armor_id()),
		"xp": player_xp,
	}


func _apply_player_combat_dict(next_player: Dictionary) -> void:
	apply_player_combat_dict(next_player)


func apply_player_combat_dict(next_player: Dictionary) -> void:
	player_life = int(next_player.get("life", player_life))
	player_max_life = int(next_player.get("max_life", player_max_life))
	player_life = clampi(player_life, 0, player_max_life)
	_sync_profile_player()


func _spawn_initial_slime() -> void:
	_runtime.spawn_controller.setup(self)


func _tick_enemy_spawns(delta: float) -> void:
	_runtime.spawn_controller.tick(self, delta)


func _spawn_active_enemy_slots() -> void:
	_runtime.spawn_controller.spawn_active_slots(self)


func _current_enemy_positions() -> Array[Vector2]:
	return current_enemy_positions()


func current_enemy_positions() -> Array[Vector2]:
	return _runtime.spawn_controller.current_enemy_positions(enemy_views)


func _random_enemy_spawn_position(occupied: Array[Vector2]) -> Vector2:
	return _runtime.spawn_controller.random_enemy_spawn_position(self, occupied)


func enemy_spawn_rect() -> Rect2:
	var zone := get_node_or_null("SpawnZones/Grassland") as ColorRect
	if zone == null:
		return Rect2(Vector2(380, 300), Vector2(1260, 620))
	return Rect2(Vector2(zone.offset_left, zone.offset_top), Vector2(zone.offset_right - zone.offset_left, zone.offset_bottom - zone.offset_top))


func _is_spawn_position_clear(candidate: Vector2, occupied: Array[Vector2]) -> bool:
	return is_spawn_position_clear(candidate, occupied)


func is_spawn_position_clear(candidate: Vector2, occupied: Array[Vector2]) -> bool:
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
	var definition = ENEMY_LIBRARY_SCRIPT.for_id(enemy_id)
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
	remove_enemy(instance_id)


func remove_enemy(instance_id: String) -> void:
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
		player_target_attack_ready = false


func _update_enemy_view(state) -> void:
	update_enemy_view(state)


func update_enemy_view(state) -> void:
	var view = enemy_views.get(state.instance_id, null)
	if view:
		view.update_from_state(state)


func _ensure_combat_ui() -> void:
	_player_damage_label = _player.get_node_or_null("DamageLabel") as Label
	if _player_damage_label == null:
		_player_damage_label = Label.new()
		_player_damage_label.name = "DamageLabel"
		_player_damage_label.position = Vector2(-10, -96)
		_player_damage_label.add_theme_font_size_override("font_size", 24)
		_player_damage_label.visible = false
		_player.add_child(_player_damage_label)
	_player_damage_text = _player.get_node_or_null("DamageTextComponent")
	if _player_damage_text == null:
		_player_damage_text = Node2D.new()
		_player_damage_text.name = "DamageTextComponent"
		_player_damage_text.set_script(DAMAGE_TEXT_SCRIPT)
		_player.add_child(_player_damage_text)
	_player_damage_text.label_name = "DamageLabel"
	_player_damage_text.randomize_side = false
	_player_damage_text.arc_side = -1.0
	if _player_damage_text.has_method("ensure_ready"):
		_player_damage_text.ensure_ready()
	_loot_toast_label = get_node_or_null("UI/LootToast") as Label
	if _loot_toast_label == null:
		_loot_toast_label = Label.new()
		_loot_toast_label.name = "LootToast"
		_loot_toast_label.offset_left = 28.0
		_loot_toast_label.offset_top = 166.0
		_loot_toast_label.offset_right = 460.0
		_loot_toast_label.offset_bottom = 206.0
		_loot_toast_label.add_theme_font_size_override("font_size", 24)
		_loot_toast_label.visible = false
		$UI.add_child(_loot_toast_label)


func _show_player_damage(damage: int) -> void:
	show_player_damage(damage)


func show_player_damage(damage: int) -> void:
	if _player_damage_text and _player_damage_text.has_method("show_damage"):
		_player_damage_text.show_damage(damage, Color(1.0, 0.2, 0.2, 1.0))
	elif _player_damage_label:
		_player_damage_label.text = str(damage)
		_player_damage_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
		_player_damage_label.visible = true
	_player_damage_timer = 0.75


func _tick_player_damage_label(delta: float) -> void:
	if _player_damage_timer <= 0.0:
		return
	_player_damage_timer -= delta
	if _player_damage_timer <= 0.0 and _player_damage_label:
		_player_damage_label.visible = false


func _show_loot_toast(text: String) -> void:
	if _loot_toast_label:
		_loot_toast_label.text = text
		_loot_toast_label.visible = true
		_loot_toast_timer = LOOT_TOAST_DURATION


func _tick_loot_toast(delta: float) -> void:
	if _loot_toast_timer <= 0.0:
		return
	_loot_toast_timer -= delta
	if _loot_toast_timer <= 0.0 and _loot_toast_label:
		_loot_toast_label.visible = false


func _update_combat_ui() -> void:
	if _hud:
		_hud.set_life(player_life, player_max_life)


func _grant_enemy_drops(state) -> void:
	grant_enemy_drops(state)


func grant_enemy_drops(state) -> void:
	for drop in state.drop_table:
		if not _drop_succeeds(drop):
			continue
		var item_id := str(drop.get("item_id", ""))
		var quantity := int(drop.get("quantity", 1))
		if inventory.add_item(item_id, quantity):
			record_item_gathered(item_id, quantity)
			_show_loot_toast("+ %s x%d" % [item_id, quantity])
			_play_feedback_sfx("loot_drop")


func _on_shortcut_pressed(_slot_number: int, item_id: String) -> void:
	if item_id == "apple":
		_use_apple()


func _on_equipment_changed() -> void:
	_update_player_age_sprite()
	_update_combat_ui()
	_play_feedback_sfx("equip_item")


func _use_apple() -> bool:
	if inventory == null or not inventory.has_method("quantity") or inventory.quantity("apple") <= 0:
		_show_loot_toast("No apple")
		return false
	if player_life >= player_max_life:
		_show_loot_toast("Life is full")
		return false
	if not inventory.has_method("consume_item") or not inventory.consume_item("apple", 1):
		_show_loot_toast("No apple")
		return false
	var before := player_life
	player_life = mini(player_max_life, player_life + APPLE_HEAL_AMOUNT)
	_update_combat_ui()
	if _hud and _hud.has_method("set_inventory_model"):
		_hud.set_inventory_model(_inventory_model_for_hud())
	_show_loot_toast("Used apple +%d Life" % [player_life - before])
	_play_feedback_sfx("apple_use")
	return true


func _drop_succeeds(drop: Dictionary, roll: int = -1) -> bool:
	var resolved_roll := roll if roll > 0 else forced_drop_roll
	return _runtime.drop_system.succeeds(drop, resolved_roll, _drop_rng)


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
		if QuestSystem.has_certification("swordsman_certification"):
			_dialog_view.show_dialog("Forest Path", FOREST_TO_BE_CONTINUED, false, false)
			return
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
		if QuestSystem.has_certification("swordsman_certification"):
			_play_feedback_sfx("forest_open")
			request_scene(FOREST_PATH)
			return
		_open_dialog(_forest_guard)


func request_scene(scene_path: String) -> void:
	requested_scene_path = scene_path
	if is_inside_tree():
		call_deferred("_change_scene_to_file", scene_path)


func _on_options_end_game_requested() -> void:
	Engine.time_scale = 1.0
	request_scene(MAIN_MENU_PATH)


func _on_game_speed_changed(speed_id: String) -> void:
	Engine.time_scale = SETTINGS_SCRIPT.multiplier_for_game_speed(speed_id)


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	_runtime.camera_controller.update_camera(camera, _player, CAMERA_OFFSET)


func _start_camera_shake() -> void:
	start_camera_shake()


func start_camera_shake() -> void:
	_runtime.camera_controller.start_shake()


func is_camera_shaking() -> bool:
	return _runtime.camera_controller.is_shaking()


func _tick_camera_shake(delta: float) -> void:
	_runtime.camera_controller.tick_shake(delta)


func _camera_shake_offset() -> Vector2:
	return _runtime.camera_controller.camera_shake_offset()


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


func record_enemy_defeat(enemy_id: String) -> void:
	if QuestSystem.record_enemy_defeated(enemy_id):
		_update_quest_window()


func record_item_gathered(item_id: String, quantity: int = 1) -> void:
	if QuestSystem.record_item_gathered(item_id, quantity):
		_update_quest_window()


func _update_player_age_sprite() -> void:
	if _runtime == null or _runtime.player_aging == null:
		return
	var sprite := _player.get_node_or_null("Sprite") as Sprite2D
	if sprite:
		sprite.texture = _load_texture(_runtime.player_aging.texture_path_for_max_hp_and_equipment(player_max_life, _equipped_weapon_id(), _equipped_armor_id()))


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


func _reach_forest_guard_checkpoint() -> void:
	if QuestSystem.has_certification("swordsman_certification"):
		return
	if QuestSystem.current_main_objective_id() == "enter_forest":
		return
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	if QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification"):
		_play_feedback_sfx("quest_update")
	_update_quest_window()


func _player_movement() -> CharacterMovement:
	return player_movement()


func player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement


func player_attack_ready_range() -> float:
	return PLAYER_ATTACK_READY_RANGE


func player_attack_leash_range() -> float:
	return PLAYER_ATTACK_LEASH_RANGE


func player_attack_animation_style() -> String:
	if _equipped_weapon_id() == "training_sword":
		return "thrust"
	return "slash"


func is_player_target_attack_ready() -> bool:
	return player_target_attack_ready


func mark_player_target_attack_ready() -> void:
	player_target_attack_ready = true


func clear_player_target_attack_ready() -> void:
	player_target_attack_ready = false


func _inventory_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/InventorySystem")


func _inventory_model_for_hud():
	var system := _inventory_system()
	if system:
		return system.model()
	return inventory


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


func _feedback_system() -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/FeedbackSystem")
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("FeedbackSystem")


func _profile_system() -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/ProfileSystem")
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("ProfileSystem")


func _sync_profile_player() -> void:
	var profile := _profile_system()
	if profile == null or not profile.has_method("player"):
		return
	var profile_player = profile.player()
	if profile_player == null:
		return
	profile_player.max_hp = player_max_life


func _play_feedback_sfx(sfx_name: String) -> void:
	play_feedback_sfx(sfx_name)


func play_feedback_sfx(sfx_name: String) -> void:
	var system := _feedback_system()
	if system and system.has_method("play_sfx"):
		system.play_sfx(sfx_name)
