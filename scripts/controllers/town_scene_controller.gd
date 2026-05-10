## TownSceneController — manages the town hub scene.
## Displays player stats and quest info from models.
## Handles mouse click-to-move via CharacterMovement view.
class_name TownSceneController
extends Node2D

# Preload forces Godot to parse CharacterMovement before this file,
# making class_name CharacterMovement available for type annotations.
const _PMovement = preload("res://scripts/views/character_movement.gd")
const _DialogView = preload("res://scripts/views/town_dialog_view.gd")

# ── References ─────────────────────────────────────────────────────────

@onready var _hp_label: Label = $UI/HPLabel
@onready var _quest_label: Label = $UI/QuestLabel
@onready var _title_label: Label = $UI/StatsTitle
@onready var _dialog_view = $UI/DialogPanel
@onready var _player: CharacterBody2D = $Player

var _player_stats: PlayerStats
var _quest_manager: QuestManager
var _active_npc: NpcController
var _pending_npc: NpcController


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title_label.add_theme_font_size_override("font_size", 24)
	_player_stats = PlayerStats.new()
	_quest_manager = QuestManager.new()
	_connect_dialog_buttons()
	_connect_npcs()
	_dialog_view.hide_dialog()
	_update_stats()


# ── Input ──────────────────────────────────────────────────────────────

func _physics_process(_delta: float) -> void:
	if _pending_npc == null:
		return
	if _pending_npc.is_player_in_talk_range(_player.global_position):
		_open_dialog(_pending_npc)


func _unhandled_input(event: InputEvent) -> void:
	if _dialog_view.is_open():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos := get_global_mouse_position()
		var pm := _player_movement()
		if pm:
			pm.move_to(world_pos)


# ── Stats Display ──────────────────────────────────────────────────────

func _update_stats() -> void:
	_hp_label.text = "HP: %d / %d" % [_player_stats.max_hp, _player_stats.max_hp]
	_quest_label.text = "Quests: %d active" % _quest_manager.active_quests.size()


func update_quest_count(count: int) -> void:
	_quest_label.text = "Quests: %d active" % count


func _connect_dialog_buttons() -> void:
	_dialog_view.ensure_ready()
	if not _dialog_view.accept_quest_requested.is_connected(_on_accept_quest_pressed):
		_dialog_view.accept_quest_requested.connect(_on_accept_quest_pressed)
	if not _dialog_view.complete_quest_requested.is_connected(_on_complete_quest_pressed):
		_dialog_view.complete_quest_requested.connect(_on_complete_quest_pressed)
	if not _dialog_view.close_requested.is_connected(_on_close_dialog_pressed):
		_dialog_view.close_requested.connect(_on_close_dialog_pressed)


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
	if not npc.is_player_in_talk_range(_player.global_position):
		_pending_npc = npc
		var pm := _player_movement()
		if pm:
			pm.move_to(npc.talk_point_for(_player.global_position))
		return
	_open_dialog(npc)


func _open_dialog(npc: NpcController) -> void:
	_pending_npc = null
	_active_npc = npc
	var pm := _player_movement()
	if pm:
		pm.stop_moving()
		pm.face_target(npc.global_position)
		pm.can_move = false
	npc.face_toward_player(_player.global_position)
	_dialog_view.show_dialog(npc.display_name, npc.dialog_text, _can_offer_quest(), _has_active_quest())
	_quest_label.text = "Talking to: %s" % npc.name


func _configure_dialog_buttons() -> void:
	_dialog_view.configure_buttons(_can_offer_quest(), _has_active_quest())


func _has_active_quest() -> bool:
	return _quest_manager.active_quests.size() > 0


func _can_offer_quest() -> bool:
	return _active_npc != null and _active_npc.role == "quest_giver" and _active_npc.quest_name != "" and not _has_active_quest()


func _on_accept_quest_pressed() -> void:
	if _active_npc == null:
		return
	var accepted := _quest_manager.take_quest(_player_stats.max_hp)
	if accepted:
		_player_stats.take_quest()
		_dialog_view.set_body("Quest accepted: %s" % _active_npc.quest_name)
	else:
		_dialog_view.set_body("No quests available.")
	_update_stats()
	_configure_dialog_buttons()


func _on_complete_quest_pressed() -> void:
	if _quest_manager.complete_quest():
		_player_stats.complete_quest()
		_dialog_view.set_body("Quest completed. Your life was spent well.")
	_update_stats()
	_configure_dialog_buttons()


func _on_close_dialog_pressed() -> void:
	_dialog_view.hide_dialog()
	_active_npc = null
	_pending_npc = null
	var pm := _player_movement()
	if pm:
		pm.can_move = true


# ── Player ─────────────────────────────────────────────────────────────

func get_player() -> CharacterBody2D:
	return _player


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
