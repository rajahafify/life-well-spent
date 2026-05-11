## TownSceneController — manages the town hub scene.
## Displays player stats and quest info from models.
## Handles mouse click-to-move via CharacterMovement view.
class_name TownSceneController
extends Node2D

# Preload forces Godot to parse CharacterMovement before this file,
# making class_name CharacterMovement available for type annotations.
const _PMovement = preload("res://scripts/views/character_movement.gd")
const _DialogView = preload("res://scripts/views/town_dialog_view.gd")
const _LifeTracker = preload("res://scripts/models/life_tracker.gd")
const _ProgressionModel = preload("res://scripts/models/progression_model.gd")
const _SettingsModel = preload("res://scripts/models/settings_model.gd")
const _AudioManager = preload("res://scripts/managers/audio_manager.gd")

# ── References ─────────────────────────────────────────────────────────

@onready var _hp_label: Label = $UI/HPLabel
@onready var _quest_label: Label = $UI/QuestLabel
@onready var _title_label: Label = $UI/StatsTitle
@onready var _dialog_view = $UI/DialogPanel
@onready var _daily_task_list: VBoxContainer = $UI/DailyTaskPanel/VBox/TaskList
@onready var _xp_label: Label = $UI/DailyTaskPanel/VBox/XPLabel
@onready var _settings_panel: Control = $UI/SettingsPanel
@onready var _player: CharacterBody2D = $Player

var _player_stats: PlayerStats
var _quest_manager: QuestManager
var _life_tracker
var _progression
var _settings
var _audio
var _active_npc: NpcController
var _pending_npc: NpcController


# ── Bootstrap ──────────────────────────────────────────────────────────

func _ready() -> void:
	_title_label.add_theme_font_size_override("font_size", 24)
	_player_stats = PlayerStats.new()
	_quest_manager = QuestManager.new()
	_life_tracker = _new_script_object("res://scripts/models/life_tracker.gd")
	_progression = _new_script_object("res://scripts/models/progression_model.gd", [_player_stats, _quest_manager, _life_tracker])
	_settings = _new_script_object("res://scripts/models/settings_model.gd")
	_audio = _new_script_object("res://scripts/managers/audio_manager.gd")
	add_child(_audio)
	_seed_daily_tasks()
	_connect_dialog_buttons()
	_connect_npcs()
	_connect_daily_task_buttons()
	_connect_settings_buttons()
	_dialog_view.hide_dialog()
	_settings_panel.visible = false
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
	_xp_label.text = "XP: %d" % _life_tracker.xp


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
	if npc.life_task_id != "":
		_quest_manager.add_life_task_quest(npc.quest_name, npc.quest_cost, npc.quest_description, npc.life_task_id)
	else:
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


# ── Daily Tasks / Settings ────────────────────────────────────────────

func complete_daily_task(task_id: String, date: String) -> bool:
	var completed: bool = _progression.complete_life_task(task_id, date)
	if completed:
		_audio.play_sfx("complete_task")
	_update_stats()
	return completed


func _seed_daily_tasks() -> void:
	_life_tracker.add_habit("hydrate", "Drink water", 10)
	_life_tracker.add_task("gather_wood", "Gather wood for town", 15)


func _connect_daily_task_buttons() -> void:
	for child in _daily_task_list.get_children():
		if child is Button:
			var button := child as Button
			if not button.pressed.is_connected(_on_daily_task_button_pressed.bind(button.name)):
				button.pressed.connect(_on_daily_task_button_pressed.bind(button.name))


func _connect_settings_buttons() -> void:
	var options := get_node_or_null("UI/DailyTaskPanel/VBox/OptionsButton") as Button
	if options and not options.pressed.is_connected(_on_options_pressed):
		options.pressed.connect(_on_options_pressed)
	var close := get_node_or_null("UI/SettingsPanel/VBox/CloseButton") as Button
	if close and not close.pressed.is_connected(_on_close_settings_pressed):
		close.pressed.connect(_on_close_settings_pressed)


func _on_daily_task_button_pressed(task_id: String) -> void:
	complete_daily_task(task_id, "2026-05-11")


func _on_options_pressed() -> void:
	_settings_panel.visible = true


func _on_close_settings_pressed() -> void:
	_settings_panel.visible = false


func _new_script_object(path: String, args: Array = []):
	var script: GDScript = load(path)
	return Callable(script, "new").callv(args)


# ── Player ─────────────────────────────────────────────────────────────

func get_player() -> CharacterBody2D:
	return _player


func _player_movement() -> CharacterMovement:
	return _player.get_node_or_null("Sprite") as CharacterMovement
