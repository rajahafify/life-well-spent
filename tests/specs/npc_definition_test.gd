# tests/specs/npc_definition_test.gd
# Spec: NpcDefinition — data resources for NPC role variants

class_name TestNpcDefinition
extends TestCase

func _definition_script() -> GDScript:
	return load("res://scripts/models/npc_definition.gd") as GDScript


func test_quest_giver_factory_sets_quest_fields() -> void:
	var definition = _definition_script().quest_giver("Lumber Elder", "Gather Wood", 40, "Gather wood for town")
	assert_eq("Lumber Elder", definition.display_name)
	assert_eq("quest_giver", definition.role)
	assert_eq("Gather Wood", definition.quest_name)
	assert_eq(40, definition.quest_cost)


func test_vendor_factory_sets_vendor_role() -> void:
	var definition = _definition_script().vendor("Mira", "Useful goods soon.")
	assert_eq("vendor", definition.role)
	assert_eq("Mira", definition.display_name)
	assert_eq("Useful goods soon.", definition.dialog_text)


func test_facility_factory_sets_facility_unlock() -> void:
	var definition = _definition_script().facility("Gardener", "garden", "Town Garden")
	assert_eq("facility", definition.role)
	assert_eq("garden", definition.facility_id)
	assert_eq("Town Garden", definition.facility_name)


func test_npc_controller_applies_definition() -> void:
	var npc := NpcController.new()
	npc.definition = _definition_script().vendor("Mira", "Useful goods soon.")
	npc._ready()
	assert_eq("Mira", npc.display_name)
	assert_eq("vendor", npc.role)
	assert_eq("Useful goods soon.", npc.dialog_text)
	npc.free()
