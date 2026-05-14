# tests/specs/shared_hud_view_test.gd
# Spec: SharedHUDView - reusable global HUD for gameplay scenes.

class_name TestSharedHUDView
extends TestCase

const HUD_SCENE := "res://scenes/ui/shared_hud.tscn"
const INVENTORY_SCRIPT := "res://scripts/models/inventory_model.gd"

var hud
var inventory


func setup() -> void:
	var scene: PackedScene = load(HUD_SCENE)
	assert_not_null(scene, "Shared HUD scene should load")
	hud = scene.instantiate() if scene else null
	if hud:
		hud._ready()
	var script := load(INVENTORY_SCRIPT) as GDScript
	inventory = script.new() if script else null


func teardown() -> void:
	if hud:
		hud.free()
		hud = null
	if inventory:
		inventory.free()
		inventory = null


func test_shared_hud_has_life_inventory_button_quest_tracker_and_window() -> void:
	if hud == null:
		return
	assert_not_null(hud.get_node_or_null("LifeLabel") as Label)
	assert_not_null(hud.get_node_or_null("InventoryButton") as Button)
	assert_not_null(hud.get_node_or_null("ShortcutBar") as HBoxContainer)
	assert_not_null(hud.get_node_or_null("QuestWindow") as PanelContainer)
	assert_not_null(hud.get_node_or_null("InventoryWindow") as PanelContainer)
	assert_eq("Inventory", (hud.get_node("InventoryButton") as Button).text)
	assert_false((hud.get_node("InventoryWindow") as PanelContainer).visible)


func test_shared_hud_updates_life_and_quest_tracker() -> void:
	if hud == null:
		return
	hud.set_life(42, 60)
	hud.show_quest("Explore the World", "Get Swordsman Certification.")
	assert_eq("Life: 42/60", (hud.get_node("LifeLabel") as Label).text)
	assert_eq("Explore the World\nGet Swordsman Certification.", (hud.get_node("QuestWindow/VBox/ObjectiveLabel") as Label).text)


func test_inventory_button_and_i_key_toggle_inventory_window() -> void:
	if hud == null or inventory == null:
		return
	inventory.add_item("slime_gel", 2)
	hud.set_inventory_model(inventory)
	var button := hud.get_node("InventoryButton") as Button
	var window := hud.get_node("InventoryWindow") as PanelContainer
	button.pressed.emit()
	assert_true(window.visible)
	assert_eq("slime_gel x2", (window.get_node("VBox/ItemList").get_child(0) as Label).text)
	button.pressed.emit()
	assert_false(window.visible)
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_I
	hud._unhandled_input(event)
	assert_true(window.visible)


func test_inventory_window_equip_button_updates_weapon_slot() -> void:
	if hud == null or inventory == null:
		return
	inventory.add_item("training_sword", 1)
	hud.set_inventory_model(inventory)
	hud.toggle_inventory_window()
	var row := hud.get_node("InventoryWindow/VBox/ItemList").get_child(0) as HBoxContainer
	(row.get_child(1) as Button).pressed.emit()
	assert_eq("training_sword", inventory.weapon_slot)
	var slots := hud.get_node("InventoryWindow/VBox/SlotList") as VBoxContainer
	assert_eq("Weapon: training_sword", (slots.get_child(0) as Label).text)


func test_inventory_window_equip_button_emits_equipment_changed() -> void:
	if hud == null or inventory == null:
		return
	var changed: Array = []
	hud.equipment_changed.connect(func(): changed.append(true))
	inventory.add_item("training_sword", 1)
	hud.set_inventory_model(inventory)
	hud.toggle_inventory_window()
	var row := hud.get_node("InventoryWindow/VBox/ItemList").get_child(0) as HBoxContainer
	(row.get_child(1) as Button).pressed.emit()
	assert_eq([true], changed)


func test_inventory_window_equip_button_updates_consumable_slot_and_shortcut() -> void:
	if hud == null or inventory == null:
		return
	inventory.add_item("apple", 1)
	hud.set_inventory_model(inventory)
	hud.toggle_inventory_window()
	var row := hud.get_node("InventoryWindow/VBox/ItemList").get_child(0) as HBoxContainer
	(row.get_child(1) as Button).pressed.emit()
	assert_eq("apple", inventory.consumable_slot)
	assert_eq("apple", inventory.shortcut_item(1))
	var slots := hud.get_node("InventoryWindow/VBox/SlotList") as VBoxContainer
	assert_eq("Consumable: apple", (slots.get_child(2) as Label).text)
	assert_eq("1\napple", (hud.get_node("ShortcutBar") as HBoxContainer).get_child(0).text)


func test_inventory_button_blocks_world_mouse_input() -> void:
	if hud == null:
		return
	var button := hud.get_node("InventoryButton") as Button
	var inside := button.position + (button.size * 0.5)
	var outside := Vector2(button.position.x + button.size.x + 200.0, button.position.y + button.size.y + 200.0)
	assert_true(hud.blocks_world_mouse_at(inside))
	assert_false(hud.blocks_world_mouse_at(outside))


func test_shortcut_bar_renders_nine_slots_and_number_keys_emit_slot() -> void:
	if hud == null or inventory == null:
		return
	hud.set_inventory_model(inventory)
	var bar := hud.get_node("ShortcutBar") as HBoxContainer
	assert_eq(9, bar.get_child_count())
	assert_eq("1\n-", (bar.get_child(0) as Label).text)
	assert_eq("2\n-", (bar.get_child(1) as Label).text)
	assert_true((bar.get_child(0) as Label).has_theme_stylebox_override("normal"), "Shortcut slots should have a visible border and background")
	var pressed: Array = []
	hud.shortcut_pressed.connect(func(slot_number: int, item_id: String): pressed.append([slot_number, item_id]))
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_1
	hud._unhandled_input(event)
	assert_eq([[1, ""]], pressed)


func test_inventory_key_ignores_echo_events() -> void:
	if hud == null:
		return
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = true
	event.keycode = KEY_I
	hud._unhandled_input(event)
	assert_false((hud.get_node("InventoryWindow") as PanelContainer).visible)


func test_shortcut_number_maps_only_one_through_nine() -> void:
	if hud == null:
		return
	var zero := InputEventKey.new()
	zero.pressed = true
	zero.keycode = KEY_0
	var one := InputEventKey.new()
	one.pressed = true
	one.keycode = KEY_1
	assert_eq(0, hud._shortcut_number_for_event(zero))
	assert_eq(1, hud._shortcut_number_for_event(one))
