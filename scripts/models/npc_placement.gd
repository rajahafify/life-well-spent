## NpcPlacement — pure stable NPC placement data.
class_name NpcPlacement
extends Resource

@export var character_id: String = ""
@export var map_id: String = ""
@export var position: Vector2 = Vector2.ZERO
@export var dialog_id: String = ""
@export var sprite_id: String = ""
@export var blocks_gateway_id: String = ""


func matches_map(candidate_map_id: String) -> bool:
	return map_id == candidate_map_id


static func create(character_id_value: String, map_id_value: String, position_value: Vector2, dialog_id_value: String, sprite_id_value: String, blocks_gateway_id_value: String = ""):
	var script: GDScript = load("res://scripts/models/npc_placement.gd")
	var placement = script.new()
	placement.character_id = character_id_value
	placement.map_id = map_id_value
	placement.position = position_value
	placement.dialog_id = dialog_id_value
	placement.sprite_id = sprite_id_value
	placement.blocks_gateway_id = blocks_gateway_id_value
	return placement


static func forest_guard():
	return create(
		"forest_guard",
		"field",
		Vector2(1500, 250),
		"forest_guard_warning",
		"forest_guard",
		"field_to_forest_locked"
	)
