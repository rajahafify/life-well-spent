## RandomEnemyRespawnSystem — pure spawn-zone timer/cap rules.
class_name RandomEnemyRespawnSystem
extends Object


func define_zone(spawn_zone_id: String, enemy_pool: Array, max_active: int, respawn_interval: float, biome_type: String = "") -> Dictionary:
	return {
		"spawn_zone_id": spawn_zone_id,
		"enemy_pool": enemy_pool.duplicate(),
		"max_active": max_active,
		"respawn_interval": respawn_interval,
		"biome_type": biome_type,
		"timer": respawn_interval,
	}


func tick_zone(zone: Dictionary, elapsed: float, active_count: int) -> Dictionary:
	if active_count >= int(zone.get("max_active", 0)):
		return _no_spawn(zone, "max_active", max(0.0, float(zone.get("timer", zone.get("respawn_interval", 0.0))) - elapsed))

	var remaining: float = max(0.0, float(zone.get("timer", zone.get("respawn_interval", 0.0))) - elapsed)
	if remaining > 0.0:
		return _no_spawn(zone, "waiting", remaining)

	var pool: Array = zone.get("enemy_pool", [])
	if pool.is_empty():
		return _no_spawn(zone, "empty_pool", 0.0)

	return {
		"should_spawn": true,
		"spawn_zone_id": zone.get("spawn_zone_id", ""),
		"enemy_id": str(pool[0]),
		"remaining_timer": 0.0,
	}


func schedule_after_spawn(zone: Dictionary) -> Dictionary:
	var next_zone := zone.duplicate(true)
	next_zone["timer"] = float(zone.get("respawn_interval", 0.0))
	return next_zone


func _no_spawn(zone: Dictionary, reason: String, remaining_timer: float) -> Dictionary:
	return {
		"should_spawn": false,
		"spawn_zone_id": zone.get("spawn_zone_id", ""),
		"enemy_id": "",
		"reason": reason,
		"remaining_timer": remaining_timer,
	}
