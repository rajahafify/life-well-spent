# tests/specs/scene_smoke_test.gd
# Spec: scene resources and player wiring

class_name TestSceneSmoke
extends TestCase


func test_legacy_demo_scene_is_removed() -> void:
	assert_false(ResourceLoader.exists("res://scenes/test_runner_scene.tscn"), "legacy demo scene should stay removed")
	assert_false(ResourceLoader.exists("res://scripts/controllers/demo_controller.gd"), "legacy demo controller should stay removed")


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
	assert_eq(AnimationController.COLUMNS, sprite.hframes, "player editor preview should slice LPC sheet columns")
	assert_eq(AnimationController.ROWS, sprite.vframes, "player editor preview should slice LPC sheet rows")
	assert_eq(Vector2i(1, 10), sprite.frame_coords, "player editor preview should show standing-down frame")
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
	assert_eq(AnimationController.COLUMNS, sprite.hframes, "npc editor preview should slice LPC sheet columns")
	assert_eq(AnimationController.ROWS, sprite.vframes, "npc editor preview should slice LPC sheet rows")
	assert_eq(Vector2i(1, 10), sprite.frame_coords, "npc editor preview should show standing-down frame")
	root.free()


func test_npc_scene_has_solid_collision_without_proximity_dialog_trigger() -> void:
	var scene: PackedScene = load("res://scenes/npc.tscn")
	assert_not_null(scene, "npc scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	var collision: CollisionShape2D = root.get_node("Collision") as CollisionShape2D
	assert_eq(20.0, collision.shape.radius, "solid NPC collision should be body-sized")
	assert_null(root.get_node_or_null("Proximity"), "NPC dialog should not trigger from proximity")
	root.free()


func test_town_scene_first_slice_dialog_opens() -> void:
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	assert_not_null(scene, "town scene should load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	root._ready()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var label: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	assert_eq("Guildmaster", label.text)
	root.free()
