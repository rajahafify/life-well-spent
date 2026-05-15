# tests/specs/npc_controller_test.gd
# Spec: NpcController interaction faces explicit player target and syncs state/view

class_name TestNpcController
extends TestCase


func test_interact_with_player_faces_right_when_player_is_right() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	var sprite: CharacterMovement = npc.get_node("Sprite") as CharacterMovement
	sprite._ready()
	npc._ready()
	assert_true(npc.has_method("interact_with_player"), "NpcController should expose interact_with_player(target_pos)")
	if not npc.has_method("interact_with_player"):
		npc.free()
		return
	npc.global_position = Vector2.ZERO
	npc.call("interact_with_player", Vector2(100, 0))
	assert_eq("interacting", npc.npc_state.state)
	assert_eq("right", npc.npc_state.facing)
	assert_eq(Vector2i(1, 11), sprite.frame_coords)
	npc.free()


func test_interact_with_player_faces_up_when_player_is_above() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	var sprite: CharacterMovement = npc.get_node("Sprite") as CharacterMovement
	sprite._ready()
	npc._ready()
	assert_true(npc.has_method("interact_with_player"), "NpcController should expose interact_with_player(target_pos)")
	if not npc.has_method("interact_with_player"):
		npc.free()
		return
	npc.global_position = Vector2.ZERO
	npc.call("interact_with_player", Vector2(0, -100))
	assert_eq("up", npc.npc_state.facing)
	assert_eq(Vector2i(1, 8), sprite.frame_coords)
	npc.free()


func test_interact_signal_emits_npc_instance() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	npc._ready()
	var emitted: Array = []
	npc.interacted.connect(func(actor): emitted.append(actor))
	npc.interact_with_player(Vector2(100, 0))
	assert_eq(1, emitted.size())
	assert_eq(npc, emitted[0])
	npc.free()


func test_npc_scene_does_not_emit_interaction_from_proximity() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	npc._ready()
	var emitted: Array = []
	npc.interacted.connect(func(actor): emitted.append(actor))
	assert_null(npc.get_node_or_null("Proximity"), "NPC scene should not include proximity dialog trigger")
	assert_eq(0, emitted.size())
	npc.free()


func test_npc_exposes_dialog_metadata_defaults() -> void:
	var npc := NpcController.new()
	assert_eq("NPC", npc.display_name)
	assert_eq("generic", npc.role)
	assert_eq("", npc.quest_name)
	npc.free()


func test_is_player_in_talk_range_true_inside_radius() -> void:
	var npc := NpcController.new()
	npc.global_position = Vector2(100, 100)
	assert_true(npc.has_method("is_player_in_talk_range"), "NpcController should expose range query")
	if npc.has_method("is_player_in_talk_range"):
		assert_true(npc.call("is_player_in_talk_range", Vector2(150, 100)))
	npc.free()


func test_is_player_in_talk_range_false_outside_radius() -> void:
	var npc := NpcController.new()
	npc.global_position = Vector2(100, 100)
	assert_true(npc.has_method("is_player_in_talk_range"), "NpcController should expose range query")
	if npc.has_method("is_player_in_talk_range"):
		assert_false(npc.call("is_player_in_talk_range", Vector2(300, 100)))
	npc.free()


func test_talk_point_is_offset_from_npc_toward_player() -> void:
	var npc := NpcController.new()
	npc.global_position = Vector2.ZERO
	assert_true(npc.has_method("talk_point_for"), "NpcController should expose talk point helper")
	if not npc.has_method("talk_point_for"):
		npc.free()
		return
	var talk_point: Vector2 = npc.call("talk_point_for", Vector2(100, 0))
	assert_true(talk_point.x > 20.0, "talk point should sit outside solid collision")
	assert_true(talk_point.x < 60.0, "talk point should stay inside talk radius")
	assert_eq(0.0, talk_point.y)
	npc.free()


func test_npc_scene_hides_overhead_name_label() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	npc.display_name = "Guide"
	npc._ready()
	var label: Label = npc.get_node_or_null("NameLabel") as Label
	assert_not_null(label, "npc scene may keep NameLabel node for future hover labels")
	if label:
		assert_false(label.visible, "NPC name label should be hidden by default")
	npc.free()


func test_npc_controller_applies_exported_sprite_texture() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var npc: NpcController = scene.instantiate() as NpcController
	npc.sprite_texture = load("res://assets/npcs/guildmaster.png") as Texture2D
	npc._ready()
	var sprite: Sprite2D = npc.get_node("Sprite") as Sprite2D
	assert_true(sprite.texture.resource_path.ends_with("guildmaster.png"))
	npc.free()
