# tests/specs/main_menu_test.gd
# Spec: MainMenu scene structure and button text

class_name TestMainMenu
extends TestCase

class FakePlayer:
	var game_over_requested: bool = true
	var max_hp: int = 0
	var hp: int = 0
	var unlocked_facilities: Array[String] = ["swordsman_guild"]

	func rebirth() -> void:
		max_hp = 100
		hp = 100
		game_over_requested = false


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


func test_new_game_button_text() -> void:
	var root = _scene.instantiate()
	var btn: Button = root.get_node("CenterContainer/UI/NewGameButton") as Button
	assert_not_null(btn)
	var controller: MainMenuController = root as MainMenuController
	controller._ready()
	assert_eq("New Game", btn.text, "button should say 'New Game'")
	root.free()


func test_new_game_auto_rebirths_ended_run_before_entering_town() -> void:
	var root = _scene.instantiate() as MainMenuController
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	assert_true(root._auto_rebirth_ended_run(profile, inventory))
	assert_false(profile.fake_player.game_over_requested)
	assert_eq(100, profile.fake_player.max_hp)
	assert_eq(100, profile.fake_player.hp)
	assert_true(inventory.reset_called)
	assert_true(profile.saved)
	assert_in("swordsman_guild", profile.fake_player.unlocked_facilities)
	root.free()


func test_new_game_does_not_rebirth_active_run() -> void:
	var root = _scene.instantiate() as MainMenuController
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	profile.fake_player.game_over_requested = false
	assert_false(root._auto_rebirth_ended_run(profile, inventory))
	assert_false(inventory.reset_called)
	assert_false(profile.saved)
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
