# tests/specs/quest_window_view_test.gd
# Spec: QuestWindowView - reusable top-right quest objective display.

class_name TestQuestWindowView
extends TestCase

const VIEW_SCRIPT := "res://scripts/views/quest_window_view.gd"

var view: PanelContainer


func setup() -> void:
	var script := load(VIEW_SCRIPT) as GDScript
	view = PanelContainer.new()
	view.name = "QuestWindow"
	view.set_script(script)
	view._ready()


func teardown() -> void:
	if view:
		view.free()
		view = null


func test_view_creates_title_and_objective_labels() -> void:
	var title := view.get_node_or_null("VBox/TitleLabel") as Label
	var objective := view.get_node_or_null("VBox/ObjectiveLabel") as Label
	assert_not_null(title)
	assert_not_null(objective)
	if title and objective:
		assert_eq("Quest", title.text)
		assert_true(objective.autowrap_mode != TextServer.AUTOWRAP_OFF)


func test_show_main_objective_sets_display_text() -> void:
	view.show_main_objective("Explore the World", "Find the Forest path.")
	var objective := view.get_node("VBox/ObjectiveLabel") as Label
	assert_eq("Explore the World\nFind the Forest path.", objective.text)


func test_show_main_objective_ignores_checkpoint_text() -> void:
	view.show_main_objective("Explore the World", "Get Swordsman Certification.", "Forest Guard reached.")
	var objective := view.get_node("VBox/ObjectiveLabel") as Label
	assert_eq("Explore the World\nGet Swordsman Certification.", objective.text)
