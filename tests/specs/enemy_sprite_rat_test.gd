# tests/specs/enemy_sprite_rat_test.gd
# Spec: Rat enemy sprite metadata V1.

class_name TestEnemySpriteRat
extends TestCase

const CATALOG_SCRIPT := "res://scripts/models/enemy_sprite_catalog.gd"
const RAT_JSON := "res://assets/enemies/Rat/rat.asset.json"


func _catalog_script() -> GDScript:
	var script := load(CATALOG_SCRIPT) as GDScript
	assert_not_null(script, "EnemySpriteCatalog script should exist")
	return script


func test_rat_metadata_file_exists_and_uses_schema_v1() -> void:
	assert_true(ResourceLoader.exists(RAT_JSON), "rat metadata json should exist")
	var file := FileAccess.open(RAT_JSON, FileAccess.READ)
	assert_not_null(file, "rat metadata json should be readable")
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(data is Dictionary)
	assert_eq(1, data["schema_version"])
	assert_eq("rat", data["enemy_id"])
	assert_eq("Rat", data["display_name"])
	assert_eq("horizontal_2d", data["directions"])
	assert_eq(true, data["supports_flip"])


func test_catalog_loads_rat_actions() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	var sprite_set: Dictionary = catalog.load_enemy("rat")
	assert_eq("rat", sprite_set["enemy_id"])
	assert_eq("Rat", sprite_set["display_name"])
	assert_eq(Vector2i(64, 64), sprite_set["frame_size"])
	for action in ["idle", "run", "hit", "attack", "death", "ability"]:
		assert_has(sprite_set["animations"], action)
	assert_eq("res://assets/enemies/Rat/Rat_Idle.png", sprite_set["animations"]["idle"]["texture_path"])
	catalog.free()


func test_catalog_validates_rat_textures_and_dimensions() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	var sprite_set: Dictionary = catalog.load_enemy("rat")
	assert_eq([], catalog.validate_sprite_set(sprite_set))
	catalog.free()
