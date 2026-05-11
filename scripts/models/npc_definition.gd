## NpcDefinition — Resource data for NPC role variants.
class_name NpcDefinition
extends Resource

@export var display_name: String = "NPC"
@export var role: String = "generic"
@export_multiline var dialog_text: String = "Hello."
@export var quest_name: String = ""
@export var quest_cost: int = 40
@export_multiline var quest_description: String = ""
@export var life_task_id: String = ""
@export var facility_id: String = ""
@export var facility_name: String = ""


static func quest_giver(name: String, quest: String, cost: int, description: String, task_id: String = ""):
	var script: GDScript = load("res://scripts/models/npc_definition.gd")
	var definition = script.new()
	definition.display_name = name
	definition.role = "quest_giver"
	definition.dialog_text = "Can you spare some life for a worthy task?"
	definition.quest_name = quest
	definition.quest_cost = cost
	definition.quest_description = description
	definition.life_task_id = task_id
	return definition


static func vendor(name: String, dialog: String):
	var script: GDScript = load("res://scripts/models/npc_definition.gd")
	var definition = script.new()
	definition.display_name = name
	definition.role = "vendor"
	definition.dialog_text = dialog
	return definition


static func facility(name: String, id: String, title: String):
	var script: GDScript = load("res://scripts/models/npc_definition.gd")
	var definition = script.new()
	definition.display_name = name
	definition.role = "facility"
	definition.dialog_text = "%s improves as your habits grow." % title
	definition.facility_id = id
	definition.facility_name = title
	return definition
