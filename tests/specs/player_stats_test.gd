# tests/specs/test_player_stats.gd
# Spec: PlayerStats model — HP, level, death/rebirth cycle

class_name TestPlayerStats
extends TestCase

var player: PlayerStats


func class_setup() -> void:
	pass


func setup() -> void:
	player = PlayerStats.new()


func teardown() -> void:
	player.free()


# ─── Initialization ──────────────────────────────────────────────────

func test_initial_max_hp_is_100() -> void:
	assert_eq(100, player.max_hp)


func test_initial_level_is_1() -> void:
	assert_eq(1, player.level)


func test_initial_state_is_alive() -> void:
	assert_eq("alive", player.state)


func test_initial_game_over_is_not_requested() -> void:
	assert_false(player.game_over_requested)


# ─── Quest Deductions ────────────────────────────────────────────────

func test_take_quest_costs_no_hp() -> void:
	player.take_quest()
	assert_eq(100, player.max_hp)


func test_taking_multiple_quests_costs_no_hp() -> void:
	player.max_hp = 100
	player.take_quest()
	player.take_quest()
	assert_eq(100, player.max_hp)


func test_complete_quest_cannot_deduct_below_zero() -> void:
	player.max_hp = 40
	player.complete_quest()
	assert_eq(0, player.max_hp)
	assert_eq("dead", player.state)
	player.complete_quest()
	assert_eq(0, player.max_hp)


# ─── Quest Completion ────────────────────────────────────────────────

func test_complete_quest_deducts_40_hp() -> void:
	player.complete_quest()
	assert_eq(60, player.max_hp)


func test_quest_complete_triggers_death() -> void:
	player.max_hp = 40
	player.complete_quest()
	assert_eq(0, player.max_hp)
	assert_eq("dead", player.state)


# ─── Death and Rebirth ───────────────────────────────────────────────

func test_death_sets_state_to_dead() -> void:
	player.max_hp = 40
	player.complete_quest()
	assert_eq("dead", player.state)


func test_rebirth_resets_hp_to_100() -> void:
	player.max_hp = 40
	player.complete_quest()
	player.rebirth()
	assert_eq(100, player.max_hp)


func test_rebirth_resets_level_to_1() -> void:
	player.level = 5
	player.rebirth()
	assert_eq(1, player.level)


func test_rebirth_resets_state_to_alive() -> void:
	player.max_hp = 40
	player.complete_quest()
	player.rebirth()
	assert_eq("alive", player.state)


func test_rebirth_clears_game_over_request() -> void:
	player.max_hp = 40
	player.complete_quest()
	player.rebirth()
	assert_false(player.game_over_requested)


func test_rebirth_preserves_unlocked_facilities() -> void:
	player.unlocked_facilities.append("workshop")
	player.max_hp = 40
	player.complete_quest()
	player.rebirth()
	assert_in("workshop", player.unlocked_facilities, "workshop should survive rebirth")


func test_rebirth_preserves_swordsman_guild_unlock() -> void:
	player.unlock_facility("swordsman_guild")
	player.max_hp = 40
	player.complete_quest()
	player.rebirth()
	assert_in("swordsman_guild", player.unlocked_facilities)
