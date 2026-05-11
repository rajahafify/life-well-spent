## SettingsModel — pure settings state and validation.
class_name SettingsModel
extends Object

var master_volume: float = 1.0
var fullscreen: bool = false


func set_master_volume(value: float) -> void:
	master_volume = max(0.0, min(1.0, value))


func set_fullscreen(value: bool) -> void:
	fullscreen = value


func to_dict() -> Dictionary:
	return {
		"master_volume": master_volume,
		"fullscreen": fullscreen,
	}


func apply_dict(data: Dictionary) -> void:
	set_master_volume(float(data.get("master_volume", 1.0)))
	fullscreen = bool(data.get("fullscreen", false))
