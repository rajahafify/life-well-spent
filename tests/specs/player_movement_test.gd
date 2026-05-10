# tests/specs/player_movement_test.gd
# Spec: CharacterMovement view — direction vector math, state defaults

class_name TestCharacterMovement
extends TestCase


# ─── Direction Vector Helpers ────────────────────────────────────────

func test_dir_from_vector_right() -> void:
	assert_eq("right", CharacterMovement._dir_from_vector(Vector2(10, 5)))


func test_dir_from_vector_left() -> void:
	assert_eq("left", CharacterMovement._dir_from_vector(Vector2(-10, 5)))


func test_dir_from_vector_down() -> void:
	assert_eq("down", CharacterMovement._dir_from_vector(Vector2(3, 10)))


func test_dir_from_vector_up() -> void:
	assert_eq("up", CharacterMovement._dir_from_vector(Vector2(-3, -10)))


func test_dir_from_vector_equal_magnitudes_favors_horizontal() -> void:
	# When |x| == |y|, horizontal axis wins
	assert_eq("right", CharacterMovement._dir_from_vector(Vector2(5, 5)))


func test_dir_from_vector_zero_vector_defaults_to_down() -> void:
	assert_eq("down", CharacterMovement._dir_from_vector(Vector2.ZERO))


func test_dir_from_vector_pure_vertical_down() -> void:
	assert_eq("down", CharacterMovement._dir_from_vector(Vector2(0, 10)))


func test_dir_from_vector_pure_vertical_up() -> void:
	assert_eq("up", CharacterMovement._dir_from_vector(Vector2(0, -10)))


func test_dir_from_vector_pure_horizontal_right() -> void:
	assert_eq("right", CharacterMovement._dir_from_vector(Vector2(10, 0)))


func test_dir_from_vector_pure_horizontal_left() -> void:
	assert_eq("left", CharacterMovement._dir_from_vector(Vector2(-10, 0)))


# ─── Movement / Facing API ───────────────────────────────────────────

func test_static_character_ignores_move_to() -> void:
	var movement := CharacterMovement.new()
	movement.is_static = true
	movement.move_to(Vector2(100, 100))
	assert_false(movement.moving, "static NPC movement should ignore move_to")
	movement.free()


func test_set_facing_updates_frame_direction() -> void:
	var movement := CharacterMovement.new()
	movement._ready()
	assert_true(movement.has_method("set_facing"), "CharacterMovement should expose set_facing for controllers")
	if not movement.has_method("set_facing"):
		movement.free()
		return
	movement.call("set_facing", "left")
	assert_eq(Vector2i(0, 1), movement.frame_coords)
	movement.free()
