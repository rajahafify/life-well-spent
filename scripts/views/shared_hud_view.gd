## SharedHUDView - global gameplay HUD presentation.
class_name SharedHUDView
extends CanvasLayer

signal shortcut_pressed(slot_number: int, item_id: String)

@onready var _life_label: Label = $LifeLabel
@onready var _inventory_button: Button = $InventoryButton
@onready var _shortcut_bar: HBoxContainer = $ShortcutBar
@onready var _quest_window: PanelContainer = $QuestWindow
@onready var _inventory_window: PanelContainer = $InventoryWindow

var _inventory_model = null


func _ready() -> void:
	ensure_ready()
	_connect_inventory_controls()
	set_life(100, 100)


func ensure_ready() -> void:
	_life_label = get_node_or_null("LifeLabel") as Label
	_inventory_button = get_node_or_null("InventoryButton") as Button
	_shortcut_bar = get_node_or_null("ShortcutBar") as HBoxContainer
	_quest_window = get_node_or_null("QuestWindow") as PanelContainer
	_inventory_window = get_node_or_null("InventoryWindow") as PanelContainer


func set_inventory_model(inventory_model) -> void:
	ensure_ready()
	_connect_inventory_controls()
	_inventory_model = inventory_model
	_render_shortcut_bar()


func set_life(current_life: int, max_life: int) -> void:
	ensure_ready()
	if _life_label:
		_life_label.text = "Life: %d/%d" % [current_life, max_life]


func show_quest(quest_title: String, objective_text: String, checkpoint_text: String = "") -> void:
	ensure_ready()
	if _quest_window and _quest_window.has_method("show_main_objective"):
		_quest_window.show_main_objective(quest_title, objective_text, checkpoint_text)


func toggle_inventory_window() -> void:
	ensure_ready()
	if _inventory_window == null:
		return
	if _inventory_window.visible:
		close_inventory_window()
	elif _inventory_window.has_method("show_inventory"):
		_inventory_window.show_inventory(_inventory_model)


func close_inventory_window() -> void:
	ensure_ready()
	if _inventory_window == null:
		return
	if _inventory_window.has_method("hide_inventory"):
		_inventory_window.hide_inventory()
	else:
		_inventory_window.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if _is_inventory_key(event):
		toggle_inventory_window()
		_mark_input_handled()
		return
	var shortcut_number := _shortcut_number_for_event(event)
	if shortcut_number > 0:
		_emit_shortcut(shortcut_number)
		_mark_input_handled()


func _connect_inventory_controls() -> void:
	ensure_ready()
	if _inventory_button and not _inventory_button.pressed.is_connected(toggle_inventory_window):
		_inventory_button.pressed.connect(toggle_inventory_window)
	if _inventory_window and _inventory_window.has_signal("close_requested") and not _inventory_window.close_requested.is_connected(close_inventory_window):
		_inventory_window.close_requested.connect(close_inventory_window)


func _is_inventory_key(event: InputEventKey) -> bool:
	return event.keycode == KEY_I or event.physical_keycode == KEY_I or event.unicode == KEY_I


func _render_shortcut_bar() -> void:
	if _shortcut_bar == null:
		return
	for child in _shortcut_bar.get_children():
		_shortcut_bar.remove_child(child)
		child.free()
	for slot_number in range(1, 10):
		var label := Label.new()
		var item_id := _shortcut_item(slot_number)
		label.text = "%d\n%s" % [slot_number, item_id if item_id != "" else "-"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(58, 48)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.06, 0.06, 0.06, 1.0))
		label.add_theme_stylebox_override("normal", _shortcut_slot_style())
		_shortcut_bar.add_child(label)


func _shortcut_slot_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color(0.08, 0.08, 0.08, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 6.0
	style.content_margin_top = 4.0
	style.content_margin_right = 6.0
	style.content_margin_bottom = 4.0
	return style


func _shortcut_item(slot_number: int) -> String:
	if _inventory_model and _inventory_model.has_method("shortcut_item"):
		return str(_inventory_model.shortcut_item(slot_number))
	return ""


func _shortcut_number_for_event(event: InputEventKey) -> int:
	for number in range(1, 10):
		var key := KEY_0 + number
		if event.keycode == key or event.physical_keycode == key or event.unicode == key:
			return number
	return 0


func _emit_shortcut(slot_number: int) -> void:
	shortcut_pressed.emit(slot_number, _shortcut_item(slot_number))


func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.set_input_as_handled()
