# tests/specs/drop_system_test.gd
# Spec: DropSystem - pure chance roll helper for enemy drops.

class_name TestDropSystem
extends TestCase

const DROP_SYSTEM_SCRIPT := "res://scripts/models/drop_system.gd"

var drops


func setup() -> void:
	var script := load(DROP_SYSTEM_SCRIPT) as GDScript
	assert_not_null(script, "DropSystem script should exist")
	drops = script.new() if script else null


func teardown() -> void:
	drops.free()
	drops = null


func test_guaranteed_drop_succeeds_without_chance_fields() -> void:
	assert_true(drops.succeeds({}))


func test_zero_numerator_drop_fails() -> void:
	assert_false(drops.succeeds({"chance_numerator": 0, "chance_denominator": 5}, 1))


func test_roll_at_numerator_succeeds() -> void:
	assert_true(drops.succeeds({"chance_numerator": 2, "chance_denominator": 5}, 2))


func test_roll_above_numerator_fails() -> void:
	assert_false(drops.succeeds({"chance_numerator": 2, "chance_denominator": 5}, 3))


func test_numerator_above_denominator_clamps_to_guaranteed() -> void:
	assert_true(drops.succeeds({"chance_numerator": 7, "chance_denominator": 5}, 5))
