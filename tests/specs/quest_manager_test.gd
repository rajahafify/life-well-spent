# tests/specs/quest_manager_test.gd
# Spec: QuestManager — quest catalog, take/complete lifecycle, completion cost handled by PlayerStats

class_name TestQuestManager
extends TestCase

var qm: QuestManager


func class_setup() -> void:
	pass


func setup() -> void:
	qm = QuestManager.new()


func teardown() -> void:
	qm.free()


func _start_swordsman_chain() -> void:
	qm.setup_core_quests()
	qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")


func _record_enemy_defeats(enemy_id: String, count: int) -> void:
	for _i in range(count):
		qm.record_enemy_defeated(enemy_id)


func _record_item_gathered(item_id: String, count: int) -> void:
	for _i in range(count):
		qm.record_item_gathered(item_id)


# ─── Catalog ──────────────────────────────────────────────────────────

func test_catalog_starts_empty() -> void:
	assert_eq(0, qm.quest_catalog.size(), "catalog should start empty")


func test_add_quest_populates_catalog() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts from the ridge")
	assert_eq(1, qm.quest_catalog.size())
	assert_eq("Goblin Scout", qm.quest_catalog[0].name)
	assert_eq(40, qm.quest_catalog[0].cost)
	assert_eq("Clear goblin scouts from the ridge", qm.quest_catalog[0].description)


func test_catalog_supports_many_quests() -> void:
	for i in range(50):
		qm.add_quest("Quest %d" % i, 40, "Quest %d" % i)
	assert_eq(50, qm.quest_catalog.size(), "catalog should hold 50 quests")


# ─── Take Quest ──────────────────────────────────────────────────────

func test_take_quest_adds_to_active_quests() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts from the ridge")
	qm.take_quest(100)
	assert_eq(1, qm.active_quests.size(), "should have 1 active quest")
	assert_eq("Goblin Scout", qm.active_quests[0].name)


func test_take_quest_returns_false_when_no_catalog() -> void:
	var result: bool = qm.take_quest(100)
	assert_false(result, "should return false when no quests available")
	assert_eq(0, qm.active_quests.size(), "should have no active quests when taking fails")


func test_take_quest_works_with_many_quests_no_hard_limit() -> void:
	for i in range(10):
		qm.add_quest("Quest %d" % i, 40, "Quest %d" % i)
	qm.take_quest(100)
	qm.complete_quest()
	qm.take_quest(100)
	qm.complete_quest()
	qm.take_quest(100)
	qm.complete_quest()
	# No hard limit - can take quests across lives
	assert_eq(0, qm.active_quests.size(), "should be able to take multiple quests")
	assert_eq(3, qm.quests_taken, "should track total quests taken")


# ─── Complete Quest ──────────────────────────────────────────────────

func test_complete_quest_removes_one_active() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest(100)
	qm.complete_quest()
	assert_eq(0, qm.active_quests.size(), "active quest should be removed after completion")


func test_two_active_quests_removes_first_on_complete() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.add_quest("Bandit Camp", 40, "Clear bandit camp")
	qm.take_quest(100)
	qm.take_quest(100)
	assert_eq(2, qm.active_quests.size())
	qm.complete_quest()
	assert_eq(1, qm.active_quests.size())
	assert_eq("Bandit Camp", qm.active_quests[0].name, "second quest should remain active")


func test_complete_quest_with_no_active_returns_false() -> void:
	var result: bool = qm.complete_quest()
	assert_false(result, "should return false with no active quest")


# ─── Reset for Life ──────────────────────────────────────────────────

func test_reset_clears_quest_state() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.add_quest("Bandit Camp", 40, "Clear bandit camp")
	qm.take_quest(100)
	qm.take_quest(100)
	assert_eq(2, qm.quests_taken)
	assert_eq(2, qm.active_quests.size())
	qm.reset_for_life()
	assert_eq(0, qm.quests_taken)
	assert_eq(0, qm.active_quests.size(), "all active quests should be cleared")


# ─── Acceptance Cost Timing ─────────────────────────────────────────

func test_take_quest_succeeds_even_when_hp_below_cost() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	var result: bool = qm.take_quest(39)
	assert_true(result, "accepting a quest should cost no HP and not require affordability")
	assert_eq(1, qm.active_quests.size())
	assert_eq("Goblin Scout", qm.active_quests[0].name)


func test_take_quest_succeeds_when_enough_hp() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	var result: bool = qm.take_quest(40)
	assert_true(result, "accepting a quest should succeed when catalog has a quest")
	assert_eq(1, qm.active_quests.size())


func test_successful_take_clears_last_rejection() -> void:
	qm.last_rejection = "no_quest_available"
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest(1)
	assert_null(qm.last_rejection, "rejection should be cleared on successful accept")


func test_setup_core_quests_starts_explore_world_main_objective() -> void:
	qm.setup_core_quests()
	assert_eq("find_forest_path", qm.current_main_objective_id())
	assert_eq("Find the Forest path.", qm.current_main_objective_text())


