## SummarySceneController - run summary and restart choices.
class_name SummarySceneController
extends Control

const TOWN_SCENE_PATH := "res://scenes/town_scene.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"
const RUN_SUMMARY_SCRIPT := preload("res://scripts/models/run_summary_model.gd")

var requested_scene_path: String = ""
var _run_summary = RUN_SUMMARY_SCRIPT.new()


func _exit_tree() -> void:
	if _run_summary:
		_run_summary.free()
		_run_summary = null


func _ready() -> void:
	var title := get_node_or_null("CenterContainer/UI/TitleLabel") as Label
	if title:
		title.text = "Run Summary"
		title.add_theme_font_size_override("font_size", 42)
	var rebirth_button := get_node_or_null("CenterContainer/UI/Buttons/RebirthButton") as Button
	if rebirth_button:
		rebirth_button.text = "Rebirth"
		rebirth_button.add_theme_font_size_override("font_size", 26)
		if not rebirth_button.pressed.is_connected(_on_rebirth_pressed):
			rebirth_button.pressed.connect(_on_rebirth_pressed)
	var new_game_button := get_node_or_null("CenterContainer/UI/Buttons/NewGameButton") as Button
	if new_game_button:
		new_game_button.text = "End Game"
		new_game_button.add_theme_font_size_override("font_size", 26)
		if not new_game_button.pressed.is_connected(_on_new_game_pressed):
			new_game_button.pressed.connect(_on_new_game_pressed)
	render_summary(_profile_system(), _inventory_system())
	_play_feedback_sfx("summary_open")


func render_summary(profile_system, inventory_system) -> void:
	var summary := get_node_or_null("CenterContainer/UI/SummaryLabel") as Label
	if summary == null:
		return
	var player = profile_system.player() if profile_system and profile_system.has_method("player") else null
	var inventory = inventory_system.model() if inventory_system and inventory_system.has_method("model") else null
	summary.text = _run_summary.summary_text(player, inventory)
	summary.add_theme_font_size_override("font_size", 28)


func rebirth_to_town(profile_system, inventory_system) -> bool:
	if profile_system == null or not profile_system.has_method("player"):
		return false
	var player = profile_system.player()
	if player == null:
		return false
	if player.has_method("rebirth"):
		player.rebirth()
	if inventory_system and inventory_system.has_method("reset"):
		inventory_system.reset()
	if profile_system.has_method("save_profile"):
		profile_system.save_profile()
	requested_scene_path = TOWN_SCENE_PATH
	return true


func end_game_to_main_menu(profile_system, _inventory_system) -> bool:
	if profile_system and profile_system.has_method("save_profile"):
		profile_system.save_profile()
	requested_scene_path = MAIN_MENU_SCENE_PATH
	return true


func _on_rebirth_pressed() -> void:
	_play_feedback_sfx("rebirth")
	if rebirth_to_town(_profile_system(), _inventory_system()) and is_inside_tree():
		call_deferred("_change_scene_to_file", TOWN_SCENE_PATH)


func _on_new_game_pressed() -> void:
	_play_feedback_sfx("new_game")
	if end_game_to_main_menu(_profile_system(), _inventory_system()) and is_inside_tree():
		call_deferred("_change_scene_to_file", MAIN_MENU_SCENE_PATH)


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _profile_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/ProfileSystem")


func _inventory_system() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/InventorySystem")


func _feedback_system() -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/FeedbackSystem")
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("FeedbackSystem")


func _play_feedback_sfx(sfx_name: String) -> void:
	var system := _feedback_system()
	if system and system.has_method("play_sfx"):
		system.play_sfx(sfx_name)
