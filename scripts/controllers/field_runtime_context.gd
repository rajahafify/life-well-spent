## FieldRuntimeContext - owns Field runtime collaborators.
## Controller-side composition root for Field helper controllers and pure models.
class_name FieldRuntimeContext
extends Object

const ENEMY_BEHAVIOR_SCRIPT := preload("res://scripts/models/enemy_behavior_system.gd")
const COMBAT_SCRIPT := preload("res://scripts/models/combat_system.gd")
const DROP_SYSTEM_SCRIPT := preload("res://scripts/models/drop_system.gd")
const PLAYER_AGING_SCRIPT := preload("res://scripts/models/player_aging_model.gd")
const EQUIPMENT_STATS_SCRIPT := preload("res://scripts/models/equipment_stats.gd")
const FIELD_CAMERA_CONTROLLER_SCRIPT := preload("res://scripts/controllers/field_camera_controller.gd")
const FIELD_ENEMY_SPAWN_CONTROLLER_SCRIPT := preload("res://scripts/controllers/field_enemy_spawn_controller.gd")
const FIELD_COMBAT_CONTROLLER_SCRIPT := preload("res://scripts/controllers/field_combat_controller.gd")

var behavior = ENEMY_BEHAVIOR_SCRIPT.new()
var combat = COMBAT_SCRIPT.new()
var drop_system = DROP_SYSTEM_SCRIPT.new()
var camera_controller = FIELD_CAMERA_CONTROLLER_SCRIPT.new()
var spawn_controller = FIELD_ENEMY_SPAWN_CONTROLLER_SCRIPT.new()
var combat_controller = FIELD_COMBAT_CONTROLLER_SCRIPT.new()
var player_aging = PLAYER_AGING_SCRIPT.new()
var equipment_stats = EQUIPMENT_STATS_SCRIPT.new()


func randomize_runtime() -> void:
	camera_controller.randomize()


func dispose() -> void:
	for item in [
		behavior,
		combat,
		drop_system,
		camera_controller,
		spawn_controller,
		combat_controller,
		player_aging,
		equipment_stats,
	]:
		if is_instance_valid(item):
			item.free()
	behavior = null
	combat = null
	drop_system = null
	camera_controller = null
	spawn_controller = null
	combat_controller = null
	player_aging = null
	equipment_stats = null
