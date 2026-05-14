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
	assert_eq("", inventory.weapon_slot)
	assert_eq("", inventory.armor_slot)
	assert_eq("", inventory.consumable_slot)
	assert_eq("Weapon: \nArmor: \nConsumable: ", inventory.slot_summary_text())
	assert_eq("", inventory.shortcut_item(1))
	assert_eq("", inventory.shortcut_item(2))
	assert_eq("", inventory.shortcut_item(9))


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
	inventory.add_item("training_sword", 1)
	inventory.add_item("leather_armor", 1)
	inventory.add_item("apple", 1)
	inventory.equip_weapon("training_sword")
	inventory.equip_armor("leather_armor")
	inventory.set_consumable("apple")
	inventory.assign_shortcut(2, "slime_gel")
	var script := load("res://scripts/models/inventory_model.gd") as GDScript
	var restored = script.new()
	restored.apply_dict(inventory.to_dict())
	assert_eq(2, restored.quantity("slime_gel"))
	assert_eq(1, restored.quantity("training_sword"))
	assert_eq(1, restored.quantity("leather_armor"))
	assert_eq(1, restored.quantity("apple"))
	assert_eq("training_sword", restored.weapon_slot)
	assert_eq("leather_armor", restored.armor_slot)
	assert_eq("apple", restored.consumable_slot)
	assert_eq("apple", restored.shortcut_item(1))
	assert_eq("slime_gel", restored.shortcut_item(2))
	restored.free()


func test_summary_text_lists_item_counts() -> void:
	if inventory == null:
		return
	assert_eq("Inventory: empty", inventory.summary_text())
	inventory.add_item("slime_gel", 2)
	assert_eq("Inventory: slime_gel x2", inventory.summary_text())


func test_items_list_returns_sorted_public_item_rows() -> void:
	if inventory == null:
		return
	inventory.add_item("slime_gel", 2)
	inventory.add_item("rat_tail", 1)
	var rows: Array = inventory.items_list()
	assert_eq(2, rows.size())
	assert_eq("rat_tail", rows[0]["item_id"])
	assert_eq(1, rows[0]["quantity"])
	assert_eq("slime_gel", rows[1]["item_id"])
	assert_eq(2, rows[1]["quantity"])
	assert_eq("", rows[1]["equipment_slot"])


func test_training_sword_can_equip_when_owned() -> void:
	if inventory == null:
		return
	inventory.add_item("training_sword", 1)
	assert_true(inventory.equip_weapon("training_sword"))
	assert_eq("training_sword", inventory.weapon_slot)


func test_apple_can_be_set_as_consumable_when_owned() -> void:
	if inventory == null:
		return
	inventory.add_item("apple", 1)
	assert_true(inventory.set_consumable("apple"))
	assert_eq("apple", inventory.consumable_slot)
	assert_eq("apple", inventory.shortcut_item(1))


func test_equipment_slots_reject_unowned_equipment() -> void:
	if inventory == null:
		return
	assert_false(inventory.equip_weapon("training_sword"))
	assert_false(inventory.equip_armor("leather_armor"))
	assert_false(inventory.set_consumable("apple"))
	assert_eq("", inventory.weapon_slot)
	assert_eq("", inventory.armor_slot)
	assert_eq("", inventory.consumable_slot)


func test_equipment_slots_reject_blank_ids() -> void:
	if inventory == null:
		return
	assert_false(inventory.equip_weapon(""))
	assert_false(inventory.equip_armor(""))
	assert_false(inventory.set_consumable(""))
	assert_eq("", inventory.weapon_slot)
	assert_eq("", inventory.armor_slot)
	assert_eq("", inventory.consumable_slot)


func test_consume_item_reduces_stack_only_when_available() -> void:
	if inventory == null:
		return
	assert_false(inventory.consume_item("apple"))
	inventory.add_item("apple", 2)
	assert_true(inventory.consume_item("apple"))
	assert_eq(1, inventory.quantity("apple"))
	assert_true(inventory.consume_item("apple"))
	assert_eq(0, inventory.quantity("apple"))
	assert_false(inventory.consume_item("apple"))


func test_shortcut_slots_map_one_through_nine() -> void:
	if inventory == null:
		return
	assert_true(inventory.assign_shortcut(9, "rat_tail"))
	assert_eq("rat_tail", inventory.shortcut_item(9))
	assert_false(inventory.assign_shortcut(0, "slime_gel"))
	assert_false(inventory.assign_shortcut(10, "slime_gel"))
	assert_eq("", inventory.shortcut_item(0))
	assert_eq("", inventory.shortcut_item(10))
