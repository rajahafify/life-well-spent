# tests/specs/town_scene_dialog_test.gd
# Spec: Town first-slice NPC dialog presentation.

class_name TestTownSceneDialog
extends TestCase

var root: Node


func setup() -> void:
	if QuestSystem:
		QuestSystem.reset()
	var feedback := _feedback_system()
	if feedback:
		feedback.reset()
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	root = scene.instantiate()
	root._ready()


func teardown() -> void:
	if root:
		root.free()
		root = null


func _close_start_dialog() -> void:
	root.close_dialog()


func _record_swordsman_objective(enemy_id: String, count: int) -> void:
	for _i in range(count):
		QuestSystem.record_enemy_defeated(enemy_id)


func _gather_swordsman_item(item_id: String, count: int) -> void:
	for _i in range(count):
		QuestSystem.record_item_gathered(item_id)


func _inventory_model():
	return root._inventory_model_for_hud()


func _feedback_system() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("FeedbackSystem")


func _advance_dialog_to_last_page() -> void:
	var next := root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	while next.visible:
		next.pressed.emit()


func test_near_guildmaster_interaction_opens_first_dialog_page() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	assert_true(dialog.visible)
	assert_eq("Guildmaster", title.text)
	assert_eq("The Swordsman Guild still stands.", body.text)
	assert_true(next.visible)


func test_town_opens_reborn_copy_as_start_dialog() -> void:
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	assert_true(dialog.visible)
	assert_eq("Reborn", title.text)
	assert_eq("You have been reborn.\nWill you spend this life well?", body.text)
	assert_false(next.visible)
	assert_null(root.get_node_or_null("UI/RebornPrompt"))


func test_town_does_not_repeat_reborn_copy_after_first_visit() -> void:
	root.free()
	root = null
	var first_scene: PackedScene = load("res://scenes/town_scene.tscn")
	var first_root = first_scene.instantiate()
	first_root._ready()
	first_root.free()
	var second_scene: PackedScene = load("res://scenes/town_scene.tscn")
	root = second_scene.instantiate()
	root._ready()
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	assert_false(dialog.visible)


func test_town_has_top_right_quest_window() -> void:
	var hud := root.get_node_or_null("UI")
	assert_true(hud != null and hud.has_method("set_life") and hud.has_method("show_quest"), "Town should use the shared gameplay HUD")
	var life_label := root.get_node_or_null("UI/LifeLabel") as Label
	var inventory_button := root.get_node_or_null("UI/InventoryButton") as Button
	var quest_window := root.get_node_or_null("UI/QuestWindow") as PanelContainer
	var quest_label := root.get_node_or_null("UI/QuestWindow/VBox/ObjectiveLabel") as Label
	assert_not_null(life_label)
	assert_not_null(inventory_button)
	assert_not_null(quest_window)
	assert_not_null(quest_label)
	if life_label and inventory_button and quest_window and quest_label:
		assert_eq("Life: 100/100", life_label.text)
		assert_eq("Inventory", inventory_button.text)
		assert_true(quest_window.visible)
		assert_eq(1.0, quest_window.anchor_right)
		assert_eq(-28.0, quest_window.offset_right)
		assert_eq("Explore the World\nFind the Forest path.", quest_label.text)


func test_dialog_text_is_large_enough_for_1080p() -> void:
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	assert_true(int(title.get_theme_font_size("font_size")) >= 28)
	assert_true(int(body.get_theme_font_size("font_size")) >= 30)
	assert_true(int(next.get_theme_font_size("font_size")) >= 24)


func test_dialog_buttons_stick_to_bottom_right() -> void:
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var buttons: HBoxContainer = root.get_node("UI/DialogPanel/VBox/Buttons") as HBoxContainer
	assert_true((body.size_flags_vertical & Control.SIZE_EXPAND) == Control.SIZE_EXPAND)
	assert_eq(BoxContainer.ALIGNMENT_END, buttons.alignment)


