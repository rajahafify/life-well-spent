# tests/specs/slime_asset_viewer_test.gd
# Spec: SlimeAssetView — focused animated Slime asset viewer.

class_name TestSlimeAssetViewer
extends TestCase

const VIEWER_SCENE := "res://assets/asset-view.tscn"
const VIEWER_SCRIPT := "res://assets/asset_view.gd"


func _instantiate_viewer():
	var scene: PackedScene = load(VIEWER_SCENE)
	assert_not_null(scene, "slime asset view scene should load")
	if scene == null:
		return null
	var root = scene.instantiate()
	if root.has_method("_ready"):
		root._ready()
	return root


func test_slime_asset_view_scene_loads_with_expected_root() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_eq("SlimeAssetView", root.name)
	assert_true(root.get_script().resource_path.ends_with("asset_view.gd"))
	root.free()


func test_slime_asset_view_loads_slime_spiked_metadata() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var sprite_set: Dictionary = root.load_sprite_set()
	assert_eq("slime_spiked", sprite_set["enemy_id"])
	assert_eq("Spiked Slime", sprite_set["display_name"])
	assert_has(sprite_set["animations"], "idle")
	assert_eq("res://assets/enemies/Slime/Slime_Spiked_Idle.png", sprite_set["animations"]["idle"]["texture_path"])
	root.free()


func test_slime_asset_view_has_single_sprite_defaulting_to_idle() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("Scroll/Margin/VBox/PreviewArea"), "single preview area should exist")
	var sprite := root.get_node_or_null("Scroll/Margin/VBox/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	assert_not_null(sprite, "single animated sprite should exist")
	if sprite:
		assert_eq("idle", sprite.animation)
		assert_true(sprite.is_playing())
		assert_true(sprite.sprite_frames.has_animation("idle"))
		assert_true(sprite.sprite_frames.has_animation("death"))
		assert_eq(4, sprite.sprite_frames.get_frame_count("idle"))
		assert_eq(Vector2(180, 120), sprite.position, "animated sprite should be centered in single preview area")
	assert_null(root.get_node_or_null("Scroll/Margin/VBox/AnimationGrid"), "old multi-card gallery should be removed")
	root.free()


func test_slime_asset_view_has_buttons_for_each_supported_animation() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var buttons := root.get_node_or_null("Scroll/Margin/VBox/AnimationButtons") as HBoxContainer
	assert_not_null(buttons, "animation buttons should exist")
	if buttons:
		var names: Array = []
		for child in buttons.get_children():
			names.append(child.name)
		for animation_name in ["idle", "run", "hit", "jump", "death", "ability"]:
			assert_in("%sButton" % animation_name.capitalize(), names)
	root.free()


func test_slime_asset_view_buttons_switch_single_sprite_animation() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	root.play_animation("death")
	var sprite := root.get_node("Scroll/Margin/VBox/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	assert_eq("death", sprite.animation)
	assert_false(sprite.sprite_frames.get_animation_loop("death"))
	root.play_animation("run")
	assert_eq("run", sprite.animation)
	assert_true(sprite.sprite_frames.get_animation_loop("run"))
	root.free()


func test_slime_asset_view_uses_metadata_frame_slicing() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var sprite_set: Dictionary = root.load_sprite_set()
	assert_eq(Vector2i(64, 64), sprite_set["frame_size"])
	assert_eq(4, root.frame_count_for_animation("idle"))
	assert_eq(8, root.frame_count_for_animation("death"))
	root.free()
