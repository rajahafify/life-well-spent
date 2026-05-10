# tests/specs/main_menu_test.gd
# Spec: MainMenu scene structure and button text

class_name TestMainMenu
extends TestCase


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
