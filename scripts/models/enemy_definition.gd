## EnemyDefinition — pure enemy identity/stats for Field prototypes.
class_name EnemyDefinition
extends Resource

@export var enemy_id: String = ""
@export var display_name: String = "Enemy"
@export var hp: int = 1
@export var attack: int = 1
@export var defense: int = 0
@export var xp_reward: int = 0
@export var spawn_position: Vector2 = Vector2.ZERO
@export var biome_tags: Array = []


func is_defeated(current_hp: int) -> bool:
	return current_hp <= 0


func to_combat_state() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"display_name": display_name,
		"hp": hp,
		"attack": attack,
		"defense": defense,
		"xp_reward": xp_reward,
	}


static func create(id: String, name: String, max_hp: int, atk: int, def: int, xp: int, tags: Array = ["grassland"]):
	var script: GDScript = load("res://scripts/models/enemy_definition.gd")
	var enemy = script.new()
	enemy.enemy_id = id
	enemy.display_name = name
	enemy.hp = max_hp
	enemy.attack = atk
	enemy.defense = def
	enemy.xp_reward = xp
	enemy.biome_tags = tags.duplicate()
	return enemy


static func chick():
	return create("chick", "Chick", 5, 1, 0, 2)


static func rabbit():
	return create("rabbit", "Rabbit", 8, 2, 0, 4)


static func slime():
	return create("slime", "Slime", 14, 1, 1, 5)


static func prototype_field_enemies() -> Array:
	return [chick(), rabbit(), slime()]
