## TestRunnerScene — live demo of PlayerStats model.
## Press Q to take quest, R for rebirth. HP displayed on label.
extends Node2D

var _player: PlayerStats

@onready var _label: Label = $UI/HPLabel


func _ready() -> void:
	_player = PlayerStats.new()
	_update_display()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 32)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit(0)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			_player.take_quest()
			_update_display()
		if event.keycode == KEY_R:
			_player.rebirth()
			_update_display()


func _update_display() -> void:
	var status = "💀 DEAD" if _player.state == "dead" else "❤️  ALIVE"
	_label.text = "%s\nLevel %d\nHP: %d" % [
		status, _player.level, _player.max_hp
	]
