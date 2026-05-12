## PlayerAgingModel - pure rules for mapping Life pressure to player visual age.
class_name PlayerAgingModel
extends Object

const STAGE_ONE_TEXTURE := "res://assets/player_age_1.png"
const STAGE_TWO_TEXTURE := "res://assets/player_age_2.png"
const STAGE_THREE_TEXTURE := "res://assets/player_age_3.png"


func stage_for_max_hp(max_hp: int) -> int:
	if max_hp <= 20:
		return 3
	if max_hp <= 60:
		return 2
	return 1


func texture_path_for_stage(stage: int) -> String:
	match clamp(stage, 1, 3):
		1:
			return STAGE_ONE_TEXTURE
		2:
			return STAGE_TWO_TEXTURE
		_:
			return STAGE_THREE_TEXTURE


func texture_path_for_max_hp(max_hp: int) -> String:
	return texture_path_for_stage(stage_for_max_hp(max_hp))