func test_forest_gate_objective_starts_swordsman_guild_side_chain() -> void:
	qm.setup_core_quests()
	assert_true(qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification"))
	assert_eq("get_swordsman_certification", qm.current_main_objective_id())
	assert_eq("Get Swordsman Certification.", qm.current_main_objective_text())
	assert_true(qm.is_side_quest_active("rebuilding_swordsman_guild"))


func test_swordsman_certification_can_advance_main_objective_to_forest_endpoint() -> void:
	qm.setup_core_quests()
	qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	assert_true(qm.advance_main_quest_objective("explore_the_world", "enter_forest"))
	assert_eq("enter_forest", qm.current_main_objective_id())
	assert_eq("Enter the Forest.", qm.current_main_objective_text())


func test_town_reborn_intro_is_marked_once() -> void:
	assert_false(qm.has_seen_town_reborn_intro())
	assert_true(qm.mark_town_reborn_intro_seen())
	assert_true(qm.has_seen_town_reborn_intro())
	assert_false(qm.mark_town_reborn_intro_seen())


func test_main_quest_tracks_forest_guard_checkpoint() -> void:
	qm.setup_core_quests()
	assert_false(qm.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_true(qm.mark_main_checkpoint("explore_the_world", "forest_guard"))
	assert_true(qm.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_eq("Forest Guard reached.", qm.current_main_checkpoint_text())


func test_completing_swordsman_guild_chain_grants_certification() -> void:
	qm.setup_core_quests()
	qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	assert_true(qm.complete_side_quest_chain("rebuilding_swordsman_guild"))
	assert_true(qm.has_certification("swordsman_certification"))
	assert_false(qm.is_side_quest_active("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_starts_at_step_zero() -> void:
	qm.setup_core_quests()
	qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	assert_eq(0, qm.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_step_zero_objective_is_guildmaster_stance_training() -> void:
	_start_swordsman_chain()
	assert_eq("Defeat 10 Slimes for Guildmaster stance training. (0/10)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_slime_objective_tracks_kill_progress() -> void:
	_start_swordsman_chain()
	assert_true(qm.record_enemy_defeated("slime_spiked"))
	assert_eq("Defeat 10 Slimes for Guildmaster stance training. (1/10)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_slime_objective_ignores_wrong_enemy() -> void:
	_start_swordsman_chain()
	assert_false(qm.record_enemy_defeated("bat"))
	assert_eq("Defeat 10 Slimes for Guildmaster stance training. (0/10)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_step_cannot_advance_before_objective_complete() -> void:
	_start_swordsman_chain()
	assert_false(qm.advance_side_quest_step("rebuilding_swordsman_guild"))
	assert_eq(0, qm.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_guild_current_step_reports_complete_after_required_kills() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	assert_true(qm.is_current_side_quest_step_complete("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_step_one_objective_is_guildmaster_guard_training() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (0/2)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_bat_wing_objective_tracks_item_progress() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_true(qm.record_item_gathered("bat_wing"))
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (1/2)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_bat_wing_objective_ignores_enemy_defeats() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_false(qm.record_enemy_defeated("bat"))
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (0/2)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_step_two_objective_is_guildmaster_life_oath() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_item_gathered("bat_wing", 2)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_eq("Defeat 2 Rats for the Guildmaster's Life oath. (0/2)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_step_three_objective_is_guild_unlocked() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_item_gathered("bat_wing", 2)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_enemy_defeats("rat", 2)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_eq("Swordsman Guild unlocked.", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_advances_to_next_step() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	assert_true(qm.advance_side_quest_step("rebuilding_swordsman_guild"))
	assert_eq(1, qm.side_quest_step("rebuilding_swordsman_guild"))


func test_swordsman_guild_chain_step_cannot_exceed_max_step() -> void:
	_start_swordsman_chain()
	_record_enemy_defeats("slime_spiked", 10)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_item_gathered("bat_wing", 2)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	_record_enemy_defeats("rat", 2)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	assert_false(qm.advance_side_quest_step("rebuilding_swordsman_guild"))
	assert_eq(3, qm.side_quest_step("rebuilding_swordsman_guild"))


func test_core_quest_state_round_trips_through_save_data() -> void:
	qm.setup_core_quests()
	qm.mark_main_checkpoint("explore_the_world", "forest_guard")
	qm.advance_main_quest_objective("explore_the_world", "get_swordsman_certification")
	_record_enemy_defeats("slime_spiked", 4)
	assert_eq("Defeat 10 Slimes for Guildmaster stance training. (4/10)", qm.current_side_quest_objective_text("rebuilding_swordsman_guild"))
	_record_enemy_defeats("slime_spiked", 6)
	qm.advance_side_quest_step("rebuilding_swordsman_guild")
	qm.complete_side_quest_chain("rebuilding_swordsman_guild")
	var restored := QuestManager.new()
	restored.apply_dict(qm.to_dict())
	assert_eq("get_swordsman_certification", restored.current_main_objective_id())
	assert_true(restored.has_main_checkpoint("explore_the_world", "forest_guard"))
	assert_true(restored.has_certification("swordsman_certification"))
	assert_eq(1, restored.side_quest_step("rebuilding_swordsman_guild"))
	assert_false(restored.is_side_quest_active("rebuilding_swordsman_guild"))
	assert_eq("Gather 2 Bat Wings for Guildmaster guard training. (0/2)", restored.current_side_quest_objective_text("rebuilding_swordsman_guild"))
	restored.free()
