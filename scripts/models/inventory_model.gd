## InventoryModel - pure stackable item counts for loot drops.
class_name InventoryModel
extends Object

var item_counts: Dictionary = {}
var weapon_slot: String = ""
var armor_slot: String = ""
var consumable_slot: String = ""
var shortcut_slots: Array[String] = ["", "", "", "", "", "", "", "", ""]


func reset() -> void:
	item_counts.clear()
	weapon_slot = ""
	armor_slot = ""
	consumable_slot = ""
	shortcut_slots = ["", "", "", "", "", "", "", "", ""]


func add_item(item_id: String, amount: int = 1) -> bool:
	if item_id.strip_edges() == "" or amount <= 0:
		return false
	item_counts[item_id] = quantity(item_id) + amount
	return true


func quantity(item_id: String) -> int:
	return int(item_counts.get(item_id, 0))


func consume_item(item_id: String, amount: int = 1) -> bool:
	if item_id.strip_edges() == "" or amount <= 0 or quantity(item_id) < amount:
		return false
	item_counts[item_id] = quantity(item_id) - amount
	if quantity(item_id) <= 0:
		item_counts.erase(item_id)
	return true


func equip_weapon(item_id: String) -> bool:
	if not can_equip_weapon(item_id):
		return false
	weapon_slot = item_id
	return true


func equip_armor(item_id: String) -> bool:
	if not can_equip_armor(item_id):
		return false
	armor_slot = item_id
	return true


func set_consumable(item_id: String) -> bool:
	if not can_set_consumable(item_id):
		return false
	consumable_slot = item_id
	assign_shortcut(1, item_id)
	return true


func assign_shortcut(slot_number: int, item_id: String) -> bool:
	if slot_number < 1 or slot_number > 9:
		return false
	shortcut_slots[slot_number - 1] = item_id.strip_edges()
	return true


func shortcut_item(slot_number: int) -> String:
	if slot_number < 1 or slot_number > 9:
		return ""
	return str(shortcut_slots[slot_number - 1])


func to_dict() -> Dictionary:
	return {
		"item_counts": item_counts.duplicate(true),
		"weapon_slot": weapon_slot,
		"armor_slot": armor_slot,
		"consumable_slot": consumable_slot,
		"shortcut_slots": shortcut_slots.duplicate(true),
	}


func apply_dict(data: Dictionary) -> void:
	item_counts = Dictionary(data.get("item_counts", {})).duplicate(true)
	weapon_slot = str(data.get("weapon_slot", ""))
	armor_slot = str(data.get("armor_slot", ""))
	consumable_slot = str(data.get("consumable_slot", ""))
	shortcut_slots = _normalized_shortcut_slots(Array(data.get("shortcut_slots", [])))


func slot_summary_text() -> String:
	return "Weapon: %s\nArmor: %s\nConsumable: %s" % [weapon_slot, armor_slot, consumable_slot]


func items_list() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var ids := item_counts.keys()
	ids.sort()
	for item_id in ids:
		var count := quantity(str(item_id))
		if count > 0:
			rows.append({
				"item_id": str(item_id),
				"quantity": count,
				"equipment_slot": equipment_slot_for_item(str(item_id)),
			})
	return rows


func can_equip_weapon(item_id: String) -> bool:
	return equipment_slot_for_item(item_id) == "weapon" and quantity(item_id) > 0


func can_equip_armor(item_id: String) -> bool:
	return equipment_slot_for_item(item_id) == "armor" and quantity(item_id) > 0


func can_set_consumable(item_id: String) -> bool:
	return equipment_slot_for_item(item_id) == "consumable" and quantity(item_id) > 0


func equipment_slot_for_item(item_id: String) -> String:
	match item_id.strip_edges():
		"training_sword":
			return "weapon"
		"leather_armor":
			return "armor"
		"apple":
			return "consumable"
	return ""


func _normalized_shortcut_slots(values: Array) -> Array[String]:
	var normalized: Array[String] = []
	for index in range(9):
		normalized.append(str(values[index]) if index < values.size() else "")
	return normalized


func summary_text() -> String:
	var parts: Array[String] = []
	for row in items_list():
		parts.append("%s x%d" % [row["item_id"], row["quantity"]])
	if parts.is_empty():
		return "Inventory: empty"
	return "Inventory: %s" % ", ".join(parts)
