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


func test_slime_asset_view_collects_slime_animation_paths() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var paths: Dictionary = root.slime_animation_paths()
	assert_has(paths, "idle")
	assert_has(paths, "run")
	assert_has(paths, "hit")
	assert_has(paths, "death")
	assert_eq("res://assets/enemies/Slime/Slime_Spiked_Idle.png", paths["idle"])
	assert_true(ResourceLoader.exists(paths["idle"]))
	root.free()


func test_slime_asset_view_builds_animated_previews() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var grid := root.get_node_or_null("Scroll/Margin/VBox/AnimationGrid") as GridContainer
	assert_not_null(grid, "slime asset view should have animation grid")
	if grid == null:
		root.free()
		return
	assert_true(grid.get_child_count() >= 5, "slime view should show several animation cards")
	var idle_card := root.get_node_or_null("Scroll/Margin/VBox/AnimationGrid/IdleCard")
	assert_not_null(idle_card, "idle card should exist")
	if idle_card:
		var preview := idle_card.get_node_or_null("PreviewArea") as Control
		assert_not_null(preview, "animation card should reserve a preview area")
		var sprite := idle_card.get_node("PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
		assert_not_null(sprite.sprite_frames)
		assert_true(sprite.sprite_frames.has_animation("idle"))
		assert_eq(4, sprite.sprite_frames.get_frame_count("idle"))
		assert_eq(Vector2(110, 80), sprite.position, "animated sprite should be centered in preview area")
		assert_true(sprite.is_playing())
	root.free()


func test_slime_asset_view_uses_64x64_frame_slicing() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_eq(Vector2i(64, 64), root.frame_size)
	assert_eq(4, root.frame_count_for_strip("res://assets/enemies/Slime/Slime_Spiked_Idle.png"))
	assert_eq(8, root.frame_count_for_strip("res://assets/enemies/Slime/Slime_Spiked_Death.png"))
	root.free()
