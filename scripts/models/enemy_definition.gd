## EnemyDefinition — tweakable enemy type data.
class_name EnemyDefinition
extends Resource

@export var enemy_id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 1
@export var attack: int = 1
@export var defense: int = 0
@export var xp_reward: int = 0
@export var move_speed: float = 45.0
@export var chase_speed: float = 65.0
@export var wander_radius: float = 120.0
@export var aggro_radius: float = 0.0
@export var attack_range: float = 48.0
@export var idle_min_time: float = 0.6
@export var idle_max_time: float = 2.0
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
	}


static func slime_spiked():
	var script: GDScript = load("res://scripts/models/enemy_definition.gd")
	var enemy = script.new()
	enemy.enemy_id = "slime_spiked"
	enemy.display_name = "Spiked Slime"
	enemy.max_hp = 14
	enemy.attack = 1
	enemy.defense = 1
	enemy.xp_reward = 5
	enemy.move_speed = 45.0
	enemy.chase_speed = 65.0
	enemy.wander_radius = 120.0
	enemy.aggro_radius = 0.0
	enemy.attack_range = 48.0
	enemy.idle_min_time = 0.6
	enemy.idle_max_time = 2.0
	enemy.attack_interval = 1.4
	enemy.death_duration = 0.8
	return enemy
