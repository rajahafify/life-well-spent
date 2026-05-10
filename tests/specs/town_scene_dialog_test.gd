# tests/specs/town_scene_dialog_test.gd
# Spec: Town NPC dialog + quest UI

class_name TestTownSceneDialog
extends TestCase

const TownDialogViewScript = preload("res://scripts/views/town_dialog_view.gd")

var root: TownSceneController


func _move_player_near(npc: NpcController, offset := Vector2(40, 0)) -> void:
	root.get_player().global_position = npc.global_position + offset


func _emit_near(npc: NpcController) -> void:
	_move_player_near(npc)
	npc.interacted.emit(npc)


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


func test_dialog_panel_uses_town_dialog_view() -> void:
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_eq(TownDialogViewScript, panel.get_script(), "DialogPanel should delegate dialog UI to TownDialogView")


func test_town_dialog_view_configures_dialog_metadata() -> void:
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	panel.show_dialog("Quest Giver", "Can you spare some life?", true, false)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	assert_true(panel.visible, "dialog view should show panel")
	assert_eq("Quest Giver", title.text)
	assert_eq("Can you spare some life?", body.text)
	assert_true(accept.visible, "accept should show when quest can be offered")
	assert_false(complete.visible, "complete should hide when no active quest exists")


func test_quest_giver_interaction_opens_dialog_with_metadata() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
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
	_emit_near(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	assert_eq("Vendor", title.text)
	assert_false(accept.visible, "vendor should not show Accept Quest button yet")


func test_accept_quest_from_dialog_costs_no_hp_and_updates_ui() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
	root._on_accept_quest_pressed()
	var hp: Label = root.get_node("UI/HPLabel") as Label
	var quest: Label = root.get_node("UI/QuestLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("HP: 100 / 100", hp.text)
	assert_eq("Quests: 1 active", quest.text)
	assert_true(body.text.contains("Quest accepted"), "dialog should confirm accepted quest")


func test_complete_quest_from_dialog_removes_active_and_updates_ui() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
	root._on_accept_quest_pressed()
	root._on_complete_quest_pressed()
	var hp: Label = root.get_node("UI/HPLabel") as Label
	var quest: Label = root.get_node("UI/QuestLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("HP: 60 / 60", hp.text)
	assert_eq("Quests: 0 active", quest.text)
	assert_true(body.text.contains("Quest completed"), "dialog should confirm completed quest")


func test_close_dialog_hides_panel() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
	root._on_close_dialog_pressed()
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_false(panel.visible)


func test_click_npc_outside_range_sets_pending_npc_without_opening_dialog() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	root.get_player().global_position = Vector2(640, 360)
	npc.interacted.emit(npc)
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	var movement: CharacterMovement = root.get_player().get_node("Sprite") as CharacterMovement
	assert_false(panel.visible, "far NPC click should not open dialog immediately")
	assert_eq(npc, root.get("_pending_npc"))
	assert_true(movement.moving, "far NPC click should move player toward talk point")


func test_pending_npc_opens_dialog_when_player_enters_range() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	root.get_player().global_position = Vector2(640, 360)
	npc.interacted.emit(npc)
	root.get_player().global_position = npc.global_position + Vector2(40, 0)
	root._physics_process(0.016)
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_true(panel.visible, "pending NPC should open when player reaches talk range")
	assert_null(root.get("_pending_npc"))


func test_click_npc_inside_range_opens_dialog_immediately() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_move_player_near(npc)
	npc.interacted.emit(npc)
	var panel: Control = root.get_node("UI/DialogPanel") as Control
	assert_true(panel.visible, "near NPC click should open dialog immediately")


func test_dialog_open_disables_player_movement() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
	var movement: CharacterMovement = root.get_player().get_node("Sprite") as CharacterMovement
	assert_false(movement.can_move, "dialog should lock player click-to-move")


func test_close_dialog_reenables_player_movement() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_emit_near(npc)
	root._on_close_dialog_pressed()
	var movement: CharacterMovement = root.get_player().get_node("Sprite") as CharacterMovement
	assert_true(movement.can_move, "closing dialog should restore movement")


func test_dialog_open_faces_player_and_npc() -> void:
	var npc: NpcController = root.get_node("QuestGiver") as NpcController
	_move_player_near(npc, Vector2(40, 0))
	npc.interacted.emit(npc)
	var movement: CharacterMovement = root.get_player().get_node("Sprite") as CharacterMovement
	assert_eq("right", npc.npc_state.facing)
	assert_eq(Vector2i(0, 1), movement.frame_coords)
