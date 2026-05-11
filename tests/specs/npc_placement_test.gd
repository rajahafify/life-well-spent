# tests/specs/npc_placement_test.gd
# Spec: NpcPlacement — stable NPC map placement data.

class_name TestNpcPlacement
extends TestCase

const PLACEMENT_SCRIPT := "res://scripts/models/npc_placement.gd"


func _placement_script() -> GDScript:
	var script := load(PLACEMENT_SCRIPT) as GDScript
	assert_not_null(script, "NpcPlacement script should exist")
	return script


func test_forest_guard_placement_fields_are_defined() -> void:
	var script := _placement_script()
	if script == null:
		return
	var placement = script.forest_guard()
	assert_eq("forest_guard", placement.character_id)
	assert_eq("field", placement.map_id)
	assert_eq(Vector2(1500, 250), placement.position)
	assert_eq("forest_guard_warning", placement.dialog_id)
	assert_eq("forest_guard", placement.sprite_id)
	assert_eq("field_to_forest_locked", placement.blocks_gateway_id)


func test_placement_matches_map() -> void:
	var script := _placement_script()
	if script == null:
		return
	var placement = script.forest_guard()
	assert_true(placement.matches_map("field"))
	assert_false(placement.matches_map("town"))
