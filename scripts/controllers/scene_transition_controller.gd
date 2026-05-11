## SceneTransitionController — thin scene transition boundary.
class_name SceneTransitionController
extends Node

var target_scene_path: String = ""
var transition_requested: bool = false


func request_transition(scene_path: String) -> void:
	target_scene_path = scene_path
	transition_requested = true


func execute_transition() -> Error:
	if target_scene_path == "" or get_tree() == null:
		return ERR_UNCONFIGURED
	transition_requested = false
	return get_tree().change_scene_to_file(target_scene_path)
