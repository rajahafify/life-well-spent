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
	if not state.is_aggro and distance_to_player <= definition.aggro_radius:
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
		if state.idle_timer >= 1.0:
			state.idle_timer = 0.0
			state.behavior_state = "wander"
			var offset := Vector2(definition.wander_radius * 0.5, 0)
			state.target_position = state.spawn_position + offset
	elif state.behavior_state == "wander":
		state.position = state.position.move_toward(state.target_position, definition.move_speed * delta)
		if state.position.distance_to(state.target_position) <= 2.0:
			state.behavior_state = "idle"
	return result
