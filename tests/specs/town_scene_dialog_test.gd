# tests/specs/town_scene_dialog_test.gd
# Spec: Town first-slice NPC dialog presentation.

class_name TestTownSceneDialog
extends TestCase

var root: Node


func setup() -> void:
	var scene: PackedScene = load("res://scenes/town_scene.tscn")
	root = scene.instantiate()
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


func test_dialog_text_is_large_enough_for_1080p() -> void:
	var title: Label = root.get_node("UI/DialogPanel/VBox/NameLabel") as Label
	var body: Label = root.get_node("UI/DialogPanel/VBox/BodyLabel") as Label
	var next: Button = root.get_node("UI/DialogPanel/VBox/Buttons/NextButton") as Button
	assert_true(int(title.get_theme_font_size("font_size")) >= 28)
	assert_true(int(body.get_theme_font_size("font_size")) >= 30)
	assert_true(int(next.get_theme_font_size("font_size")) >= 24)


func test_dialog_shows_npc_portrait_from_sprite_sheet_above_box() -> void:
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
	assert_true(root.get_node("Player").global_position.distance_to(movement.destination) >= 95.0, "talk point should prevent sprite overlap")


func test_pending_npc_opens_dialog_when_player_reaches_talk_range() -> void:
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
	assert_eq(player.global_position + Vector2(0, -150), camera.global_position)


func test_town_npc_idle_animation_has_distinct_timing() -> void:
	var guild: CharacterMovement = root.get_node("Guildmaster/Sprite") as CharacterMovement
	var shop: CharacterMovement = root.get_node("Shopkeeper/Sprite") as CharacterMovement
	var smith: CharacterMovement = root.get_node("Smith/Sprite") as CharacterMovement
	assert_neq(guild.idle_cycle_interval, shop.idle_cycle_interval)
	assert_neq(shop.idle_cycle_interval, smith.idle_cycle_interval)


func test_close_button_signal_hides_dialog() -> void:
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
