## InventoryModel - pure stackable item counts for loot drops.
class_name InventoryModel
extends Object

var item_counts: Dictionary = {}


func add_item(item_id: String, amount: int = 1) -> bool:
	if item_id.strip_edges() == "" or amount <= 0:
		return false
	item_counts[item_id] = quantity(item_id) + amount
	return true


func quantity(item_id: String) -> int:
	return int(item_counts.get(item_id, 0))


func to_dict() -> Dictionary:
	return {
		"item_counts": item_counts.duplicate(true),
	}


func apply_dict(data: Dictionary) -> void:
	item_counts = Dictionary(data.get("item_counts", {})).duplicate(true)


func summary_text() -> String:
	if item_counts.is_empty():
		return "Inventory: empty"
	var parts: Array[String] = []
	var ids := item_counts.keys()
	ids.sort()
	for item_id in ids:
		var count := quantity(str(item_id))
		if count > 0:
			parts.append("%s x%d" % [str(item_id), count])
	if parts.is_empty():
		return "Inventory: empty"
	return "Inventory: %s" % ", ".join(parts)
