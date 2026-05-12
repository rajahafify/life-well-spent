## QuestManager — quest catalog and lifecycle management.
## Pure logic. No Node references. Delegates HP deduction to PlayerStats.
## No hard limit per life — quest pickup blocked by HP affordability.
class_name QuestManager
extends Object

const MAIN_EXPLORE_WORLD := "explore_the_world"
const OBJ_FIND_FOREST_PATH := "find_forest_path"
const OBJ_GET_SWORDSMAN_CERTIFICATION := "get_swordsman_certification"
const OBJ_ENTER_FOREST := "enter_forest"
const CHECKPOINT_FOREST_GUARD := "forest_guard"
const SIDE_REBUILD_SWORDSMAN_GUILD := "rebuilding_swordsman_guild"
const CERT_SWORDSMAN := "swordsman_certification"
const PROGRESS_KEY := "objective_progress"

var quest_catalog: Array[Dictionary] = []
var active_quests: Array[Dictionary] = []
var quests_taken: int = 0
var last_rejection = null
var main_quests: Dictionary = {}
var side_quest_chains: Dictionary = {}
var certifications: Dictionary = {}
var town_reborn_intro_seen: bool = false


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


func setup_core_quests() -> void:
	if not main_quests.has(MAIN_EXPLORE_WORLD):
		main_quests[MAIN_EXPLORE_WORLD] = {
			"title": "Explore the World",
			"objective_id": OBJ_FIND_FOREST_PATH,
			"objectives": {
				OBJ_FIND_FOREST_PATH: "Find the Forest path.",
				OBJ_GET_SWORDSMAN_CERTIFICATION: "Get Swordsman Certification.",
				OBJ_ENTER_FOREST: "Enter the Forest.",
			},
			"checkpoints": {
				CHECKPOINT_FOREST_GUARD: {
					"text": "Forest Guard reached.",
					"completed": false,
				},
			},
			"active": true,
			"completed": false,
		}


func current_main_objective_id(main_id: String = MAIN_EXPLORE_WORLD) -> String:
	setup_core_quests()
	if not main_quests.has(main_id):
		return ""
	return str(main_quests[main_id].get("objective_id", ""))


func current_main_objective_text(main_id: String = MAIN_EXPLORE_WORLD) -> String:
	setup_core_quests()
	if not main_quests.has(main_id):
		return ""
	var quest: Dictionary = main_quests[main_id]
	var objectives: Dictionary = quest.get("objectives", {})
	return str(objectives.get(quest.get("objective_id", ""), ""))


func advance_main_quest_objective(main_id: String, objective_id: String) -> bool:
	setup_core_quests()
	if not main_quests.has(main_id):
		return false
	var quest: Dictionary = main_quests[main_id]
	var objectives: Dictionary = quest.get("objectives", {})
	if not objectives.has(objective_id):
		return false
	quest["objective_id"] = objective_id
	main_quests[main_id] = quest
	if main_id == MAIN_EXPLORE_WORLD and objective_id == OBJ_GET_SWORDSMAN_CERTIFICATION:
		_activate_swordsman_guild_chain()
	return true


func mark_main_checkpoint(main_id: String, checkpoint_id: String) -> bool:
	setup_core_quests()
	if not main_quests.has(main_id):
		return false
	var quest: Dictionary = main_quests[main_id]
	var checkpoints: Dictionary = quest.get("checkpoints", {})
	if not checkpoints.has(checkpoint_id):
		return false
	var checkpoint: Dictionary = checkpoints[checkpoint_id]
	checkpoint["completed"] = true
	checkpoints[checkpoint_id] = checkpoint
	quest["checkpoints"] = checkpoints
	main_quests[main_id] = quest
	return true


func has_main_checkpoint(main_id: String, checkpoint_id: String) -> bool:
	setup_core_quests()
	if not main_quests.has(main_id):
		return false
	var checkpoints: Dictionary = main_quests[main_id].get("checkpoints", {})
	if not checkpoints.has(checkpoint_id):
		return false
	return bool(Dictionary(checkpoints[checkpoint_id]).get("completed", false))


func current_main_checkpoint_text(main_id: String = MAIN_EXPLORE_WORLD) -> String:
	setup_core_quests()
	if not main_quests.has(main_id):
		return ""
	var checkpoints: Dictionary = main_quests[main_id].get("checkpoints", {})
	for checkpoint_id in checkpoints.keys():
		var checkpoint: Dictionary = checkpoints[checkpoint_id]
		if bool(checkpoint.get("completed", false)):
			return str(checkpoint.get("text", ""))
	return ""


func is_side_quest_active(chain_id: String) -> bool:
	if not side_quest_chains.has(chain_id):
		return false
	var chain: Dictionary = side_quest_chains[chain_id]
	return bool(chain.get("active", false)) and not bool(chain.get("completed", false))


func side_quest_step(chain_id: String) -> int:
	if not side_quest_chains.has(chain_id):
		return -1
	return int(Dictionary(side_quest_chains[chain_id]).get("step", 0))


func current_side_quest_objective_text(chain_id: String) -> String:
	if not side_quest_chains.has(chain_id):
		return ""
	var chain: Dictionary = side_quest_chains[chain_id]
	var step := int(chain.get("step", 0))
	var objective := _swordsman_objective_for_step(step)
	if objective.is_empty():
		return "Swordsman Guild unlocked."
	var progress := _swordsman_objective_progress(chain, step)
	var required := int(objective.get("required", 1))
	return "%s (%d/%d)" % [str(objective.get("text", "")), mini(progress, required), required]


