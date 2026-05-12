## InventorySystem - game-wide runtime boundary for player inventory.
extends Node

const INVENTORY_SCRIPT := preload("res://scripts/models/inventory_model.gd")

var _inventory = INVENTORY_SCRIPT.new()


func _exit_tree() -> void:
	if _inventory:
		_inventory.free()
		_inventory = null


func reset() -> void:
	_inventory.reset()


func model():
	return _inventory


func add_item(item_id: String, amount: int = 1) -> bool:
	return _inventory.add_item(item_id, amount)


func quantity(item_id: String) -> int:
	return _inventory.quantity(item_id)


func consume_item(item_id: String, amount: int = 1) -> bool:
	return _inventory.consume_item(item_id, amount)


func summary_text() -> String:
	return _inventory.summary_text()


func to_dict() -> Dictionary:
	return _inventory.to_dict()


func apply_dict(data: Dictionary) -> void:
	_inventory.apply_dict(data)