func test_dialog_shows_npc_portrait_from_sprite_sheet_above_box() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var portrait: TextureRect = root.get_node("UI/DialogPortrait") as TextureRect
	var dialog: PanelContainer = root.get_node("UI/DialogPanel") as PanelContainer
	assert_true(portrait.visible)
	assert_true(portrait.texture is AtlasTexture)
	assert_true(portrait.position.y < dialog.position.y, "portrait should sit above dialog box, not inside text flow")
	var atlas := (portrait.texture as AtlasTexture).atlas
	assert_true(atlas.resource_path.ends_with("guildmaster.png"))
	assert_eq(Rect2(80, 648, 32, 32), (portrait.texture as AtlasTexture).region)


func test_guildmaster_dialog_advances_pages() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	dialog.next_page()
	assert_true(body.text.contains("Not as it was"))
	dialog.next_page()
	dialog.next_page()
	assert_true(body.text.contains("Perhaps one day"))
	assert_false(next.visible)


func test_guildmaster_offers_swordsman_chain_after_forest_gate_objective() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_true(body.text.contains("Forest"))
	assert_true(body.text.contains("Swordsman Certification"))
	assert_eq("Defeat 10 Slimes for Guildmaster stance training. (0/10)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))
	assert_false(complete.visible)
	assert_true(QuestSystem.is_side_quest_active("rebuilding_swordsman_guild"))
	var quest_label := root.get_node("UI/QuestWindow/VBox/ObjectiveLabel") as Label
	assert_eq("Explore the World\nGet Swordsman Certification.\nDefeat 10 Slimes for Guildmaster stance training. (0/10)", quest_label.text)


func test_guildmaster_button_says_complete_quest() -> void:
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_eq("Complete Quest", complete.text)


func test_guildmaster_hides_complete_button_until_objective_is_complete() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_false(complete.visible)


func test_guildmaster_completed_step_shows_claim_reward_dialog_action() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_true(body.text.contains("Your stance held"))
	assert_false(complete.visible)
	_advance_dialog_to_last_page()
	assert_true(complete.visible)
	assert_false(close.visible)
	assert_eq("Claim Reward", complete.text)


func test_guildmaster_step_one_advances_to_next_guildmaster_quest() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_false(complete.visible)
	_advance_dialog_to_last_page()
	assert_true(complete.visible)
	assert_eq("Claim Reward", complete.text)
	complete.pressed.emit()
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (0/2)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))
	assert_false(complete.visible)
	assert_eq("Reward", (root.get_node("UI/DialogPanel/VBox/NameLabel") as Label).text)
	assert_eq("Reward\n1 x Training Sword\nAdded to your inventory.", (root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label).text)
	assert_eq(1, _inventory_model().quantity("training_sword"))
	assert_eq("quest_reward", _feedback_system().last_sfx)


func test_guildmaster_step_two_uses_bat_wings_already_in_inventory() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_inventory_model().add_item("bat_wing", 4)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_false(complete.visible)
	_advance_dialog_to_last_page()
	assert_true(complete.visible)
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (2/2)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_guildmaster_step_two_uses_guard_training_dialog_copy() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("A swordsman does not stand alone"))
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (0/2)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_guildmaster_step_two_completed_uses_armor_claim_copy() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_gather_swordsman_item("bat_wing", 2)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("You watched the sky"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("leather armor"))


