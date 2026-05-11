## LifeTracker — pure model for daily tasks, habits, completions, streaks, and XP.
class_name LifeTracker
extends Object

var tasks: Array[Dictionary] = []
var completions: Dictionary = {}
var streaks: Dictionary = {}
var xp: int = 0


func add_task(id: String, title: String, xp_reward: int = 10) -> void:
	if _find_task(id) != null:
		return
	tasks.append({
		"id": id,
		"title": title,
		"xp_reward": xp_reward,
		"habit": false,
	})


func add_habit(id: String, title: String, xp_reward: int = 10) -> void:
	if _find_task(id) != null:
		return
	tasks.append({
		"id": id,
		"title": title,
		"xp_reward": xp_reward,
		"habit": true,
	})
	streaks[id] = 0


func complete_task(id: String, date: String) -> bool:
	var task = _find_task(id)
	if task == null:
		return false
	var key := _completion_key(id, date)
	if completions.has(key):
		return false
	completions[key] = true
	xp += int(task["xp_reward"])
	if bool(task.get("habit", false)):
		_update_streak(id, date)
	return true


func is_task_complete(id: String, date: String) -> bool:
	return completions.has(_completion_key(id, date))


func completed_count_for_date(date: String) -> int:
	var count := 0
	for key in completions.keys():
		if str(key).ends_with("|" + date):
			count += 1
	return count


func streak_for(id: String) -> int:
	return int(streaks.get(id, 0))


func to_dict() -> Dictionary:
	return {
		"tasks": tasks.duplicate(true),
		"completions": completions.duplicate(true),
		"streaks": streaks.duplicate(true),
		"xp": xp,
	}


func apply_dict(data: Dictionary) -> void:
	tasks = _duplicate_array(data.get("tasks", []))
	completions = Dictionary(data.get("completions", {})).duplicate(true)
	streaks = Dictionary(data.get("streaks", {})).duplicate(true)
	xp = int(data.get("xp", 0))


static func from_dict(data: Dictionary):
	var script: GDScript = load("res://scripts/models/life_tracker.gd")
	var tracker = script.new()
	tracker.apply_dict(data)
	return tracker


func _find_task(id: String):
	for task: Dictionary in tasks:
		if task.get("id", "") == id:
			return task
	return null


func _completion_key(id: String, date: String) -> String:
	return "%s|%s" % [id, date]


func _update_streak(id: String, date: String) -> void:
	var previous_date := _latest_completion_before(id, date)
	if previous_date == "":
		streaks[id] = 1
		return
	streaks[id] = int(streaks.get(id, 0)) + 1 if _days_between(previous_date, date) == 1 else 1


func _latest_completion_before(id: String, date: String) -> String:
	var latest := ""
	for key in completions.keys():
		var parts := str(key).split("|")
		if parts.size() != 2 or parts[0] != id or parts[1] >= date:
			continue
		if latest == "" or parts[1] > latest:
			latest = parts[1]
	return latest


func _days_between(first: String, second: String) -> int:
	return _date_ordinal(second) - _date_ordinal(first)


func _date_ordinal(date: String) -> int:
	var parts := date.split("-")
	if parts.size() != 3:
		return 0
	var year := int(parts[0])
	var month := int(parts[1])
	var day := int(parts[2])
	var month_lengths := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	var ordinal := year * 365 + day
	for i in range(month - 1):
		ordinal += month_lengths[i]
	if month > 2 and _is_leap_year(year):
		ordinal += 1
	return ordinal


func _is_leap_year(year: int) -> bool:
	return year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)


func _duplicate_array(value) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in value:
		result.append(Dictionary(item).duplicate(true))
	return result
