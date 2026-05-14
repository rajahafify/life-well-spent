# tests/specs/profile_system_test.gd
# Spec: ProfileSystem profile path and reset behavior.

class_name TestProfileSystem
extends TestCase

const PROFILE_SCRIPT := preload("res://scripts/managers/profile_system.gd")

var profile
var _test_path := "user://life_well_spent_profile_system_test.json"


func setup() -> void:
	profile = PROFILE_SCRIPT.new()


func teardown() -> void:
	if profile:
		profile.free()
		profile = null
	if FileAccess.file_exists(_test_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_test_path))


func test_set_profile_path_redirects_save_and_load() -> void:
	profile.set_profile_path(_test_path)
	profile.player().unlock_facility("swordsman_guild")
	assert_true(profile.save_profile())
	var restored = PROFILE_SCRIPT.new()
	restored.set_profile_path(_test_path)
	assert_true(restored.load_profile())
	assert_in("swordsman_guild", restored.player().unlocked_facilities)
	restored.free()


func test_empty_profile_path_uses_default_path() -> void:
	profile.set_profile_path("")
	assert_eq(profile.PROFILE_PATH, profile.current_profile_path())
