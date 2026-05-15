# tests/specs/main_menu_test.gd
# Spec: MainMenu scene structure and button text

class_name TestMainMenu
extends TestCase

class FakePlayer:
	var game_over_requested: bool = true
	var max_hp: int = 0
	var hp: int = 0
	var xp: int = 10
	var unlocked_facilities: Array[String] = ["swordsman_guild"]

	func rebirth() -> void:
		max_hp = 100
		hp = 100
		game_over_requested = false

	func apply_dict(data: Dictionary) -> void:
		max_hp = int(data.get("max_hp", 100))
		hp = max_hp
		xp = int(data.get("xp", 0))
		game_over_requested = bool(data.get("game_over_requested", false))
		unlocked_facilities.clear()
		for facility in data.get("unlocked_facilities", []):
			unlocked_facilities.append(str(facility))


class FakeProfileSystem:
	var fake_player := FakePlayer.new()
	var saved: bool = false

	func player():
		return fake_player

	func save_profile() -> bool:
		saved = true
		return true


class FakeInventorySystem:
	var reset_called: bool = false

	func reset() -> void:
		reset_called = true


static var _scene: PackedScene = load("res://scenes/main_menu.tscn")


func teardown() -> void:
	pass


# ─── Scene Structure ──────────────────────────────────────────────────

func test_scene_loads_without_error() -> void:
	var root = _scene.instantiate()
	assert_not_null(root, "main menu scene should instantiate")
	assert_true(root is Control, "root should be a Control")
	root.free()


func test_has_center_container() -> void:
	var root = _scene.instantiate()
	var center = root.get_node("CenterContainer")
	assert_not_null(center, "should have CenterContainer child")
	root.free()


func test_has_ui_vbox() -> void:
	var root = _scene.instantiate()
	var ui = root.get_node("CenterContainer/UI")
	assert_not_null(ui, "should have UI VBoxContainer")
	root.free()


# ─── Title ────────────────────────────────────────────────────────────

func test_main_menu_uses_aging_image_below_menu() -> void:
	var root = _scene.instantiate()
	var icon_container := root.get_node("IconContainer") as CenterContainer
	var hero := root.get_node("IconContainer/AgingImage") as TextureRect
	assert_not_null(icon_container)
	assert_not_null(hero)
	assert_true(hero.texture.resource_path.ends_with("icon.png"))
	assert_eq(TextureRect.STRETCH_KEEP_ASPECT_CENTERED, hero.stretch_mode)
	assert_eq(Vector2(560, 420), hero.custom_minimum_size)
	assert_true(abs(icon_container.anchor_top - 0.68) < 0.001)
	assert_eq(1.0, icon_container.anchor_bottom)
	root.free()


func test_main_menu_keeps_menu_center_stage_on_icon_colored_background() -> void:
	var root = _scene.instantiate()
	var background := root.get_node("Background") as ColorRect
	var center := root.get_node("CenterContainer") as CenterContainer
	assert_not_null(background)
	assert_eq(Color(0.38, 0.62, 0.43, 1.0), background.color)
	assert_eq(0.0, center.anchor_top)
	assert_eq(1.0, center.anchor_bottom)
	root.free()


func test_main_menu_title_and_buttons_are_centered_with_wide_icon() -> void:
	var root = _scene.instantiate()
	var title := root.get_node("CenterContainer/UI/Title") as Label
	var continue_button := root.get_node("CenterContainer/UI/ContinueButton") as Button
	var new_game_button := root.get_node("CenterContainer/UI/NewGameButton") as Button
	var quit_button := root.get_node("CenterContainer/UI/QuitButton") as Button
	assert_eq(Control.SIZE_SHRINK_CENTER, title.size_flags_horizontal)
	assert_eq(Control.SIZE_SHRINK_CENTER, continue_button.size_flags_horizontal)
	assert_eq(Control.SIZE_SHRINK_CENTER, new_game_button.size_flags_horizontal)
	assert_eq(Control.SIZE_SHRINK_CENTER, quit_button.size_flags_horizontal)
	root.free()


func test_has_title_label() -> void:
	var root = _scene.instantiate()
	var title = root.get_node("CenterContainer/UI/Title")
	assert_not_null(title, "should have Title Label")
	root.free()


func test_title_text_is_life_well_spent() -> void:
	var root = _scene.instantiate()
	var title: Label = root.get_node("CenterContainer/UI/Title") as Label
	assert_not_null(title)
	var controller: MainMenuController = root as MainMenuController
	controller._ready()
	assert_eq("Life Well Spent", title.text, "title should read 'Life Well Spent'")
	root.free()


