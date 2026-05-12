## QuestSystem - game-wide runtime boundary for main and side quest state.
extends Node

const QUEST_MANAGER_SCRIPT := preload("res://scripts/models/quest_manager.gd")

var quests = QUEST_MANAGER_SCRIPT.new()


func _ready() -> void:
	setup_core_quests()


func reset() -> void:
	quests.free()
	quests = QUEST_MANAGER_SCRIPT.new()
	setup_core_quests()


func setup_core_quests() -> void:
	quests.setup_core_quests()


func current_main_objective_id(main_id: String = "explore_the_world") -> String:
	return quests.current_main_objective_id(main_id)


func current_main_objective_text(main_id: String = "explore_the_world") -> String:
	return quests.current_main_objective_text(main_id)


func advance_main_quest_objective(main_id: String, objective_id: String) -> bool:
	return quests.advance_main_quest_objective(main_id, objective_id)


func mark_main_checkpoint(main_id: String, checkpoint_id: String) -> bool:
	return quests.mark_main_checkpoint(main_id, checkpoint_id)


func has_main_checkpoint(main_id: String, checkpoint_id: String) -> bool:
	return quests.has_main_checkpoint(main_id, checkpoint_id)


func current_main_checkpoint_text(main_id: String = "explore_the_world") -> String:
	return quests.current_main_checkpoint_text(main_id)


func is_side_quest_active(chain_id: String) -> bool:
	return quests.is_side_quest_active(chain_id)


func side_quest_step(chain_id: String) -> int:
	return quests.side_quest_step(chain_id)


func current_side_quest_objective_text(chain_id: String) -> String:
	return quests.current_side_quest_objective_text(chain_id)


func advance_side_quest_step(chain_id: String) -> bool:
	return quests.advance_side_quest_step(chain_id)


func complete_side_quest_chain(chain_id: String) -> bool:
	return quests.complete_side_quest_chain(chain_id)


func has_seen_town_reborn_intro() -> bool:
	return quests.has_seen_town_reborn_intro()


func mark_town_reborn_intro_seen() -> bool:
	return quests.mark_town_reborn_intro_seen()


func has_certification(certification_id: String) -> bool:
	return quests.has_certification(certification_id)


func to_dict() -> Dictionary:
	return quests.to_dict()


func apply_dict(data: Dictionary) -> void:
	quests.apply_dict(data)
	setup_core_quests()
