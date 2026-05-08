# tests/specs/test_player_stats.gd
# Spec: PlayerStats model — HP, level, death/rebirth cycle
# Uses check() which warns on failure and tracks it.

class_name TestPlayerStats
extends Object

var player: PlayerStats
var _failures: Array[String] = []


func class_setup():
	pass


func setup():
	player = PlayerStats.new()
	_failures = []


func teardown():
	pass


func get_failures() -> Array[String]:
	return _failures.duplicate()


func check(condition: bool, msg: String) -> bool:
	if not condition:
		_failures.append(msg)
		return false
	return true


func check_eq(got, expected, msg: String) -> bool:
	if not (got == expected):
		_failures.append("%s (got %s, expected %s)" % [msg, got, expected])
		return false
	return true


# ─── Initialization ──────────────────────────────────────────────────

func test_initial_max_hp_is_100():
	check_eq(player.max_hp, 100, "max_hp should be 100")


func test_initial_level_is_1():
	check_eq(player.level, 1, "level should be 1")


func test_initial_state_is_alive():
	check_eq(player.state, "alive", "state should be 'alive'")


# ─── Quest Deductions ────────────────────────────────────────────────

func test_take_quest_deducts_40_hp():
	player.take_quest()
	check_eq(player.max_hp, 60, "max_hp should be 60 after quest")


func test_quest_deducts_multiple_times():
	player.max_hp = 100
	player.take_quest()
	player.take_quest()
	check_eq(player.max_hp, 20, "max_hp should be 20 after two quests")


func test_quest_cannot_deduct_below_zero():
	player.max_hp = 40
	player.take_quest()
	check_eq(player.max_hp, 0, "max_hp should be 0")
	check_eq(player.state, "dead", "state should be 'dead'")
	player.take_quest()
	check_eq(player.max_hp, 0, "max_hp should stay at 0")


# ─── Quest Completion ────────────────────────────────────────────────

func test_complete_quest_deducts_40_hp():
	player.complete_quest()
	check_eq(player.max_hp, 60, "max_hp should be 60 after quest complete")


func test_quest_complete_triggers_death():
	player.max_hp = 40
	player.complete_quest()
	check_eq(player.max_hp, 0, "max_hp should be 0")
	check_eq(player.state, "dead", "state should be 'dead'")


# ─── Death and Rebirth ───────────────────────────────────────────────

func test_death_sets_state_to_dead():
	player.max_hp = 40
	player.take_quest()
	check_eq(player.state, "dead", "state should be 'dead' after death")


func test_rebirth_resets_hp_to_100():
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check_eq(player.max_hp, 100, "max_hp should be 100 after rebirth")


func test_rebirth_resets_level_to_1():
	player.level = 5
	player.rebirth()
	check_eq(player.level, 1, "level should be 1 after rebirth")


func test_rebirth_resets_state_to_alive():
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check_eq(player.state, "alive", "state should be 'alive' after rebirth")


func test_rebirth_preserves_unlocked_facilities():
	player.unlocked_facilities.append("workshop")
	player.max_hp = 40
	player.take_quest()
	player.rebirth()
	check("workshop" in player.unlocked_facilities, "workshop should survive rebirth")
