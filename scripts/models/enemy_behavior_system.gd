## EnemyBehaviorSystem — pure-ish enemy behavior transitions for Field enemies.
class_name EnemyBehaviorSystem
extends Object

const ENEMY_RANDOM_SEQUENCE := preload("res://scripts/models/enemy_random_sequence.gd")


func tick(state, definition, context: Dictionary, delta: float) -> void:
	state.enemy_attack_ready = false
	state.died_this_tick = false
	if state.hp <= 0:
		if state.behavior_state != "die":
			state.died_this_tick = true
		state.behavior_state = "die"
		state.is_defeated = true
		state.is_aggro = false
		return

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
				state.enemy_attack_ready = true
		else:
			state.behavior_state = "chase"
			state.attack_timer = 0.0
			state.position = state.position.move_toward(player_position, definition.chase_speed * delta)
		return

	if state.behavior_state == "idle":
		state.idle_timer += delta
		if state.idle_timer >= state.idle_duration:
			state.idle_timer = 0.0
			state.idle_duration = ENEMY_RANDOM_SEQUENCE.idle_duration(state, definition)
			state.behavior_state = "wander"
			state.target_position = _next_wander_target(state, definition)
	elif state.behavior_state == "wander":
		state.position = state.position.move_toward(state.target_position, definition.move_speed * delta)
		if state.position.distance_to(state.target_position) <= 2.0:
			state.behavior_state = "idle"


func _next_wander_target(state, definition) -> Vector2:
	state.wander_step += 1
	var angle: float = TAU * ENEMY_RANDOM_SEQUENCE.unit(state)
	var distance: float = definition.wander_radius * ENEMY_RANDOM_SEQUENCE.range_value(state, 0.35, 0.9)
	return state.spawn_position + Vector2(cos(angle), sin(angle)) * distance
