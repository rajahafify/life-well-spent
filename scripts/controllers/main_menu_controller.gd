## MainMenuController — thin glue for main menu UI.
## Listens to button signals, calls engine methods to transition scenes.
class_name MainMenuController
extends Control


# ── References ─────────────────────────────────────────────────────────

@onready var _title: Label = $CenterContainer/UI/Title
@onready var _new_game_btn: Button = $CenterContainer/UI/NewGameButton
@onready var _quit_btn: Button = $CenterContainer/UI/QuitButton


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title.text = "Life Well Spent"
	_new_game_btn.text = "New Game"
	_quit_btn.text = "Quit"
	_title.add_theme_font_size_override("font_size", 36)
	$CenterContainer/UI.add_theme_constant_override("separation", 16)

	_new_game_btn.pressed.connect(_on_new_game_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)


# ── Actions ────────────────────────────────────────────────────────────

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/town_hub.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
