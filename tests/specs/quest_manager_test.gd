# tests/specs/quest_manager_test.gd
# Spec: QuestManager — quest catalog, take/complete lifecycle, 2-quest limit

class_name TestQuestManager
extends TestCase

var qm: QuestManager


func class_setup() -> void:
	pass


func setup() -> void:
	qm = QuestManager.new()


func teardown() -> void:
	qm.free()


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
	qm.take_quest()
	assert_eq(1, qm.active_quests.size(), "should have 1 active quest")
	assert_eq("Goblin Scout", qm.active_quests[0].name)


func test_take_quest_returns_false_when_no_catalog() -> void:
	var result: bool = qm.take_quest()
	assert_false(result, "should return false when no quests available")
	assert_eq(0, qm.active_quests.size(), "should have no active quests when taking fails")


func test_take_quest_works_with_many_quests_no_hard_limit() -> void:
	for i in range(10):
		qm.add_quest("Quest %d" % i, 40, "Quest %d" % i)
	qm.take_quest()
	qm.complete_quest()
	qm.take_quest()
	qm.complete_quest()
	qm.take_quest()
	qm.complete_quest()
	# No hard limit — can take quests across lives
	assert_eq(0, qm.active_quests.size(), "should be able to take multiple quests")
	assert_eq(3, qm.quests_taken, "should track total quests taken")


# ─── Complete Quest ──────────────────────────────────────────────────

func test_complete_quest_removes_one_active() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest()
	qm.complete_quest()
	assert_eq(0, qm.active_quests.size(), "active quest should be removed after completion")


func test_two_active_quests_removes_first_on_complete() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.add_quest("Bandit Camp", 40, "Clear bandit camp")
	qm.take_quest()
	qm.take_quest()
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
	qm.take_quest()
	qm.take_quest()
	assert_eq(2, qm.quests_taken)
	assert_eq(2, qm.active_quests.size())
	qm.reset_for_life()
	assert_eq(0, qm.quests_taken)
	assert_eq(0, qm.active_quests.size(), "all active quests should be cleared")


# ─── HP-Based Quest Taking ──────────────────────────────────────────

func test_take_quest_checks_hp_cost() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	var result: bool = qm.take_quest(39)
	assert_false(result, "should not take quest when HP < cost")
	assert_eq(0, qm.active_quests.size())


func test_take_quest_succeeds_when_enough_hp() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	var result: bool = qm.take_quest(40)
	assert_true(result, "should take quest when HP >= cost")
	assert_eq(1, qm.active_quests.size())


func test_take_quest_fails_when_hp_exactly_at_cost() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	var result: bool = qm.take_quest(40)
	assert_true(result, "should take quest when HP == cost")
	assert_eq("Goblin Scout", qm.active_quests[0].name)


func test_take_quest_gives_rejection_message() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest(39)
	assert_not_null(qm.last_rejection, "should store rejection reason")
	assert_eq("not_enough_hp", qm.last_rejection, "rejection reason should be not_enough_hp")


func test_successful_take_clears_last_rejection() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest(39)  # fail first
	assert_not_null(qm.last_rejection)
	qm.take_quest(40)  # then succeed
	assert_null(qm.last_rejection, "rejection should be cleared on success")