# ─── New Game Button ──────────────────────────────────────────────────

func test_has_new_game_button() -> void:
	var root = _scene.instantiate()
	var btn = root.get_node("CenterContainer/UI/NewGameButton")
	assert_not_null(btn, "should have NewGameButton")
	root.free()


func test_has_continue_button() -> void:
	var root = _scene.instantiate()
	var btn = root.get_node("CenterContainer/UI/ContinueButton")
	assert_not_null(btn, "should have ContinueButton")
	root.free()


func test_new_game_button_text() -> void:
	var root = _scene.instantiate()
	var btn: Button = root.get_node("CenterContainer/UI/NewGameButton") as Button
	assert_not_null(btn)
	var controller: MainMenuController = root as MainMenuController
	controller._ready()
	assert_eq("New Game", btn.text, "button should say 'New Game'")
	root.free()


func test_continue_button_text() -> void:
	var root = _scene.instantiate()
	var btn: Button = root.get_node("CenterContainer/UI/ContinueButton") as Button
	assert_not_null(btn)
	var controller: MainMenuController = root as MainMenuController
	controller._ready()
	assert_eq("Continue", btn.text, "button should say 'Continue'")
	root.free()


func test_continue_auto_rebirths_ended_run_before_entering_town() -> void:
	var root = _scene.instantiate() as MainMenuController
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	assert_true(root.continue_existing_run(profile, inventory))
	assert_false(profile.fake_player.game_over_requested)
	assert_eq(100, profile.fake_player.max_hp)
	assert_eq(100, profile.fake_player.hp)
	assert_true(inventory.reset_called)
	assert_true(profile.saved)
	assert_in("swordsman_guild", profile.fake_player.unlocked_facilities)
	root.free()


func test_continue_does_not_rebirth_active_run() -> void:
	var root = _scene.instantiate() as MainMenuController
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	profile.fake_player.game_over_requested = false
	assert_false(root.continue_existing_run(profile, inventory))
	assert_false(inventory.reset_called)
	assert_false(profile.saved)
	root.free()


func test_new_game_button_opens_reset_confirmation() -> void:
	var root = _scene.instantiate() as MainMenuController
	root._ready()
	var panel := root.get_node("CenterContainer/UI/NewGameConfirmPanel") as PanelContainer
	assert_false(panel.visible)
	(root.get_node("CenterContainer/UI/NewGameButton") as Button).pressed.emit()
	assert_true(panel.visible)
	assert_true((panel.get_node("VBox/MessageLabel") as Label).text.contains("starting a new game will reset progress"))
	root.free()


func test_controller_down_then_accept_opens_new_game_confirmation() -> void:
	var root = _scene.instantiate() as MainMenuController
	root._ready()
	var panel := root.get_node("CenterContainer/UI/NewGameConfirmPanel") as PanelContainer
	var down := InputEventJoypadButton.new()
	down.button_index = JOY_BUTTON_DPAD_DOWN
	down.pressed = true
	root._unhandled_input(down)
	var accept := InputEventJoypadButton.new()
	accept.button_index = JOY_BUTTON_A
	accept.pressed = true
	root._unhandled_input(accept)
	assert_true(panel.visible)
	root.free()


func test_confirm_new_game_resets_progress_from_zero() -> void:
	var root = _scene.instantiate() as MainMenuController
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	assert_true(root.start_new_game_from_zero(profile, inventory))
	assert_eq(100, profile.fake_player.max_hp)
	assert_eq(0, profile.fake_player.xp)
	assert_false(profile.fake_player.game_over_requested)
	assert_eq([], profile.fake_player.unlocked_facilities)
	assert_true(inventory.reset_called)
	assert_true(profile.saved)
	assert_eq("res://scenes/town_scene.tscn", root.requested_scene_path)
	root.free()


# ─── Quit Button ──────────────────────────────────────────────────────

func test_has_quit_button() -> void:
	var root = _scene.instantiate()
	var btn = root.get_node("CenterContainer/UI/QuitButton")
	assert_not_null(btn, "should have QuitButton")
	root.free()


func test_quit_button_text() -> void:
	var root = _scene.instantiate()
	var btn: Button = root.get_node("CenterContainer/UI/QuitButton") as Button
	assert_not_null(btn)
	var controller: MainMenuController = root as MainMenuController
	controller._ready()
	assert_eq("Quit", btn.text, "button should say 'Quit'")
	root.free()
