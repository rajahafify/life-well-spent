# tests/specs/field_scene_test.gd
# Spec: Field playable prototype scene structure and controller behavior.

class_name TestFieldScene
extends TestCase

const FIELD_SCENE := "res://scenes/field.tscn"
const FIELD_SCRIPT := "res://scripts/controllers/field.gd"
const FIELD_OBJECTIVE := "Objective: Find the Forest path."
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


func test_field_has_player_camera_gateways_and_objective() -> void:
	if root == null:
		return
	assert_not_null(root.get_node_or_null("Player"), "Field should have Player")
	assert_not_null(root.get_node_or_null("Camera2D"), "Field should have Camera2D")
	assert_not_null(root.get_node_or_null("TownGateway"), "Field should have Town Gateway")
	assert_not_null(root.get_node_or_null("ForestGateway"), "Field should have Forest Gateway")
	assert_not_null(root.get_node_or_null("ForestBlocker"), "Field should have Forest Blocker")
	var objective := root.get_node_or_null("UI/ObjectivePrompt") as Label
	assert_not_null(objective, "Field should have objective prompt")
	if objective:
		assert_eq(FIELD_OBJECTIVE, objective.text)
		assert_true(objective.visible)


func test_field_has_slime_and_simple_life_combat_text() -> void:
	if root == null:
		return
	var slime := root.get_node_or_null("Enemies/Slime")
	assert_not_null(slime, "Field should show first Slime enemy")
	assert_eq(5, root.get_node("Enemies").get_child_count(), "Field should start with five Slimes")
	if slime:
		assert_eq("slime_spiked", slime.enemy_id)
	var life_label := root.get_node_or_null("UI/LifeLabel") as Label
	var slime_label := root.get_node_or_null("UI/SlimeHpLabel") as Label
	var player_damage_label := root.get_node_or_null("Player/DamageLabel") as Label
	assert_not_null(life_label, "Field should show simple Life text")
	assert_not_null(slime_label, "Field should show simple Slime HP text")
	assert_not_null(player_damage_label, "Field should show RO-style damage text above Player")
	if life_label:
		assert_eq("Life: 100/100", life_label.text)
	if slime_label:
		assert_eq("Slime: 14/14", slime_label.text)


func test_clicking_slime_engages_and_moves_player_toward_slime() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	var movement = root.get_node("Player/Sprite")
	movement._ready()
	player.global_position = Vector2(200, 700)
	slime.global_position = Vector2(700, 700)
	root.engage_enemy("field_slime_001")
	assert_eq("field_slime_001", root.player_target_enemy_instance_id)
	assert_false(root.enemy_states["field_slime_001"].is_aggro, "targeted Slime should wait until first hit before aggro")
	assert_true(movement.moving)
	assert_eq(Vector2(656, 700), movement.destination)


func test_auto_attack_damages_slime_shows_hit_text_and_slime_damages_life() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	assert_true(root.enemy_states["field_slime_001"].hp < 14)
	assert_true(root.enemy_states["field_slime_001"].is_aggro)
	root._physics_process(1.5)
	assert_true(root.player_life < 100)
	var player_damage_label := root.get_node("Player/DamageLabel") as Label
	assert_true(player_damage_label.visible)
	assert_eq("1", player_damage_label.text)
	var hit_label := slime.get_node("HitLabel") as Label
	assert_true(hit_label.visible)
	assert_eq("3", hit_label.text)
	var movement = root.get_node("Player/Sprite")
	assert_eq("attacking", movement._anim.state)
	assert_eq("slash", movement._anim.attack_style)
	root._physics_process(0.016)
	assert_eq("attacking", movement._anim.state, "movement stop should not cancel visible slash animation")


func test_player_can_stop_auto_attack_by_moving_away() -> void:
	if root == null:
		return
	root.engage_enemy("field_slime_001")
	assert_eq("field_slime_001", root.player_target_enemy_instance_id)
	root.stop_auto_attack()
	assert_eq("", root.player_target_enemy_instance_id)


func test_aggro_slime_chases_player_when_player_moves_away() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.engage_enemy("field_slime_001")
	root._physics_process(1.5)
	player.global_position = Vector2(760, 500)
	root._physics_process(0.5)
	assert_eq("chase", root.enemy_states["field_slime_001"].behavior_state)
	assert_true(slime.global_position.x > 530.0)


func test_slime_dies_plays_death_before_removal() -> void:
	if root == null:
		return
	var player: Node2D = root.get_node("Player") as Node2D
	var slime: Node2D = root.get_node("Enemies/Slime") as Node2D
	player.global_position = Vector2(500, 500)
	slime.global_position = Vector2(530, 500)
	root.enemy_states["field_slime_001"].hp = 1
	root.engage_enemy("field_slime_001")
	root._physics_process(1.1)
	assert_true(root.enemy_states.has("field_slime_001"))
	assert_not_null(root.get_node_or_null("Enemies/Slime"))
	assert_eq("die", root.enemy_states["field_slime_001"].behavior_state)
	var sprite := slime.get_node("AnimatedSprite2D") as AnimatedSprite2D
	assert_eq("death", sprite.animation)
	assert_eq(5, root.player_xp)
	root._physics_process(0.8)
	assert_false(root.enemy_states.has("field_slime_001"))
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


func test_world_primitives_ignore_mouse_so_ground_clicks_move() -> void:
	if root == null:
		return
	for node_path in [
		"Ground",
		"Paths/MainPath",
		"Paths/ForestPath",
		"ForestEdge",
		"ForestBlocker/Visual",
		"TownGateway/Visual",
		"Props/Rock",
		"Props/Bush",
	]:
		var control := root.get_node(node_path) as Control
		assert_eq(Control.MOUSE_FILTER_IGNORE, control.mouse_filter, "%s should not consume ground clicks" % node_path)


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
	assert_eq("Stop.", body.text)
	dialog.next_page()
	assert_true(body.text.contains("Demon King"))
	dialog.next_page()
	assert_true(body.text.contains("Forest remembers"))
	assert_false(next.visible)


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
	var dialog = root.get_node("UI/DialogPanel")
	assert_true(dialog.visible)
