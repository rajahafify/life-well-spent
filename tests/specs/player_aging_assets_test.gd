# tests/specs/player_aging_assets_test.gd
# Spec: Player aging sprites - asset colors communicate older character stages.

class_name TestPlayerAgingAssets
extends TestCase


func test_stage_one_front_hair_is_normal_warm_hair() -> void:
	var color := _pixel("res://assets/player_age_1.png", Vector2i(25, 146))
	assert_true(color.r > color.g)
	assert_true(color.g > color.b)


func test_stage_two_front_hair_is_grey() -> void:
	var color := _pixel("res://assets/player_age_2.png", Vector2i(25, 146))
	assert_true(absf(color.r - color.g) < 0.03)
	assert_true(absf(color.g - color.b) < 0.03)
	assert_true(color.r < 0.85)


func test_stage_three_front_beard_is_white() -> void:
	var color := _pixel("res://assets/player_age_3.png", Vector2i(31, 164))
	assert_true(color.r > 0.9)
	assert_true(color.g > 0.9)
	assert_true(color.b > 0.9)


func test_stage_one_slash_frame_does_not_include_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_1.png", Vector2i(14, 675))
	assert_eq(0.0, color.a)


func test_stage_two_slash_frame_does_not_include_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_2.png", Vector2i(14, 675))
	assert_eq(0.0, color.a)


func test_stage_three_slash_frame_does_not_include_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_3.png", Vector2i(14, 675))
	assert_eq(0.0, color.a)


func test_stage_one_training_sword_sheet_includes_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_1_sword.png", Vector2i(14, 672))
	assert_true(color.a > 0.0)


func test_stage_two_training_sword_sheet_includes_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_2_sword.png", Vector2i(14, 672))
	assert_true(color.a > 0.0)


func test_stage_three_training_sword_sheet_includes_sword_layer() -> void:
	var color := _pixel("res://assets/player_age_3_sword.png", Vector2i(14, 672))
	assert_true(color.a > 0.0)


func test_stage_one_training_sword_attack_rows_have_weapon_pixels_in_all_directions() -> void:
	_assert_attack_rows_differ_from_bare("res://assets/player_age_1.png", "res://assets/player_age_1_sword.png")


func test_stage_two_training_sword_attack_rows_have_weapon_pixels_in_all_directions() -> void:
	_assert_attack_rows_differ_from_bare("res://assets/player_age_2.png", "res://assets/player_age_2_sword.png")


func test_stage_three_training_sword_attack_rows_have_weapon_pixels_in_all_directions() -> void:
	_assert_attack_rows_differ_from_bare("res://assets/player_age_3.png", "res://assets/player_age_3_sword.png")


func test_stage_one_training_sword_armor_attack_rows_have_weapon_pixels_in_all_directions() -> void:
	_assert_attack_rows_differ_from_bare("res://assets/player_age_1.png", "res://assets/player_age_1_sword_armor.png")


func test_stage_one_training_sword_armor_sheet_includes_armor_layer() -> void:
	var color := _pixel("res://assets/player_age_1_sword_armor.png", Vector2i(333, 31))
	assert_true(color.a > 0.0)


func test_stage_one_training_sword_armor_sheet_uses_brown_leather() -> void:
	var color := _pixel("res://assets/player_age_1_sword_armor.png", Vector2i(333, 31))
	assert_true(color.r > color.g)
	assert_true(color.g >= color.b)
	assert_true(color.r - color.b > 0.08)


func test_stage_two_training_sword_armor_sheet_includes_armor_layer() -> void:
	var color := _pixel("res://assets/player_age_2_sword_armor.png", Vector2i(333, 31))
	assert_true(color.a > 0.0)


func test_stage_three_training_sword_armor_sheet_includes_armor_layer() -> void:
	var color := _pixel("res://assets/player_age_3_sword_armor.png", Vector2i(333, 31))
	assert_true(color.a > 0.0)


func _pixel(path: String, position: Vector2i) -> Color:
	var image := _load_png(path)
	return image.get_pixelv(position)


func _load_png(path: String) -> Image:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return Image.new()
	var buffer := file.get_buffer(file.get_length())
	var image := Image.new()
	var error := image.load_png_from_buffer(buffer)
	assert_eq(OK, error)
	return image


func _assert_attack_rows_differ_from_bare(bare_path: String, equipped_path: String) -> void:
	var bare := _load_png(bare_path)
	var equipped := _load_png(equipped_path)
	for row in [4, 5, 6, 7]:
		assert_true(_different_pixel_count_in_row(bare, equipped, row) > 20, "%s row %d should include visible sword pixels" % [equipped_path, row])


func _different_pixel_count_in_row(bare: Image, equipped: Image, row: int) -> int:
	var count := 0
	var start_y := row * 64
	for y in range(start_y, start_y + 64):
		for x in range(0, min(bare.get_width(), equipped.get_width())):
			if bare.get_pixel(x, y) != equipped.get_pixel(x, y):
				count += 1
	return count
