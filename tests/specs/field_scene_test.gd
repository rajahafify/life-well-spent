# tests/specs/field_scene_test.gd
# Spec: Field playable prototype scene structure and controller behavior.

class_name TestFieldScene
extends TestCase

const FIELD_SCENE := "res://scenes/field.tscn"
const FIELD_SCRIPT := "res://scripts/controllers/field.gd"
const TOWN_PATH := "res://scenes/town_scene.tscn"
const FOREST_GUARD_DIALOG := "Stop.\n\nThe Demon King is gone.\nBut old places do not become safe overnight.\n\nThe Forest remembers what we forgot.\nReturn to Town.\nEarn certification from the Swordsman Guild."

var root: Node


func setup() -> void:
	var scene: PackedScene = load(FIELD_SCENE)
	assert_not_null(scene, "Field scene should load")
	if scene:
		root = scene.instantiate()
		if root.has_method("_ready"):
			root._ready()


func teardown() -> void:
	if root:
		root.free()
		root = null


func test_field_scene_root_is_named_field() -> void:
	if root == null:
		return
	assert_eq("Field", root.name)


func test_field_controller_class_name_is_field() -> void:
	var file := FileAccess.open(FIELD_SCRIPT, FileAccess.READ)
	assert_not_null(file, "Field controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("class_name Field"))


func test_field_has_player_and_camera() -> void:
	if root == null:
		return
	var player := root.get_node_or_null("Player") as Node2D
	assert_not_null(player, "Field should have Player")
	assert_not_null(root.get_node_or_null("Camera2D"), "Field should have Camera2D")


func test_field_has_town_gateway_spawn_point_near_portal() -> void:
	if root == null:
		return
	var player := root.get_node_or_null("Player") as Node2D
	var town_gateway := root.get_node_or_null("TownGateway") as Node2D
	assert_not_null(town_gateway, "Field should have Town Gateway")
	var spawn := root.get_node_or_null("SpawnPoints/FromTownGateway") as Marker2D
	assert_not_null(spawn, "Field should have named spawn point for Town gateway arrivals")
	if player and town_gateway and spawn:
		assert_eq(spawn.global_position, player.global_position)
		assert_true(spawn.global_position.distance_to(town_gateway.global_position) <= 180.0, "Field spawn should sit close to Town portal")
		assert_true(spawn.global_position.distance_to(town_gateway.global_position) > 64.0, "Field spawn should not auto-trigger Town portal")


func test_field_has_forest_gateway_and_grassland_spawn_zone() -> void:
	if root == null:
		return
	assert_not_null(root.get_node_or_null("ForestGateway"), "Field should have Forest Gateway")
	assert_not_null(root.get_node_or_null("SpawnZones/Grassland"), "Field should have explicit enemy spawn zone")


func test_field_uses_shared_hud_without_scene_specific_objective_label() -> void:
	if root == null:
		return
	var hud := root.get_node_or_null("UI")
	assert_true(hud != null and hud.has_method("set_life") and hud.has_method("show_quest"), "Field should use the shared gameplay HUD")
	assert_null(root.get_node_or_null("UI/ObjectivePrompt"), "Field should not own a scene-specific objective HUD label")


func test_field_quest_window_renders_current_objective() -> void:
	if root == null:
		return
	var quest_window := root.get_node_or_null("UI/QuestWindow") as PanelContainer
	var quest_label := root.get_node_or_null("UI/QuestWindow/VBox/ObjectiveLabel") as Label
	assert_not_null(quest_window, "Field should have a dedicated Quest Window")
	assert_not_null(quest_label, "Quest Window should show current objective")
	if quest_window and quest_label:
		assert_true(quest_window.visible)
		assert_eq(1.0, quest_window.anchor_right)
		assert_eq(-28.0, quest_window.offset_right)
		assert_eq("Explore the World\nFind the Forest path.", quest_label.text)


func test_field_inventory_button_starts_with_hidden_inventory_window() -> void:
	if root == null:
		return
	var inventory_button := root.get_node_or_null("UI/InventoryButton") as Button
	var inventory_window := root.get_node_or_null("UI/InventoryWindow") as PanelContainer
	assert_not_null(inventory_button, "Field should have an inventory HUD button")
	assert_not_null(inventory_window, "Field should instance the reusable inventory window")
	if inventory_button and inventory_window:
		assert_eq("Inventory", inventory_button.text)
		assert_false(inventory_window.visible)


func test_field_instances_tiny_town_field_map() -> void:
	if root == null:
		return
	var map := root.get_node_or_null("FieldMap") as Node2D
	var collision := root.get_node_or_null("FieldCollision") as Node2D
	assert_not_null(map, "Field should instance generated field map")
	assert_not_null(collision, "Field should instance generated field collision")
	if map:
		assert_eq("res://scenes/maps/field_map.tscn", map.scene_file_path)
		assert_eq(Vector2.ZERO, map.position)
		assert_eq(Vector2(1, 1), map.scale)
	if collision:
		assert_eq("res://scenes/maps/field_collision.tscn", collision.scene_file_path)
		assert_eq(Vector2.ZERO, collision.position)
		assert_eq(Vector2(1, 1), collision.scale)
		assert_true(collision.get_child_count() > 0, "Field collision should include blockers")


func test_town_gateway_sits_at_north_road_entry() -> void:
	if root == null:
		return
	var gateway := root.get_node_or_null("TownGateway") as Node2D
	var spawn := root.get_node_or_null("SpawnPoints/FromTownGateway") as Marker2D
	var player := root.get_node_or_null("Player") as Node2D
	assert_not_null(gateway, "Field should have Town gateway")
	assert_not_null(spawn, "Field should have Town gateway spawn")
	if gateway and spawn and player:
		assert_eq(Vector2(1552, 64), gateway.position)
		assert_eq(Vector2(1552, 160), spawn.position)
		assert_eq(spawn.global_position, player.global_position)
		assert_true(spawn.global_position.distance_to(gateway.global_position) > 64.0, "Player should start clear of the portal trigger")


func test_forest_guard_and_gate_are_at_southeast_road_end() -> void:
	if root == null:
		return
	var gate := root.get_node_or_null("ForestGateway") as Node2D
	var guard := root.get_node_or_null("ForestGuard") as Node2D
	assert_not_null(gate, "Field should have ForestGateway")
	assert_not_null(guard, "Field should have ForestGuard")
	assert_true(root.get_node_or_null("ForestBlocker") == null, "FieldCollision should own blockers instead of a visible ForestBlocker bar")
	if gate and guard:
		assert_eq(Vector2(2768, 2112), gate.position)
		assert_eq(Vector2(2768, 2000), guard.position)


func test_enemy_movement_rejects_field_collision_blockers() -> void:
	if root == null:
		return
	var collision_root := root.get_node_or_null("FieldCollision") as Node2D
	assert_not_null(collision_root, "Field should have generated collision")
	assert_true(root.has_method("_move_enemy_with_collision"), "Field should route enemy movement through collision")
	if collision_root == null or not root.has_method("_move_enemy_with_collision"):
		return
	var blocker := StaticBody2D.new()
	blocker.name = "SpecEnemyBlocker"
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 96)
	shape_node.shape = shape
	blocker.add_child(shape_node)
	collision_root.add_child(blocker)
	blocker.global_position = Vector2(600, 500)
	var state = root.enemy_state("field_slime_001")
	var view := root.enemy_view("field_slime_001") as Node2D
	state.position = Vector2(500, 500)
	view.global_position = state.position
	root._move_enemy_with_collision(state, Vector2(600, 500))
	assert_eq(Vector2(500, 500), state.position)
	assert_eq(Vector2(500, 500), view.global_position)
	blocker.free()


