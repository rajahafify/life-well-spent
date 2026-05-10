# tests/specs/player_movement_test.gd
# Spec: PlayerMovement view — direction vector math, state defaults

class_name TestPlayerMovement
extends TestCase


# ─── Direction Vector Helpers ────────────────────────────────────────

func test_dir_from_vector_right() -> void:
	assert_eq("right", PlayerMovement._dir_from_vector(Vector2(10, 5)))


func test_dir_from_vector_left() -> void:
	assert_eq("left", PlayerMovement._dir_from_vector(Vector2(-10, 5)))


func test_dir_from_vector_down() -> void:
	assert_eq("down", PlayerMovement._dir_from_vector(Vector2(3, 10)))


func test_dir_from_vector_up() -> void:
	assert_eq("up", PlayerMovement._dir_from_vector(Vector2(-3, -10)))


func test_dir_from_vector_equal_magnitudes_favors_horizontal() -> void:
	# When |x| == |y|, horizontal axis wins
	assert_eq("right", PlayerMovement._dir_from_vector(Vector2(5, 5)))


func test_dir_from_vector_zero_vector_defaults_to_down() -> void:
	assert_eq("down", PlayerMovement._dir_from_vector(Vector2.ZERO))


func test_dir_from_vector_pure_vertical_down() -> void:
	assert_eq("down", PlayerMovement._dir_from_vector(Vector2(0, 10)))


func test_dir_from_vector_pure_vertical_up() -> void:
	assert_eq("up", PlayerMovement._dir_from_vector(Vector2(0, -10)))


func test_dir_from_vector_pure_horizontal_right() -> void:
	assert_eq("right", PlayerMovement._dir_from_vector(Vector2(10, 0)))


func test_dir_from_vector_pure_horizontal_left() -> void:
	assert_eq("left", PlayerMovement._dir_from_vector(Vector2(-10, 0)))
