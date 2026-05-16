# tests/specs/town_dialog_view_test.gd
# Spec: TownDialogView paged button presentation.

class_name TestTownDialogView
extends TestCase

static var _scene: PackedScene = load("res://scenes/town_scene.tscn")


func test_claim_reward_button_only_appears_on_final_dialog_page() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	dialog.ensure_ready()
	dialog.show_dialog_pages("Guildmaster", ["You have completed this trial.", "Claim when ready."], false, true)
	var claim := dialog.get_node("VBox/Buttons/CompleteQuestButton") as Button
	var next := dialog.get_node("VBox/Buttons/NextButton") as Button
	assert_false(claim.visible, "claim reward should be hidden before the final dialog page")
	assert_true(next.visible, "next should be visible before the final dialog page")
	dialog.next_page()
	assert_true(claim.visible, "claim reward should appear on the final dialog page")
	assert_false(next.visible, "next should hide on the final dialog page")
	root.free()


func test_close_button_only_appears_on_final_dialog_page() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	dialog.ensure_ready()
	dialog.show_dialog_pages("Guildmaster", ["First.", "Last."], false, false)
	var close := dialog.get_node("VBox/Buttons/CloseButton") as Button
	assert_false(close.visible, "close should be hidden before the final dialog page")
	dialog.next_page()
	assert_true(close.visible, "close should appear on the final dialog page")
	root.free()


func test_controller_accept_advances_dialog_to_next_page() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	dialog.ensure_ready()
	dialog.show_dialog_pages("Guildmaster", ["First.", "Last."], false, false)
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	dialog._unhandled_input(event)
	var close := dialog.get_node("VBox/Buttons/CloseButton") as Button
	assert_true(close.visible)
	root.free()


func test_controller_accept_emits_close_on_final_close_page() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	var closed := []
	dialog.close_requested.connect(func(): closed.append(true))
	dialog.ensure_ready()
	dialog.show_dialog_pages("Guildmaster", ["Done."], false, false)
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	dialog._unhandled_input(event)
	assert_eq([true], closed)
	root.free()


func test_dialog_layout_sticks_to_top_on_720p_viewport() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	dialog.ensure_ready()
	dialog.show_dialog_pages("Reborn", ["You have been reborn."], false, false)
	dialog.apply_layout_for_viewport(Vector2(1280, 720))
	assert_eq(220.0, dialog.position.y)
	assert_true(dialog.position.y + dialog.size.y < 720.0)
	root.free()


func test_dialog_embeds_portrait_inside_panel_on_720p_viewport() -> void:
	var root = _scene.instantiate()
	var dialog := root.get_node("UI/DialogPanel") as TownDialogView
	var detached_portrait := root.get_node("UI/DialogPortrait") as TextureRect
	var image := Image.create(832, 832, false, Image.FORMAT_RGBA8)
	var texture := ImageTexture.create_from_image(image)
	dialog.ensure_ready()
	dialog.show_dialog_pages("Smith", ["I used to shape steel for adventurers."], false, false, texture)
	dialog.apply_layout_for_viewport(Vector2(1280, 720))
	var embedded_portrait := dialog.get_node("VBox/Portrait") as TextureRect
	assert_false(detached_portrait.visible)
	assert_true(embedded_portrait.visible)
	assert_eq(Vector2(112, 112), embedded_portrait.custom_minimum_size)
	root.free()
