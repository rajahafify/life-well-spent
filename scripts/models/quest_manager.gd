## QuestManager — quest catalog and lifecycle management.
## Pure logic. No Node references. Delegates HP deduction to PlayerStats.
## No hard limit per life — quest pickup blocked by HP affordability.
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary] = []
var active_quests: Array[Dictionary] = []
var quests_taken: int = 0
var last_rejection = null


func add_quest(name: String, cost: int, description: String) -> void:
	quest_catalog.append({
		"name": name,
		"cost": cost,
		"description": description,
		"life_task_id": "",
	})


func add_life_task_quest(name: String, cost: int, description: String, life_task_id: String) -> void:
	quest_catalog.append({
		"name": name,
		"cost": cost,
		"description": description,
		"life_task_id": life_task_id,
	})


func take_quest(_current_hp: int) -> bool:
	if quest_catalog.is_empty():
		last_rejection = "no_quest_available"
		return false
	var quest: Dictionary = quest_catalog.pop_front()
	last_rejection = null
	active_quests.append(quest)
	quests_taken += 1
	return true


func complete_quest() -> bool:
	if active_quests.is_empty():
		return false
	active_quests.pop_front()
	return true


func complete_quest_for_life_task(life_task_id: String) -> bool:
	for i in range(active_quests.size()):
		if active_quests[i].get("life_task_id", "") == life_task_id:
			active_quests.remove_at(i)
			return true
	return false


func abandon_quest() -> bool:
	if active_quests.is_empty():
		return false
	active_quests.pop_front()
	return true


func reset_for_life() -> void:
	active_quests.clear()
	quests_taken = 0


func to_dict() -> Dictionary:
	return {
		"quest_catalog": quest_catalog.duplicate(true),
		"active_quests": active_quests.duplicate(true),
		"quests_taken": quests_taken,
		"last_rejection": last_rejection,
	}


func apply_dict(data: Dictionary) -> void:
	quest_catalog = _duplicate_array(data.get("quest_catalog", []))
	active_quests = _duplicate_array(data.get("active_quests", []))
	quests_taken = int(data.get("quests_taken", 0))
	last_rejection = data.get("last_rejection", null)


func _duplicate_array(value) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in value:
		result.append(Dictionary(item).duplicate(true))
	return result