func test_guildmaster_step_two_advances_to_life_oath_quest() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_gather_swordsman_item("bat_wing", 2)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	complete.pressed.emit()
	assert_eq("Defeat 2 Rats for the Guildmaster's Life oath. (0/2)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))
	assert_eq("Reward\n1 x Leather Armor\nAdded to your inventory.", (root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label).text)
	assert_eq(1, _inventory_model().quantity("leather_armor"))


func test_guildmaster_step_three_uses_life_oath_dialog_copy() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_gather_swordsman_item("bat_wing", 2)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("The last oath costs attention"))
	assert_eq("Defeat 2 Rats for the Guildmaster's Life oath. (0/2)", QuestSystem.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_guildmaster_step_three_completed_uses_certification_claim_copy() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_gather_swordsman_item("bat_wing", 2)
	QuestSystem.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_swordsman_objective("rat", 2)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("The road is clear"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("reopen the Guild"))


func test_guildmaster_certification_completion_spends_life_to_60() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	complete.pressed.emit()
	assert_eq(60, root.player_stats.max_hp)
	assert_eq(1, QuestSystem.side_quest_step("rebuilding_swordsman_guild"))
	assert_eq("Life: 60/60", (root.get_node("UI/LifeLabel") as Label).text)
	var sprite := root.get_node("Player/Sprite") as Sprite2D
	assert_true(sprite.texture.resource_path.ends_with("player_age_2.png"))


func test_guildmaster_final_certification_unlocks_achievement() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	complete.pressed.emit()
	_gather_swordsman_item("bat_wing", 2)
	root.close_dialog()
	npc.interacted.emit(npc)
	_advance_dialog_to_last_page()
	complete.pressed.emit()
	_record_swordsman_objective("rat", 2)
	root.close_dialog()
	npc.interacted.emit(npc)
	_advance_dialog_to_last_page()
	complete.pressed.emit()
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(QuestSystem.has_certification("swordsman_certification"))
	assert_in("swordsman_guild", root.player_stats.unlocked_facilities)
	assert_true(root.player_stats.game_over_requested)
	assert_eq("Reward", (root.get_node("UI/DialogPanel/VBox/NameLabel") as Label).text)
	assert_eq("Reward\nSwordsman Guild Unlocked\nThe Forest path is open.", body.text)
	assert_eq("res://scenes/game_over.tscn", root.requested_scene_path)
	assert_eq("enter_forest", QuestSystem.current_main_objective_id())
	var sprite := root.get_node("Player/Sprite") as Sprite2D
	assert_true(sprite.texture.resource_path.ends_with("player_age_3.png"))


func test_certified_guildmaster_dialog_points_to_forest_without_repeating_trials() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	complete.pressed.emit()
	_gather_swordsman_item("bat_wing", 2)
	complete.pressed.emit()
	_record_swordsman_objective("rat", 2)
	complete.pressed.emit()
	root.close_dialog()
	root.show_rebirth_panel()
	var rebirth := root.get_node("UI/RebirthPanel/VBox/RebirthButton") as Button
	rebirth.pressed.emit()
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(body.text.contains("The Guild is awake again"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("The Forest path will know you"))
	assert_false(body.text.contains("Defeat 10 Slimes"))


func test_game_over_summary_panel_lists_run_gains() -> void:
	_close_start_dialog()
	_inventory_model().add_item("training_sword", 1)
	_inventory_model().add_item("leather_armor", 1)
	root.player_stats.max_hp = 20
	root.player_stats.game_over_requested = true
	root.player_stats.unlock_facility("swordsman_guild")
	root.show_rebirth_panel()
	var panel := root.get_node_or_null("UI/RebirthPanel") as PanelContainer
	var title := root.get_node_or_null("UI/RebirthPanel/VBox/TitleLabel") as Label
	var label := root.get_node_or_null("UI/RebirthPanel/VBox/MessageLabel") as Label
	var summary := root.get_node_or_null("UI/RebirthPanel/VBox/SummaryLabel") as Label
	var end_button := root.get_node_or_null("UI/RebirthPanel/VBox/EndGameButton") as Button
	assert_not_null(panel)
	assert_not_null(title)
	assert_not_null(label)
	assert_not_null(summary)
	assert_not_null(end_button)
	if panel and title and label and summary and end_button:
		assert_true(panel.visible)
		assert_eq("Game Over", title.text)
		assert_true(label.text.contains("spent this life"))
		assert_true(summary.text.contains("Run Summary"))
		assert_true(summary.text.contains("Training Sword x1"))
		assert_true(summary.text.contains("Leather Armor x1"))
		assert_true(summary.text.contains("Life Spent: 80"))
		assert_true(summary.text.contains("Swordsman Guild"))
		assert_eq("End Game", end_button.text)
		assert_eq("game_over", _feedback_system().last_sfx)


func test_rebirth_button_resets_life_and_preserves_swordsman_guild() -> void:
	_close_start_dialog()
	_inventory_model().add_item("training_sword", 1)
	root.player_stats.max_hp = 0
	root.player_stats.state = "dead"
	root.player_stats.game_over_requested = true
	root.player_stats.unlock_facility("swordsman_guild")
	root.show_rebirth_panel()
	var button := root.get_node("UI/RebirthPanel/VBox/RebirthButton") as Button
	button.pressed.emit()
	assert_eq(100, root.player_stats.max_hp)
	assert_eq("alive", root.player_stats.state)
	assert_false(root.player_stats.game_over_requested)
	assert_in("swordsman_guild", root.player_stats.unlocked_facilities)
	assert_false((root.get_node("UI/RebirthPanel") as PanelContainer).visible)
	assert_eq("Life: 100/100", (root.get_node("UI/LifeLabel") as Label).text)
	assert_eq(0, _inventory_model().quantity("training_sword"))
	assert_eq("rebirth", _feedback_system().last_sfx)


func test_end_game_button_requests_main_menu() -> void:
	_close_start_dialog()
	root.player_stats.game_over_requested = true
	root.show_rebirth_panel()
	var button := root.get_node("UI/RebirthPanel/VBox/EndGameButton") as Button
	button.pressed.emit()
	assert_eq("res://scenes/main_menu.tscn", root.requested_scene_path)


func test_options_end_game_requests_main_menu() -> void:
	_close_start_dialog()
	var options := root.get_node("UI/OptionsButton") as Button
	options.pressed.emit()
	var end_game := root.get_node("UI/OptionsPanel/VBox/EndGameButton") as Button
	end_game.pressed.emit()
	assert_eq("res://scenes/main_menu.tscn", root.requested_scene_path)


func test_rebirth_panel_blocks_player_movement() -> void:
	_close_start_dialog()
	root.show_rebirth_panel()
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	assert_false(root.move_player_to(Vector2(700, 520)))
	assert_false(movement.moving)


func test_town_player_starts_with_age_stage_one_sprite() -> void:
	_close_start_dialog()
	var sprite := root.get_node("Player/Sprite") as Sprite2D
	assert_true(sprite.texture.resource_path.ends_with("player_age_1.png"))


func test_town_follow_held_mouse_updates_player_destination() -> void:
	_close_start_dialog()
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var target := Vector2(820, 640)
	assert_true(root.follow_held_mouse(target))
	assert_eq(target, movement.destination)


func test_far_guildmaster_interaction_moves_player_without_opening_dialog() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = Vector2(960, 700)
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	assert_false(dialog.visible)
	assert_true(movement.moving)
	assert_true(root.get_node("Player").global_position.distance_to(movement.destination) >= 95.0, "talk point should prevent sprite overlap")


func test_pending_npc_opens_dialog_when_player_reaches_talk_range() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = Vector2(960, 700)
	npc.interacted.emit(npc)
	root.get_node("Player").global_position = npc.global_position + Vector2(100, 0)
	root._physics_process(0.016)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	assert_true(dialog.visible)
	assert_eq("Guildmaster", title.text)


func test_shopkeeper_interaction_opens_worldbuilding_dialog() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Shopkeeper") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Shopkeeper", title.text)
	assert_true(body.text.contains("Welcome, traveler."))


func test_smith_interaction_opens_worldbuilding_dialog() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Smith") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Smith", title.text)
	assert_true(body.text.contains("I used to shape steel"))


