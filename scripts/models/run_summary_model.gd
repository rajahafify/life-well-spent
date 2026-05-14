## RunSummaryModel - pure text summary for a completed life run.
class_name RunSummaryModel
extends Object


func summary_lines(player_stats, inventory) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Run Summary")
	lines.append("Items: %s" % _items_text(inventory))
	lines.append("Unlocks: %s" % _unlocks_text(player_stats))
	return lines


func summary_text(player_stats, inventory) -> String:
	return "\n".join(summary_lines(player_stats, inventory))


func _items_text(inventory) -> String:
	if inventory == null or not inventory.has_method("items_list"):
		return "none"
	var parts: Array[String] = []
	for row in inventory.items_list():
		parts.append("%s x%d" % [str(row.get("item_id", "")), int(row.get("quantity", 0))])
	return "none" if parts.is_empty() else ", ".join(parts)


func _unlocks_text(player_stats) -> String:
	if player_stats == null:
		return "none"
	var facilities: Array = player_stats.unlocked_facilities if "unlocked_facilities" in player_stats else []
	if facilities.is_empty():
		return "none"
	var parts: Array[String] = []
	for facility in facilities:
		parts.append(_display_name_for_unlock(str(facility)))
	return ", ".join(parts)


func _display_name_for_unlock(unlock_id: String) -> String:
	match unlock_id:
		"swordsman_guild":
			return "Swordsman Guild"
		_:
			return unlock_id.capitalize()
