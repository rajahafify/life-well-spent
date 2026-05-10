## TownSceneController — manages the town hub scene.
## Displays player stats and quest info from models.
## Handles mouse click-to-move.
class_name TownSceneController
extends Node2D


# ── References ─────────────────────────────────────────────────────────

@onready var _hp_label: Label = $UI/HPLabel
@onready var _quest_label: Label = $UI/QuestLabel
@onready var _title_label: Label = $UI/StatsTitle
@onready var _player: CharacterBody2D = $Player


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title_label.add_theme_font_size_override("font_size", 24)
	_update_stats()


# ── Input ──────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos := get_global_mouse_position()
		var pm: PlayerMovement = _player.get_node("Sprite") as PlayerMovement
		if pm:
			pm.move_to(world_pos)


# ── Stats Display ──────────────────────────────────────────────────────

func _update_stats() -> void:
	var ps: PlayerStats = PlayerStats.new()
	_hp_label.text = "HP: %d / %d" % [ps.max_hp, ps.max_hp]
	_quest_label.text = "Quests: 0 active"
	ps.free()


func update_quest_count(count: int) -> void:
	_quest_label.text = "Quests: %d active" % count


# ── Player ─────────────────────────────────────────────────────────────

func get_player() -> CharacterBody2D:
	return _player
