## EnemySpawnSystem - pure game-wide enemy spawn slot state.
class_name EnemySpawnSystem
extends RefCounted

const DEFAULT_RESPAWN_DELAY := 60.0

var elapsed_time: float = 0.0
var _biomes: Dictionary = {}
var _slots: Dictionary = {}
var _slot_order: Array = []


func register_biome(map_id: String, biome_id: String, max_active: int, respawn_delay: float = DEFAULT_RESPAWN_DELAY) -> void:
	_biomes[_biome_key(map_id, biome_id)] = {
		"map_id": map_id,
		"biome_id": biome_id,
		"max_active": max(0, max_active),
		"respawn_delay": max(0.0, respawn_delay),
	}


func register_spawn_slot(slot_id: String, map_id: String, biome_id: String, enemy_id: String) -> void:
	if _slots.has(slot_id):
		var existing: Dictionary = _slots[slot_id]
		existing["map_id"] = map_id
		existing["biome_id"] = biome_id
		existing["enemy_id"] = enemy_id
		_slots[slot_id] = existing
		return
	_slot_order.append(slot_id)
	_slots[slot_id] = {
		"slot_id": slot_id,
		"map_id": map_id,
		"biome_id": biome_id,
		"enemy_id": enemy_id,
		"alive": true,
		"defeated_at": -1.0,
		"respawn_at": -1.0,
	}


func tick(delta: float) -> void:
	elapsed_time += max(0.0, delta)


func active_spawn_slots(map_id: String, biome_id: String = "") -> Array:
	var result: Array = []
	var active_counts := {}
	for slot_id in _sorted_slot_ids():
		var slot: Dictionary = _slots[slot_id]
		if str(slot.get("map_id", "")) != map_id:
			continue
		if biome_id != "" and str(slot.get("biome_id", "")) != biome_id:
			continue
		var slot_biome := str(slot.get("biome_id", ""))
		var config := _biome_config(map_id, slot_biome)
		var max_active := int(config.get("max_active", 0))
		if bool(slot.get("alive", true)):
			if int(active_counts.get(slot_biome, 0)) < max_active:
				result.append(slot.duplicate(true))
				active_counts[slot_biome] = int(active_counts.get(slot_biome, 0)) + 1
			continue
		if float(slot.get("respawn_at", 0.0)) > elapsed_time:
			continue
		if int(active_counts.get(slot_biome, 0)) >= max_active:
			continue
		slot["alive"] = true
		slot["defeated_at"] = -1.0
		slot["respawn_at"] = -1.0
		_slots[slot_id] = slot
		active_counts[slot_biome] = int(active_counts.get(slot_biome, 0)) + 1
		result.append(slot.duplicate(true))
	return result


func mark_defeated(slot_id: String) -> void:
	if not _slots.has(slot_id):
		return
	var slot: Dictionary = _slots[slot_id]
	if not bool(slot.get("alive", true)):
		return
	var config := _biome_config(str(slot.get("map_id", "")), str(slot.get("biome_id", "")))
	var delay := float(config.get("respawn_delay", DEFAULT_RESPAWN_DELAY))
	slot["alive"] = false
	slot["defeated_at"] = elapsed_time
	slot["respawn_at"] = elapsed_time + delay
	_slots[slot_id] = slot


func is_slot_alive(slot_id: String) -> bool:
	if not _slots.has(slot_id):
		return false
	return bool(Dictionary(_slots[slot_id]).get("alive", true))


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"elapsed_time": elapsed_time,
		"biomes": _biomes.duplicate(true),
		"slots": _slots.duplicate(true),
		"slot_order": _slot_order.duplicate(true),
	}


func apply_dict(data: Dictionary) -> void:
	elapsed_time = float(data.get("elapsed_time", 0.0))
	_biomes = Dictionary(data.get("biomes", {})).duplicate(true)
	_slots = Dictionary(data.get("slots", {})).duplicate(true)
	_slot_order = Array(data.get("slot_order", []))
	for slot_id in _slots.keys():
		if not _slot_order.has(slot_id):
			_slot_order.append(slot_id)


func reset() -> void:
	elapsed_time = 0.0
	_biomes.clear()
	_slots.clear()
	_slot_order.clear()


func _biome_config(map_id: String, biome_id: String) -> Dictionary:
	return Dictionary(_biomes.get(_biome_key(map_id, biome_id), {
		"map_id": map_id,
		"biome_id": biome_id,
		"max_active": 0,
		"respawn_delay": DEFAULT_RESPAWN_DELAY,
	}))


func _biome_key(map_id: String, biome_id: String) -> String:
	return "%s:%s" % [map_id, biome_id]


func _sorted_slot_ids() -> Array:
	return _slot_order.duplicate()
