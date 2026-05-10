## DemoController — live demo of PlayerStats + QuestManager.
## Click to move, Q=take quest, C=complete, A=abandon, R=rebirth, F=debug.
extends Node2D

var _player: PlayerStats
var _quests: QuestManager
var _player_sprite: Sprite2D
var _hp_label: Label
var _quest_label: Label


func _ready() -> void:
	_player_sprite = get_node_or_null("Player")
	_hp_label = get_node_or_null("UI/HPLabel")
	_quest_label = get_node_or_null("UI/QuestLabel")

	_player = PlayerStats.new()
	_quests = QuestManager.new()

	# Add sample quests (50 for extended QA)
	for i in range(50):
		_quests.add_quest("Quest %d" % i, 40, "Quest %d description" % i)

	if _hp_label:
		_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_hp_label.add_theme_font_size_override("font_size", 32)
	if _quest_label:
		_quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_quest_label.add_theme_font_size_override("font_size", 24)

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
		var taken: bool = _quests.take_quest()
		if taken:
			_player.take_quest()
		_update_display()
	elif keycode == KEY_C:
		_quests.complete_quest()
		_update_display()
	elif keycode == KEY_A:
		_quests.abandon_quest()
		_update_display()
	elif keycode == KEY_R:
		_player.rebirth()
		_quests.reset_for_life()
		_update_display()
	elif keycode == KEY_F:
		if _player_sprite:
			var target: Vector2 = get_viewport_rect().size * 0.8
			_player_sprite.move_to(target)


func _update_display() -> void:
	if _hp_label:
		var status = "💀 DEAD" if _player.state == "dead" else "❤️  ALIVE"
		_hp_label.text = "%s\nLevel %d\nHP: %d" % [
			status, _player.level, _player.max_hp
		]
	if _quest_label:
		var lines: Array[String] = []
		lines.append("Quests taken: %d/%d" % [_quests.quests_taken, _quests.max_quests_per_life])
		if _quests.active_quest != null:
			lines.append("Active: %s" % _quests.active_quest.name)
		else:
			lines.append("Active: none")
		lines.append("Catalog: %d remaining" % _quests.quest_catalog.size())
		_quest_label.text = "\n".join(lines)
