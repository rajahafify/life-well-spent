# tests/specs/enemy_library_test.gd
# Spec: EnemyLibrary - registry-backed enemy definition catalog.

class_name TestEnemyLibrary
extends TestCase

const LIBRARY_SCRIPT := "res://scripts/models/enemy_library.gd"


func _library():
	var script := load(LIBRARY_SCRIPT) as GDScript
	assert_not_null(script, "EnemyLibrary script should exist")
	return script


func test_for_id_loads_slime_from_registry() -> void:
	var library = _library()
	if library == null:
		return
	var slime = library.for_id("slime_spiked")
	assert_eq("slime_spiked", slime.enemy_id)
	assert_eq("Spiked Slime", slime.display_name)
	assert_eq(140, slime.max_hp)


func test_for_id_loads_bat_from_registry() -> void:
	var library = _library()
	if library == null:
		return
	var bat = library.for_id("bat")
	assert_eq("bat", bat.enemy_id)
	assert_eq(80, bat.max_hp)
	assert_eq("bat_wing", bat.drop_table[0]["item_id"])


func test_unknown_id_falls_back_to_slime() -> void:
	var library = _library()
	if library == null:
		return
	assert_eq("slime_spiked", library.for_id("missing").enemy_id)


func test_definition_uses_dictionary_config_without_positional_build_calls() -> void:
	var file := FileAccess.open("res://scripts/models/enemy_definition.gd", FileAccess.READ)
	assert_not_null(file, "EnemyDefinition script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_false(source.contains("static func _build("), "EnemyDefinition should not own positional factory construction")
	assert_false(source.contains("static func for_id("), "EnemyDefinition should not own enemy catalog lookup")
