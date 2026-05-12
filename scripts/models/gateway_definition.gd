## GatewayDefinition — pure map gateway target/lock data.
class_name GatewayDefinition
extends Resource

@export var gateway_id: String = ""
@export var source_map: String = ""
@export var target_map: String = ""
@export var target_scene_path: String = ""
@export var target_spawn_id: String = ""
@export var is_locked: bool = false
@export var unlock_conditions: Dictionary = {}
@export var blocked_dialog_id: String = ""


func can_transfer(state: Dictionary = {}) -> bool:
	if not is_locked:
		return true
	for key in unlock_conditions.keys():
		if state.get(key, null) != unlock_conditions[key]:
			return false
	return not unlock_conditions.is_empty()


func transfer_target(state: Dictionary = {}) -> Dictionary:
	if not can_transfer(state):
		return {}
	return {
		"gateway_id": gateway_id,
		"source_map": source_map,
		"target_map": target_map,
		"target_scene_path": target_scene_path,
		"target_spawn_id": target_spawn_id,
	}


static func town_to_field():
	var script: GDScript = load("res://scripts/models/gateway_definition.gd")
	var gateway = script.new()
	gateway.gateway_id = "town_to_field"
	gateway.source_map = "town"
	gateway.target_map = "field"
	gateway.target_scene_path = "res://scenes/field.tscn"
	gateway.target_spawn_id = "from_town_gateway"
	return gateway


static func field_to_town():
	var script: GDScript = load("res://scripts/models/gateway_definition.gd")
	var gateway = script.new()
	gateway.gateway_id = "field_to_town"
	gateway.source_map = "field"
	gateway.target_map = "town"
	gateway.target_scene_path = "res://scenes/town_scene.tscn"
	gateway.target_spawn_id = "from_field_gateway"
	return gateway


static func field_to_forest_locked():
	var script: GDScript = load("res://scripts/models/gateway_definition.gd")
	var gateway = script.new()
	gateway.gateway_id = "field_to_forest_locked"
	gateway.source_map = "field"
	gateway.target_map = "forest"
	gateway.target_scene_path = "res://scenes/forest.tscn"
	gateway.target_spawn_id = "from_field_gateway"
	gateway.is_locked = true
	gateway.unlock_conditions = {"swordsman_certified": true}
	gateway.blocked_dialog_id = "forest_guard_warning"
	return gateway
