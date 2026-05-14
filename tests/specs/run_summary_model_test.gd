# tests/specs/run_summary_model_test.gd
# Spec: RunSummaryModel - summarizes completed run gains.

class_name TestRunSummaryModel
extends TestCase

const SUMMARY_SCRIPT := "res://scripts/models/run_summary_model.gd"
const PLAYER_SCRIPT := "res://scripts/models/player_stats.gd"
const INVENTORY_SCRIPT := "res://scripts/models/inventory_model.gd"

var summary
var player
var inventory


func setup() -> void:
	summary = (load(SUMMARY_SCRIPT) as GDScript).new()
	player = (load(PLAYER_SCRIPT) as GDScript).new()
	inventory = (load(INVENTORY_SCRIPT) as GDScript).new()


func teardown() -> void:
	for object in [summary, player, inventory]:
		if object:
			object.free()
	summary = null
	player = null
	inventory = null


func test_summary_lists_items_and_unlocks() -> void:
	inventory.add_item("training_sword", 1)
	inventory.add_item("bat_wing", 2)
	player.unlock_facility("swordsman_guild")
	var text: String = summary.summary_text(player, inventory)
	assert_true(text.contains("Run Summary"))
	assert_true(text.contains("bat_wing x2"))
	assert_true(text.contains("training_sword x1"))
	assert_true(text.contains("Swordsman Guild"))


func test_summary_uses_none_when_run_has_no_gains() -> void:
	var text: String = summary.summary_text(player, inventory)
	assert_true(text.contains("Items: none"))
	assert_true(text.contains("Unlocks: none"))
