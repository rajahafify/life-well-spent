# tests/specs/asset_gallery_test.gd
# Spec: AssetGallery - looping editor-visible enemy SpriteFrames gallery.

class_name TestAssetGallery
extends TestCase

const GALLERY_SCENE := "res://assets/assets-gallery.tscn"
const VIEW_ROOT := "Center/Panel/Margin/VBox"


func _instantiate_gallery():
	var scene: PackedScene = load(GALLERY_SCENE)
	assert_not_null(scene, "asset gallery scene should load")
	if scene == null:
		return null
	var root = scene.instantiate()
	if root.has_method("_ready"):
		root._ready()
	return root


func test_asset_gallery_scene_loads_with_one_root_control() -> void:
	var root = _instantiate_gallery()
	if root == null:
		return
	assert_eq("AssetGallery", root.name)
	assert_true(root.get_script().resource_path.ends_with("asset_gallery.gd"))
	root.free()


func test_asset_gallery_has_editor_visible_sprite_for_each_enemy() -> void:
	var root = _instantiate_gallery()
	if root == null:
		return
	var expected := {
		"SlimePreview/SlimeArea/SlimeSprite": "res://assets/enemies/Slime/slime_spiked_sprite_frames.tres",
		"RatPreview/RatArea/RatSprite": "res://assets/enemies/Rat/rat_sprite_frames.tres",
		"BatPreview/BatArea/BatSprite": "res://assets/enemies/Bat/bat_sprite_frames.tres",
		"CrabPreview/CrabArea/CrabSprite": "res://assets/enemies/Crab/crab_sprite_frames.tres",
		"ArmoredGolemPreview/ArmoredGolemArea/ArmoredGolemSprite": "res://assets/enemies/Golem/Armored/golem_armored_sprite_frames.tres",
		"GolemPreview/GolemArea/GolemSprite": "res://assets/enemies/Golem/No Armor/golem_sprite_frames.tres",
		"PebblePreview/PebbleArea/PebbleSprite": "res://assets/enemies/Pebble/pebble_sprite_frames.tres",
		"SkullPreview/SkullArea/SkullSprite": "res://assets/enemies/Skull/skull_sprite_frames.tres",
	}
	for node_path in expected.keys():
		var sprite := root.get_node_or_null(VIEW_ROOT + "/GalleryScroll/GalleryGrid/" + node_path) as AnimatedSprite2D
		assert_not_null(sprite, "%s should exist for editor timing edits" % node_path)
		if sprite:
			assert_eq("idle", sprite.animation)
			assert_not_null(sprite.sprite_frames, "%s should have SpriteFrames" % node_path)
			assert_eq(expected[node_path], sprite.sprite_frames.resource_path)
	root.free()


func test_asset_gallery_adds_character_sprite_previews() -> void:
	var root = _instantiate_gallery()
	if root == null:
		return
	for character_id in ["player", "forest_guard"]:
		var sprite := root.sprite_node_for_character(character_id) as AnimatedSprite2D
		assert_not_null(sprite)
		if sprite:
			assert_eq("idle", sprite.animation)
			assert_true(sprite.is_playing())
			assert_true(sprite.sprite_frames.has_animation("slash"))
	root.free()


func test_asset_gallery_loops_and_plays_all_idle_previews() -> void:
	var root = _instantiate_gallery()
	if root == null:
		return
	for enemy_id in ["slime_spiked", "rat", "bat", "crab", "golem_armored", "golem", "pebble", "skull"]:
		var sprite := root.sprite_node_for_enemy(enemy_id) as AnimatedSprite2D
		assert_not_null(sprite)
		if sprite:
			assert_eq("idle", sprite.animation)
			assert_true(sprite.is_playing())
			assert_true(sprite.sprite_frames.get_animation_loop("idle"))
	root.free()
