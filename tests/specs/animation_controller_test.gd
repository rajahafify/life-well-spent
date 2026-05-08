# tests/specs/animation_controller_test.gd
# Spec: AnimationController — handles idle/walk states and direction

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


func test_initial_frame_is_0() -> void:
	check_eq(anim.current_frame, 0)


func test_initial_direction_is_down() -> void:
	check_eq(anim.direction, "down")


func test_frame_count_is_4() -> void:
	check_eq(anim.FRAME_COUNT, 4)


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


# ─── Frame Mapping ───────────────────────────────────────────────────

func test_frame_matches_direction_down() -> void:
	anim.set_direction("down")
	check_eq(anim.current_frame, 0)


func test_frame_matches_direction_up() -> void:
	anim.set_direction("up")
	check_eq(anim.current_frame, 1)


func test_frame_matches_direction_left() -> void:
	anim.set_direction("left")
	check_eq(anim.current_frame, 2)


func test_frame_matches_direction_right() -> void:
	anim.set_direction("right")
	check_eq(anim.current_frame, 3)


# ─── Idle Animation ──────────────────────────────────────────────────

func test_idle_cycles_directions() -> void:
	# Start facing down
	anim.set_direction("down")
	check_eq(anim.current_frame, 0)
	
	# Tick to cycle direction
	anim.tick(0.6)
	check_eq(anim.direction, "up")
	check_eq(anim.current_frame, 1)
	
	# Tick again
	anim.tick(0.6)
	check_eq(anim.direction, "left")
	check_eq(anim.current_frame, 2)
	
	# Tick again
	anim.tick(0.6)
	check_eq(anim.direction, "right")
	check_eq(anim.current_frame, 3)
	
	# Tick again - should loop back to down
	anim.tick(0.6)
	check_eq(anim.direction, "down")
	check_eq(anim.current_frame, 0)


func test_idle_does_not_change_frame_without_tick() -> void:
	var initial_frame = anim.current_frame
	anim.tick(0.1)  # Less than 0.5s threshold
	check_eq(anim.current_frame, initial_frame)


func test_walking_state_does_not_cycle_direction() -> void:
	anim.start_walking()
	anim.set_direction("down")
	check_eq(anim.current_frame, 0)
	
	# Tick while walking — idle cycling shouldn't happen
	anim.tick(1.0)
	check_eq(anim.direction, "down")
	check_eq(anim.current_frame, 0)


# ─── State + Direction Combination ────────────────────────────────────

func test_start_walking_updates_frame() -> void:
	anim.set_direction("up")
	check_eq(anim.current_frame, 1)
	
	anim.start_walking()
	# Frame should still be 1 (up) — walking doesn't change frame
	check_eq(anim.current_frame, 1)


func test_stop_walking_preserves_direction() -> void:
	anim.set_direction("left")
	anim.start_walking()
	check_eq(anim.direction, "left")
	
	anim.stop_walking()
	check_eq(anim.direction, "left")
	check_eq(anim.current_frame, 2)
