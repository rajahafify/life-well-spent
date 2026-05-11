# tests/specs/random_enemy_respawn_test.gd
# Spec: RandomEnemyRespawnSystem — pure spawn zone rules.

class_name TestRandomEnemyRespawn
extends TestCase

const RESPAWN_SCRIPT := "res://scripts/models/random_enemy_respawn_system.gd"


func _respawn_system():
	var script := load(RESPAWN_SCRIPT) as GDScript
	assert_not_null(script, "RandomEnemyRespawnSystem script should exist")
	if script == null:
		return null
	return script.new()


func test_spawn_zone_rolls_enemy_when_timer_elapsed_and_under_cap() -> void:
	var system = _respawn_system()
	if system == null:
		return
	var zone: Dictionary = system.define_zone("field_grass", ["chick", "rabbit", "slime"], 3, 5.0, "grassland")
	var result: Dictionary = system.tick_zone(zone, 5.0, 2)
	assert_true(result["should_spawn"])
	assert_eq("chick", result["enemy_id"])
	assert_eq("field_grass", result["spawn_zone_id"])
	assert_eq(0.0, result["remaining_timer"])
	combat_free(system)


func test_spawn_zone_does_not_spawn_when_at_active_cap() -> void:
	var system = _respawn_system()
	if system == null:
		return
	var zone: Dictionary = system.define_zone("field_grass", ["chick"], 1, 5.0, "grassland")
	var result: Dictionary = system.tick_zone(zone, 9.0, 1)
	assert_false(result["should_spawn"])
	assert_eq("max_active", result["reason"])
	combat_free(system)


func test_spawn_zone_waits_for_respawn_interval() -> void:
	var system = _respawn_system()
	if system == null:
		return
	var zone: Dictionary = system.define_zone("field_grass", ["chick"], 1, 5.0, "grassland")
	var result: Dictionary = system.tick_zone(zone, 4.0, 0)
	assert_false(result["should_spawn"])
	assert_eq("waiting", result["reason"])
	assert_eq(1.0, result["remaining_timer"])
	combat_free(system)


func combat_free(object) -> void:
	if object and object.has_method("free"):
		object.free()
