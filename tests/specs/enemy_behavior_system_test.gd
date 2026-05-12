# tests/specs/enemy_behavior_system_test.gd
# Spec: EnemyBehaviorSystem — Slime idle/wander/chase/attack/die behavior.

class_name TestEnemyBehaviorSystem
extends TestCase

const DEF_SCRIPT := "res://scripts/models/enemy_definition.gd"
const STATE_SCRIPT := "res://scripts/models/enemy_state.gd"
const BEHAVIOR_SCRIPT := "res://scripts/models/enemy_behavior_system.gd"


func _slime_definition():
	var script := load(DEF_SCRIPT) as GDScript
	assert_not_null(script, "EnemyDefinition script should exist")
	if script == null:
		return null
	return script.slime_spiked()


func _slime_state():
	var def = _slime_definition()
	if def == null:
		return null
	var script := load(STATE_SCRIPT) as GDScript
	assert_not_null(script, "EnemyState script should exist")
	if script == null:
		return null
	return script.from_definition("field_slime_001", def, Vector2(500, 500))


func _behavior():
	var script := load(BEHAVIOR_SCRIPT) as GDScript
	assert_not_null(script, "EnemyBehaviorSystem script should exist")
	if script == null:
		return null
	return script.new()


func test_slime_definition_is_tweakable_and_uses_life_combat_values() -> void:
	var slime = _slime_definition()
	if slime == null:
		return
	assert_eq("slime_spiked", slime.enemy_id)
	assert_eq("Spiked Slime", slime.display_name)
	assert_eq(140, slime.max_hp)
	assert_eq(1, slime.attack)
	assert_eq(10, slime.defense)
	assert_eq(5, slime.xp_reward)
	assert_eq([{"item_id": "slime_gel", "quantity": 1}], slime.drop_table)
	assert_eq(0.0, slime.aggro_radius)
	assert_eq(48.0, slime.attack_range)
	assert_eq(1.4, slime.attack_interval)
	assert_eq(0.8, slime.death_duration)
	assert_eq(0.4, slime.idle_min_time)
	assert_eq(3.5, slime.idle_max_time)


func test_bat_and_rat_definitions_are_available_for_field() -> void:
	var script := load(DEF_SCRIPT) as GDScript
	assert_not_null(script, "EnemyDefinition script should exist")
	if script == null:
		return
	var bat = script.bat()
	var rat = script.rat()
	assert_eq("bat", bat.enemy_id)
	assert_eq("Bat", bat.display_name)
	assert_eq(80, bat.max_hp)
	assert_eq(2, bat.attack)
	assert_eq(4, bat.xp_reward)
	assert_eq([{"item_id": "bat_wing", "quantity": 1}], bat.drop_table)
	assert_eq("rat", rat.enemy_id)
	assert_eq("Rat", rat.display_name)
	assert_eq(60, rat.max_hp)
	assert_eq(2, rat.attack)
	assert_eq(3, rat.xp_reward)
	assert_eq([{"item_id": "rat_tail", "quantity": 1}], rat.drop_table)


func test_enemy_state_starts_idle_with_full_hp() -> void:
	var state = _slime_state()
	if state == null:
		return
	assert_eq("field_slime_001", state.instance_id)
	assert_eq("slime_spiked", state.enemy_id)
	assert_eq(140, state.hp)
	assert_eq(140, state.max_hp)
	assert_eq("idle", state.behavior_state)
	assert_false(state.is_defeated)


func test_slime_wander_targets_vary_by_instance_id() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state_a = _slime_state()
	var state_b = null
	if def != null:
		var script := load(STATE_SCRIPT) as GDScript
		state_b = script.from_definition("field_slime_002", def, Vector2(500, 500))
	if behavior == null or def == null or state_a == null or state_b == null:
		return
	state_a.idle_timer = state_a.idle_duration
	state_b.idle_timer = state_b.idle_duration
	behavior.tick(state_a, def, {"player_position": Vector2(2000, 2000)}, 0.01)
	behavior.tick(state_b, def, {"player_position": Vector2(2000, 2000)}, 0.01)
	assert_eq("wander", state_a.behavior_state)
	assert_eq("wander", state_b.behavior_state)
	assert_neq(state_a.target_position, state_b.target_position)
	assert_neq(Vector2(def.wander_radius * 0.5, 0), state_a.target_position - state_a.spawn_position)
	behavior.free()


func test_slime_does_not_aggro_by_proximity_when_aggro_radius_disabled() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state = _slime_state()
	if behavior == null or def == null or state == null:
		return
	behavior.tick(state, def, {"player_position": Vector2(501, 500)}, 0.1)
	assert_eq("idle", state.behavior_state)
	assert_false(state.is_aggro)
	behavior.free()


func test_slime_aggros_and_chases_when_player_inside_radius() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state = _slime_state()
	if behavior == null or def == null or state == null:
		return
	def.aggro_radius = 180.0
	behavior.tick(state, def, {"player_position": Vector2(620, 500)}, 0.1)
	assert_eq("chase", state.behavior_state)
	assert_true(state.is_aggro)
	behavior.free()


func test_slime_enters_attack_when_in_range_and_attacks_on_interval() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state = _slime_state()
	if behavior == null or def == null or state == null:
		return
	state.is_aggro = true
	state.behavior_state = "chase"
	var result: Dictionary = behavior.tick(state, def, {"player_position": Vector2(530, 500)}, 1.4)
	assert_eq("attack", state.behavior_state)
	assert_true(result.get("enemy_attack", false))
	behavior.free()


func test_slime_chases_when_attack_target_moves_out_of_range() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state = _slime_state()
	if behavior == null or def == null or state == null:
		return
	state.is_aggro = true
	state.behavior_state = "attack"
	behavior.tick(state, def, {"player_position": Vector2(700, 500)}, 0.1)
	assert_eq("chase", state.behavior_state)
	behavior.free()


func test_slime_dies_when_hp_reaches_zero() -> void:
	var behavior = _behavior()
	var def = _slime_definition()
	var state = _slime_state()
	if behavior == null or def == null or state == null:
		return
	state.hp = 0
	var result: Dictionary = behavior.tick(state, def, {"player_position": Vector2(530, 500)}, 0.1)
	assert_eq("die", state.behavior_state)
	assert_true(state.is_defeated)
	assert_true(result.get("died", false))
	behavior.free()