func test_first_slice_dialog_hides_quest_buttons() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_false(accept.visible)
	assert_false(complete.visible)
	assert_eq(not next.visible, close.visible)


func test_paged_dialog_hides_close_until_last_page() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_true(next.visible)
	assert_false(close.visible)
	while next.visible:
		dialog.next_page()
	assert_false(next.visible)
	assert_true(close.visible)


func test_guildmaster_marker_is_yellow_for_new_swordsman_quest() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	root.update_quest_markers()
	var marker := root.get_node("Guildmaster/QuestMarker") as Label
	assert_true(marker.visible)
	assert_eq("!", marker.text)
	assert_eq(Color(1.0, 0.86, 0.12, 1.0), marker.get_theme_color("font_color"))
	assert_eq(56, marker.get_theme_font_size("font_size"))
	assert_eq(8, marker.get_theme_constant("outline_size"))
	assert_true(marker.has_meta("pulse_marker"))
	assert_eq(Vector2(-48, -92), marker.position)
	assert_eq(Vector2(96, 72), marker.size)
	assert_eq(Vector2(48, 36), marker.pivot_offset)


func test_guildmaster_marker_is_white_for_active_incomplete_quest() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	root.update_quest_markers()
	var marker := root.get_node("Guildmaster/QuestMarker") as Label
	assert_true(marker.visible)
	assert_eq(Color.WHITE, marker.get_theme_color("font_color"))


