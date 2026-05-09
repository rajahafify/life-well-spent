## TestRunnerScene — live demo of PlayerStats model.
## Click to move, Q to take quest, R to rebirth. HP displayed on label.
extends Node2D

var _player: PlayerStats
var _ci_mode: bool = false
var _player_sprite: Sprite2D
var _label: Label
var _results_label: Label


func _ready() -> void:
	# Look up nodes (may be missing in CI scene)
	_player_sprite = get_node_or_null("Player")
	_label = get_node_or_null("UI/HPLabel")
	_results_label = get_node_or_null("UI/ResultsLabel")

	# Run all specs first
	var results: Dictionary = TestRunner.run_with_output()
	var total_passed: int = results["passed"]
	var total_failed: int = results["failed"]

	_player = PlayerStats.new()

	if _label:
		# Main scene: show test results + live HP display
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.add_theme_font_size_override("font_size", 32)
		_label.text = "Tests: %d/%d passed" % [total_passed, total_passed + total_failed]
	elif _results_label:
		# CI scene: no HP label, just results
		_results_label.text = "Tests: %d/%d passed" % [total_passed, total_passed + total_failed]
		_ci_mode = true


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
			# Debug: move to bottom-right
			var target: Vector2 = get_viewport_rect().size * 0.8
			_player_sprite.move_to(target)


func _update_display() -> void:
	if not _label:
		return
	var status = "💀 DEAD" if _player.state == "dead" else "❤️  ALIVE"
	_label.text = "%s\nLevel %d\nHP: %d" % [
		status, _player.level, _player.max_hp
	]
