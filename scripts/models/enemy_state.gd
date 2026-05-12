## EnemyState — runtime state for one spawned enemy instance.
class_name EnemyState
extends RefCounted

var instance_id: String = ""
var enemy_id: String = ""
var display_name: String = ""
var hp: int = 1
var max_hp: int = 1
var attack: int = 1
var defense: int = 0
var xp_reward: int = 0
var spawn_position: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var behavior_state: String = "idle"
var is_aggro: bool = false
var is_defeated: bool = false
var attack_timer: float = 0.0
var idle_timer: float = 0.0
var idle_duration: float = 1.0
var wander_step: int = 0
var random_seed: int = 1
var death_timer: float = 0.0
var reward_granted: bool = false


func to_combat_dict() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"display_name": display_name,
		"hp": hp,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"xp_reward": xp_reward,
	}


func apply_combat_dict(next_state: Dictionary) -> void:
	hp = int(next_state.get("hp", hp))
	if hp <= 0:
		is_defeated = true
		behavior_state = "die"


static func from_definition(instance_id_value: String, definition, spawn_pos: Vector2):
	var script: GDScript = load("res://scripts/models/enemy_state.gd")
	var state = script.new()
	state.instance_id = instance_id_value
	state.enemy_id = definition.enemy_id
	state.display_name = definition.display_name
	state.hp = definition.max_hp
	state.max_hp = definition.max_hp
	state.attack = definition.attack
	state.defense = definition.defense
	state.xp_reward = definition.xp_reward
	state.spawn_position = spawn_pos
	state.position = spawn_pos
	state.target_position = spawn_pos
	state.random_seed = max(1, abs(hash(instance_id_value)))
	state.idle_duration = state.next_idle_duration(definition)
	state.idle_timer = -state.next_random_range(0.0, definition.idle_max_time)
	state.behavior_state = "idle"
	return state


func next_random_unit() -> float:
	random_seed = int((1103515245 * random_seed + 12345) & 0x7fffffff)
	return float(random_seed % 10000) / 9999.0


func next_random_range(min_value: float, max_value: float) -> float:
	return min_value + (max_value - min_value) * next_random_unit()


func next_idle_duration(definition) -> float:
	return next_random_range(definition.idle_min_time, definition.idle_max_time)