func test_guildmaster_marker_is_green_for_completed_unclaimed_quest() -> void:
	_close_start_dialog()
	QuestSystem.mark_main_checkpoint("explore_the_world", "forest_guard")
	QuestSystem.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	QuestSystem.activate_swordsman_guild_chain()
	_record_swordsman_objective("slime_spiked", 10)
	root.update_quest_markers()
	var marker := root.get_node("Guildmaster/QuestMarker") as Label
	assert_true(marker.visible)
	assert_eq(Color(0.2, 1.0, 0.32, 1.0), marker.get_theme_color("font_color"))


func test_smith_marker_is_yellow_after_rebirth_with_swordsman_unlock() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	root.player_stats.game_over_requested = false
	root.update_quest_markers()
	var marker := root.get_node("Smith/QuestMarker") as Label
	assert_true(marker.visible)
	assert_eq("!", marker.text)
	assert_eq(Color(1.0, 0.86, 0.12, 1.0), marker.get_theme_color("font_color"))


func test_shopkeeper_marker_is_yellow_after_rebirth_with_swordsman_unlock() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	root.player_stats.game_over_requested = false
	root.update_quest_markers()
	var marker := root.get_node("Shopkeeper/QuestMarker") as Label
	assert_true(marker.visible)
	assert_eq("!", marker.text)
	assert_eq(Color(1.0, 0.86, 0.12, 1.0), marker.get_theme_color("font_color"))


func test_smith_reopen_blacksmith_quest_offer_mentions_guild_demand() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	var npc: NpcController = root.get_node("Smith") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	assert_eq("Smith", title.text)
	assert_true(body.text.contains("Swordsman Guild is open"))
	assert_true(body.text.contains("weapons"))
	assert_true(body.text.contains("armor"))
	_advance_dialog_to_last_page()
	assert_true(accept.visible)
	assert_eq("Accept Quest", accept.text)


