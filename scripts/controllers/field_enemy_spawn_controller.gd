## FieldEnemySpawnController - enemy spawn registration and polling for Field.
class_name FieldEnemySpawnController
extends Object

const FIELD_MAP_ID := "field"
const FIELD_BIOME_ID := "grassland"
const FIELD_MAX_ACTIVE_ENEMIES := 9
const FIELD_RESPAWN_DELAY := 60.0
const ENEMY_SPAWN_POLL_INTERVAL := 1.0

var spawn_slots: Dictionary = {}
var poll_timer: float = 0.0
var rng := RandomNumberGenerator.new()


func setup(owner) -> void:
	if owner.has_enemy("field_slime_001"):
		return
	rng.randomize()
	var spawns := [
		{"enemy_id": "slime_spiked", "id": "field_slime_001", "name": "Slime"},
		{"enemy_id": "slime_spiked", "id": "field_slime_002", "name": "Slime2"},
		{"enemy_id": "slime_spiked", "id": "field_slime_003", "name": "Slime3"},
		{"enemy_id": "slime_spiked", "id": "field_slime_004", "name": "Slime4"},
		{"enemy_id": "slime_spiked", "id": "field_slime_005", "name": "Slime5"},
		{"enemy_id": "bat", "id": "field_bat_001", "name": "Bat"},
		{"enemy_id": "bat", "id": "field_bat_002", "name": "Bat2"},
		{"enemy_id": "rat", "id": "field_rat_001", "name": "Rat"},
		{"enemy_id": "rat", "id": "field_rat_002", "name": "Rat2"},
	]
	EnemySpawnManager.register_biome(FIELD_MAP_ID, FIELD_BIOME_ID, FIELD_MAX_ACTIVE_ENEMIES, FIELD_RESPAWN_DELAY)
	spawn_slots.clear()
	for spawn in spawns:
		EnemySpawnManager.register_spawn_slot(spawn["id"], FIELD_MAP_ID, FIELD_BIOME_ID, spawn["enemy_id"])
		spawn_slots[spawn["id"]] = spawn
	spawn_active_slots(owner)


func tick(owner, delta: float) -> void:
	poll_timer += delta
	if poll_timer < ENEMY_SPAWN_POLL_INTERVAL:
		return
	poll_timer = 0.0
	spawn_active_slots(owner)


func spawn_active_slots(owner) -> void:
	var occupied: Array[Vector2] = owner.current_enemy_positions()
	for active_slot in EnemySpawnManager.active_spawn_slots(FIELD_MAP_ID, FIELD_BIOME_ID):
		var slot_id := str(active_slot.get("slot_id", ""))
		if owner.has_enemy(slot_id):
			continue
		var spawn: Dictionary = spawn_slots.get(slot_id, {})
		if spawn.is_empty():
			continue
		var spawn_pos := random_enemy_spawn_position(owner, occupied)
		occupied.append(spawn_pos)
		owner.spawn_enemy(spawn["enemy_id"], spawn_pos, spawn["id"], spawn["name"])


func current_enemy_positions(enemy_views: Dictionary) -> Array[Vector2]:
	var occupied: Array[Vector2] = []
	for view in enemy_views.values():
		if view is Node2D:
			occupied.append((view as Node2D).global_position)
	return occupied


func random_enemy_spawn_position(owner, occupied: Array[Vector2]) -> Vector2:
	var rect: Rect2 = owner.enemy_spawn_rect()
	for attempt in range(24):
		var candidate := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		if owner.is_spawn_position_clear(candidate, occupied):
			return candidate
	return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
