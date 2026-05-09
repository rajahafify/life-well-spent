## DemoController — live demo of PlayerStats model.
## Click to move, Q to take quest, R to rebirth. HP displayed on label.
extends Node2D

var _player: PlayerStats
var _player_sprite: Sprite2D
var _label: Label


func _ready() -> void:
	_player_sprite = get_node_or_null("Player")
	_label = get_node_or_null("UI/HPLabel")

	_player = PlayerStats.new()

	if _label:
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.add_theme_font_size_override("font_size", 32)
	_update_display()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _player_sprite:
			_player_sprite.move_to(event.position)
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit(0)
	elif event is InputEventKey and event.pressed:
		_handle_key(event.keycode)


func _handle_key(keycode: int) -> void:
	if not _player:
		return
	if keycode == KEY_Q:
		_player.take_quest()
		_update_display()
	elif keycode == KEY_R:
		_player.rebirth()
		_update_display()
	elif keycode == KEY_F:
		if _player_sprite:
			var target: Vector2 = get_viewport_rect().size * 0.8
			_player_sprite.move_to(target)


func _update_display() -> void:
	if not _label:
		return
	var status = "💀 DEAD" if _player.state == "dead" else "❤️  ALIVE"
	_label.text = "%s\nLevel %d\nHP: %d" % [
		status, _player.level, _player.max_hp
	]
