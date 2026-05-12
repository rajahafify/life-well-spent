## EnemyDefinition — tweakable enemy type data.
class_name EnemyDefinition
extends Resource

@export var enemy_id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 1
@export var attack: int = 1
@export var defense: int = 0
@export var xp_reward: int = 0
@export var drop_table: Array[Dictionary] = []
@export var move_speed: float = 45.0
@export var chase_speed: float = 65.0
@export var wander_radius: float = 120.0
@export var aggro_radius: float = 0.0
@export var attack_range: float = 48.0
@export var idle_min_time: float = 0.4
@export var idle_max_time: float = 3.5
@export var attack_interval: float = 1.4
@export var death_duration: float = 0.25


func to_enemy_state_dict(hp_override: int = -1) -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"display_name": display_name,
		"hp": max_hp if hp_override < 0 else hp_override,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"xp_reward": xp_reward,
		"drop_table": drop_table.duplicate(true),
	}


static func slime_spiked():
	return _build("slime_spiked", "Spiked Slime", 140, 1, 10, 5, [{"item_id": "slime_gel", "quantity": 1}], 45.0, 65.0, 120.0, 48.0, 1.4, 0.8)


static func bat():
	return _build("bat", "Bat", 80, 2, 0, 4, [{"item_id": "bat_wing", "quantity": 1}], 70.0, 95.0, 170.0, 54.0, 1.1, 0.7)


static func rat():
	return _build("rat", "Rat", 60, 2, 0, 3, [{"item_id": "rat_tail", "quantity": 1}], 75.0, 105.0, 140.0, 44.0, 1.0, 0.6)


static func for_id(enemy_id_value: String):
	match enemy_id_value:
		"bat":
			return bat()
		"rat":
			return rat()
		_:
			return slime_spiked()


static func _build(enemy_id_value: String, display_name_value: String, hp: int, attack_value: int, defense_value: int, xp: int, drops: Array[Dictionary], move: float, chase: float, wander: float, range: float, interval: float, death: float):
	var script: GDScript = load("res://scripts/models/enemy_definition.gd")
	var enemy = script.new()
	enemy.enemy_id = enemy_id_value
	enemy.display_name = display_name_value
	enemy.max_hp = hp
	enemy.attack = attack_value
	enemy.defense = defense_value
	enemy.xp_reward = xp
	enemy.drop_table = drops.duplicate(true)
	enemy.move_speed = move
	enemy.chase_speed = chase
	enemy.wander_radius = wander
	enemy.aggro_radius = 0.0
	enemy.attack_range = range
	enemy.idle_min_time = 0.4
	enemy.idle_max_time = 3.5
	enemy.attack_interval = interval
	enemy.death_duration = death
	return enemy