func test_field_starts_with_slime_bat_and_rat_enemies() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	assert_not_null(slime, "Field should show first Slime enemy")
	assert_eq(9, root.get_node("Enemies").get_child_count(), "Field should start with Slimes, Bats, and Rats")
	if slime:
		assert_eq("slime_spiked", slime.enemy_id)
	var bat = root.get_node("Enemies/Bat")
	var rat = root.get_node("Enemies/Rat")
	assert_eq("bat", bat.enemy_id)
	assert_eq("rat", rat.enemy_id)


func test_field_enemy_spawn_positions_are_inside_grassland_zone() -> void:
	if root == null:
		return
	var spawn_rect: Rect2 = root.enemy_spawn_rect()
	assert_eq(Rect2(Vector2(380, 300), Vector2(2480, 1640)), spawn_rect)
	for enemy in root.get_node("Enemies").get_children():
		assert_true(spawn_rect.has_point(enemy.global_position))
		assert_true(enemy.global_position.distance_to(root.get_node("TownGateway").global_position) >= 260.0)


func test_field_bat_and_rat_use_sprite_frame_resources() -> void:
	if root == null:
		return
	var bat = root.get_node("Enemies/Bat")
	var rat = root.get_node("Enemies/Rat")
	assert_eq("res://assets/enemies/Bat/bat_sprite_frames.tres", bat.get_node("AnimatedSprite2D").sprite_frames.resource_path)
	assert_eq("res://assets/enemies/Rat/rat_sprite_frames.tres", rat.get_node("AnimatedSprite2D").sprite_frames.resource_path)


