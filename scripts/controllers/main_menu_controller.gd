## MainMenuController — thin glue for main menu UI.
## Listens to button signals, calls engine methods to transition scenes.
class_name MainMenuController
extends Control

const TOWN_SCENE_PATH := "res://scenes/town_scene.tscn"

var requested_scene_path: String = ""
var _menu_selection_index: int = 0
var _confirm_selection_index: int = 0


# ── References ─────────────────────────────────────────────────────────

@onready var _title: Label = $CenterContainer/UI/Title
@onready var _continue_btn: Button = $CenterContainer/UI/ContinueButton
@onready var _new_game_btn: Button = $CenterContainer/UI/NewGameButton
@onready var _confirm_panel: PanelContainer = $CenterContainer/UI/NewGameConfirmPanel
@onready var _confirm_new_game_btn: Button = $CenterContainer/UI/NewGameConfirmPanel/VBox/ConfirmButton
@onready var _cancel_new_game_btn: Button = $CenterContainer/UI/NewGameConfirmPanel/VBox/CancelButton
@onready var _quit_btn: Button = $CenterContainer/UI/QuitButton
@onready var _icon_container: CenterContainer = $IconContainer
@onready var _aging_image: TextureRect = $IconContainer/AgingImage


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
	_apply_responsive_layout()

	_continue_btn.pressed.connect(_on_continue_pressed)
	_new_game_btn.pressed.connect(_on_new_game_pressed)
	_confirm_new_game_btn.pressed.connect(_on_confirm_new_game_pressed)
	_cancel_new_game_btn.pressed.connect(_on_cancel_new_game_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)
	_grab_selected_menu_focus()


func apply_layout_for_viewport(viewport_size: Vector2) -> void:
	if viewport_size.y <= 760.0:
		_aging_image.custom_minimum_size = Vector2(380, 285)
		_icon_container.anchor_top = 0.72
		_icon_container.offset_top = 0.0
		_icon_container.offset_bottom = 0.0
	else:
		_aging_image.custom_minimum_size = Vector2(560, 420)
		_icon_container.anchor_top = 0.68
		_icon_container.offset_top = 0.0
		_icon_container.offset_bottom = 0.0


func _apply_responsive_layout() -> void:
	var viewport_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width", 1280),
		ProjectSettings.get_setting("display/window/size/viewport_height", 720)
	)
	if is_inside_tree():
		viewport_size = get_viewport_rect().size
	apply_layout_for_viewport(viewport_size)


# ── Actions ────────────────────────────────────────────────────────────

func _on_continue_pressed() -> void:
	continue_existing_run(_profile_system(), _inventory_system())
	requested_scene_path = TOWN_SCENE_PATH
	get_tree().change_scene_to_file(TOWN_SCENE_PATH)


func _on_new_game_pressed() -> void:
	_confirm_panel.visible = true
	_confirm_selection_index = 0
	_grab_selected_menu_focus()


func _on_confirm_new_game_pressed() -> void:
	start_new_game_from_zero(_profile_system(), _inventory_system())
	get_tree().change_scene_to_file(TOWN_SCENE_PATH)


func _on_cancel_new_game_pressed() -> void:
	_confirm_panel.visible = false
	_grab_selected_menu_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton) or not event.pressed:
		return
	match event.button_index:
		JOY_BUTTON_DPAD_DOWN:
			_move_controller_selection(1)
			_mark_input_handled()
		JOY_BUTTON_DPAD_UP:
			_move_controller_selection(-1)
			_mark_input_handled()
		JOY_BUTTON_A:
			_press_selected_controller_button()
			_mark_input_handled()
		JOY_BUTTON_B:
			if _confirm_panel.visible:
				_on_cancel_new_game_pressed()
				_mark_input_handled()


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


func _move_controller_selection(delta: int) -> void:
	var buttons := _controller_buttons()
	if buttons.is_empty():
		return
	if _confirm_panel.visible:
		_confirm_selection_index = wrapi(_confirm_selection_index + delta, 0, buttons.size())
	else:
		_menu_selection_index = wrapi(_menu_selection_index + delta, 0, buttons.size())
	_grab_selected_menu_focus()


func _press_selected_controller_button() -> void:
	var button := _selected_controller_button()
	if button:
		button.pressed.emit()


func _grab_selected_menu_focus() -> void:
	if not is_inside_tree():
		return
	var button := _selected_controller_button()
	if button:
		button.grab_focus()


func _selected_controller_button() -> Button:
	var buttons := _controller_buttons()
	if buttons.is_empty():
		return null
	var index := _confirm_selection_index if _confirm_panel.visible else _menu_selection_index
	return buttons[clampi(index, 0, buttons.size() - 1)]


func _controller_buttons() -> Array[Button]:
	if _confirm_panel.visible:
		return [_confirm_new_game_btn, _cancel_new_game_btn]
	return [_continue_btn, _new_game_btn, _quit_btn]


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


func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.set_input_as_handled()
