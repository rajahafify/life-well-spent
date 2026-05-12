## EnemyLibrary - registry-backed factory for enemy definitions.
class_name EnemyLibrary
extends Object

const ENEMY_DEFINITION_SCRIPT := preload("res://scripts/models/enemy_definition.gd")
const MATERIAL_CHANCE_NUMERATOR := 1
const MATERIAL_CHANCE_DENOMINATOR := 5
const RARE_CHANCE_NUMERATOR := 1
const RARE_CHANCE_DENOMINATOR := 20
const APPLE_DROP := {"item_id": "apple", "quantity": 1, "chance_numerator": RARE_CHANCE_NUMERATOR, "chance_denominator": RARE_CHANCE_DENOMINATOR}
const BAT_WEAPON_DROP := {"item_id": "training_sword", "quantity": 1, "chance_numerator": RARE_CHANCE_NUMERATOR, "chance_denominator": RARE_CHANCE_DENOMINATOR}
const RAT_ARMOR_DROP := {"item_id": "leather_armor", "quantity": 1, "chance_numerator": RARE_CHANCE_NUMERATOR, "chance_denominator": RARE_CHANCE_DENOMINATOR}

const REGISTRY := {
	"slime_spiked": {
		"enemy_id": "slime_spiked",
		"display_name": "Spiked Slime",
		"max_hp": 140,
		"attack": 1,
		"defense": 10,
		"xp_reward": 5,
		"drop_table": [
			{"item_id": "slime_gel", "quantity": 1, "chance_numerator": MATERIAL_CHANCE_NUMERATOR, "chance_denominator": MATERIAL_CHANCE_DENOMINATOR},
			APPLE_DROP,
		],
		"move_speed": 45.0,
		"chase_speed": 65.0,
		"wander_radius": 120.0,
		"aggro_radius": 0.0,
		"attack_range": 96.0,
		"idle_min_time": 0.4,
		"idle_max_time": 3.5,
		"attack_interval": 1.4,
		"death_duration": 0.8,
	},
	"bat": {
		"enemy_id": "bat",
		"display_name": "Bat",
		"max_hp": 80,
		"attack": 2,
		"defense": 0,
		"xp_reward": 4,
		"drop_table": [
			{"item_id": "bat_wing", "quantity": 1, "chance_numerator": MATERIAL_CHANCE_NUMERATOR, "chance_denominator": MATERIAL_CHANCE_DENOMINATOR},
			BAT_WEAPON_DROP,
		],
		"move_speed": 70.0,
		"chase_speed": 95.0,
		"wander_radius": 170.0,
		"aggro_radius": 0.0,
		"attack_range": 104.0,
		"idle_min_time": 0.4,
		"idle_max_time": 3.5,
		"attack_interval": 1.1,
		"death_duration": 0.7,
	},
	"rat": {
		"enemy_id": "rat",
		"display_name": "Rat",
		"max_hp": 60,
		"attack": 2,
		"defense": 0,
		"xp_reward": 3,
		"drop_table": [
			{"item_id": "rat_tail", "quantity": 1, "chance_numerator": MATERIAL_CHANCE_NUMERATOR, "chance_denominator": MATERIAL_CHANCE_DENOMINATOR},
			RAT_ARMOR_DROP,
		],
		"move_speed": 75.0,
		"chase_speed": 105.0,
		"wander_radius": 140.0,
		"aggro_radius": 0.0,
		"attack_range": 96.0,
		"idle_min_time": 0.4,
		"idle_max_time": 3.5,
		"attack_interval": 1.0,
		"death_duration": 0.6,
	},
}


static func for_id(enemy_id: String):
	return from_config(Dictionary(REGISTRY.get(enemy_id, REGISTRY["slime_spiked"])))


static func from_config(config: Dictionary):
	var enemy = ENEMY_DEFINITION_SCRIPT.new()
	enemy.apply_config(config)
	return enemy
