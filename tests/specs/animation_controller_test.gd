# tests/specs/animation_controller_test.gd
# Spec: AnimationController — handles idle/walk states with LPC frame_coords

class_name TestAnimationController
extends TestCase

var anim: AnimationController


func class_setup() -> void:
	pass


func setup() -> void:
	anim = AnimationController.new()


# ─── Initialization ──────────────────────────────────────────────────

func test_initial_state_is_idle() -> void:
	assert_eq("idle", anim.state)


func test_initial_direction_is_down() -> void:
	assert_eq("down", anim.direction)


func test_initial_frame_coords_idle_down() -> void:
	# Idle + down → column 0, row 2 (IDLE_BASE=0 + down=2)
	assert_eq(Vector2i(0, 2), anim.frame_coords)


# ─── State Transitions ───────────────────────────────────────────────

func test_start_walking() -> void:
	anim.start_walking()
	assert_eq("walking", anim.state)


func test_stop_walking() -> void:
	anim.start_walking()
	anim.stop_walking()
	assert_eq("idle", anim.state)


func test_walking_to_idle_cycle() -> void:
	# Multiple cycles
	anim.start_walking()
	assert_eq("walking", anim.state)

	anim.stop_walking()
	assert_eq("idle", anim.state)

	anim.start_walking()
	assert_eq("walking", anim.state)

	anim.stop_walking()
	assert_eq("idle", anim.state)


# ─── Direction ───────────────────────────────────────────────────────

func test_set_direction_down() -> void:
	anim.set_direction("down")
	assert_eq("down", anim.direction)


func test_set_direction_up() -> void:
	anim.set_direction("up")
	assert_eq("up", anim.direction)


func test_set_direction_left() -> void:
	anim.set_direction("left")
	assert_eq("left", anim.direction)


func test_set_direction_right() -> void:
	anim.set_direction("right")
	assert_eq("right", anim.direction)


func test_invalid_direction_defaults_to_down() -> void:
	anim.set_direction("invalid")
	assert_eq("down", anim.direction)


func test_direction_changes_during_walking() -> void:
	anim.start_walking()
	anim.set_direction("up")
	assert_eq("walking", anim.state)
	assert_eq("up", anim.direction)


# ─── Frame Mapping (frame_coords = Vector2i(column, row)) ────────────

func test_frame_coords_idle_down() -> void:
	anim.set_direction("down")
	assert_eq(Vector2i(0, 2), anim.frame_coords)  # col 0, row IDLE_BASE+down=2


func test_frame_coords_idle_up() -> void:
	anim.set_direction("up")
	assert_eq(Vector2i(0, 0), anim.frame_coords)  # col 0, row IDLE_BASE+up=0


func test_frame_coords_idle_left() -> void:
	anim.set_direction("left")
	assert_eq(Vector2i(0, 1), anim.frame_coords)  # col 0, row IDLE_BASE+left=1


func test_frame_coords_idle_right() -> void:
	anim.set_direction("right")
	assert_eq(Vector2i(0, 3), anim.frame_coords)  # col 0, row IDLE_BASE+right=3


func test_frame_coords_walking_down() -> void:
	anim.start_walking()
	anim.set_direction("down")
	# Walking uses WALK_BASE=8 + direction row
	assert_eq(Vector2i(0, 10), anim.frame_coords)  # col 0, row WALK_BASE+down=10


func test_frame_coords_walking_up() -> void:
	anim.start_walking()
	anim.set_direction("up")
	assert_eq(Vector2i(0, 8), anim.frame_coords)  # col 0, row WALK_BASE+up=8


# ─── Idle Animation ──────────────────────────────────────────────────

func test_idle_cycles_directions() -> void:
	# Start facing down
	anim.set_direction("down")
	assert_eq(Vector2i(0, 2), anim.frame_coords)

	# Tick to cycle direction (up)
	anim.tick(0.6)
	assert_eq("up", anim.direction)
	assert_eq(Vector2i(0, 0), anim.frame_coords)

	# Tick again (left)
	anim.tick(0.6)
	assert_eq("left", anim.direction)
	assert_eq(Vector2i(0, 1), anim.frame_coords)

	# Tick again (right)
	anim.tick(0.6)
	assert_eq("right", anim.direction)
	assert_eq(Vector2i(0, 3), anim.frame_coords)

	# Tick again — should loop back to down
	anim.tick(0.6)
	assert_eq("down", anim.direction)
	assert_eq(Vector2i(0, 2), anim.frame_coords)


func test_idle_does_not_change_frame_without_tick() -> void:
	var initial_coords = anim.frame_coords
	anim.tick(0.1)  # Less than 0.5s threshold
	assert_eq(initial_coords, anim.frame_coords)


func test_walking_advances_frame_but_does_not_cycle_direction() -> void:
	anim.start_walking()
	anim.set_direction("down")
	assert_eq(Vector2i(0, 10), anim.frame_coords)

	# Tick while walking — frame advances, direction stays
	anim.tick(1.0)
	assert_eq("down", anim.direction)
	# 10 frame advances at 0.1s each → walk_frame = 10 % 9 = 1
	assert_eq(Vector2i(1, 10), anim.frame_coords)


# ─── State + Direction Combination ────────────────────────────────────

func test_start_walking_updates_frame() -> void:
	anim.set_direction("up")
	assert_eq(Vector2i(0, 0), anim.frame_coords)

	anim.start_walking()
	# Frame should still be up but now on walk row
	assert_eq(Vector2i(0, 8), anim.frame_coords)


func test_stop_walking_preserves_direction() -> void:
	anim.set_direction("left")
	anim.start_walking()
	assert_eq("left", anim.direction)

	anim.stop_walking()
	assert_eq("left", anim.direction)
	assert_eq(Vector2i(0, 1), anim.frame_coords)  # col 0, row IDLE_BASE+left=1
