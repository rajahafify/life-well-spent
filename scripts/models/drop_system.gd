## DropSystem - pure chance roll helper for enemy drop tables.
class_name DropSystem
extends Object


func succeeds(drop: Dictionary, roll: int = -1, rng: RandomNumberGenerator = null) -> bool:
	var denominator := int(drop.get("chance_denominator", 1))
	var numerator := int(drop.get("chance_numerator", denominator))
	if denominator <= 1:
		return true
	numerator = clampi(numerator, 0, denominator)
	if numerator <= 0:
		return false
	var resolved_roll := roll
	if resolved_roll <= 0:
		if rng != null:
			resolved_roll = rng.randi_range(1, denominator)
		else:
			var local_rng := RandomNumberGenerator.new()
			resolved_roll = local_rng.randi_range(1, denominator)
			local_rng.free()
	return resolved_roll <= numerator
