# tests/specs/feedback_system_test.gd
# Spec: FeedbackSystem - global feedback boundary for decoupled combat juice.

class_name TestFeedbackSystem
extends TestCase


func setup() -> void:
	_feedback_system().reset()


func teardown() -> void:
	_feedback_system().reset()


func test_feedback_system_records_sfx_requests_without_source_node_ownership() -> void:
	var system := _feedback_system()
	assert_eq("", system.last_sfx)
	system.play_sfx("player_hit")
	assert_eq("player_hit", system.last_sfx)
	assert_eq(1, system.spawned_sfx_count)


func _feedback_system() -> Node:
	return Engine.get_main_loop().root.get_node("FeedbackSystem")
