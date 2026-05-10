# tests/specs/scene_smoke_test.gd
# Spec: scene resources and player wiring

class_name TestSceneSmoke
extends TestCase


func test_demo_scene_player_uses_character_movement() -> void:
	var scene: PackedScene = load("res://scenes/test_runner_scene.tscn")
	assert_not_null(scene, "demo scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	var player = root.get_node_or_null("Player")
	assert_not_null(player, "demo scene should have Player node")
	assert_true(player is CharacterMovement, "demo Player should use CharacterMovement script")
	root.free()


func test_player_scene_root_is_player_without_npc_controller() -> void:
	var scene: PackedScene = load("res://scenes/player.tscn")
	assert_not_null(scene, "player scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	assert_eq("Player", root.name, "player scene root should be named Player")
	assert_null(root.get_script(), "player root should not use NpcController")
	assert_null(root.get_node_or_null("Proximity"), "player scene should not include NPC proximity trigger")
	var sprite = root.get_node_or_null("Sprite")
	assert_true(sprite is CharacterMovement, "player Sprite should use CharacterMovement")
	root.free()
