## InventoryWindowView - reusable inventory overlay presentation.
class_name InventoryWindowView
extends PanelContainer

signal close_requested

var _item_list: VBoxContainer
var _slot_list: VBoxContainer
var _close_button: Button


func _ready() -> void:
	ensure_ready()
	visible = false


func ensure_ready() -> void:
	_slot_list = get_node_or_null("VBox/SlotList") as VBoxContainer
	_item_list = get_node_or_null("VBox/ItemList") as VBoxContainer
	_close_button = get_node_or_null("VBox/Header/CloseButton") as Button
	if _close_button and not _close_button.pressed.is_connected(_on_close_pressed):
		_close_button.pressed.connect(_on_close_pressed)


func show_inventory(inventory) -> void:
	ensure_ready()
	visible = true
	_render_slots(inventory)
	_clear_items()
	if inventory == null or inventory.item_counts.is_empty():
		_add_item_label("No items")
		return
	var ids: Array = inventory.item_counts.keys()
	ids.sort()
	for item_id in ids:
		var count: int = inventory.quantity(str(item_id))
		if count > 0:
			_add_item_label("%s x%d" % [str(item_id), count])
	if _item_list.get_child_count() == 0:
		_add_item_label("No items")


func hide_inventory() -> void:
	visible = false


func _clear_items() -> void:
	for child in _item_list.get_children():
		_item_list.remove_child(child)
		child.free()


func _render_slots(inventory) -> void:
	if _slot_list == null:
		return
	for child in _slot_list.get_children():
		_slot_list.remove_child(child)
		child.free()
	if inventory == null:
		_add_slot_label("Weapon: -")
		_add_slot_label("Armor: -")
		_add_slot_label("Consumable: -")
		return
	_add_slot_label("Weapon: %s" % str(inventory.weapon_slot))
	_add_slot_label("Armor: %s" % str(inventory.armor_slot))
	_add_slot_label("Consumable: %s" % str(inventory.consumable_slot))


func _add_slot_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	_slot_list.add_child(label)


func _add_item_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	_item_list.add_child(label)


func _on_close_pressed() -> void:
	close_requested.emit()
