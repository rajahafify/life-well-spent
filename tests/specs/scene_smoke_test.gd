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


func test_npc_scene_sprite_is_static_without_marker() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	var sprite: CharacterMovement = root.get_node_or_null("Sprite") as CharacterMovement
	assert_not_null(sprite, "npc scene should have CharacterMovement Sprite")
	assert_true(sprite.is_static, "npc Sprite should be static")
	assert_eq(NodePath(""), sprite.marker_path, "npc Sprite should not control shared destination marker")
	root.free()


func test_npc_scene_collision_and_talk_range_radii() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	var collision: CollisionShape2D = root.get_node("Collision") as CollisionShape2D
	var area_collision: CollisionShape2D = root.get_node("Proximity/AreaCollision") as CollisionShape2D
	assert_eq(20.0, collision.shape.radius, "solid NPC collision should be body-sized")
	assert_eq(60.0, area_collision.shape.radius, "talk range should be wider than solid collision")
	root.free()


func test_town_scene_npc_interaction_updates_quest_label() -> void:
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	assert_not_null(scene, "town scene should load")
	if scene == null:
		return
	var root: TownSceneController = scene.instantiate() as TownSceneController
	root._ready()
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	root.get_player().global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var label: Label = root.get_node("UI/QuestLabel") as Label
	assert_eq("Talking to: QuestGiver", label.text)
	root.free()
