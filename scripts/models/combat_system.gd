## CombatSystem — pure Field combat rules. Combat HP only; Life untouched.
class_name CombatSystem
extends Object


func player_attack_enemy(player_stats: Dictionary, enemy_state: Dictionary) -> Dictionary:
	var next_enemy := enemy_state.duplicate(true)
	var damage := _damage_value(int(player_stats.get("attack", 1)), int(enemy_state.get("defense", 0)))
	var next_hp: int = max(0, int(enemy_state.get("hp", 0)) - damage)
	next_enemy["hp"] = next_hp
	var defeated := next_hp <= 0
	return {
		"damage": damage,
		"enemy_state": next_enemy,
		"enemy_defeated": defeated,
		"xp_reward": int(enemy_state.get("xp_reward", 0)) if defeated else 0,
	}


func enemy_attack_player(enemy_state: Dictionary, player_state: Dictionary) -> Dictionary:
	var next_player := player_state.duplicate(true)
	var damage := _damage_value(int(enemy_state.get("attack", 1)), int(player_state.get("defense", 0)))
	var next_hp: int = max(0, int(player_state.get("combat_hp", 0)) - damage)
	next_player["combat_hp"] = next_hp
	# Deliberately preserve Life exactly as provided; Field combat cannot spend/damage Life.
	if player_state.has("life"):
		next_player["life"] = player_state["life"]
	return {
		"damage": damage,
		"player_state": next_player,
		"player_defeated": next_hp <= 0,
	}


func _damage_value(attack_value: int, defense_value: int) -> int:
	return max(1, attack_value - defense_value)
