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
	assert_eq("Weapon: wooden_sword", (slots.get_child(0) as Label).text)
	assert_eq("Armor: cloth_armor", (slots.get_child(1) as Label).text)
	assert_eq("Consumable: apple", (slots.get_child(2) as Label).text)
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
	assert_eq("rat_tail x1", (list.get_child(0) as Label).text)
	assert_eq("slime_gel x2", (list.get_child(1) as Label).text)


func test_close_button_emits_close_requested() -> void:
	if window == null:
		return
	var emitted: Array = []
	window.close_requested.connect(func(): emitted.append(true))
	(window.get_node("VBox/Header/CloseButton") as Button).pressed.emit()
	assert_eq([true], emitted)
