# tests/specs/enemy_system_test.gd
# Spec: EnemyDefinition — prototype Field enemies.

class_name TestEnemySystem
extends TestCase

const ENEMY_SCRIPT := "res://scripts/models/enemy_definition.gd"


func _enemy_script() -> GDScript:
	var script := load(ENEMY_SCRIPT) as GDScript
	assert_not_null(script, "EnemyDefinition script should exist")
	return script


func test_chick_definition_has_tutorial_stats() -> void:
	var script := _enemy_script()
	if script == null:
		return
	var chick = script.chick()
	assert_eq("chick", chick.enemy_id)
	assert_eq("Chick", chick.display_name)
	assert_eq(5, chick.hp)
	assert_eq(1, chick.attack)
	assert_eq(0, chick.defense)
	assert_eq(2, chick.xp_reward)
	assert_in("grassland", chick.biome_tags)


func test_rabbit_definition_has_medium_starter_stats() -> void:
	var script := _enemy_script()
	if script == null:
		return
	var rabbit = script.rabbit()
	assert_eq("rabbit", rabbit.enemy_id)
	assert_eq("Rabbit", rabbit.display_name)
	assert_eq(8, rabbit.hp)
	assert_eq(2, rabbit.attack)
	assert_eq(0, rabbit.defense)
	assert_eq(4, rabbit.xp_reward)


func test_slime_definition_has_tanky_starter_stats() -> void:
	var script := _enemy_script()
	if script == null:
		return
	var slime = script.slime()
	assert_eq("slime", slime.enemy_id)
	assert_eq("Slime", slime.display_name)
	assert_eq(14, slime.hp)
	assert_eq(1, slime.attack)
	assert_eq(1, slime.defense)
	assert_eq(5, slime.xp_reward)


func test_enemy_defeat_uses_current_hp() -> void:
	var script := _enemy_script()
	if script == null:
		return
	var chick = script.chick()
	assert_false(chick.is_defeated(1))
	assert_true(chick.is_defeated(0))
