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
			state.idle_duration = state.next_idle_duration(definition)
			state.behavior_state = "wander"
			state.target_position = _next_wander_target(state, definition)
	elif state.behavior_state == "wander":
		state.position = state.position.move_toward(state.target_position, definition.move_speed * delta)
		if state.position.distance_to(state.target_position) <= 2.0:
			state.behavior_state = "idle"
	return result


func _next_wander_target(state, definition) -> Vector2:
	state.wander_step += 1
	var angle: float = TAU * state.next_random_unit()
	var distance: float = definition.wander_radius * state.next_random_range(0.35, 0.9)
	return state.spawn_position + Vector2(cos(angle), sin(angle)) * distance
