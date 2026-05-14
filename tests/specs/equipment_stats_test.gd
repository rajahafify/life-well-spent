# tests/specs/equipment_stats_test.gd
# Spec: EquipmentStats - equipment items contribute combat bonuses.

class_name TestEquipmentStats
extends TestCase

const MODEL_SCRIPT := "res://scripts/models/equipment_stats.gd"

var stats


func setup() -> void:
	var script := load(MODEL_SCRIPT) as GDScript
	assert_not_null(script, "EquipmentStats script should exist")
	if script:
		stats = script.new()


func teardown() -> void:
	if stats:
		stats.free()
		stats = null


func test_training_sword_adds_attack_bonus() -> void:
	if stats == null:
		return
	assert_eq(20, stats.attack_bonus_for_weapon("training_sword"))


func test_unknown_weapon_adds_no_attack_bonus() -> void:
	if stats == null:
		return
	assert_eq(0, stats.attack_bonus_for_weapon("unknown_sword"))


func test_leather_armor_adds_defense_bonus() -> void:
	if stats == null:
		return
	assert_eq(1, stats.defense_bonus_for_armor("leather_armor"))


func test_unknown_armor_adds_no_defense_bonus() -> void:
	if stats == null:
		return
	assert_eq(0, stats.defense_bonus_for_armor("unknown_armor"))
