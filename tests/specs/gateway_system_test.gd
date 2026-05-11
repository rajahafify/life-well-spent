# tests/specs/gateway_system_test.gd
# Spec: GatewayDefinition — map transfer and lock behavior.

class_name TestGatewaySystem
extends TestCase

const GATEWAY_SCRIPT := "res://scripts/models/gateway_definition.gd"


func _gateway_script() -> GDScript:
	var script := load(GATEWAY_SCRIPT) as GDScript
	assert_not_null(script, "GatewayDefinition script should exist")
	return script


func test_open_gateway_allows_transfer_target() -> void:
	var script := _gateway_script()
	if script == null:
		return
	var gateway = script.new()
	gateway.gateway_id = "town_to_field"
	gateway.source_map = "town"
	gateway.target_map = "field"
	gateway.target_scene_path = "res://scenes/field.tscn"
	gateway.target_spawn_id = "field_spawn"
	gateway.is_locked = false
	assert_true(gateway.can_transfer({}))
	var target: Dictionary = gateway.transfer_target({})
	assert_eq("field", target["target_map"])
	assert_eq("res://scenes/field.tscn", target["target_scene_path"])
	assert_eq("field_spawn", target["target_spawn_id"])


func test_locked_gateway_blocks_transfer_and_exposes_dialog() -> void:
	var script := _gateway_script()
	if script == null:
		return
	var gateway = script.new()
	gateway.gateway_id = "field_to_forest_locked"
	gateway.source_map = "field"
	gateway.target_map = "forest"
	gateway.target_scene_path = "res://scenes/forest.tscn"
	gateway.target_spawn_id = "forest_spawn"
	gateway.is_locked = true
	gateway.blocked_dialog_id = "forest_guard_warning"
	assert_false(gateway.can_transfer({}))
	assert_eq("forest_guard_warning", gateway.blocked_dialog_id)
	assert_eq({}, gateway.transfer_target({}))


func test_unlock_conditions_open_locked_gateway_when_met() -> void:
	var script := _gateway_script()
	if script == null:
		return
	var gateway = script.new()
	gateway.is_locked = true
	gateway.unlock_conditions = {"swordsman_certified": true}
	assert_false(gateway.can_transfer({"swordsman_certified": false}))
	assert_true(gateway.can_transfer({"swordsman_certified": true}))
