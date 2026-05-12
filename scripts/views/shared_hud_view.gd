## SharedHUDView - global gameplay HUD presentation.
class_name SharedHUDView
extends CanvasLayer

@onready var _life_label: Label = $LifeLabel
@onready var _inventory_button: Button = $InventoryButton
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
	_quest_window = get_node_or_null("QuestWindow") as PanelContainer
	_inventory_window = get_node_or_null("InventoryWindow") as PanelContainer


func set_inventory_model(inventory_model) -> void:
	ensure_ready()
	_connect_inventory_controls()
	_inventory_model = inventory_model


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
	if event is InputEventKey and event.pressed and not event.echo and _is_inventory_key(event):
		toggle_inventory_window()
		var viewport := get_viewport()
		if viewport:
			viewport.set_input_as_handled()


func _connect_inventory_controls() -> void:
	ensure_ready()
	if _inventory_button and not _inventory_button.pressed.is_connected(toggle_inventory_window):
		_inventory_button.pressed.connect(toggle_inventory_window)
	if _inventory_window and _inventory_window.has_signal("close_requested") and not _inventory_window.close_requested.is_connected(close_inventory_window):
		_inventory_window.close_requested.connect(close_inventory_window)


func _is_inventory_key(event: InputEventKey) -> bool:
	return event.keycode == KEY_I or event.physical_keycode == KEY_I or event.unicode == KEY_I
