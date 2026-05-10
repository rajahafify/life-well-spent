## PlayerStats — pure business logic for player progression.
## No Node references. No Godot APIs. Pure data + behavior.
class_name PlayerStats
extends Object

const _G = preload("res://scripts/models/game_balance.gd")

# ── State ─────────────────────────────────────────────────────────────

var max_hp: int = 100
var level: int = 1
var state: String = "alive"
var unlocked_facilities: Array[String] = []


# ── Quest ─────────────────────────────────────────────────────────────

func take_quest() -> void:
	pass


func complete_quest() -> void:
	_deduct_hp(_G.QUEST_HP_COST)


func _deduct_hp(amount: int) -> void:
	if state == "dead":
		return
	max_hp = max(max_hp - amount, 0)
	if max_hp <= 0:
		state = "dead"


# ── Rebirth ───────────────────────────────────────────────────────────

func rebirth() -> void:
	max_hp = 100
	level = 1
	state = "alive"
	# Preserves unlocked_facilities