func test_field_shared_hud_shows_life_and_removes_legacy_inventory_text() -> void:
	if root == null:
		return
	var life_label := root.get_node_or_null("UI/LifeLabel") as Label
	var player_damage_label := root.get_node_or_null("Player/DamageLabel") as Label
	assert_not_null(life_label, "Shared HUD should show player Life text")
	assert_null(root.get_node_or_null("UI/InventoryLabel"), "Inventory text should live in the shared inventory window, not Field HUD")
	assert_not_null(player_damage_label, "Field should show RO-style damage text above Player")
	if life_label:
		assert_eq("Life: 100/100", life_label.text)


func test_field_enemy_feedback_components_are_attached_to_slime() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	assert_not_null(slime.get_node_or_null("HitFeedbackComponent"), "Enemy should own reusable hit feedback component")
	assert_not_null(slime.get_node_or_null("DamageTextComponent"), "Enemy should own reusable damage text component")


func test_field_slime_uses_hp_bar_instead_of_hp_text() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	var slime_hp_bar := slime.get_node_or_null("HpBar") as ProgressBar
	assert_not_null(slime_hp_bar, "Enemy HP should be shown as a bar")
	assert_null(slime.get_node_or_null("HpLabel"), "Enemy HP should not be shown as text")
	assert_null(root.get_node_or_null("UI/SlimeHpLabel"), "Field should not use the temporary enemy HP text HUD")
	if slime_hp_bar:
		assert_eq(0.0, slime_hp_bar.min_value)
		assert_eq(140.0, slime_hp_bar.max_value)
		assert_eq(140.0, slime_hp_bar.value)
		assert_false(slime_hp_bar.show_percentage)
		assert_eq(Vector2(-56, 90), slime_hp_bar.position)
		assert_eq(112.0, slime_hp_bar.size.x)
		assert_true(slime_hp_bar.scale.y <= 0.2, "enemy HP bar should render thin")
		assert_false(slime_hp_bar.visible, "enemy HP bar should stay hidden until the enemy is attacked")


func test_field_slime_sprite_and_collision_are_enlarged() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	var slime_sprite := slime.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	var slime_collision := slime.get_node_or_null("CollisionShape2D") as CollisionShape2D
	assert_not_null(slime_sprite, "Enemy should have a visible sprite")
	assert_not_null(slime_collision, "Enemy should have click/spacing collision")
	if slime_sprite:
		assert_eq(Vector2(4, 4), slime_sprite.scale)
	if slime_collision and slime_collision.shape is CircleShape2D:
		assert_true((slime_collision.shape as CircleShape2D).radius >= 76.0, "enemy collision should be larger than the enlarged sprite footprint")


