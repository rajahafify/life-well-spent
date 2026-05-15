## GameOverController - transition beat between run end and run summary.
class_name GameOverController
extends Control

const SUMMARY_SCENE_PATH := "res://scenes/summary_scene.tscn"

var requested_scene_path: String = ""


func _ready() -> void:
	var title := get_node_or_null("CenterContainer/UI/TitleLabel") as Label
	if title:
		title.text = "Game Over"
		title.add_theme_font_size_override("font_size", 48)
	var message := get_node_or_null("CenterContainer/UI/MessageLabel") as Label
	if message:
		message.text = "You spent this life."
		message.add_theme_font_size_override("font_size", 30)
	var button := get_node_or_null("CenterContainer/UI/ContinueButton") as Button
	if button:
		button.text = "Continue"
		button.add_theme_font_size_override("font_size", 28)
		if not button.pressed.is_connected(_on_continue_pressed):
			button.pressed.connect(_on_continue_pressed)
	_play_feedback_sfx("game_over")


func _on_continue_pressed() -> void:
	_play_feedback_sfx("summary_open")
	requested_scene_path = SUMMARY_SCENE_PATH
	if is_inside_tree():
		call_deferred("_change_scene_to_file", SUMMARY_SCENE_PATH)


func _change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


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
