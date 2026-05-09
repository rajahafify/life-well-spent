# tests/specs/animation_controller_test.gd
# Spec: AnimationController — handles idle/walk states with LPC frame_coords

class_name TestAnimationController
extends TestCase

var anim: AnimationController


func class_setup() -> void:
	pass


func setup() -> void:
	anim = AnimationController.new()


func teardown() -> void:
	pass


# ─── Initialization ──────────────────────────────────────────────────

func test_initial_state_is_idle() -> void:
	check_eq(anim.state, "idle")


func test_initial_direction_is_down() -> void:
	check_eq(anim.direction, "down")


func test_initial_frame_coords_idle_down() -> void:
	# Idle + down → column 0, row 2 (IDLE_BASE=0 + down=2)
	check_eq(anim.frame_coords, Vector2i(0, 2))


# ─── State Transitions ───────────────────────────────────────────────

func test_start_walking() -> void:
	anim.start_walking()
	check_eq(anim.state, "walking")


func test_stop_walking() -> void:
	anim.start_walking()
	anim.stop_walking()
	check_eq(anim.state, "idle")


func test_walking_to_idle_cycle() -> void:
	# Multiple cycles
	anim.start_walking()
	check_eq(anim.state, "walking")

	anim.stop_walking()
	check_eq(anim.state, "idle")

	anim.start_walking()
	check_eq(anim.state, "walking")

	anim.stop_walking()
	check_eq(anim.state, "idle")


# ─── Direction ───────────────────────────────────────────────────────

func test_set_direction_down() -> void:
	anim.set_direction("down")
	check_eq(anim.direction, "down")


func test_set_direction_up() -> void:
	anim.set_direction("up")
	check_eq(anim.direction, "up")


func test_set_direction_left() -> void:
	anim.set_direction("left")
	check_eq(anim.direction, "left")


func test_set_direction_right() -> void:
	anim.set_direction("right")
	check_eq(anim.direction, "right")


func test_invalid_direction_defaults_to_down() -> void:
	anim.set_direction("invalid")
	check_eq(anim.direction, "down")


func test_direction_changes_during_walking() -> void:
	anim.start_walking()
	anim.set_direction("up")
	check_eq(anim.state, "walking")
	check_eq(anim.direction, "up")


# ─── Frame Mapping (frame_coords = Vector2i(column, row)) ────────────

func test_frame_coords_idle_down() -> void:
	anim.set_direction("down")
	check_eq(anim.frame_coords, Vector2i(0, 2))  # col 0, row IDLE_BASE+down=2


func test_frame_coords_idle_up() -> void:
	anim.set_direction("up")
	check_eq(anim.frame_coords, Vector2i(0, 0))  # col 0, row IDLE_BASE+up=0


func test_frame_coords_idle_left() -> void:
	anim.set_direction("left")
	check_eq(anim.frame_coords, Vector2i(0, 1))  # col 0, row IDLE_BASE+left=1


func test_frame_coords_idle_right() -> void:
	anim.set_direction("right")
	check_eq(anim.frame_coords, Vector2i(0, 3))  # col 0, row IDLE_BASE+right=3


func test_frame_coords_walking_down() -> void:
	anim.start_walking()
	anim.set_direction("down")
	# Walking uses WALK_BASE=8 + direction row
	check_eq(anim.frame_coords, Vector2i(0, 10))  # col 0, row WALK_BASE+down=10


func test_frame_coords_walking_up() -> void:
	anim.start_walking()
	anim.set_direction("up")
	check_eq(anim.frame_coords, Vector2i(0, 8))  # col 0, row WALK_BASE+up=8


# ─── Idle Animation ──────────────────────────────────────────────────

func test_idle_cycles_directions() -> void:
	# Start facing down
	anim.set_direction("down")
	check_eq(anim.frame_coords, Vector2i(0, 2))

	# Tick to cycle direction (up)
	anim.tick(0.6)
	check_eq(anim.direction, "up")
	check_eq(anim.frame_coords, Vector2i(0, 0))

	# Tick again (left)
	anim.tick(0.6)
	check_eq(anim.direction, "left")
	check_eq(anim.frame_coords, Vector2i(0, 1))

	# Tick again (right)
	anim.tick(0.6)
	check_eq(anim.direction, "right")
	check_eq(anim.frame_coords, Vector2i(0, 3))

	# Tick again — should loop back to down
	anim.tick(0.6)
	check_eq(anim.direction, "down")
	check_eq(anim.frame_coords, Vector2i(0, 2))


func test_idle_does_not_change_frame_without_tick() -> void:
	var initial_coords = anim.frame_coords
	anim.tick(0.1)  # Less than 0.5s threshold
	check_eq(anim.frame_coords, initial_coords)


func test_walking_state_does_not_cycle_direction() -> void:
	anim.start_walking()
	anim.set_direction("down")
	check_eq(anim.frame_coords, Vector2i(0, 10))

	# Tick while walking — idle cycling shouldn't happen
	anim.tick(1.0)
	check_eq(anim.direction, "down")
	check_eq(anim.frame_coords, Vector2i(0, 10))


# ─── State + Direction Combination ────────────────────────────────────

func test_start_walking_updates_frame() -> void:
	anim.set_direction("up")
	check_eq(anim.frame_coords, Vector2i(0, 0))

	anim.start_walking()
	# Frame should still be up but now on walk row
	check_eq(anim.frame_coords, Vector2i(0, 8))


func test_stop_walking_preserves_direction() -> void:
	anim.set_direction("left")
	anim.start_walking()
	check_eq(anim.direction, "left")

	anim.stop_walking()
	check_eq(anim.direction, "left")
	check_eq(anim.frame_coords, Vector2i(0, 1))  # col 0, row IDLE_BASE+left=1
