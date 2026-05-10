## QuestManager — quest catalog and lifecycle management.
## Pure logic. No Node references. Delegates HP deduction to PlayerStats.
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary] = []
var active_quest = null
var quests_taken: int = 0
var max_quests_per_life: int = 2
const QUEST_HP_COST: int = 40


func add_quest(name: String, cost: int, description: String) -> void:
	quest_catalog.append({
		"name": name,
		"cost": cost,
		"description": description,
	})


func take_quest() -> bool:
	if quest_catalog.is_empty():
		return false
	if quests_taken >= max_quests_per_life:
		return false
	var quest: Dictionary = quest_catalog.pop_front()
	active_quest = quest
	quests_taken += 1
	return true


func complete_quest() -> bool:
	if active_quest == null:
		return false
	active_quest = null
	return true


func abandon_quest() -> bool:
	if active_quest == null:
		return false
	active_quest = null
	return true


func reset_for_life() -> void:
	active_quest = null
	quests_taken = 0
