# tests/specs/game_over_summary_flow_test.gd
# Spec: Game Over and Summary scene flow.

class_name TestGameOverSummaryFlow
extends TestCase

const GAME_OVER_SCENE := "res://scenes/game_over.tscn"
const SUMMARY_SCENE := "res://scenes/summary_scene.tscn"


class FakePlayer:
	var game_over_requested: bool = true
	var max_hp: int = 20
	var hp: int = 20
	var unlocked_facilities: Array[String] = ["swordsman_guild"]

	func rebirth() -> void:
		max_hp = 100
		hp = 100
		game_over_requested = false


class FakeProfileSystem:
	var fake_player := FakePlayer.new()
	var saved: bool = false

	func player():
		return fake_player

	func save_profile() -> bool:
		saved = true
		return true


class FakeInventory:
	func items_list() -> Array[Dictionary]:
		return [
			{"item_id": "training_sword", "quantity": 1},
			{"item_id": "leather_armor", "quantity": 1},
		]


class FakeInventorySystem:
	var fake_inventory := FakeInventory.new()
	var reset_called: bool = false

	func model():
		return fake_inventory

	func reset() -> void:
		reset_called = true


func test_game_over_scene_continues_to_summary_scene() -> void:
	var scene := load(GAME_OVER_SCENE) as PackedScene
	assert_not_null(scene)
	if scene == null:
		return
	var root = scene.instantiate()
	root._ready()
	assert_eq("Game Over", (root.get_node("CenterContainer/UI/TitleLabel") as Label).text)
	(root.get_node("CenterContainer/UI/ContinueButton") as Button).pressed.emit()
	assert_eq(SUMMARY_SCENE, root.requested_scene_path)
	root.free()


func test_summary_scene_renders_run_summary() -> void:
	var scene := load(SUMMARY_SCENE) as PackedScene
	assert_not_null(scene)
	if scene == null:
		return
	var root = scene.instantiate()
	root._ready()
	root.render_summary(FakeProfileSystem.new(), FakeInventorySystem.new())
	var summary := (root.get_node("CenterContainer/UI/SummaryLabel") as Label).text
	assert_true(summary.contains("Run Summary"))
	assert_true(summary.contains("Life Spent: 80"))
	assert_true(summary.contains("Training Sword x1"))
	assert_true(summary.contains("Leather Armor x1"))
	assert_true(summary.contains("Swordsman Guild"))
	root.free()


func test_summary_rebirth_resets_run_and_enters_town() -> void:
	var scene := load(SUMMARY_SCENE) as PackedScene
	var root = scene.instantiate()
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	assert_true(root.rebirth_to_town(profile, inventory))
	assert_false(profile.fake_player.game_over_requested)
	assert_eq(100, profile.fake_player.max_hp)
	assert_true(inventory.reset_called)
	assert_true(profile.saved)
	assert_eq("res://scenes/town_scene.tscn", root.requested_scene_path)
	root.free()


func test_summary_second_choice_is_end_game_to_main_menu_without_rebirth() -> void:
	var scene := load(SUMMARY_SCENE) as PackedScene
	var root = scene.instantiate()
	root._ready()
	var button := root.get_node("CenterContainer/UI/Buttons/NewGameButton") as Button
	assert_eq("End Game", button.text)
	var profile := FakeProfileSystem.new()
	var inventory := FakeInventorySystem.new()
	assert_true(root.end_game_to_main_menu(profile, inventory))
	assert_true(profile.fake_player.game_over_requested)
	assert_eq(20, profile.fake_player.max_hp)
	assert_false(inventory.reset_called)
	assert_eq("res://scenes/main_menu.tscn", root.requested_scene_path)
	root.free()
