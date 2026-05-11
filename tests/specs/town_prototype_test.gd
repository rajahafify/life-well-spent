# tests/specs/town_prototype_test.gd
# Spec: Town first-slice prototype scene structure and dialog copy.

class_name TestTownPrototype
extends TestCase

const TOWN_SCENE := "res://scenes/town_scene.tscn"
const TOWN_SCRIPT := "res://scripts/controllers/town_scene_controller.gd"

const REBORN_PROMPT := "You have been reborn.\nWill you spend this life well?"
const PORTAL_LABEL := "Starter Area"
const PORTAL_PROMPT := "Enter Starter Area?"

const GUILDMASTER_DIALOG := "The Swordsman Guild still stands.\n\nNot as it was.\nThe halls are quiet, and the old names fade from the register.\n\nBut a guild is not stone or banners.\nIt lives when someone chooses the path.\n\nPerhaps one day, someone will help me raise it again."

const SHOPKEEPER_DIALOG := "Welcome, traveler.\n\nThis shop once packed bags for heroes.\nNow I sell apples, candles, and thread.\n\nIt is quieter, yes.\nBut quiet days are worth protecting too."

const SMITH_DIALOG := "I used to shape steel for adventurers.\n\nNow I mend plows, hinges, and cooking pots.\nHonest work.\n\nStill, I keep the sword molds clean.\nOld roads have a way of calling again."


func _instantiate_town() -> Node:
	var scene: PackedScene = load(TOWN_SCENE)
	assert_not_null(scene, "town scene should load")
	if scene == null:
		return null
	return scene.instantiate()


func test_town_scene_root_is_named_town() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_eq("Town", root.name)
	root.free()


func test_town_controller_class_name_is_town() -> void:
	var file := FileAccess.open(TOWN_SCRIPT, FileAccess.READ)
	assert_not_null(file, "town controller script should exist")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("class_name Town"), "town controller should expose class_name Town")


func test_town_has_three_buildings() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("Buildings/Shop"), "Town should have Shop building")
	assert_not_null(root.get_node_or_null("Buildings/SwordsmanGuild"), "Town should have Swordsman Guild building")
	assert_not_null(root.get_node_or_null("Buildings/Blacksmith"), "Town should have Blacksmith building")
	root.free()


func test_town_has_three_worldbuilding_npcs() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("Shopkeeper"), "Town should have Shopkeeper NPC")
	assert_not_null(root.get_node_or_null("Guildmaster"), "Town should have Guildmaster NPC")
	assert_not_null(root.get_node_or_null("Smith"), "Town should have Smith NPC")
	root.free()


func test_town_has_starter_area_portal() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("StarterAreaPortal"), "Town should have glowing Starter Area portal")
	root.free()


func test_town_has_reborn_prompt_copy() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var prompt := root.get_node_or_null("UI/RebornPrompt") as Label
	assert_not_null(prompt, "Town should show reborn prompt label")
	if prompt:
		assert_eq(REBORN_PROMPT, prompt.text)
	root.free()


func test_town_has_player_and_camera() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("Player"), "Town should have Player")
	assert_not_null(root.get_node_or_null("Camera2D"), "Town should have Camera2D")
	root.free()


func test_world_primitives_ignore_mouse_so_ground_clicks_move() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	for node_path in [
		"Ground",
		"Paths/MainPath",
		"Paths/PortalPath",
		"Buildings/Shop",
		"Buildings/SwordsmanGuild",
		"Buildings/Blacksmith",
		"StarterAreaPortal/Visual",
	]:
		var control := root.get_node(node_path) as Control
		assert_eq(Control.MOUSE_FILTER_IGNORE, control.mouse_filter, "%s should not consume ground clicks" % node_path)
	root.free()


func test_town_has_dialog_panel() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	assert_not_null(root.get_node_or_null("UI/DialogPanel"), "Town should have dialog panel")
	root.free()


func test_town_scene_uses_1080p_viewport_settings() -> void:
	var file := FileAccess.open("res://project.godot", FileAccess.READ)
	assert_not_null(file, "project settings should be readable")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()
	assert_true(source.contains("window/size/viewport_width=1920"), "viewport width should be 1920")
	assert_true(source.contains("window/size/viewport_height=1080"), "viewport height should be 1080")


func test_starter_area_portal_label_and_prompt_copy() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var label := root.get_node_or_null("StarterAreaPortal/Label") as Label
	var prompt := root.get_node_or_null("UI/PortalPrompt") as Label
	assert_not_null(label, "Starter Area portal should have label")
	assert_not_null(prompt, "Town should define portal prompt copy")
	if label:
		assert_eq(PORTAL_LABEL, label.text)
	if prompt:
		assert_eq(PORTAL_PROMPT, prompt.text)
	root.free()


func test_guildmaster_dialog_copy_is_defined() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var npc := root.get_node_or_null("Guildmaster")
	assert_not_null(npc, "Guildmaster should exist")
	if npc:
		assert_eq(GUILDMASTER_DIALOG, npc.dialog_text)
	root.free()


func test_shopkeeper_dialog_copy_is_defined() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var npc := root.get_node_or_null("Shopkeeper")
	assert_not_null(npc, "Shopkeeper should exist")
	if npc:
		assert_eq(SHOPKEEPER_DIALOG, npc.dialog_text)
	root.free()


func test_smith_dialog_copy_is_defined() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var npc := root.get_node_or_null("Smith")
	assert_not_null(npc, "Smith should exist")
	if npc:
		assert_eq(SMITH_DIALOG, npc.dialog_text)
	root.free()


func test_worldbuilding_npc_roles_are_defined() -> void:
	var root := _instantiate_town()
	if root == null:
		return
	var guildmaster := root.get_node_or_null("Guildmaster")
	var shopkeeper := root.get_node_or_null("Shopkeeper")
	var smith := root.get_node_or_null("Smith")
	assert_not_null(guildmaster, "Guildmaster should exist")
	assert_not_null(shopkeeper, "Shopkeeper should exist")
	assert_not_null(smith, "Smith should exist")
	if guildmaster:
		assert_eq("Guildmaster", guildmaster.display_name)
		assert_eq("guildmaster", guildmaster.role)
	if shopkeeper:
		assert_eq("Shopkeeper", shopkeeper.display_name)
		assert_eq("shopkeeper", shopkeeper.role)
	if smith:
		assert_eq("Smith", smith.display_name)
		assert_eq("smith", smith.role)
	root.free()
