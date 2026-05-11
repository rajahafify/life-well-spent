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


func test_near_guildmaster_interaction_opens_first_dialog_page() -> void:
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


func test_guildmaster_dialog_advances_pages() -> void:
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


func test_far_guildmaster_interaction_moves_player_without_opening_dialog() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = Vector2(960, 700)
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	assert_false(dialog.visible)
	assert_true(movement.moving)


func test_pending_npc_opens_dialog_when_player_reaches_talk_range() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = Vector2(960, 700)
	npc.interacted.emit(npc)
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	root._physics_process(0.016)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	assert_true(dialog.visible)
	assert_eq("Guildmaster", title.text)


func test_shopkeeper_interaction_opens_worldbuilding_dialog() -> void:
	var npc: NpcController = root.get_node("Shopkeeper") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Shopkeeper", title.text)
	assert_true(body.text.contains("Welcome, traveler."))


func test_smith_interaction_opens_worldbuilding_dialog() -> void:
	var npc: NpcController = root.get_node("Smith") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	assert_eq("Smith", title.text)
	assert_true(body.text.contains("I used to shape steel"))


func test_first_slice_dialog_hides_quest_buttons() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var accept: Button = root.get_node("UI/DialogPanel/VBox/Buttons/AcceptQuestButton") as Button
	var complete: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CompleteQuestButton") as Button
	var close: Button = root.get_node("UI/DialogPanel/VBox/Buttons/CloseButton") as Button
	assert_false(accept.visible)
	assert_false(complete.visible)
	assert_true(close.visible)


func test_town_routes_player_movement_to_character_movement() -> void:
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var target := Vector2(700, 520)
	assert_true(root.move_player_to(target))
	assert_eq(target, movement.destination)
	assert_true(movement.moving)


func test_dialog_blocks_player_movement() -> void:
	var movement: CharacterMovement = root.get_node("Player/Sprite") as CharacterMovement
	movement._ready()
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	assert_false(root.move_player_to(Vector2(700, 520)))
	assert_false(movement.moving)


func test_camera_follows_player_with_ro_style_offset() -> void:
	var player: Node2D = root.get_node("Player") as Node2D
	var camera: Camera2D = root.get_node("Camera2D") as Camera2D
	player.global_position = Vector2(1200, 700)
	root._physics_process(0.016)
	assert_eq(player.global_position + Town.CAMERA_OFFSET, camera.global_position)


func test_close_button_signal_hides_dialog() -> void:
	var npc: NpcController = root.get_node("Guildmaster") as NpcController
	root.get_node("Player").global_position = npc.global_position + Vector2(40, 0)
	npc.interacted.emit(npc)
	var dialog: TownDialogView = root.get_node("UI/DialogPanel") as TownDialogView
	assert_true(dialog.visible)
	dialog.close_requested.emit()
	assert_false(dialog.visible)


func test_portal_prompt_starts_hidden() -> void:
	var prompt: Label = root.get_node("UI/PortalPrompt") as Label
	var choices: Control = root.get_node("UI/PortalChoices") as Control
	assert_false(prompt.visible)
	assert_false(choices.visible)


func test_portal_yes_button_records_starter_area_target() -> void:
	root.show_portal_prompt()
	var yes: Button = root.get_node("UI/PortalChoices/YesButton") as Button
	yes.pressed.emit()
	var prompt: Label = root.get_node("UI/PortalPrompt") as Label
	assert_eq(Town.STARTER_AREA_PATH, root.requested_scene_path)
	assert_true(prompt.visible)


func test_portal_body_entered_shows_prompt_and_choices() -> void:
	var player: Node = root.get_node("Player")
	root._on_starter_area_portal_body_entered(player)
	var prompt: Label = root.get_node("UI/PortalPrompt") as Label
	var choices: Control = root.get_node("UI/PortalChoices") as Control
	assert_true(prompt.visible)
	assert_true(choices.visible)


func test_portal_no_button_hides_prompt() -> void:
	root.show_portal_prompt()
	var no: Button = root.get_node("UI/PortalChoices/NoButton") as Button
	no.pressed.emit()
	var prompt: Label = root.get_node("UI/PortalPrompt") as Label
	var choices: Control = root.get_node("UI/PortalChoices") as Control
	assert_false(prompt.visible)
	assert_false(choices.visible)
