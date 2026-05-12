# tests/specs/slime_asset_viewer_test.gd
# Spec: AssetView - focused animated enemy asset viewer.

class_name TestAssetView
extends TestCase

const VIEWER_SCENE := "res://assets/asset-view.tscn"
const VIEW_ROOT := "Center/Panel/Margin/VBox"


func _instantiate_viewer():
	var scene: PackedScene = load(VIEWER_SCENE)
	assert_not_null(scene, "asset view scene should load")
	if scene == null:
		return null
	var root = scene.instantiate()
	if root.has_method("_ready"):
		root._ready()
	return root


func test_asset_view_scene_loads_with_expected_root() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_eq("AssetView", root.name)
	assert_true(root.get_script().resource_path.ends_with("asset_view.gd"))
	root.free()


func test_asset_view_scene_saves_single_preview_nodes() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_not_null(root.get_node_or_null(VIEW_ROOT + "/PreviewArea/AnimatedSprite2D"))
	assert_not_null(root.get_node_or_null(VIEW_ROOT + "/EnemySelector"))
	assert_not_null(root.get_node_or_null(VIEW_ROOT + "/AnimationButtons"))
	assert_null(root.get_node_or_null(VIEW_ROOT + "/GalleryScroll"), "all-sprite gallery belongs in assets-gallery.tscn")
	root.free()


func test_asset_view_loads_selected_enemy_metadata() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var sprite_set: Dictionary = root.load_sprite_set()
	assert_eq("slime_spiked", sprite_set["enemy_id"])
	assert_eq("Spiked Slime", sprite_set["display_name"])
	assert_has(sprite_set["animations"], "idle")
	root.enemy_id = "rat"
	sprite_set = root.load_sprite_set()
	assert_eq("rat", sprite_set["enemy_id"])
	assert_eq("Rat", sprite_set["display_name"])
	root.free()


func test_asset_view_content_is_centered() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var center := root.get_node_or_null("Center") as CenterContainer
	var panel := root.get_node_or_null("Center/Panel") as PanelContainer
	assert_not_null(center)
	assert_not_null(panel)
	if center:
		assert_eq(1.0, center.anchor_right)
		assert_eq(1.0, center.anchor_bottom)
	if panel:
		assert_eq(Vector2(520, 520), panel.custom_minimum_size)
	root.free()


func test_asset_view_has_single_sprite_defaulting_to_idle() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var sprite := root.get_node_or_null(VIEW_ROOT + "/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	assert_not_null(sprite)
	if sprite:
		assert_eq("idle", sprite.animation)
		assert_true(sprite.is_playing())
		assert_true(sprite.sprite_frames.has_animation("idle"))
		assert_eq("res://assets/enemies/Slime/slime_spiked_sprite_frames.tres", sprite.sprite_frames.resource_path)
	root.free()


func test_asset_view_has_enemy_selector_and_buttons_for_each_supported_animation() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var selector := root.get_node_or_null(VIEW_ROOT + "/EnemySelector") as OptionButton
	assert_not_null(selector)
	if selector:
		assert_true(selector.item_count >= 2)
		assert_eq("Spiked Slime", selector.get_item_text(0))
		assert_eq("Rat", selector.get_item_text(1))
	var buttons := root.get_node_or_null(VIEW_ROOT + "/AnimationButtons") as HBoxContainer
	assert_not_null(buttons)
	if buttons:
		var names: Array = []
		for child in buttons.get_children():
			names.append(child.name)
		for animation_name in ["idle", "run", "hit", "jump", "death", "ability"]:
			assert_in("%sButton" % animation_name.capitalize(), names)
	root.free()


func test_asset_view_buttons_switch_single_sprite_animation() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	root.play_animation("death")
	var sprite := root.get_node(VIEW_ROOT + "/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	assert_eq("death", sprite.animation)
	assert_false(sprite.sprite_frames.get_animation_loop("death"))
	root.play_animation("run")
	assert_eq("run", sprite.animation)
	assert_true(sprite.sprite_frames.get_animation_loop("run"))
	root.free()


func test_asset_view_can_switch_to_rat_and_rebuild_actions() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	root.select_enemy("rat")
	assert_eq("rat", root.enemy_id)
	var title := root.get_node(VIEW_ROOT + "/Title") as Label
	assert_eq("RAT Asset View", title.text)
	var sprite := root.get_node(VIEW_ROOT + "/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	assert_eq("idle", sprite.animation)
	assert_eq("res://assets/enemies/Rat/rat_sprite_frames.tres", sprite.sprite_frames.resource_path)
	var buttons := root.get_node(VIEW_ROOT + "/AnimationButtons") as HBoxContainer
	var names: Array = []
	for child in buttons.get_children():
		names.append(child.name)
	assert_in("AttackButton", names)
	assert_false("JumpButton" in names)
	root.free()


func test_asset_view_uses_metadata_frame_slicing() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var sprite_set: Dictionary = root.load_sprite_set()
	assert_eq(Vector2i(64, 64), sprite_set["frame_size"])
	assert_eq(4, root.frame_count_for_animation("idle"))
	assert_eq(8, root.frame_count_for_animation("death"))
	root.free()
