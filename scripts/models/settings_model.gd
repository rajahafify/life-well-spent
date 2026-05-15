## SettingsModel — pure settings state and validation.
class_name SettingsModel
extends Object

var master_volume: float = 1.0
var fullscreen: bool = false
var game_speed: String = "normal"


func set_master_volume(value: float) -> void:
	master_volume = max(0.0, min(1.0, value))


func set_fullscreen(value: bool) -> void:
	fullscreen = value


func set_game_speed(value: String) -> void:
	game_speed = value if value in ["normal", "fast", "ultra"] else "normal"


func game_speed_multiplier() -> float:
	return multiplier_for_game_speed(game_speed)


static func multiplier_for_game_speed(speed_id: String) -> float:
	match speed_id:
		"fast":
			return 2.0
		"ultra":
			return 4.0
		_:
			return 1.0


func to_dict() -> Dictionary:
	return {
		"master_volume": master_volume,
		"fullscreen": fullscreen,
		"game_speed": game_speed,
	}


func apply_dict(data: Dictionary) -> void:
	set_master_volume(float(data.get("master_volume", 1.0)))
	fullscreen = bool(data.get("fullscreen", false))
	set_game_speed(str(data.get("game_speed", "normal")))
