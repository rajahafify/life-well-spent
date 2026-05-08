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
	pass


# ─── Initialization ──────────────────────────────────────────────────

func test_initial_max_hp_is_100() -> void:
	check_eq(player.max_hp, 100)


func test_initial_level_is_1() -> void:
	check_eq(player.level, 1)


func test_initial_state_is_alive() -> void:
	check_eq(player.state, "alive")


# ─── Quest Deductions ────────────────────────────────────────────────

func test_take_quest_deducts_40_hp() -> void:
	player.take_quest()
	check_eq(player.max_hp, 60)


func test_quest_deducts_multiple_times() -> void:
	player.max_hp = 100
	player.take_quest()
	player.take_quest()
	check_eq(player.max_hp, 20)


func test_quest_cannot_deduct_below_zero() -> void:
	player.max_hp = 40
	player.take_quest()
	check_eq(player.max_hp, 0)
	check_eq(player.state, "dead")
	player.take_quest()
	check_eq(player.max_hp, 0)


# ─── Quest Completion ────────────────────────────────────────────────

func test_complete_quest_deducts_40_hp() -> void:
	player.complete_quest()
	check_eq(player.max_hp, 60)


func test_quest_complete_triggers_death() -> void:
	player.max_hp = 40
	player.complete_quest()
	check_eq(player.max_hp, 0)
	check_eq(player.state, "dead")


# ─── Death and Rebirth ───────────────────────────────────────────────

func test_death_sets_state_to_dead() -> void:
	player.max_hp = 40
	player.take_quest()
	check_eq(player.state, "dead")


func test_rebirth_resets_hp_to_100() -> void:
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check_eq(player.max_hp, 100)


func test_rebirth_resets_level_to_1() -> void:
	player.level = 5
	player.rebirth()
	check_eq(player.level, 1)


func test_rebirth_resets_state_to_alive() -> void:
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check_eq(player.state, "alive")


func test_rebirth_preserves_unlocked_facilities() -> void:
	player.unlocked_facilities.append("workshop")
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check("workshop" in player.unlocked_facilities, "workshop should survive rebirth")
