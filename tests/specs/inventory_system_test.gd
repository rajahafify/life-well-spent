# tests/specs/inventory_system_test.gd
# Spec: InventorySystem - game-wide inventory runtime boundary.

class_name TestInventorySystem
extends TestCase


func setup() -> void:
	_inventory_system().reset()


func teardown() -> void:
	_inventory_system().reset()


func test_inventory_system_exposes_global_stack_counts() -> void:
	var system := _inventory_system()
	assert_eq(0, system.quantity("slime_gel"))
	assert_true(system.add_item("slime_gel", 2))
	assert_eq(2, system.quantity("slime_gel"))


func test_inventory_system_provides_model_for_shared_hud_window() -> void:
	var system := _inventory_system()
	system.add_item("bat_wing", 1)
	var model = system.model()
	assert_not_null(model)
	if model:
		assert_eq(1, model.quantity("bat_wing"))


func _inventory_system() -> Node:
	return Engine.get_main_loop().root.get_node("InventorySystem")
