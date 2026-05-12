## EnemyDefinition - data-only enemy type resource.
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


func apply_config(config: Dictionary) -> void:
	enemy_id = str(config.get("enemy_id", enemy_id))
	display_name = str(config.get("display_name", display_name))
	max_hp = int(config.get("max_hp", max_hp))
	attack = int(config.get("attack", attack))
	defense = int(config.get("defense", defense))
	xp_reward = int(config.get("xp_reward", xp_reward))
	drop_table = []
	for drop in Array(config.get("drop_table", [])):
		if drop is Dictionary:
			drop_table.append((drop as Dictionary).duplicate(true))
	move_speed = float(config.get("move_speed", move_speed))
	chase_speed = float(config.get("chase_speed", chase_speed))
	wander_radius = float(config.get("wander_radius", wander_radius))
	aggro_radius = float(config.get("aggro_radius", aggro_radius))
	attack_range = float(config.get("attack_range", attack_range))
	idle_min_time = float(config.get("idle_min_time", idle_min_time))
	idle_max_time = float(config.get("idle_max_time", idle_max_time))
	attack_interval = float(config.get("attack_interval", attack_interval))
	death_duration = float(config.get("death_duration", death_duration))


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
