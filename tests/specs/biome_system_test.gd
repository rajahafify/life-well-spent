# tests/specs/biome_system_test.gd
# Spec: BiomeDefinition — Field grassland data.

class_name TestBiomeSystem
extends TestCase

const BIOME_SCRIPT := "res://scripts/models/biome_definition.gd"


func _biome_script() -> GDScript:
	var script := load(BIOME_SCRIPT) as GDScript
	assert_not_null(script, "BiomeDefinition script should exist")
	return script


func test_field_grassland_biome_defines_palette_enemies_and_props() -> void:
	var script := _biome_script()
	if script == null:
		return
	var biome = script.field_grassland()
	assert_eq("grassland", biome.biome_type)
	assert_eq(Color(0.36, 0.72, 0.24, 1), biome.palette["grass"])
	assert_eq(Color(0.45, 0.28, 0.12, 1), biome.palette["dirt"])
	assert_eq(["slime_spiked", "bat", "rat"], biome.enemy_pool)
	assert_in("rocks", biome.prop_pool)
	assert_in("bushes", biome.prop_pool)
	assert_in("grass_patches", biome.prop_pool)


func test_biome_allows_only_pool_enemies() -> void:
	var script := _biome_script()
	if script == null:
		return
	var biome = script.field_grassland()
	assert_true(biome.allows_enemy("slime_spiked"))
	assert_true(biome.allows_enemy("bat"))
	assert_true(biome.allows_enemy("rat"))
	assert_false(biome.allows_enemy("forest_wolf"))
