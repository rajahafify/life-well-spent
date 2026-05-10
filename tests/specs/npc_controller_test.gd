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
	assert_eq(Vector2i(0, 3), sprite.frame_coords)
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
	assert_eq(Vector2i(0, 0), sprite.frame_coords)
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
