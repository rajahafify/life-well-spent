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
	})


func take_quest(current_hp: int) -> bool:
	if quest_catalog.is_empty():
		last_rejection = "no_quest_available"
		return false
	var quest: Dictionary = quest_catalog.pop_front()
	if current_hp < quest.cost:
		last_rejection = "not_enough_hp"
		quest_catalog.push_front(quest)
		return false
	last_rejection = null
	active_quests.append(quest)
	quests_taken += 1
	return true


func complete_quest() -> bool:
	if active_quests.is_empty():
		return false
	active_quests.pop_front()
	return true


func abandon_quest() -> bool:
	if active_quests.is_empty():
		return false
	active_quests.pop_front()
	return true


func reset_for_life() -> void:
	active_quests.clear()
	quests_taken = 0
