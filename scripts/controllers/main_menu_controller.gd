## MainMenuController — thin glue for main menu UI.
## Listens to button signals, calls engine methods to transition scenes.
class_name MainMenuController
extends Control

const TOWN_SCENE_PATH := "res://scenes/town_scene.tscn"

var requested_scene_path: String = ""


# ── References ─────────────────────────────────────────────────────────

@onready var _title: Label = $CenterContainer/UI/Title
@onready var _continue_btn: Button = $CenterContainer/UI/ContinueButton
@onready var _new_game_btn: Button = $CenterContainer/UI/NewGameButton
@onready var _confirm_panel: PanelContainer = $CenterContainer/UI/NewGameConfirmPanel
@onready var _confirm_new_game_btn: Button = $CenterContainer/UI/NewGameConfirmPanel/VBox/ConfirmButton
@onready var _cancel_new_game_btn: Button = $CenterContainer/UI/NewGameConfirmPanel/VBox/CancelButton
@onready var _quit_btn: Button = $CenterContainer/UI/QuitButton


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title.text = "Life Well Spent"
	_continue_btn.text = "Continue"
	_new_game_btn.text = "New Game"
	_confirm_new_game_btn.text = "Start New Game"
	_cancel_new_game_btn.text = "Cancel"
	_quit_btn.text = "Quit"
	_title.add_theme_font_size_override("font_size", 36)
	$CenterContainer/UI.add_theme_constant_override("separation", 16)
	_confirm_panel.visible = false

	_continue_btn.pressed.connect(_on_continue_pressed)
	_new_game_btn.pressed.connect(_on_new_game_pressed)
	_confirm_new_game_btn.pressed.connect(_on_confirm_new_game_pressed)
	_cancel_new_game_btn.pressed.connect(_on_cancel_new_game_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)


# ── Actions ────────────────────────────────────────────────────────────

func _on_continue_pressed() -> void:
	continue_existing_run(_profile_system(), _inventory_system())
	requested_scene_path = TOWN_SCENE_PATH
	get_tree().change_scene_to_file(TOWN_SCENE_PATH)


func _on_new_game_pressed() -> void:
	_confirm_panel.visible = true


func _on_confirm_new_game_pressed() -> void:
	start_new_game_from_zero(_profile_system(), _inventory_system())
	get_tree().change_scene_to_file(TOWN_SCENE_PATH)


func _on_cancel_new_game_pressed() -> void:
	_confirm_panel.visible = false


func start_new_game_from_zero(profile_system, inventory_system) -> bool:
	if profile_system == null or not profile_system.has_method("player"):
		return false
	var player = profile_system.player()
	if player == null:
		return false
	if player.has_method("apply_dict"):
		player.apply_dict({})
	if inventory_system and inventory_system.has_method("reset"):
		inventory_system.reset()
	if profile_system.has_method("save_profile"):
		profile_system.save_profile()
	requested_scene_path = TOWN_SCENE_PATH
	return true


func _on_quit_pressed() -> void:
	get_tree().quit()


func continue_existing_run(profile_system, inventory_system) -> bool:
	if profile_system == null or not profile_system.has_method("player"):
		return false
	var player = profile_system.player()
	if player == null or not ("game_over_requested" in player) or not player.game_over_requested:
		return false
	if player.has_method("rebirth"):
		player.rebirth()
	if inventory_system and inventory_system.has_method("reset"):
		inventory_system.reset()
	if profile_system.has_method("save_profile"):
		profile_system.save_profile()
	return true


func _auto_rebirth_ended_run(profile_system, inventory_system) -> bool:
	return continue_existing_run(profile_system, inventory_system)


func _profile_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/ProfileSystem")


func _inventory_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/InventorySystem")
