# tests/specs/progression_model_test.gd
# Spec: ProgressionModel — complete life tasks, finish linked quests, unlock facilities

class_name TestProgressionModel
extends TestCase

var player: PlayerStats
var quests: QuestManager
var life
var progression


func _new_script_object(path: String, args: Array = []):
	var script: GDScript = load(path)
	return Callable(script, "new").callv(args)


func setup() -> void:
	player = PlayerStats.new()
	quests = QuestManager.new()
	life = _new_script_object("res://scripts/models/life_tracker.gd")
	progression = _new_script_object("res://scripts/models/progression_model.gd", [player, quests, life])


func teardown() -> void:
	progression.free()
	life.free()
	quests.free()
	player.free()


func _start_swordsman_chain() -> void:
	quests.setup_core_quests()
	quests.mark_main_checkpoint("explore_the_world", "forest_guard")
	quests.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	quests.activate_swordsman_guild_chain()


func _complete_current_swordsman_objective(enemy_id: String, count: int) -> void:
	for _i in range(count):
		quests.record_enemy_defeated(enemy_id)


func _gather_current_swordsman_item(item_id: String, count: int) -> void:
	for _i in range(count):
		quests.record_item_gathered(item_id)


func test_complete_life_task_adds_xp_to_player() -> void:
	life.add_task("hydrate", "Drink water", 10)
	progression.complete_life_task("hydrate", "2026-05-11")
	assert_eq(10, life.xp)
	assert_eq(10, player.xp)


func test_life_task_completion_completes_linked_quest() -> void:
	quests.add_life_task_quest("Hydrate Quest", 40, "Drink water", "hydrate")
	quests.take_quest(player.max_hp)
	life.add_task("hydrate", "Drink water", 10)
	progression.complete_life_task("hydrate", "2026-05-11")
	assert_eq(0, quests.active_quests.size())
	assert_eq(60, player.max_hp)


func test_xp_unlocks_facility_once() -> void:
	life.add_task("walk", "Take walk", 60)
	progression.add_unlock_rule("garden", 50)
	progression.complete_life_task("walk", "2026-05-11")
	progression.complete_life_task("walk", "2026-05-12")
	assert_in("garden", player.unlocked_facilities)
	assert_eq(1, player.unlocked_facilities.size())


func test_swordsman_certification_rejects_inactive_chain() -> void:
	var result: bool = progression.complete_swordsman_certification_step()
	assert_false(result)
	assert_eq(100, player.max_hp)


func test_swordsman_certification_rejects_incomplete_objective() -> void:
	_start_swordsman_chain()
	assert_false(progression.complete_swordsman_certification_step())
	assert_eq(100, player.max_hp)
	assert_eq(0, quests.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_certification_step_one_spends_life_to_60() -> void:
	_start_swordsman_chain()
	_complete_current_swordsman_objective("slime_spiked", 10)
	assert_true(progression.complete_swordsman_certification_step())
	assert_eq(60, player.max_hp)
	assert_eq(1, quests.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_certification_step_two_spends_life_to_20() -> void:
	_start_swordsman_chain()
	_complete_current_swordsman_objective("slime_spiked", 10)
	progression.complete_swordsman_certification_step()
	_gather_current_swordsman_item("bat_wing", 2)
	assert_true(progression.complete_swordsman_certification_step())
	assert_eq(20, player.max_hp)
	assert_eq(2, quests.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_certification_step_three_unlocks_guild_and_requests_game_over() -> void:
	_start_swordsman_chain()
	_complete_current_swordsman_objective("slime_spiked", 10)
	progression.complete_swordsman_certification_step()
	_gather_current_swordsman_item("bat_wing", 2)
	progression.complete_swordsman_certification_step()
	_complete_current_swordsman_objective("rat", 2)
	assert_true(progression.complete_swordsman_certification_step())
	assert_eq(0, player.max_hp)
	assert_true(player.game_over_requested)
	assert_true(quests.has_certification("swordsman_certification"))
	assert_in("swordsman_guild", player.unlocked_facilities)
	assert_false(quests.is_side_quest_active("rebuilding_swordsman_guild"))


func test_swordsman_certification_step_three_advances_main_objective() -> void:
	_start_swordsman_chain()
	_complete_current_swordsman_objective("slime_spiked", 10)
	progression.complete_swordsman_certification_step()
	_gather_current_swordsman_item("bat_wing", 2)
	progression.complete_swordsman_certification_step()
	_complete_current_swordsman_objective("rat", 2)
	progression.complete_swordsman_certification_step()
	assert_eq("enter_forest", quests.current_main_objective_id())
	assert_eq("Enter the Forest.", quests.current_main_objective_text())
