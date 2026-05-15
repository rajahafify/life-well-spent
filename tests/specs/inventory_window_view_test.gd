# tests/specs/inventory_window_view_test.gd
# Spec: InventoryWindowView - reusable inventory overlay scene.

class_name TestInventoryWindowView
extends TestCase

const WINDOW_SCENE := "res://scenes/ui/inventory_window.tscn"
const INVENTORY_SCRIPT := "res://scripts/models/inventory_model.gd"

var window: PanelContainer
var inventory


func setup() -> void:
	var scene := load(WINDOW_SCENE) as PackedScene
	assert_not_null(scene, "Inventory window scene should exist")
	if scene:
		window = scene.instantiate()
		if window.has_method("_ready"):
			window._ready()
	var script := load(INVENTORY_SCRIPT) as GDScript
	inventory = script.new() if script else null


func teardown() -> void:
	if window:
		window.free()
		window = null
	if inventory:
		inventory.free()
		inventory = null


func test_inventory_window_starts_hidden_with_title_and_close_button() -> void:
	if window == null:
		return
	assert_false(window.visible)
	assert_eq("Inventory", (window.get_node("VBox/Header/TitleLabel") as Label).text)
	assert_not_null(window.get_node_or_null("VBox/Header/CloseButton"))


func test_show_inventory_renders_empty_state() -> void:
	if window == null or inventory == null:
		return
	window.show_inventory(inventory)
	assert_true(window.visible)
	var slots := window.get_node("VBox/SlotList") as VBoxContainer
	assert_eq("Weapon: Empty", (slots.get_child(0) as Label).text)
	assert_eq("Armor: Empty", (slots.get_child(1) as Label).text)
	assert_eq("Consumable: Empty", (slots.get_child(2) as Label).text)
	var list := window.get_node("VBox/ItemList") as VBoxContainer
	assert_eq(1, list.get_child_count())
	assert_eq("No items", (list.get_child(0) as Label).text)


func test_show_inventory_renders_item_stacks() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("slime_gel", 2)
	inventory.add_item("rat_tail", 1)
	window.show_inventory(inventory)
	var list := window.get_node("VBox/ItemList") as VBoxContainer
	assert_eq(2, list.get_child_count())
	assert_eq("Rat Tail x1", (list.get_child(0) as Label).text)
	assert_eq("Slime Gel x2", (list.get_child(1) as Label).text)


func test_training_sword_row_has_equip_button() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("training_sword", 1)
	window.show_inventory(inventory)
	var list := window.get_node("VBox/ItemList") as VBoxContainer
	var row := list.get_child(0) as HBoxContainer
	assert_not_null(row)
	assert_eq("Training Sword x1", (row.get_child(0) as Label).text)
	assert_eq("Equip", (row.get_child(1) as Button).text)


func test_equipped_training_sword_row_marks_equipped_state() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("training_sword", 1)
	inventory.equip_weapon("training_sword")
	window.show_inventory(inventory)
	var slots := window.get_node("VBox/SlotList") as VBoxContainer
	assert_eq("Weapon: Training Sword", (slots.get_child(0) as Label).text)
	var row := window.get_node("VBox/ItemList").get_child(0) as HBoxContainer
	assert_eq("Training Sword x1", (row.get_child(0) as Label).text)
	assert_eq("Equipped", (row.get_child(1) as Button).text)
	assert_true((row.get_child(1) as Button).disabled)


func test_equip_button_emits_item_and_slot() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("training_sword", 1)
	window.show_inventory(inventory)
	var emitted: Array = []
	window.equip_item_requested.connect(func(item_id: String, slot: String): emitted.append([item_id, slot]))
	var row := window.get_node("VBox/ItemList").get_child(0) as HBoxContainer
	(row.get_child(1) as Button).pressed.emit()
	assert_eq([["training_sword", "weapon"]], emitted)


func test_apple_row_has_consumable_equip_button() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("apple", 1)
	window.show_inventory(inventory)
	var emitted: Array = []
	window.equip_item_requested.connect(func(item_id: String, slot: String): emitted.append([item_id, slot]))
	var row := window.get_node("VBox/ItemList").get_child(0) as HBoxContainer
	assert_eq("Apple x1", (row.get_child(0) as Label).text)
	(row.get_child(1) as Button).pressed.emit()
	assert_eq([["apple", "consumable"]], emitted)


func test_material_rows_use_readable_display_names() -> void:
	if window == null or inventory == null:
		return
	inventory.add_item("slime_gel", 2)
	inventory.add_item("bat_wing", 1)
	window.show_inventory(inventory)
	var list := window.get_node("VBox/ItemList") as VBoxContainer
	assert_eq("Bat Wing x1", (list.get_child(0) as Label).text)
	assert_eq("Slime Gel x2", (list.get_child(1) as Label).text)


func test_close_button_emits_close_requested() -> void:
	if window == null:
		return
	var emitted: Array = []
	window.close_requested.connect(func(): emitted.append(true))
	(window.get_node("VBox/Header/CloseButton") as Button).pressed.emit()
	assert_eq([true], emitted)
