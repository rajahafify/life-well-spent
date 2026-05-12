# tests/specs/enemy_sprite_catalog_all_test.gd
# Spec: all imported enemy sprite metadata entries are cataloged and valid.

class_name TestEnemySpriteCatalogAll
extends TestCase

const CATALOG_SCRIPT := "res://scripts/models/enemy_sprite_catalog.gd"

const EXPECTED_ENEMY_IDS := [
	"slime_spiked",
	"rat",
	"bat",
	"crab",
	"golem_armored",
	"golem",
	"pebble",
	"skull",
]


func _catalog_script() -> GDScript:
	var script := load(CATALOG_SCRIPT) as GDScript
	assert_not_null(script, "EnemySpriteCatalog script should exist")
	return script


func test_catalog_lists_all_imported_enemy_types() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	assert_eq(EXPECTED_ENEMY_IDS, catalog.enemy_ids())
	catalog.free()


func test_all_imported_enemy_types_load_and_validate() -> void:
	var script := _catalog_script()
	if script == null:
		return
	var catalog = script.new()
	for enemy_id in EXPECTED_ENEMY_IDS:
		var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
		assert_eq(enemy_id, sprite_set["enemy_id"])
		assert_eq(Vector2i(64, 64), sprite_set["frame_size"])
		assert_has(sprite_set["animations"], "idle")
		assert_has(sprite_set["animations"], "run")
		assert_has(sprite_set["animations"], "hit")
		assert_has(sprite_set["animations"], "death")
		assert_eq([], catalog.validate_sprite_set(sprite_set))
	catalog.free()
