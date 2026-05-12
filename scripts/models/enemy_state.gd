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
	state.behavior_state = "idle"
	return state
