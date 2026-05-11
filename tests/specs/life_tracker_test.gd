# tests/specs/life_tracker_test.gd
# Spec: LifeTracker — daily real-life tasks, habits, streaks, XP rewards

class_name TestLifeTracker
extends TestCase

var tracker


func _new_life_tracker():
	var script: GDScript = load("res://scripts/models/life_tracker.gd")
	return script.new()


func setup() -> void:
	tracker = _new_life_tracker()


func teardown() -> void:
	tracker.free()


func test_add_task_stores_daily_task() -> void:
	tracker.add_task("hydrate", "Drink water", 10)
	assert_eq(1, tracker.tasks.size())
	assert_eq("Drink water", tracker.tasks[0].title)
	assert_eq(10, tracker.tasks[0].xp_reward)


func test_complete_task_marks_done_for_date() -> void:
	tracker.add_task("hydrate", "Drink water", 10)
	var result: bool = tracker.complete_task("hydrate", "2026-05-11")
	assert_true(result)
	assert_true(tracker.is_task_complete("hydrate", "2026-05-11"))


func test_complete_task_awards_xp_once_per_date() -> void:
	tracker.add_task("hydrate", "Drink water", 10)
	tracker.complete_task("hydrate", "2026-05-11")
	tracker.complete_task("hydrate", "2026-05-11")
	assert_eq(10, tracker.xp)


func test_daily_completion_count_tracks_date() -> void:
	tracker.add_task("hydrate", "Drink water", 10)
	tracker.add_task("walk", "Take walk", 15)
	tracker.complete_task("hydrate", "2026-05-11")
	tracker.complete_task("walk", "2026-05-12")
	assert_eq(1, tracker.completed_count_for_date("2026-05-11"))
	assert_eq(1, tracker.completed_count_for_date("2026-05-12"))


func test_habit_streak_increments_on_consecutive_days() -> void:
	tracker.add_habit("hydrate", "Drink water", 10)
	tracker.complete_task("hydrate", "2026-05-11")
	tracker.complete_task("hydrate", "2026-05-12")
	assert_eq(2, tracker.streak_for("hydrate"))


func test_habit_streak_resets_after_gap() -> void:
	tracker.add_habit("hydrate", "Drink water", 10)
	tracker.complete_task("hydrate", "2026-05-11")
	tracker.complete_task("hydrate", "2026-05-13")
	assert_eq(1, tracker.streak_for("hydrate"))


func test_serialize_round_trips_state() -> void:
	tracker.add_habit("hydrate", "Drink water", 10)
	tracker.complete_task("hydrate", "2026-05-11")
	var restored = tracker.get_script().from_dict(tracker.to_dict())
	assert_eq(1, restored.tasks.size())
	assert_eq(10, restored.xp)
	assert_true(restored.is_task_complete("hydrate", "2026-05-11"))
	restored.free()
