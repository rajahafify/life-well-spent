class_name NpcState
extends RefCounted

var state: String = "idle"
var facing: String = "down"
var current_quest = null

func face_player(player_pos: Vector2) -> void:
	var delta_x: float = player_pos.x
	var delta_y: float = player_pos.y
	
	if abs(delta_x) > abs(delta_y):
		if delta_x > 0:
			facing = "right"
		else:
			facing = "left"
	else:
		if delta_y < 0:
			facing = "up"
		else:
			facing = "down"

func assign_quest(quest_id: String) -> void:
	current_quest = quest_id

func clear_quest() -> void:
	current_quest = null

func set_interacting(interacting: bool) -> void:
	state = "interacting" if interacting else "idle"