# tests/specs/town_scene_dialog_test.gd
# Spec: Town first-slice NPC dialog presentation.

class_name TestTownSceneDialog
extends TestCase

var root: Town


func setup() -> void:
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	root = scene.instantiate() as Town
	root._ready()


func teardown() -> void:
	if root:
		root.free()
		root = null


func test_guildmaster_interaction_opens_worldbuilding_dialog() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_true(dialog.visible)
	assert_eq("Guildmaster", title.text)
	assert_true(body.text.contains("Perhaps one day, someone will help me raise it again."))


func test_shopkeeper_interaction_opens_worldbuilding_dialog() -> void:
	var npc: NpcController = root.get_node("Shopkeeper") as NpcController
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Shopkeeper", title.text)
	assert_true(body.text.contains("quiet days are worth protecting too"))


func test_smith_interaction_opens_worldbuilding_dialog() -> void:
	var npc: NpcController = root.get_node("Smith") as NpcController
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Smith", title.text)
	assert_true(body.text.contains("Old roads have a way of calling again."))


func test_first_slice_dialog_hides_quest_buttons() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	npc.interacted.emit(npc)
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_false(accept.visible)
	assert_false(complete.visible)
	assert_true(close.visible)


func test_portal_request_records_starter_area_target() -> void:
	root.request_starter_area()
	var prompt: Label = root.get_node("UI/PortalPrompt") as Label
	assert_eq(Town.STARTER_AREA_PATH, root.requested_scene_path)
	assert_true(prompt.visible)
