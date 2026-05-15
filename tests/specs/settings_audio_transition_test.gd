# tests/specs/settings_audio_transition_test.gd
# Spec: polish managers/models — settings, audio, scene transitions

class_name TestSettingsAudioTransition
extends TestCase


func _new_script_object(path: String):
	var script: GDScript = load(path)
	return script.new()


func test_settings_model_defaults() -> void:
	var settings = _new_script_object("res://scripts/models/settings_model.gd")
	assert_eq(1.0, settings.master_volume)
	assert_false(settings.fullscreen)
	settings.free()


func test_settings_model_clamps_volume() -> void:
	var settings = _new_script_object("res://scripts/models/settings_model.gd")
	settings.set_master_volume(2.0)
	assert_eq(1.0, settings.master_volume)
	settings.set_master_volume(-1.0)
	assert_eq(0.0, settings.master_volume)
	settings.free()


func test_audio_manager_tracks_named_sfx_requests() -> void:
	var audio = _new_script_object("res://scripts/managers/audio_manager.gd")
	audio.play_sfx("complete_task")
	assert_eq("complete_task", audio.last_sfx)
	audio.free()


func test_feedback_system_plays_registered_audio_cue() -> void:
	var feedback_scene := Node.new()
	var script := load("res://scripts/managers/feedback_system.gd") as GDScript
	feedback_scene.set_script(script)
	var player = feedback_scene.play_sfx("quest_reward")
	assert_eq("quest_reward", feedback_scene.last_sfx)
	assert_eq(1, feedback_scene.spawned_sfx_count)
	assert_not_null(player)
	feedback_scene.free()


func test_scene_transition_controller_requests_target_scene() -> void:
	var controller = _new_script_object("res://scripts/controllers/scene_transition_controller.gd")
	controller.request_transition("res://scenes/town_scene.tscn")
	assert_eq("res://scenes/town_scene.tscn", controller.target_scene_path)
	assert_true(controller.transition_requested)
	controller.free()
