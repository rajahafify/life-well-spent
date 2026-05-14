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


func test_field_combat_tuning_constants_are_centralized() -> void:
	assert_eq(56.0, GameBalance.FIELD_ENEMY_COLLISION_RADIUS)
	assert_eq(96.0, GameBalance.FIELD_ENEMY_APPROACH_DISTANCE)
	assert_eq(112.0, GameBalance.FIELD_PLAYER_ATTACK_READY_RANGE)
	assert_eq(192.0, GameBalance.FIELD_PLAYER_ATTACK_LEASH_RANGE)
	assert_eq(1.4, GameBalance.FIELD_LOOT_TOAST_DURATION)
	assert_eq(20, GameBalance.APPLE_HEAL_AMOUNT)
