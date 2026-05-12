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


func _pixel(path: String, position: Vector2i) -> Color:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return Color.TRANSPARENT
	var buffer := file.get_buffer(file.get_length())
	var image := Image.new()
	var error := image.load_png_from_buffer(buffer)
	assert_eq(OK, error)
	return image.get_pixelv(position)
