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

func test_take_quest_deducts_40_hp_and_tracks_taken() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts from the ridge")
	qm.take_quest()
	assert_eq(1, qm.quests_taken)
	assert_not_null(qm.active_quest, "should have an active quest after taking")
	assert_eq("Goblin Scout", qm.active_quest.name)


func test_take_quest_returns_false_when_no_catalog() -> void:
	var result: bool = qm.take_quest()
	assert_false(result, "should return false when no quests available")
	assert_eq(0, qm.quests_taken)


func test_take_quest_returns_false_when_at_limit() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest()
	qm.complete_quest()
	qm.add_quest("Bandit Camp", 40, "Clear the bandit camp")
	qm.take_quest()
	qm.complete_quest()
	qm.add_quest("Bandit Boss", 40, "Defeat the bandit boss")
	var result: bool = qm.take_quest()
	assert_false(result, "should return false at 2-quest limit")
	assert_eq(2, qm.quests_taken)


# ─── Complete Quest ──────────────────────────────────────────────────

func test_complete_quest_clears_active() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest()
	qm.complete_quest()
	assert_null(qm.active_quest, "active quest should be cleared after completion")


func test_complete_quest_with_no_active_returns_false() -> void:
	var result: bool = qm.complete_quest()
	assert_false(result, "should return false with no active quest")


# ─── Reset for Life ──────────────────────────────────────────────────

func test_reset_clears_quest_state() -> void:
	qm.add_quest("Goblin Scout", 40, "Clear goblin scouts")
	qm.take_quest()
	assert_eq(1, qm.quests_taken)
	assert_not_null(qm.active_quest)
	qm.reset_for_life()
	assert_eq(0, qm.quests_taken)
	assert_null(qm.active_quest)
