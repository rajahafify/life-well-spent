# tests/specs/assets_viewer_test.gd
# Spec: AssetsViewer — enemy asset gallery scene.

class_name TestAssetsViewer
extends TestCase

const VIEWER_SCENE := "res://assets/assets-viewer.tscn"
const VIEWER_SCRIPT := "res://assets/assets_viewer.gd"


func _instantiate_viewer():
	var scene: PackedScene = load(VIEWER_SCENE)
	assert_not_null(scene, "assets viewer scene should load")
	if scene == null:
		return null
	var root = scene.instantiate()
	if root.has_method("_ready"):
		root._ready()
	return root


func test_assets_viewer_scene_loads_with_expected_root() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	assert_eq("AssetsViewer", root.name)
	assert_true(root.get_script().resource_path.ends_with("assets_viewer.gd"))
	root.free()


func test_assets_viewer_collects_enemy_png_assets() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var paths: Array = root.collect_asset_paths()
	assert_true(paths.size() >= 70, "viewer should catalog imported PNG strips")
	assert_in("res://assets/enemies/Bat/Bat_Fly.png", paths)
	assert_in("res://assets/enemies/Slime/Slime_Spiked_Idle.png", paths)
	assert_in("res://assets/enemies/Golem/Armored/Golem_Armor_Idle.png", paths)
	root.free()


func test_assets_viewer_builds_scrollable_gallery_cards() -> void:
	var root = _instantiate_viewer()
	if root == null:
		return
	var scroll := root.get_node_or_null("Scroll") as ScrollContainer
	var grid := root.get_node_or_null("Scroll/Margin/VBox/GalleryGrid") as GridContainer
	assert_not_null(scroll, "viewer should have scroll container")
	assert_not_null(grid, "viewer should have gallery grid")
	if grid:
		assert_eq(root.collect_asset_paths().size(), grid.get_child_count())
		var first_card := grid.get_child(0)
		assert_true(first_card.has_meta("asset_path"), "gallery cards should expose asset_path metadata")
	root.free()
