## FieldCombatController - player auto-attack and enemy tick orchestration.
class_name FieldCombatController
extends Object


func tick_player_auto_attack(owner, delta: float) -> void:
	if owner.player_target_id() == "" or not owner.has_enemy(owner.player_target_id()):
		return
	var state = owner.enemy_state(owner.player_target_id())
	if state.is_defeated:
		owner.stop_auto_attack()
		return
	var distance_to_enemy: float = owner.player_node().global_position.distance_to(state.position)
	if not owner.is_player_target_attack_ready() and distance_to_enemy > owner.player_attack_ready_range():
		owner.move_player_to(owner.attack_point_for_enemy(state.position))
		return
	if not owner.is_player_target_attack_ready():
		owner.mark_player_target_attack_ready()
	if distance_to_enemy > owner.player_attack_leash_range():
		owner.clear_player_target_attack_ready()
		owner.move_player_to(owner.attack_point_for_enemy(state.position))
		return
	var movement: Object = owner.player_movement()
	if movement:
		if not movement.is_attacking():
			movement.stop_moving()
		movement.face_target(state.position)
	owner.player_attack_timer += delta
	if owner.player_attack_timer < owner.player_attack_interval:
		return
	owner.player_attack_timer = 0.0
	owner.play_feedback_sfx("player_attack")
	movement.play_attack(owner.player_attack_animation_style())
	var result: Dictionary = owner.combat_system().player_attack_enemy(owner.player_combat_dict(), state.to_combat_dict())
	owner.start_camera_shake()
	owner.play_feedback_sfx("enemy_hit")
	state.apply_combat_dict(result["enemy_state"])
	state.is_aggro = true
	if state.behavior_state != "die":
		state.behavior_state = "chase"
	if bool(result.get("enemy_defeated", false)):
		_handle_enemy_defeated(owner, state, result)
	else:
		owner.update_enemy_view(state)
		var hit_view = owner.enemy_view(state.instance_id)
		if hit_view and hit_view.has_method("play_hit_feedback"):
			hit_view.play_hit_feedback(int(result.get("damage", 1)))


func tick_enemies(owner, delta: float) -> void:
	for instance_id in owner.enemy_ids():
		if not owner.has_enemy(instance_id):
			continue
		var state = owner.enemy_state(instance_id)
		var definition = owner.enemy_definition(state.enemy_id)
		state.position = (owner.enemy_view(instance_id) as Node2D).global_position
		var previous_position: Vector2 = state.position
		owner.behavior_system().tick(state, definition, {"player_position": owner.player_node().global_position}, delta)
		owner.move_enemy_with_collision(state, state.position, previous_position)
		if state.enemy_attack_ready:
			var combat_result: Dictionary = owner.combat_system().enemy_attack_player(state.to_combat_dict(), owner.player_combat_dict())
			owner.apply_player_combat_dict(combat_result["player_state"])
			owner.show_player_damage(int(combat_result.get("damage", 1)))
			owner.start_camera_shake()
			owner.play_feedback_sfx("player_hurt")
			var attack_view = owner.enemy_view(instance_id)
			if attack_view and attack_view.has_method("play_attack_feedback"):
				attack_view.play_attack_feedback()
		if state.behavior_state == "die" or state.died_this_tick:
			state.death_timer += delta
			owner.update_enemy_view(state)
			if state.death_timer >= definition.death_duration:
				owner.remove_enemy(instance_id)
		else:
			owner.update_enemy_view(state)


func _handle_enemy_defeated(owner, state, result: Dictionary) -> void:
	if not state.reward_granted:
		owner.player_xp += int(result.get("xp_reward", 0))
		owner.grant_enemy_drops(state)
		owner.record_enemy_defeat(state.enemy_id)
		state.reward_granted = true
		EnemySpawnManager.mark_defeated(state.instance_id)
		owner.play_feedback_sfx("enemy_defeat")
	state.behavior_state = "die"
	state.is_defeated = true
	owner.update_enemy_view(state)
	owner.stop_auto_attack()
