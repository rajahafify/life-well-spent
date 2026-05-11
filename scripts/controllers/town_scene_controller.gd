## Town — first-slice Town scene controller.
## Thin glue: connects worldbuilding NPC signals to dialog view and exposes portal prompt copy.
class_name Town
extends Node2D

const STARTER_AREA_PATH := "res://scenes/starter_area.tscn"
const CAMERA_OFFSET := Vector2(0, -150)

@onready var _dialog_view: TownDialogView = $UI/DialogPanel
@onready var _portal_prompt: Label = $UI/PortalPrompt
@onready var _portal_choices: Control = $UI/PortalChoices
@onready var _portal_yes_button: Button = $UI/PortalChoices/YesButton
@onready var _portal_no_button: Button = $UI/PortalChoices/NoButton
@onready var _reborn_prompt: Label = $UI/RebornPrompt
@onready var _starter_area_portal: Area2D = $StarterAreaPortal
@onready var _player: CharacterBody2D = $Player

var requested_scene_path: String = ""
var _pending_npc: NpcController


func _ready() -> void:
	_reborn_prompt.text = "You have been reborn.\nWill you spend this life well?"
	_portal_prompt.text = "Enter Starter Area?"
	hide_portal_prompt()
	_dialog_view.hide_dialog()
	_connect_dialog()
	_connect_portal()
	_connect_portal_buttons()
	_connect_worldbuilding_npcs()
	_update_camera()


func _connect_dialog() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.close_requested.is_connected(close_dialog):
		_dialog_view.close_requested.connect(close_dialog)


func _connect_portal() -> void:
	if _starter_area_portal and not _starter_area_portal.body_entered.is_connected(_on_starter_area_portal_body_entered):
		_starter_area_portal.body_entered.connect(_on_starter_area_portal_body_entered)


func _connect_portal_buttons() -> void:
	if _portal_yes_button and not _portal_yes_button.pressed.is_connected(_on_portal_yes_pressed):
		_portal_yes_button.pressed.connect(_on_portal_yes_pressed)
	if _portal_no_button and not _portal_no_button.pressed.is_connected(hide_portal_prompt):
		_portal_no_button.pressed.connect(hide_portal_prompt)


func _connect_worldbuilding_npcs() -> void:
	for npc_name in ["Guildmaster", "Shopkeeper", "Smith"]:
		var npc := get_node_or_null(npc_name) as NpcController
		if npc and not npc.interacted.is_connected(_on_npc_interacted):
			npc.interacted.connect(_on_npc_interacted)


func _physics_process(_delta: float) -> void:
	_update_camera()
	if _pending_npc != null and _pending_npc.is_player_in_talk_range(_player.global_position):
		var npc := _pending_npc
		_pending_npc = null
		_open_dialog(npc)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		move_player_to(get_global_mouse_position())


func _on_npc_interacted(npc: NpcController) -> void:
	if not npc.is_player_in_talk_range(_player.global_position):
		_pending_npc = npc
		move_player_to(npc.talk_point_for(_player.global_position))
		return
	_open_dialog(npc)


func _open_dialog(npc: NpcController) -> void:
	var movement := _player_movement()
	if movement:
		movement.stop_moving()
		movement.face_target(npc.global_position)
	npc.face_toward_player(_player.global_position)
	_dialog_view.show_dialog(npc.display_name, npc.dialog_text, false, false)


func move_player_to(target: Vector2) -> bool:
	if _dialog_view.is_open():
		return false
	var movement := _player_movement()
	if movement == null:
		return false
	movement.move_to(target)
	return true


func request_starter_area() -> void:
	requested_scene_path = STARTER_AREA_PATH
	show_portal_prompt()


func show_portal_prompt() -> void:
	_portal_prompt.visible = true
	_portal_choices.visible = true


func hide_portal_prompt() -> void:
	_portal_prompt.visible = false
	_portal_choices.visible = false


func _on_portal_yes_pressed() -> void:
	request_starter_area()


func _on_starter_area_portal_body_entered(body: Node) -> void:
	if body.name == "Player":
		show_portal_prompt()


func close_dialog() -> void:
	_dialog_view.hide_dialog()
	_pending_npc = null


func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.global_position = _player.global_position + CAMERA_OFFSET


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
