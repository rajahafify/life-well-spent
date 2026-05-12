## EnemyBehaviorSystem — pure-ish enemy behavior transitions for Field enemies.
class_name EnemyBehaviorSystem
extends Object


func tick(state, definition, context: Dictionary, delta: float) -> Dictionary:
	var result := {
		"enemy_attack": false,
		"died": false,
	}
	if state.hp <= 0:
		if state.behavior_state != "die":
			result["died"] = true
		state.behavior_state = "die"
		state.is_defeated = true
		state.is_aggro = false
		return result

	var player_position: Vector2 = context.get("player_position", state.position)
	var distance_to_player: float = state.position.distance_to(player_position)
	if not state.is_aggro and definition.aggro_radius > 0.0 and distance_to_player <= definition.aggro_radius:
		state.is_aggro = true
		state.behavior_state = "chase"

	if state.is_aggro:
		if distance_to_player <= definition.attack_range:
			state.behavior_state = "attack"
			state.attack_timer += delta
			if state.attack_timer >= definition.attack_interval:
				state.attack_timer = 0.0
				result["enemy_attack"] = true
		else:
			state.behavior_state = "chase"
			state.attack_timer = 0.0
			state.position = state.position.move_toward(player_position, definition.chase_speed * delta)
		return result

	if state.behavior_state == "idle":
		state.idle_timer += delta
		if state.idle_timer >= state.idle_duration:
			state.idle_timer = 0.0
			state.idle_duration = _next_idle_duration(state, definition)
			state.behavior_state = "wander"
			state.target_position = _next_wander_target(state, definition)
	elif state.behavior_state == "wander":
		state.position = state.position.move_toward(state.target_position, definition.move_speed * delta)
		if state.position.distance_to(state.target_position) <= 2.0:
			state.behavior_state = "idle"
	return result


func _next_idle_duration(state, definition) -> float:
	var span: float = max(0.0, definition.idle_max_time - definition.idle_min_time)
	var seed: int = abs(hash("%s_idle_%d" % [state.instance_id, state.wander_step])) % 1000
	return definition.idle_min_time + span * (float(seed) / 999.0)


func _next_wander_target(state, definition) -> Vector2:
	state.wander_step += 1
	var seed: int = abs(hash("%s_wander_%d" % [state.instance_id, state.wander_step]))
	var angle := TAU * (float(seed % 1000) / 1000.0)
	var distance: float = definition.wander_radius * (0.35 + 0.55 * (float((seed / 1000) % 1000) / 999.0))
	return state.spawn_position + Vector2(cos(angle), sin(angle)) * distance