func record_enemy_defeated(enemy_id: String) -> bool:
	if not is_side_quest_active(SIDE_REBUILD_SWORDSMAN_GUILD):
		return false
	var chain: Dictionary = side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD]
	var step := int(chain.get("step", 0))
	var objective := _swordsman_objective_for_step(step)
	if objective.is_empty() or str(objective.get("type", "enemy")) != "enemy" or str(objective.get("enemy_id", "")) != enemy_id:
		return false
	return _advance_swordsman_objective_progress(chain, step, 1)


func record_item_gathered(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0 or not is_side_quest_active(SIDE_REBUILD_SWORDSMAN_GUILD):
		return false
	var chain: Dictionary = side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD]
	var step := int(chain.get("step", 0))
	var objective := _swordsman_objective_for_step(step)
	if objective.is_empty() or str(objective.get("type", "enemy")) != "item" or str(objective.get("item_id", "")) != item_id:
		return false
	return _advance_swordsman_objective_progress(chain, step, quantity)


func _advance_swordsman_objective_progress(chain: Dictionary, step: int, amount: int) -> bool:
	var objective := _swordsman_objective_for_step(step)
	if objective.is_empty():
		return false
	var required := int(objective.get("required", 1))
	var progress: Dictionary = Dictionary(chain.get(PROGRESS_KEY, {})).duplicate(true)
	var progress_key := str(step)
	var current := int(progress.get(progress_key, 0))
	if current >= required:
		return false
	progress[progress_key] = mini(current + amount, required)
	chain[PROGRESS_KEY] = progress
	side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD] = chain
	return true


func is_current_side_quest_step_complete(chain_id: String) -> bool:
	if not side_quest_chains.has(chain_id):
		return false
	var chain: Dictionary = side_quest_chains[chain_id]
	var step := int(chain.get("step", 0))
	var objective := _swordsman_objective_for_step(step)
	if objective.is_empty():
		return false
	return _swordsman_objective_progress(chain, step) >= int(objective.get("required", 1))


func advance_side_quest_step(chain_id: String) -> bool:
	if not is_side_quest_active(chain_id):
		return false
	var chain: Dictionary = side_quest_chains[chain_id]
	var step := int(chain.get("step", 0))
	var max_step := int(chain.get("max_step", 1))
	if step >= max_step:
		return false
	if chain_id == SIDE_REBUILD_SWORDSMAN_GUILD and not is_current_side_quest_step_complete(chain_id):
		return false
	chain["step"] = step + 1
	side_quest_chains[chain_id] = chain
	return true


func complete_side_quest_chain(chain_id: String) -> bool:
	if not side_quest_chains.has(chain_id):
		return false
	var chain: Dictionary = side_quest_chains[chain_id]
	if bool(chain.get("completed", false)):
		return false
	chain["active"] = false
	chain["completed"] = true
	side_quest_chains[chain_id] = chain
	if chain_id == SIDE_REBUILD_SWORDSMAN_GUILD:
		certifications[CERT_SWORDSMAN] = true
	return true


func has_seen_town_reborn_intro() -> bool:
	return town_reborn_intro_seen


func mark_town_reborn_intro_seen() -> bool:
	if town_reborn_intro_seen:
		return false
	town_reborn_intro_seen = true
	return true


func has_certification(certification_id: String) -> bool:
	return bool(certifications.get(certification_id, false))


func to_dict() -> Dictionary:
	return {
		"quest_catalog": quest_catalog.duplicate(true),
		"active_quests": active_quests.duplicate(true),
		"quests_taken": quests_taken,
		"last_rejection": last_rejection,
		"main_quests": main_quests.duplicate(true),
		"side_quest_chains": side_quest_chains.duplicate(true),
		"certifications": certifications.duplicate(true),
		"town_reborn_intro_seen": town_reborn_intro_seen,
	}


func apply_dict(data: Dictionary) -> void:
	quest_catalog = _duplicate_array(data.get("quest_catalog", []))
	active_quests = _duplicate_array(data.get("active_quests", []))
	quests_taken = int(data.get("quests_taken", 0))
	last_rejection = data.get("last_rejection", null)
	main_quests = Dictionary(data.get("main_quests", {})).duplicate(true)
	side_quest_chains = Dictionary(data.get("side_quest_chains", {})).duplicate(true)
	certifications = Dictionary(data.get("certifications", {})).duplicate(true)
	town_reborn_intro_seen = bool(data.get("town_reborn_intro_seen", false))


func _duplicate_array(value) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in value:
		result.append(Dictionary(item).duplicate(true))
	return result


func _activate_swordsman_guild_chain() -> void:
	if side_quest_chains.has(SIDE_REBUILD_SWORDSMAN_GUILD):
		var existing: Dictionary = side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD]
		if not bool(existing.get("completed", false)):
			existing["active"] = true
			side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD] = existing
		return
	side_quest_chains[SIDE_REBUILD_SWORDSMAN_GUILD] = {
		"title": "Rebuilding Swordsman Guild",
		"active": true,
		"completed": false,
		"step": 0,
		"max_step": 3,
		PROGRESS_KEY: {},
	}


func _swordsman_objective_for_step(step: int) -> Dictionary:
	match step:
		0:
			return {
				"type": "enemy",
				"enemy_id": "slime_spiked",
				"required": 10,
				"text": "Defeat 10 Slimes for Guildmaster stance training.",
			}
		1:
			return {
				"type": "item",
				"item_id": "bat_wing",
				"required": 2,
				"text": "Gather 2 Bat Wings for Guildmaster guard training.",
			}
		2:
			return {
				"type": "enemy",
				"enemy_id": "rat",
				"required": 2,
				"text": "Defeat 2 Rats for the Guildmaster's Life oath.",
			}
	return {}


func _swordsman_objective_progress(chain: Dictionary, step: int) -> int:
	var progress: Dictionary = chain.get(PROGRESS_KEY, {})
	return int(progress.get(str(step), 0))
