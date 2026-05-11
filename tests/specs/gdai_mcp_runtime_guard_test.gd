# tests/specs/gdai_mcp_runtime_guard_test.gd
# Spec: GDAI MCP runtime guard keeps editor MCP enabled while skipping headless runtime.

class_name TestGDAIMCPRuntimeGuard
extends TestCase

const GuardScript = preload("res://scripts/managers/gdai_mcp_runtime_guard.gd")


func test_guard_skips_headless_display() -> void:
	var guard = GuardScript.new()
	assert_true(guard.should_skip_runtime("headless"))
	guard.free()


func test_guard_allows_non_headless_display() -> void:
	var guard = GuardScript.new()
	assert_false(guard.should_skip_runtime("windows"))
	assert_false(guard.should_skip_runtime("x11"))
	guard.free()


func test_project_autoload_points_to_guard() -> void:
	var autoload_path := str(ProjectSettings.get_setting("autoload/GDAIMCPRuntime", ""))
	assert_true(autoload_path.contains("res://scripts/managers/gdai_mcp_runtime_guard.gd"), "autoload should use headless guard wrapper")
