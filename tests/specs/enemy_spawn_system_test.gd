# tests/specs/enemy_spawn_system_test.gd
# Spec: EnemySpawnSystem - game-wide persistent enemy spawn slots.

class_name TestEnemySpawnSystem
extends TestCase

const SPAWN_SCRIPT := "res://scripts/models/enemy_spawn_system.gd"
const MANAGER_SCRIPT := "res://scripts/managers/enemy_spawn_manager.gd"

var spawn_system


func setup() -> void:
	spawn_system = _new_script_object(SPAWN_SCRIPT)


func teardown() -> void:
	spawn_system = null


func _new_script_object(path: String):
	var script: GDScript = load(path)
	assert_not_null(script, "%s should load" % path)
	if script == null:
		return null
	return script.new()


func _register_field(system) -> void:
	system.register_biome("field", "grassland", 2, 60.0)
	system.register_spawn_slot("field_slime_001", "field", "grassland", "slime_spiked")
	system.register_spawn_slot("field_bat_001", "field", "grassland", "bat")
	system.register_spawn_slot("field_rat_001", "field", "grassland", "rat")


func test_biome_caps_active_enemy_slots() -> void:
	if spawn_system == null:
		return
	_register_field(spawn_system)
	var active: Array = spawn_system.active_spawn_slots("field")
	assert_eq(2, active.size())
	assert_eq("field_slime_001", active[0]["slot_id"])
	assert_eq("field_bat_001", active[1]["slot_id"])


func test_defeated_slot_stays_gone_until_respawn_delay_even_if_queried_again() -> void:
	if spawn_system == null:
		return
	_register_field(spawn_system)
	spawn_system.mark_defeated("field_slime_001")
	var active: Array = spawn_system.active_spawn_slots("field")
	assert_eq(2, active.size())
	assert_false(_contains_slot(active, "field_slime_001"))
	assert_true(_contains_slot(active, "field_rat_001"))
	active = spawn_system.active_spawn_slots("field")
	assert_false(_contains_slot(active, "field_slime_001"), "portal changes should not immediately respawn defeated enemies")


func test_defeated_slot_respawns_after_global_time_and_available_capacity() -> void:
	if spawn_system == null:
		return
	_register_field(spawn_system)
	spawn_system.mark_defeated("field_slime_001")
	spawn_system.tick(59.0)
	assert_false(_contains_slot(spawn_system.active_spawn_slots("field"), "field_slime_001"))
	spawn_system.mark_defeated("field_bat_001")
	spawn_system.tick(1.0)
	var active: Array = spawn_system.active_spawn_slots("field")
	assert_true(_contains_slot(active, "field_slime_001"))
	assert_false(_contains_slot(active, "field_bat_001"))


func test_spawn_state_serializes_and_restores_defeated_timers() -> void:
	if spawn_system == null:
		return
	_register_field(spawn_system)
	spawn_system.mark_defeated("field_slime_001")
	spawn_system.tick(30.0)
	var data: Dictionary = spawn_system.to_dict()
	var restored = _new_script_object(SPAWN_SCRIPT)
	restored.apply_dict(data)
	assert_false(_contains_slot(restored.active_spawn_slots("field"), "field_slime_001"))
	restored.tick(30.0)
	assert_true(_contains_slot(restored.active_spawn_slots("field"), "field_slime_001"))


func test_enemy_spawn_manager_is_registered_as_autoload() -> void:
	var autoload_path := str(ProjectSettings.get_setting("autoload/EnemySpawnManager", ""))
	assert_true(autoload_path.contains("res://scripts/managers/enemy_spawn_manager.gd"), "EnemySpawnManager should be a game-wide autoload")


func _contains_slot(slots: Array, slot_id: String) -> bool:
	for slot in slots:
		if str(Dictionary(slot).get("slot_id", "")) == slot_id:
			return true
	return false
