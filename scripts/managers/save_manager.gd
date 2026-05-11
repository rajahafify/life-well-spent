## SaveManager — persistence boundary for player, quests, and life tracker.
class_name SaveManager
extends Object


func build_save_data(player: PlayerStats, quests: QuestManager, life) -> Dictionary:
	return {
		"version": 1,
		"player": player.to_dict(),
		"quests": quests.to_dict(),
		"life": life.to_dict(),
	}


func apply_save_data(data: Dictionary, player: PlayerStats, quests: QuestManager, life) -> void:
	player.apply_dict(Dictionary(data.get("player", {})))
	quests.apply_dict(Dictionary(data.get("quests", {})))
	life.apply_dict(Dictionary(data.get("life", {})))


func save_to_file(path: String, player: PlayerStats, quests: QuestManager, life) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(build_save_data(player, quests, life)))
	file.close()
	return true


func load_from_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	return Dictionary(parsed) if parsed is Dictionary else {}
