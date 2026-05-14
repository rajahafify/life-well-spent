# tests/specs/player_aging_model_test.gd
# Spec: PlayerAgingModel - maps Life pressure to player sprite aging stages.

class_name TestPlayerAgingModel
extends TestCase

const MODEL_SCRIPT := "res://scripts/models/player_aging_model.gd"

var model


func setup() -> void:
	var script := load(MODEL_SCRIPT) as GDScript
	assert_not_null(script, "PlayerAgingModel script should exist")
	if script:
		model = script.new()


func teardown() -> void:
	if model:
		model.free()
		model = null


func test_full_life_uses_age_stage_one() -> void:
	if model == null:
		return
	assert_eq(1, model.stage_for_max_hp(100))


func test_sixty_life_uses_age_stage_two() -> void:
	if model == null:
		return
	assert_eq(2, model.stage_for_max_hp(60))


func test_twenty_life_uses_age_stage_three() -> void:
	if model == null:
		return
	assert_eq(3, model.stage_for_max_hp(20))


func test_stage_one_texture_path_is_first_aging_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_1.png", model.texture_path_for_stage(1))


func test_stage_two_texture_path_is_second_aging_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_2.png", model.texture_path_for_stage(2))


func test_stage_three_texture_path_is_third_aging_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_3.png", model.texture_path_for_stage(3))


func test_texture_path_for_life_uses_matching_stage() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_2.png", model.texture_path_for_max_hp(60))


func test_training_sword_uses_stage_one_weapon_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_1_sword.png", model.texture_path_for_stage_with_weapon(1, "training_sword"))


func test_training_sword_uses_stage_two_weapon_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_2_sword.png", model.texture_path_for_stage_with_weapon(2, "training_sword"))


func test_unknown_weapon_uses_bare_stage_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_3.png", model.texture_path_for_stage_with_weapon(3, "unknown_sword"))


func test_texture_path_for_life_and_training_sword_uses_matching_weapon_stage() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_2_sword.png", model.texture_path_for_max_hp_and_weapon(60, "training_sword"))


func test_training_sword_and_leather_armor_use_stage_two_equipment_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_2_sword_armor.png", model.texture_path_for_stage_with_equipment(2, "training_sword", "leather_armor"))


func test_armor_without_training_sword_uses_bare_stage_sprite() -> void:
	if model == null:
		return
	assert_eq("res://assets/player_age_1.png", model.texture_path_for_stage_with_equipment(1, "", "leather_armor"))
