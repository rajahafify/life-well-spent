## EquipmentStats - pure stat bonuses for equipped inventory items.
class_name EquipmentStats
extends Object


func attack_bonus_for_weapon(item_id: String) -> int:
	match item_id:
		"training_sword":
			return 20
		_:
			return 0


func defense_bonus_for_armor(item_id: String) -> int:
	match item_id:
		"leather_armor":
			return 1
		_:
			return 0
