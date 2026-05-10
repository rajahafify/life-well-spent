## QuestManager — quest catalog and lifecycle management.
## Pure logic. No Node references. Delegates HP deduction to PlayerStats.
## No hard limit per life — quest pickup blocked by HP affordability.
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary] = []
var active_quest = null
var quests_taken: int = 0
var last_rejection = null
const QUEST_HP_COST: int = 40


func add_quest(name: String, cost: int, description: String) -> void:
	quest_catalog.append({
		"name": name,
		"cost": cost,
		"description": description,
	})


func take_quest(current_hp: int = 100) -> bool:
	if quest_catalog.is_empty():
		last_rejection = "no_quest_available"
		return false
	var quest: Dictionary = quest_catalog.pop_front()
	if current_hp < quest.cost:
		last_rejection = "not_enough_hp"
		quest_catalog.push_front(quest)  # return it
		return false
	last_rejection = null
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
