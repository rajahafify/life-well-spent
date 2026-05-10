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
@onready var _dialog_panel: Control = $UI/DialogPanel
@onready var _dialog_name_label: Label = $UI/DialogPanel/VBox/NameLabel
@onready var _dialog_body_label: Label = $UI/DialogPanel/VBox/BodyLabel
@onready var _accept_quest_button: Button = $UI/DialogPanel/VBox/Buttons/AcceptQuestButton
@onready var _complete_quest_button: Button = $UI/DialogPanel/VBox/Buttons/CompleteQuestButton
@onready var _close_dialog_button: Button = $UI/DialogPanel/VBox/Buttons/CloseButton
@onready var _player: CharacterBody2D = $Player

var _player_stats: PlayerStats
var _quest_manager: QuestManager
var _active_npc: NpcController


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title_label.add_theme_font_size_override("font_size", 24)
	_player_stats = PlayerStats.new()
	_quest_manager = QuestManager.new()
	_connect_dialog_buttons()
	_connect_npcs()
	_dialog_panel.visible = false
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


func _connect_dialog_buttons() -> void:
	if not _accept_quest_button.pressed.is_connected(_on_accept_quest_pressed):
		_accept_quest_button.pressed.connect(_on_accept_quest_pressed)
	if not _complete_quest_button.pressed.is_connected(_on_complete_quest_pressed):
		_complete_quest_button.pressed.connect(_on_complete_quest_pressed)
	if not _close_dialog_button.pressed.is_connected(_on_close_dialog_pressed):
		_close_dialog_button.pressed.connect(_on_close_dialog_pressed)


func _connect_npcs() -> void:
	for child in get_children():
		if child is NpcController:
			var npc := child as NpcController
			if not npc.interacted.is_connected(_on_npc_interacted):
				npc.interacted.connect(_on_npc_interacted)
			_register_npc_quest(npc)


func _register_npc_quest(npc: NpcController) -> void:
	if npc.role != "quest_giver" or npc.quest_name == "":
		return
	_quest_manager.add_quest(npc.quest_name, npc.quest_cost, npc.quest_description)


func _on_npc_interacted(npc: NpcController) -> void:
	_active_npc = npc
	_dialog_panel.visible = true
	_dialog_name_label.text = npc.display_name
	_dialog_body_label.text = npc.dialog_text
	_configure_dialog_buttons()
	_quest_label.text = "Talking to: %s" % npc.name


func _configure_dialog_buttons() -> void:
	var has_active_quest := _quest_manager.active_quests.size() > 0
	var can_offer_quest := _active_npc != null and _active_npc.role == "quest_giver" and _active_npc.quest_name != "" and not has_active_quest
	_accept_quest_button.visible = can_offer_quest
	_complete_quest_button.visible = has_active_quest
	_close_dialog_button.visible = true


func _on_accept_quest_pressed() -> void:
	if _active_npc == null:
		return
	var accepted := _quest_manager.take_quest(_player_stats.max_hp)
	if accepted:
		_player_stats.take_quest()
		_dialog_body_label.text = "Quest accepted: %s" % _active_npc.quest_name
	elif _quest_manager.last_rejection == "not_enough_hp":
		_dialog_body_label.text = "You have no more life to sacrifice."
	else:
		_dialog_body_label.text = "No quests available."
	_update_stats()
	_configure_dialog_buttons()


func _on_complete_quest_pressed() -> void:
	if _quest_manager.complete_quest():
		_player_stats.complete_quest()
		_dialog_body_label.text = "Quest completed. Your life was spent well."
	_update_stats()
	_configure_dialog_buttons()


func _on_close_dialog_pressed() -> void:
	_dialog_panel.visible = false
	_active_npc = null


# ── Player ─────────────────────────────────────────────────────────────

func get_player() -> CharacterBody2D:
	return _player
