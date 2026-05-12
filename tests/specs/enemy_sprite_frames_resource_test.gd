# tests/specs/enemy_sprite_frames_resource_test.gd
# Spec: imported enemies expose Godot-native SpriteFrames resources for editor timing tweaks.

class_name TestEnemySpriteFramesResource
extends TestCase

const CATALOG_SCRIPT := "res://scripts/models/enemy_sprite_catalog.gd"


func _catalog():
	var script := load(CATALOG_SCRIPT) as GDScript
	assert_not_null(script)
	if script == null:
		return null
	return script.new()


func test_all_catalog_enemies_reference_sprite_frames_resources() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	for enemy_id in catalog.enemy_ids():
		var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
		assert_true(sprite_set.has("sprite_frames_resource"), "%s should reference SpriteFrames resource" % enemy_id)
		var resource_path := str(sprite_set.get("sprite_frames_resource", ""))
		assert_true(resource_path.ends_with(".tres"), "%s resource should be .tres" % enemy_id)
		assert_true(ResourceLoader.exists(resource_path), "%s SpriteFrames resource should exist" % enemy_id)
	catalog.free()


func test_sprite_frames_resources_load_with_required_animations() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	for enemy_id in catalog.enemy_ids():
		var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
		var frames := load(str(sprite_set["sprite_frames_resource"])) as SpriteFrames
		assert_not_null(frames, "%s SpriteFrames resource should load" % enemy_id)
		if frames == null:
			continue
		for required in ["idle", "run", "hit", "death"]:
			assert_true(frames.has_animation(required), "%s should have %s" % [enemy_id, required])
		assert_true(frames.get_frame_count("idle") > 0, "%s idle should have frames" % enemy_id)
	catalog.free()
