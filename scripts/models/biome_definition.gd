## BiomeDefinition — pure map biome palette/enemy/prop data.
class_name BiomeDefinition
extends Resource

@export var biome_type: String = ""
@export var palette: Dictionary = {}
@export var enemy_pool: Array = []
@export var prop_pool: Array = []
@export var music_id: String = ""
@export var ambient_tags: Array = []


func allows_enemy(enemy_id: String) -> bool:
	return enemy_id in enemy_pool


static func field_grassland():
	var script: GDScript = load("res://scripts/models/biome_definition.gd")
	var biome = script.new()
	biome.biome_type = "grassland"
	biome.palette = {
		"grass": Color(0.36, 0.72, 0.24, 1),
		"dirt": Color(0.45, 0.28, 0.12, 1),
		"forest": Color(0.05, 0.22, 0.08, 1),
		"portal": Color(0.1, 0.8, 0.9, 0.55),
	}
	biome.enemy_pool = ["chick", "rabbit", "slime"]
	biome.prop_pool = ["rocks", "bushes", "grass_patches"]
	biome.music_id = "field_grassland"
	biome.ambient_tags = ["bright", "beginner", "peaceful"]
	return biome
