# tests/specs/enemy_state_test.gd
# Spec: EnemyState - runtime enemy data and combat-state mapping.

class_name TestEnemyState
extends TestCase

const LIBRARY_SCRIPT := "res://scripts/models/enemy_library.gd"
const STATE_SCRIPT := "res://scripts/models/enemy_state.gd"


func _slime_definition():
	var script := load(LIBRARY_SCRIPT) as GDScript
	assert_not_null(script, "EnemyLibrary script should exist")
	return script.for_id("slime_spiked") if script else null


func _new_state():
	var definition = _slime_definition()
	var script := load(STATE_SCRIPT) as GDScript
	assert_not_null(script, "EnemyState script should exist")
	return script.from_definition("field_slime_001", definition, Vector2(500, 500)) if script and definition else null


func test_from_definition_sets_identity_and_spawn_position() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_eq("field_slime_001", state.instance_id)
	assert_eq("slime_spiked", state.enemy_id)
	assert_eq(Vector2(500, 500), state.spawn_position)
	assert_eq(Vector2(500, 500), state.position)


func test_from_definition_starts_with_combat_stats() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_eq(140, state.hp)
	assert_eq(140, state.max_hp)
	assert_eq(1, state.attack)
	assert_eq(10, state.defense)
	assert_eq(5, state.xp_reward)


func test_to_combat_dict_returns_public_combat_state() -> void:
	var state = _new_state()
	if state == null:
		return
	var combat_state: Dictionary = state.to_combat_dict()
	assert_eq("slime_spiked", combat_state["enemy_id"])
	assert_eq(140, combat_state["hp"])
	assert_eq(10, combat_state["defense"])
	assert_eq(5, combat_state["xp_reward"])


func test_apply_combat_dict_marks_defeated_at_zero_hp() -> void:
	var state = _new_state()
	if state == null:
		return
	state.apply_combat_dict({"hp": 0})
	assert_eq(0, state.hp)
	assert_true(state.is_defeated)
	assert_eq("die", state.behavior_state)


func test_spawned_state_random_seed_is_deterministic_by_instance_id() -> void:
	var state_a = _new_state()
	var state_b = _new_state()
	if state_a == null or state_b == null:
		return
	assert_eq(state_a.random_seed, state_b.random_seed)
	assert_true(state_a.random_seed > 0)
