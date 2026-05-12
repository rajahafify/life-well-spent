# tests/specs/enemy_sprite_metadata_test.gd
# Spec: Enemy sprite metadata V1 — RO-ish sprite/action metadata pipeline.

class_name TestEnemySpriteMetadata
extends TestCase

const CATALOG_SCRIPT := "res://scripts/models/enemy_sprite_catalog.gd"
const BUILDER_SCRIPT := "res://scripts/views/enemy_sprite_frames_builder.gd"
const SLIME_JSON := "res://assets/enemies/Slime/slime_spiked.asset.json"


func _catalog_script() -> GDScript:
	var script := load(CATALOG_SCRIPT) as GDScript
	assert_not_null(script, "EnemySpriteCatalog script should exist")
	return script


func _builder_script() -> GDScript:
	var script := load(BUILDER_SCRIPT) as GDScript
	assert_not_null(script, "EnemySpriteFramesBuilder script should exist")
	return script


func test_slime_spiked_metadata_file_exists_and_uses_schema_v1() -> void:
	assert_true(ResourceLoader.exists(SLIME_JSON), "slime metadata json should exist")
	var file := FileAccess.open(SLIME_JSON, FileAccess.READ)
	assert_not_null(file, "slime metadata json should be readable")
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(data is Dictionary)
	assert_eq(1, data["schema_version"])
	assert_eq("slime_spiked", data["enemy_id"])
	assert_eq("Spiked Slime", data["display_name"])
	assert_eq("horizontal_2d", data["directions"])
	assert_eq(true, data["supports_flip"])


func test_catalog_loads_slime_spiked_actions() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	var sprite_set: Dictionary = catalog.load_enemy("slime_spiked")
	assert_eq("slime_spiked", sprite_set["enemy_id"])
	assert_eq("Spiked Slime", sprite_set["display_name"])
	assert_eq(Vector2i(64, 64), sprite_set["frame_size"])
	assert_has(sprite_set["animations"], "idle")
	assert_has(sprite_set["animations"], "run")
	assert_has(sprite_set["animations"], "hit")
	assert_has(sprite_set["animations"], "jump")
	assert_has(sprite_set["animations"], "death")
	assert_has(sprite_set["animations"], "ability")
	catalog.free()


func test_catalog_validates_required_textures_and_frame_dimensions() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	var sprite_set: Dictionary = catalog.load_enemy("slime_spiked")
	var errors: Array = catalog.validate_sprite_set(sprite_set)
	assert_eq([], errors)
	catalog.free()


func test_builder_creates_sprite_frames_from_metadata() -> void:
	var catalog_script := _catalog_script()
	var builder_script := _builder_script()
	if catalog_script == null or builder_script == null:
		return
	var catalog = catalog_script.new()
	var builder = builder_script.new()
	var sprite_set: Dictionary = catalog.load_enemy("slime_spiked")
	var frames: SpriteFrames = builder.build(sprite_set)
	assert_true(frames.has_animation("idle"))
	assert_true(frames.has_animation("death"))
	assert_eq(4, frames.get_frame_count("idle"))
	assert_eq(8, frames.get_frame_count("death"))
	assert_true(frames.get_animation_loop("idle"))
	assert_false(frames.get_animation_loop("death"))
	assert_eq(6.0, frames.get_animation_speed("idle"))
	assert_eq(10.0, frames.get_animation_speed("death"))
	builder.free()
	catalog.free()