func test_accepting_smith_teaser_shows_blacksmith_job_full_game_modal() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	var npc: NpcController = root.get_node("Smith") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	_advance_dialog_to_last_page()
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	accept.pressed.emit()
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var marker := root.get_node("Smith/QuestMarker") as Label
	assert_in("blacksmith_job_teaser", root.player_stats.unlocked_facilities)
	assert_false(marker.visible)
	assert_eq("Blacksmith Job", title.text)
	assert_true(body.text.contains("available in the full game"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("learn recipes"))
	assert_true(body.text.contains("craft weapons and armor"))
	assert_true(body.text.contains("hunting for the materials"))


func test_shopkeeper_merchant_quest_offer_mentions_reopening_shop() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	var npc: NpcController = root.get_node("Shopkeeper") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	assert_eq("Shopkeeper", title.text)
	assert_true(body.text.contains("The Guild will bring travelers"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("reopen the shop"))
	_advance_dialog_to_last_page()
	assert_true(accept.visible)
	assert_eq("Accept Quest", accept.text)


func test_accepting_shopkeeper_teaser_shows_merchant_job_full_game_modal() -> void:
	_close_start_dialog()
	root.player_stats.unlocked_facilities.append("swordsman_guild")
	var npc: NpcController = root.get_node("Shopkeeper") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	_advance_dialog_to_last_page()
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	accept.pressed.emit()
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var marker := root.get_node("Shopkeeper/QuestMarker") as Label
	assert_in("merchant_job_teaser", root.player_stats.unlocked_facilities)
	assert_false(marker.visible)
	assert_eq("Merchant Job", title.text)
	assert_true(body.text.contains("available in the full game"))
	(root.get_node("UI/DialogPanel") as TownDialogView).next_page()
	assert_true(body.text.contains("enter caves"))
	assert_true(body.text.contains("explore old ruins"))
	assert_true(body.text.contains("sell them in the shop"))


func test_town_routes_player_movement_to_character_movement() -> void:
	_close_start_dialog()
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var target := Vector2(700, 520)
	assert_true(root.move_player_to(target))
	assert_eq(target, movement.destination)
	assert_true(movement.moving)


func test_inventory_button_area_blocks_player_movement() -> void:
	_close_start_dialog()
	var button := root.get_node("UI/InventoryButton") as Button
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var target := button.position + (button.size * 0.5)
	assert_false(root.follow_held_mouse(target))
	assert_false(movement.moving)


func test_dialog_blocks_player_movement() -> void:
	_close_start_dialog()
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	assert_false(root.move_player_to(Vector2(700, 520)))
	assert_false(movement.moving)


func test_camera_follows_player_with_ro_style_offset() -> void:
	_close_start_dialog()
	var player: Node2D = root.get_node("Player") as Node2D
	var camera: Camera2D = root.get_node("Camera2D") as Camera2D
	player.global_position = Vector2(1200, 700)
	root._physics_process(0.016)
	assert_eq(player.global_position + Vector2(0, -150), camera.global_position)


func test_town_npc_idle_animation_has_distinct_timing() -> void:
	var guild: CharacterMovement = root.get_node("Guildmaster/Sprite") as CharacterMovement
	var shop: CharacterMovement = root.get_node("Shopkeeper/Sprite") as CharacterMovement
	var smith: CharacterMovement = root.get_node("Smith/Sprite") as CharacterMovement
	assert_neq(guild.idle_cycle_interval, shop.idle_cycle_interval)
	assert_neq(shop.idle_cycle_interval, smith.idle_cycle_interval)


func test_close_button_signal_hides_dialog() -> void:
	_close_start_dialog()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	assert_true(dialog.visible)
	dialog.close_requested.emit()
	assert_false(dialog.visible)


func test_field_gateway_body_entered_requests_field_directly() -> void:
	var player: Node = root.get_node("Player")
	root._on_field_gateway_body_entered(player)
	assert_eq("res://scenes/field.tscn", root.requested_scene_path)


func test_field_gateway_defers_scene_change_outside_physics_callback() -> void:
	var file := FileAccess.open("res://scripts/controllers/town_scene_controller.gd", FileAccess.READ)
	assert_not_null(file, "Town controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("call_deferred(\"_change_scene_to_file\", FIELD_PATH)"))
	assert_true(source.contains("func _change_scene_to_file(scene_path: String) -> void:"))


func test_field_gateway_uses_direct_transition_without_prompt() -> void:
	assert_null(root.get_node_or_null("UI/PortalChoices"), "direct gateways should not show confirmation choices")
	assert_null(root.get_node_or_null("UI/PortalPrompt"), "direct gateways should not show confirmation prompt")
