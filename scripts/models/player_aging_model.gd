## PlayerAgingModel - pure rules for mapping Life pressure to player visual age.
class_name PlayerAgingModel
extends Object

const STAGE_ONE_TEXTURE := "res://assets/player_age_1.png"
const STAGE_TWO_TEXTURE := "res://assets/player_age_2.png"
const STAGE_THREE_TEXTURE := "res://assets/player_age_3.png"
const STAGE_ONE_SWORD_TEXTURE := "res://assets/player_age_1_sword.png"
const STAGE_TWO_SWORD_TEXTURE := "res://assets/player_age_2_sword.png"
const STAGE_THREE_SWORD_TEXTURE := "res://assets/player_age_3_sword.png"
const STAGE_ONE_SWORD_ARMOR_TEXTURE := "res://assets/player_age_1_sword_armor.png"
const STAGE_TWO_SWORD_ARMOR_TEXTURE := "res://assets/player_age_2_sword_armor.png"
const STAGE_THREE_SWORD_ARMOR_TEXTURE := "res://assets/player_age_3_sword_armor.png"


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


func texture_path_for_stage_with_weapon(stage: int, weapon_id: String) -> String:
	return texture_path_for_stage_with_equipment(stage, weapon_id, "")


func texture_path_for_max_hp_and_weapon(max_hp: int, weapon_id: String) -> String:
	return texture_path_for_stage_with_weapon(stage_for_max_hp(max_hp), weapon_id)


func texture_path_for_stage_with_equipment(stage: int, weapon_id: String, armor_id: String) -> String:
	if weapon_id != "training_sword":
		return texture_path_for_stage(stage)
	if armor_id == "leather_armor":
		match clamp(stage, 1, 3):
			1:
				return STAGE_ONE_SWORD_ARMOR_TEXTURE
			2:
				return STAGE_TWO_SWORD_ARMOR_TEXTURE
			_:
				return STAGE_THREE_SWORD_ARMOR_TEXTURE
	match clamp(stage, 1, 3):
		1:
			return STAGE_ONE_SWORD_TEXTURE
		2:
			return STAGE_TWO_SWORD_TEXTURE
		_:
			return STAGE_THREE_SWORD_TEXTURE


func texture_path_for_max_hp_and_equipment(max_hp: int, weapon_id: String, armor_id: String) -> String:
	return texture_path_for_stage_with_equipment(stage_for_max_hp(max_hp), weapon_id, armor_id)
