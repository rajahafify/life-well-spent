## ProfileSystem - persistent player profile boundary.
extends Node

const PLAYER_STATS_SCRIPT := preload("res://scripts/models/player_stats.gd")
const SAVE_MANAGER_SCRIPT := preload("res://scripts/managers/save_manager.gd")
const PROFILE_PATH := "user://life_well_spent_profile.json"

var _player: PlayerStats = PLAYER_STATS_SCRIPT.new()
var _save_manager: SaveManager = SAVE_MANAGER_SCRIPT.new()


func _ready() -> void:
	load_profile()


func _exit_tree() -> void:
	if _player:
		_player.free()
		_player = null
	if _save_manager:
		_save_manager.free()
		_save_manager = null


func player() -> PlayerStats:
	return _player


func save_profile(path: String = PROFILE_PATH) -> bool:
	return _save_manager.save_profile_to_file(path, _player)


func load_profile(path: String = PROFILE_PATH) -> bool:
	var data := _save_manager.load_from_file(path)
	if data.is_empty():
		return false
	_save_manager.apply_profile_data(data, _player)
	return true


func reset_for_tests() -> void:
	if _player:
		_player.free()
	_player = PLAYER_STATS_SCRIPT.new()
