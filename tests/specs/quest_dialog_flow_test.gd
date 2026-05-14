# tests/specs/quest_dialog_flow_test.gd
# Spec: QuestDialogFlow - reusable quest dialog panel state rules.

class_name TestQuestDialogFlow
extends TestCase

const MODEL_SCRIPT := "res://scripts/models/quest_dialog_flow.gd"

var flow


func setup() -> void:
	var script := load(MODEL_SCRIPT) as GDScript
	assert_not_null(script, "QuestDialogFlow script should exist")
	if script:
		flow = script.new()


func teardown() -> void:
	if flow:
		flow.free()
		flow = null


func test_normal_panel_has_no_reward_action() -> void:
	if flow == null:
		return
	var panel: Dictionary = flow.normal_panel("Guildmaster", "Welcome.")
	assert_eq("normal", panel["state"])
	assert_eq("Guildmaster", panel["title"])
	assert_eq("Welcome.", panel["body"])
	assert_false(panel["can_claim_reward"])


func test_incomplete_quest_panel_uses_intro_and_close_only() -> void:
	if flow == null:
		return
	var panel: Dictionary = flow.quest_panel("Guildmaster", "Begin trial.", "Claim it.", "Defeat 10 Slimes. (0/10)", false)
	assert_eq("quest_incomplete", panel["state"])
	assert_eq("Begin trial.\n\nDefeat 10 Slimes. (0/10)", panel["body"])
	assert_false(panel["can_claim_reward"])
	assert_eq("Claim Reward", panel["action_text"])


func test_complete_quest_panel_uses_claim_copy_and_claim_action() -> void:
	if flow == null:
		return
	var panel: Dictionary = flow.quest_panel("Guildmaster", "Begin trial.", "Claim it.", "Defeat 10 Slimes. (10/10)", true)
	assert_eq("quest_complete", panel["state"])
	assert_eq("Claim it.\n\nDefeat 10 Slimes. (10/10)", panel["body"])
	assert_true(panel["can_claim_reward"])
	assert_eq("Claim Reward", panel["action_text"])


func test_item_reward_panel_uses_standard_reward_shape() -> void:
	if flow == null:
		return
	var panel: Dictionary = flow.reward_item_panel("Training Sword", 1)
	assert_eq("reward", panel["state"])
	assert_eq("Reward", panel["title"])
	assert_eq("Reward: 1 x Training Sword", panel["body"])
	assert_false(panel["can_claim_reward"])


func test_unlock_reward_panel_uses_standard_reward_shape() -> void:
	if flow == null:
		return
	var panel: Dictionary = flow.reward_unlock_panel("Swordsman Guild Unlocked")
	assert_eq("Reward: Swordsman Guild Unlocked", panel["body"])
