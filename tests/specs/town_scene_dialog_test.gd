# tests/specs/town_scene_dialog_test.gd
# Spec: Town NPC dialog + quest UI

class_name TestTownSceneDialog
extends TestCase

var root: TownSceneController


func setup() -> void:
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	root = scene.instantiate() as TownSceneController
	root._ready()


func teardown() -> void:
	if root:
		root.free()


func test_dialog_panel_starts_hidden() -> void:
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_not_null(panel, "town scene should include DialogPanel")
	assert_false(panel.visible, "dialog should start hidden")


func test_quest_giver_interaction_opens_dialog_with_metadata() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	npc.interacted.emit(npc)
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	assert_true(panel.visible, "dialog should show after NPC interaction")
	assert_eq("Quest Giver", title.text)
	assert_true(body.text.contains("spare some life"), "quest giver dialog text should show")
	assert_true(accept.visible, "quest giver should show Accept Quest button")


func test_vendor_interaction_opens_dialog_without_quest_button() -> void:
	var npc: NpcController = root.get_node("Vendor") as NpcController
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	assert_eq("Vendor", title.text)
	assert_false(accept.visible, "vendor should not show Accept Quest button yet")


func test_accept_quest_from_dialog_deducts_hp_and_updates_ui() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	npc.interacted.emit(npc)
	root._on_accept_quest_pressed()
	var hp: Label = root.get_node("UI/HPLabel") as Label
	var quest: Label = root.get_node("UI/QuestLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("HP: 60 / 60", hp.text)
	assert_eq("Quests: 1 active", quest.text)
	assert_true(body.text.contains("Quest accepted"), "dialog should confirm accepted quest")


func test_complete_quest_from_dialog_removes_active_and_updates_ui() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	npc.interacted.emit(npc)
	root._on_accept_quest_pressed()
	root._on_complete_quest_pressed()
	var hp: Label = root.get_node("UI/HPLabel") as Label
	var quest: Label = root.get_node("UI/QuestLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("HP: 20 / 20", hp.text)
	assert_eq("Quests: 0 active", quest.text)
	assert_true(body.text.contains("Quest completed"), "dialog should confirm completed quest")


func test_close_dialog_hides_panel() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	npc.interacted.emit(npc)
	root._on_close_dialog_pressed()
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_false(panel.visible)
