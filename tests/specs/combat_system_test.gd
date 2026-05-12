# tests/specs/combat_system_test.gd
# Spec: CombatSystem — Field combat damages current Life and enemy HP.

class_name TestCombatSystem
extends TestCase

const COMBAT_SCRIPT := "res://scripts/models/combat_system.gd"


func _combat_system():
	var script := load(COMBAT_SCRIPT) as GDScript
	assert_not_null(script, "CombatSystem script should exist")
	if script == null:
		return null
	return script.new()


func test_player_attack_damages_enemy_hp_with_minimum_one_damage() -> void:
	var combat = _combat_system()
	if combat == null:
		return
	var player := {"attack": 1, "life": 100}
	var enemy := {"hp": 14, "defense": 5, "xp_reward": 5}
	var result: Dictionary = combat.player_attack_enemy(player, enemy)
	assert_eq(1, result["damage"])
	assert_eq(13, result["enemy_state"]["hp"])
	assert_eq(100, player["life"], "Player attacks should not damage player Life")
	combat.free()


func test_player_attack_reports_defeat_and_xp_reward() -> void:
	var combat = _combat_system()
	if combat == null:
		return
	var player := {"attack": 6, "life": 100}
	var enemy := {"hp": 5, "defense": 0, "xp_reward": 2}
	var result: Dictionary = combat.player_attack_enemy(player, enemy)
	assert_true(result["enemy_defeated"])
	assert_eq(0, result["enemy_state"]["hp"])
	assert_eq(2, result["xp_reward"])
	combat.free()


func test_enemy_attack_damages_current_life() -> void:
	var combat = _combat_system()
	if combat == null:
		return
	var enemy := {"attack": 2}
	var player := {"life": 10, "max_life": 10, "defense": 0}
	var result: Dictionary = combat.enemy_attack_player(enemy, player)
	assert_eq(2, result["damage"])
	assert_eq(8, result["player_state"]["life"])
	assert_eq(10, result["player_state"]["max_life"])
	assert_eq(10, player["life"], "CombatSystem should return next state without mutating input")
	combat.free()


func test_enemy_attack_reports_player_defeated_when_life_reaches_zero() -> void:
	var combat = _combat_system()
	if combat == null:
		return
	var enemy := {"attack": 10}
	var player := {"life": 3, "max_life": 10, "defense": 0}
	var result: Dictionary = combat.enemy_attack_player(enemy, player)
	assert_true(result["player_defeated"])
	assert_eq(0, result["player_state"]["life"])
	assert_eq(10, result["player_state"]["max_life"])
	combat.free()
