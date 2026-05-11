## ProgressionModel — coordinates model-only rewards for completed life tasks.
class_name ProgressionModel
extends Object

var player_stats
var quest_manager
var life_tracker
var unlock_rules: Dictionary = {}


func _init(player = null, quests = null, life = null) -> void:
	player_stats = player
	quest_manager = quests
	life_tracker = life


func add_unlock_rule(facility_id: String, xp_required: int) -> void:
	unlock_rules[facility_id] = xp_required


func complete_life_task(task_id: String, date: String) -> bool:
	if player_stats == null or quest_manager == null or life_tracker == null:
		return false
	var before_xp: int = life_tracker.xp
	var completed: bool = life_tracker.complete_task(task_id, date)
	if not completed:
		return false
	var gained_xp: int = life_tracker.xp - before_xp
	player_stats.award_xp(gained_xp)
	if quest_manager.complete_quest_for_life_task(task_id):
		player_stats.complete_quest()
	_apply_unlocks()
	return true


func _apply_unlocks() -> void:
	for facility_id in unlock_rules.keys():
		if player_stats.xp >= int(unlock_rules[facility_id]) and not facility_id in player_stats.unlocked_facilities:
			player_stats.unlocked_facilities.append(facility_id)
