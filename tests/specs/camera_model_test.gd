# tests/specs/camera_model_test.gd
# Spec: CameraModel — pure logic for camera follow, deadzone, bounds, zoom

class_name TestCameraModel
extends TestCase

var model: CameraModel


func setup() -> void:
	model = CameraModel.new()
	model.position = Vector2.ZERO
	model.target_position = Vector2.ZERO


func teardown() -> void:
	model.free()


# ─── Follow Target ───────────────────────────────────────────────────

func test_follows_target_with_default_lerp_speed() -> void:
	model.target_position = Vector2(300, 200)
	model.update(0.016)

	var expected_x := 0.0 + (300.0 - 0.0) * min(1.0, 5.0 * 0.016)
	var expected_y := 0.0 + (200.0 - 0.0) * min(1.0, 5.0 * 0.016)
	assert_eq(expected_x, model.position.x)
	assert_eq(expected_y, model.position.y)


func test_custom_lerp_speed_affects_follow() -> void:
	model.lerp_speed = 10.0
	model.target_position = Vector2(200, 100)
	model.update(0.016)

	var expected_x := 0.0 + (200.0 - 0.0) * min(1.0, 10.0 * 0.016)
	var expected_y := 0.0 + (100.0 - 0.0) * min(1.0, 10.0 * 0.016)
	assert_eq(expected_x, model.position.x)
	assert_eq(expected_y, model.position.y)


# ─── Deadzone ────────────────────────────────────────────────────────

func test_deadzone_stops_follow_inside_zone() -> void:
	model.deadzone = Rect2(-50, -50, 100, 100)
	model.target_position = Vector2(30, 30)
	model.update(0.016)

	assert_eq(0.0, model.position.x)
	assert_eq(0.0, model.position.y)


func test_deadzone_follows_when_outside_zone() -> void:
	model.deadzone = Rect2(-50, -50, 100, 100)
	model.target_position = Vector2(60, 60)
	model.update(0.016)

	assert_neq(0.0, model.position.x)
	assert_neq(0.0, model.position.y)


func test_no_deadzone_always_follows() -> void:
	model.deadzone = Rect2()
	model.target_position = Vector2(100, 100)
	model.update(0.016)

	assert_neq(0.0, model.position.x)
	assert_neq(0.0, model.position.y)


# ─── Bounds ───────────────────────────────────────────────────────────

func test_bounds_clamp_positive() -> void:
	model.bound_left = 100.0
	model.bound_right = 400.0
	model.bound_top = 100.0
	model.bound_bottom = 300.0
	model.target_position = Vector2(500, 500)
	model.update(10.0)

	assert_eq(400.0, model.position.x)
	assert_eq(300.0, model.position.y)


func test_bounds_clamp_negative() -> void:
	model.bound_left = 500.0
	model.bound_right = 500.0
	model.bound_top = 500.0
	model.bound_bottom = 500.0
	model.target_position = Vector2(-600, -600)
	model.update(10.0)

	assert_eq(-500.0, model.position.x)
	assert_eq(-500.0, model.position.y)


func test_no_bounds_no_clamping() -> void:
	model.bound_left = 0.0
	model.bound_right = 0.0
	model.bound_top = 0.0
	model.bound_bottom = 0.0
	model.target_position = Vector2(1000, 1000)
	model.update(10.0)

	assert_eq(1000.0, model.position.x)
	assert_eq(1000.0, model.position.y)
