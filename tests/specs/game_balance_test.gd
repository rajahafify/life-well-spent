# tests/specs/game_balance_test.gd
# Spec: GameBalance tuning constants

class_name TestGameBalance
extends TestCase


func test_quest_hp_cost_matches_life_sacrifice() -> void:
	assert_eq(40, GameBalance.QUEST_HP_COST)


func test_animation_timing_constants_are_positive() -> void:
	assert_true(GameBalance.WALK_ANIM_SPEED > 0.0)
	assert_true(GameBalance.IDLE_CYCLE_INTERVAL > 0.0)
	assert_true(GameBalance.WALK_FRAME_DURATION > 0.0)