func test_field_uses_game_wide_enemy_spawn_manager() -> void:
	var file := FileAccess.open(FIELD_SCRIPT, FileAccess.READ)
	assert_not_null(file, "Field controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("EnemySpawnManager"), "Field should use the game-wide enemy spawn manager")
	assert_true(source.contains("_tick_enemy_spawns"), "Field should poll respawns while the scene remains loaded")
	var combat_file := FileAccess.open("res://scripts/controllers/field_combat_controller.gd", FileAccess.READ)
	assert_not_null(combat_file, "Field combat controller script should exist")
	if combat_file:
		var combat_source := combat_file.get_as_text()
		combat_file.close()
		assert_true(combat_source.contains("mark_defeated"), "Field combat controller should mark defeated enemy slots globally")


func test_field_uses_quest_system_for_forest_gate_progress() -> void:
	var file := FileAccess.open(FIELD_SCRIPT, FileAccess.READ)
	assert_not_null(file, "Field controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("QuestSystem"), "Field should use the game-wide quest system")
	assert_true(source.contains("get_swordsman_certification"), "Forest gate should advance the main quest objective")


func test_inventory_button_and_i_key_toggle_inventory_window() -> void:
	if root == null:
		return
	var button := root.get_node("UI/InventoryButton") as Button
	var window := root.get_node("UI/InventoryWindow") as PanelContainer
	assert_false(window.visible)
	button.pressed.emit()
	assert_true(window.visible)
	button.pressed.emit()
	assert_false(window.visible)
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_I
	root.get_node("UI")._unhandled_input(event)
	assert_true(window.visible)


func test_shortcut_one_uses_apple_to_heal_life_and_consume_item() -> void:
	if root == null:
		return
	root.inventory.add_item("apple", 2)
	root.player_life = 65
	root.player_max_life = 100
	var hud := root.get_node("UI")
	hud.shortcut_pressed.emit(1, "apple")
	assert_eq(85, root.player_life)
	assert_eq(1, root.inventory.quantity("apple"))
	assert_eq("Life: 85/100", (root.get_node("UI/LifeLabel") as Label).text)
	var loot_toast := root.get_node("UI/LootToast") as Label
	assert_true(loot_toast.visible)
	assert_eq("Used apple +20 Life", loot_toast.text)


func test_shortcut_one_without_apple_shows_feedback() -> void:
	if root == null:
		return
	root.player_life = 65
	root.get_node("UI").shortcut_pressed.emit(1, "apple")
	var loot_toast := root.get_node("UI/LootToast") as Label
	assert_true(loot_toast.visible)
	assert_eq("No apple", loot_toast.text)
	assert_eq(65, root.player_life)


func test_field_respawns_enemy_after_global_timer_while_loaded() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	assert_not_null(slime, "Field should start with Slime")
	if slime == null:
		return
	root.get_node("Player").global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.enemy_state("field_slime_001").hp = 1
	root.forced_drop_roll = 5
	root.engage_enemy("field_slime_001")
	root._physics_process(1.1)
	root._physics_process(0.8)
	assert_false(root.has_enemy("field_slime_001"))
	assert_eq(8, root.get_node("Enemies").get_child_count())
	EnemySpawnManager._process(60.0)
	root._physics_process(1.0)
	assert_true(root.has_enemy("field_slime_001"))
	assert_eq(9, root.get_node("Enemies").get_child_count())


func test_clicking_slime_engages_and_moves_player_toward_slime() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	var movement = root.get_node("Player/Sprite")
	movement._ready()
	player.global_position = Vector2(200, 700)
	slime.global_position = Vector2(700, 700)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	assert_eq("field_slime_001", root.player_target_id())
	assert_false(root.enemy_state("field_slime_001").is_aggro, "targeted Slime should wait until first hit before aggro")
	assert_true(movement.moving)
	assert_eq(Vector2(604, 700), movement.destination)
	assert_true(movement.destination.distance_to(slime.global_position) >= 96.0, "player should stop outside the enlarged enemy footprint")


func test_auto_attack_damages_slime_and_reveals_hp_bar() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	assert_true(root.enemy_state("field_slime_001").hp < 140)
	var slime_hp_bar := slime.get_node("HpBar") as ProgressBar
	assert_eq(float(root.enemy_state("field_slime_001").hp), slime_hp_bar.value)
	assert_true(slime_hp_bar.visible, "enemy HP bar should appear after the enemy is attacked")
	assert_true(root.enemy_state("field_slime_001").is_aggro)
	assert_true(root.is_camera_shaking(), "player hit should start a small camera shake")


func test_enemy_attack_damages_player_life_and_shows_red_damage() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	root._physics_process(1.5)
	assert_true(root.player_life < 100)
	assert_true(root.is_camera_shaking(), "enemy hit should also start a small camera shake")
	var player_damage_label := root.get_node("Player/DamageLabel") as Label
	assert_true(player_damage_label.visible)
	assert_eq("1", player_damage_label.text)
	assert_eq(Color(1.0, 0.2, 0.2, 1.0), player_damage_label.get_theme_color("font_color"), "player damage should be red")


func test_auto_attack_shows_white_enemy_hit_text_and_flash() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	var hit_label := slime.get_node("HitLabel") as Label
	assert_true(hit_label.visible)
	assert_eq("30", hit_label.text)
	assert_eq(Color.WHITE, hit_label.get_theme_color("font_color"), "enemy damage should be white")
	assert_neq(Color(1, 1, 1, 1), slime.modulate, "enemy should briefly flash on hit")


func test_auto_attack_plays_visible_slash_animation() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	var movement = root.get_node("Player/Sprite")
	assert_eq("attacking", movement._anim.state)
	assert_eq("slash", movement._anim.attack_style)
	root._physics_process(0.016)
	assert_eq("attacking", movement._anim.state, "movement stop should not cancel visible slash animation")


func test_player_can_stop_auto_attack_by_moving_away() -> void:
	if root == null:
		return
	root.engage_enemy("field_slime_001")
	assert_eq("field_slime_001", root.player_target_id())
	root.stop_auto_attack()
	assert_eq("", root.player_target_id())


func test_aggro_slime_chases_player_when_player_moves_away() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(760, 500)
	slime.global_position = Vector2(790, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	player.global_position = Vector2(1040, 500)
	root._physics_process(0.5)
	assert_eq("chase", root.enemy_state("field_slime_001").behavior_state)
	assert_true(slime.global_position.x > 790.0)


func test_slime_dies_plays_death_before_removal() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_state("field_slime_001").position = slime.global_position
	root.enemy_state("field_slime_001").hp = 1
	root.forced_drop_roll = 5
	root.engage_enemy("field_slime_001")
	root._physics_process(1.1)
	assert_true(root.has_enemy("field_slime_001"))
	assert_not_null(root.get_node_or_null("Enemies/Slime"))
	assert_eq("die", root.enemy_state("field_slime_001").behavior_state)
	var sprite := slime.get_node("AnimatedSprite2D") as AnimatedSprite2D
	assert_eq("death", sprite.animation)
	assert_eq(5, root.player_xp)
	assert_eq(1, root.inventory.quantity("slime_gel"))
	assert_true(root.has_method("_drop_succeeds"), "Field should roll chance-based drops")
	assert_true(root._drop_succeeds({"chance_numerator": 1, "chance_denominator": 5}, 1))
	assert_false(root._drop_succeeds({"chance_numerator": 1, "chance_denominator": 5}, 2))
	assert_true(root._drop_succeeds({"item_id": "slime_gel"}, 5), "Drops without chance fields should stay guaranteed")
	var loot_toast := root.get_node("UI/LootToast") as Label
	assert_true(loot_toast.visible)
	assert_eq("+ slime_gel x1", loot_toast.text)
	root.toggle_inventory_window()
	var item_list := root.get_node("UI/InventoryWindow/VBox/ItemList") as VBoxContainer
	assert_eq("slime_gel x1", (item_list.get_child(0) as Label).text)
	root._physics_process(1.7)
	assert_false(loot_toast.visible)
	root._physics_process(0.8)
	assert_false(root.has_enemy("field_slime_001"))
	assert_null(root.get_node_or_null("Enemies/Slime"))


func test_field_has_forest_guard_dialog_copy() -> void:
	if root == null:
		return
	var guard := root.get_node_or_null("ForestGuard")
	assert_not_null(guard, "Field should have Forest Guard")
	if guard:
		assert_eq("Forest Guard", guard.display_name)
		assert_eq("forest_guard", guard.role)
		assert_eq(FOREST_GUARD_DIALOG, guard.dialog_text)


func test_legacy_field_art_primitives_are_removed_after_import() -> void:
	if root == null:
		return
	for node_path in [
		"Ground",
		"Paths",
		"ForestEdge",
		"Props",
	]:
		assert_true(root.get_node_or_null(node_path) == null, "%s should be replaced by imported FieldMap art" % node_path)
	var portal_visual := root.get_node_or_null("TownGateway/Visual") as Control
	assert_not_null(portal_visual, "Town gateway should keep its gameplay portal visual")
	if portal_visual:
		assert_eq(Control.MOUSE_FILTER_IGNORE, portal_visual.mouse_filter)


func test_field_routes_player_movement_and_camera_follow() -> void:
	if root == null:
		return
	var movement = root.get_node("Player/Sprite")
	movement._ready()
	var target := Vector2(820, 600)
	assert_true(root.move_player_to(target))
	assert_eq(target, movement.destination)
	assert_true(movement.moving)
	var player: Node2D = root.get_node("Player") as Node2D
	var camera: Camera2D = root.get_node("Camera2D") as Camera2D
	player.global_position = Vector2(1000, 600)
	root._physics_process(0.016)
	assert_eq(player.global_position + Vector2(0, -150), camera.global_position)


func test_field_follow_held_mouse_updates_player_destination() -> void:
	if root == null:
		return
	var movement = root.get_node("Player/Sprite")
	movement._ready()
	var target := Vector2(900, 560)
	assert_true(root.follow_held_mouse(target))
	assert_eq(target, movement.destination)


func test_far_forest_guard_click_moves_player_before_dialog() -> void:
	if root == null:
		return
	var guard = root.get_node("ForestGuard")
	var player: Node2D = root.get_node("Player") as Node2D
	var movement = root.get_node("Player/Sprite")
	movement._ready()
	player.global_position = Vector2(520, 780)
	guard.interacted.emit(guard)
	var dialog = root.get_node("UI/DialogPanel")
	assert_false(dialog.visible)
	assert_true(movement.moving)


func test_pending_guard_dialog_opens_when_player_reaches_talk_range() -> void:
	if root == null:
		return
	var guard = root.get_node("ForestGuard")
	var player: Node2D = root.get_node("Player") as Node2D
	player.global_position = Vector2(520, 780)
	guard.interacted.emit(guard)
	player.global_position = guard.global_position + Vector2(100, 0)
	root._physics_process(0.016)
	var dialog = root.get_node("UI/DialogPanel")
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	assert_true(dialog.visible)
	assert_eq("Forest Guard", title.text)
	assert_false(QuestSystem.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_eq("find_forest_path", QuestSystem.current_main_objective_id())
	var quest_label := root.get_node("UI/QuestWindow/VBox/ObjectiveLabel") as Label
	assert_eq("Explore the World\nFind the Forest path.", quest_label.text)


func test_guard_dialog_completion_updates_quest_window() -> void:
	if root == null:
		return
	var guard = root.get_node("ForestGuard")
	root.get_node("Player").global_position = guard.global_position + Vector2(40, 0)
	guard.interacted.emit(guard)
	var dialog = root.get_node("UI/DialogPanel")
	dialog.next_page()
	dialog.next_page()
	dialog.close_requested.emit()
	assert_true(QuestSystem.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_eq("get_swordsman_certification", QuestSystem.current_main_objective_id())
	var quest_label := root.get_node("UI/QuestWindow/VBox/ObjectiveLabel") as Label
	assert_eq("Explore the World\nGet Swordsman Certification.", quest_label.text)


func test_dialog_blocks_player_movement_and_pages() -> void:
	if root == null:
		return
	var guard = root.get_node("ForestGuard")
	root.get_node("Player").global_position = guard.global_position + Vector2(40, 0)
	guard.interacted.emit(guard)
	assert_false(root.move_player_to(Vector2(800, 500)))
	var dialog = root.get_node("UI/DialogPanel")
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_eq("Stop.", body.text)
	assert_false(close.visible)
	dialog.next_page()
	assert_true(body.text.contains("Demon King"))
	assert_false(close.visible)
	dialog.next_page()
	assert_true(body.text.contains("Forest remembers"))
	assert_false(next.visible)
	assert_true(close.visible)


func test_dialog_buttons_stick_to_bottom_right() -> void:
	if root == null:
		return
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var buttons: HBoxContainer = root.get_node("UI/DialogPanel/VBox/Buttons") as HBoxContainer
	assert_true((body.size_flags_vertical & Control.SIZE_EXPAND) == Control.SIZE_EXPAND)
	assert_eq(BoxContainer.ALIGNMENT_END, buttons.alignment)


func test_town_gateway_directly_requests_town_transition() -> void:
	if root == null:
		return
	var player: Node = root.get_node("Player")
	root._on_town_gateway_body_entered(player)
	assert_eq(TOWN_PATH, root.requested_scene_path)


func test_town_gateway_defers_scene_change_outside_physics_callback() -> void:
	var file := FileAccess.open(FIELD_SCRIPT, FileAccess.READ)
	assert_not_null(file, "Field controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("call_deferred(\"_change_scene_to_file\", scene_path)"))
	assert_true(source.contains("func _change_scene_to_file(scene_path: String) -> void:"))


func test_forest_gateway_stays_blocked_and_opens_guard_dialog() -> void:
	if root == null:
		return
	var player: Node = root.get_node("Player")
	root._on_forest_gateway_body_entered(player)
	assert_eq("", root.requested_scene_path)
	assert_false(QuestSystem.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_eq("find_forest_path", QuestSystem.current_main_objective_id())
	var dialog = root.get_node("UI/DialogPanel")
	assert_true(dialog.visible)


func test_forest_gateway_shows_to_be_continued_after_swordsman_certification() -> void:
	if root == null:
		return
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.complete_side_quest_chain("rebuilding_swordsman_guild")
	QuestSystem.advance_main_quest_objective("explore_the_world", "enter_forest")
	var player: Node = root.get_node("Player")
	root._on_forest_gateway_body_entered(player)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("", root.requested_scene_path)
	assert_true(body.text.contains("The path to forest is open."))
	assert_eq("enter_forest", QuestSystem.current_main_objective_id())


func test_forest_guard_interaction_after_certification_does_not_revert_objective() -> void:
	if root == null:
		return
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.complete_side_quest_chain("rebuilding_swordsman_guild")
	QuestSystem.advance_main_quest_objective("explore_the_world", "enter_forest")
	var guard: NpcController = root.get_node("ForestGuard") as NpcController
	root.get_node("Player").global_position = guard.global_position + Vector2(40, 0)
	guard.interacted.emit(guard)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("The path to forest is open."))
	root.close_dialog()
	assert_eq("enter_forest", QuestSystem.current_main_objective_id())
