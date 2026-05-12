## PlayerStats — pure business logic for player progression.
## No Node references. No Godot APIs. Pure data + behavior.
class_name PlayerStats
extends Object

const _G = preload("res://scripts/models/game_balance.gd")

# ── State ─────────────────────────────────────────────────────────────

var max_hp: int = 100
var level: int = 1
var state: String = "alive"
var xp: int = 0
var unlocked_facilities: Array[String] = []
var game_over_requested: bool = false


# ── Quest ─────────────────────────────────────────────────────────────

func take_quest() -> void:
	pass


func complete_quest() -> void:
	_deduct_hp(_G.QUEST_HP_COST)


func award_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount


func unlock_facility(facility_id: String) -> void:
	if facility_id == "":
		return
	if facility_id in unlocked_facilities:
		return
	unlocked_facilities.append(facility_id)


func _deduct_hp(amount: int) -> void:
	if state == "dead":
		return
	max_hp = max(max_hp - amount, 0)
	if max_hp <= 0:
		state = "dead"
		game_over_requested = true


# ── Rebirth ───────────────────────────────────────────────────────────

func rebirth() -> void:
	max_hp = 100
	level = 1
	state = "alive"
	game_over_requested = false
	# Preserves XP and unlocked_facilities


# ── Serialization ─────────────────────────────────────────────────────

func to_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"level": level,
		"state": state,
		"xp": xp,
		"unlocked_facilities": unlocked_facilities.duplicate(),
		"game_over_requested": game_over_requested,
	}


func apply_dict(data: Dictionary) -> void:
	max_hp = int(data.get("max_hp", 100))
	level = int(data.get("level", 1))
	state = str(data.get("state", "alive"))
	xp = int(data.get("xp", 0))
	game_over_requested = bool(data.get("game_over_requested", false))
	unlocked_facilities.clear()
	for facility in data.get("unlocked_facilities", []):
		unlocked_facilities.append(str(facility))
