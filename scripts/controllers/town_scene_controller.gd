## Town — first-slice Town scene controller.
## Thin glue: connects worldbuilding NPC signals to dialog view and exposes portal prompt copy.
class_name Town
extends Node2D

const STARTER_AREA_PATH := "res://scenes/starter_area.tscn"

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _portal_prompt: Label = $UI/PortalPrompt
@onready var _reborn_prompt: Label = $UI/RebornPrompt

var requested_scene_path: String = ""


func _ready() -> void:
	_reborn_prompt.text = "You have been reborn.\nWill you spend this life well?"
	_portal_prompt.text = "Enter Starter Area?"
	_portal_prompt.visible = false
	_dialog_view.hide_dialog()
	_connect_worldbuilding_npcs()


func _connect_worldbuilding_npcs() -> void:
	for npc_name in ["Guildmaster", "Shopkeeper", "Smith"]:
		var npc := get_node_or_null(npc_name) as NpcController
		if npc and not npc.interacted.is_connected(_on_npc_interacted):
			npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: NpcController) -> void:
	_dialog_view.show_dialog(npc.display_name, npc.dialog_text, false, false)


func request_starter_area() -> void:
	requested_scene_path = STARTER_AREA_PATH
	_portal_prompt.visible = true


func close_dialog() -> void:
	_dialog_view.hide_dialog()
