## EnemySpawnManager - game-wide persistent enemy spawn runtime.
extends Node

const SAVE_PATH := "user://enemy_spawn_state.json"
const SPAWN_SYSTEM_SCRIPT := preload("res://scripts/models/enemy_spawn_system.gd")

var _spawn_system = SPAWN_SYSTEM_SCRIPT.new()


func _ready() -> void:
	if _should_persist():
		load_state()


func _process(delta: float) -> void:
	_spawn_system.tick(delta)


func register_biome(map_id: String, biome_id: String, max_active: int, respawn_delay: float = 60.0) -> void:
	_spawn_system.register_biome(map_id, biome_id, max_active, respawn_delay)


func register_spawn_slot(slot_id: String, map_id: String, biome_id: String, enemy_id: String) -> void:
	_spawn_system.register_spawn_slot(slot_id, map_id, biome_id, enemy_id)


func active_spawn_slots(map_id: String, biome_id: String = "") -> Array:
	return _spawn_system.active_spawn_slots(map_id, biome_id)


func mark_defeated(slot_id: String) -> void:
	_spawn_system.mark_defeated(slot_id)
	if _should_persist():
		save_state()


func reset() -> void:
	_spawn_system.reset()
	if _should_persist():
		save_state()


func to_dict() -> Dictionary:
	return _spawn_system.to_dict()


func apply_dict(data: Dictionary) -> void:
	_spawn_system.apply_dict(data)


func save_state(path: String = SAVE_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(to_dict()))
	file.close()
	return true


func load_state(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		apply_dict(Dictionary(parsed))
		return true
	return false


func _should_persist() -> bool:
	return not OS.has_feature("headless")
