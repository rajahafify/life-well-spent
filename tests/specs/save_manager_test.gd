# tests/specs/save_manager_test.gd
# Spec: SaveManager — serializes player, quest, and life-tracking state

class_name TestSaveManager
extends TestCase

var player: PlayerStats
var quests: QuestManager
var life
var save_manager


func setup() -> void:
	player = PlayerStats.new()
	quests = QuestManager.new()
	life = _new_script_object("res://scripts/models/life_tracker.gd")
	save_manager = _new_script_object("res://scripts/managers/save_manager.gd")


func teardown() -> void:
	player.free()
	quests.free()
	life.free()
	save_manager.free()


func _new_script_object(path: String):
	var script: GDScript = load(path)
	return script.new()


func test_build_save_data_includes_all_models() -> void:
	quests.add_quest("Gather Wood", 40, "Gather wood for town")
	quests.take_quest(player.max_hp)
	life.add_task("hydrate", "Drink water", 10)
	life.complete_task("hydrate", "2026-05-11")
	var data: Dictionary = save_manager.build_save_data(player, quests, life)
	assert_has(data, "player")
	assert_has(data, "quests")
	assert_has(data, "life")
	assert_eq(10, data.life.xp)
	assert_eq(1, data.quests.active_quests.size())


func test_apply_save_data_restores_all_models() -> void:
	player.unlocked_facilities.append("garden")
	quests.add_quest("Gather Wood", 40, "Gather wood for town")
	quests.take_quest(player.max_hp)
	life.add_task("hydrate", "Drink water", 10)
	life.complete_task("hydrate", "2026-05-11")
	var data: Dictionary = save_manager.build_save_data(player, quests, life)
	var restored_player := PlayerStats.new()
	var restored_quests := QuestManager.new()
	var restored_life = _new_script_object("res://scripts/models/life_tracker.gd")
	save_manager.apply_save_data(data, restored_player, restored_quests, restored_life)
	assert_in("garden", restored_player.unlocked_facilities)
	assert_eq(1, restored_quests.active_quests.size())
	assert_eq(10, restored_life.xp)
	restored_player.free()
	restored_quests.free()
	restored_life.free()


func test_write_and_read_save_file() -> void:
	life.add_task("hydrate", "Drink water", 10)
	life.complete_task("hydrate", "2026-05-11")
	var path := "user://life_well_spent_test_save.json"
	assert_true(save_manager.save_to_file(path, player, quests, life))
	var data: Dictionary = save_manager.load_from_file(path)
	assert_eq(10, data.life.xp)
