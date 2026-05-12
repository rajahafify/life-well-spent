# tests/specs/inventory_model_test.gd
# Spec: InventoryModel - stackable item counts for Field drops.

class_name TestInventoryModel
extends TestCase

var inventory


func setup() -> void:
	var script := load("res://scripts/models/inventory_model.gd") as GDScript
	assert_not_null(script, "InventoryModel script should exist")
	if script:
		inventory = script.new()


func teardown() -> void:
	if inventory:
		inventory.free()
		inventory = null


func test_inventory_starts_empty() -> void:
	if inventory == null:
		return
	assert_eq(0, inventory.quantity("slime_gel"))


func test_add_item_stacks_quantities() -> void:
	if inventory == null:
		return
	assert_true(inventory.add_item("slime_gel", 1))
	assert_true(inventory.add_item("slime_gel", 2))
	assert_eq(3, inventory.quantity("slime_gel"))


func test_add_item_rejects_blank_id_and_non_positive_quantity() -> void:
	if inventory == null:
		return
	assert_false(inventory.add_item("", 1))
	assert_false(inventory.add_item("slime_gel", 0))
	assert_eq(0, inventory.quantity("slime_gel"))


func test_to_dict_round_trips_item_counts() -> void:
	if inventory == null:
		return
	inventory.add_item("slime_gel", 2)
	var script := load("res://scripts/models/inventory_model.gd") as GDScript
	var restored = script.new()
	restored.apply_dict(inventory.to_dict())
	assert_eq(2, restored.quantity("slime_gel"))
	restored.free()


func test_summary_text_lists_item_counts() -> void:
	if inventory == null:
		return
	assert_eq("Inventory: empty", inventory.summary_text())
	inventory.add_item("slime_gel", 2)
	assert_eq("Inventory: slime_gel x2", inventory.summary_text())
