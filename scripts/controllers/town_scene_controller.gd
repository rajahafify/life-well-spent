## TownSceneController — manages the town hub scene.
## Displays player stats and quest info from models.
## Handles mouse click-to-move via CharacterMovement view.
class_name TownSceneController
extends Node2D

# Preload forces Godot to parse CharacterMovement before this file,
# making class_name CharacterMovement available for type annotations.
const _PMovement = preload("res://scripts/views/character_movement.gd")

# ── References ─────────────────────────────────────────────────────────

@onready var _hp_label: Label = $UI/HPLabel
@onready var _quest_label: Label = $UI/QuestLabel
@onready var _title_label: Label = $UI/StatsTitle
@onready var _player: CharacterBody2D = $Player

var _player_stats: PlayerStats
var _quest_manager: QuestManager


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title_label.add_theme_font_size_override("font_size", 24)
	_player_stats = PlayerStats.new()
	_quest_manager = QuestManager.new()
	_connect_npcs()
	_update_stats()


# ── Input ──────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos := get_global_mouse_position()
		var pm: CharacterMovement = _player.get_node("Sprite") as CharacterMovement
		if pm:
			pm.move_to(world_pos)


# ── Stats Display ──────────────────────────────────────────────────────

func _update_stats() -> void:
	_hp_label.text = "HP: %d / %d" % [_player_stats.max_hp, _player_stats.max_hp]
	_quest_label.text = "Quests: %d active" % _quest_manager.active_quests.size()


func update_quest_count(count: int) -> void:
	_quest_label.text = "Quests: %d active" % count


func _connect_npcs() -> void:
	for child in get_children():
		if child is NpcController:
			var npc := child as NpcController
			if not npc.interacted.is_connected(_on_npc_interacted):
				npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: NpcController) -> void:
	_quest_label.text = "Talking to: %s" % npc.name


# ── Player ─────────────────────────────────────────────────────────────

func get_player() -> CharacterBody2D:
	return _player
