## PlayerStats — pure business logic for player progression.
## No Node references. No Godot APIs. Pure data + behavior.
class_name PlayerStats
extends Object

# ── State ─────────────────────────────────────────────────────────────

var max_hp: int = 100
var level: int = 1
var state: String = "alive"
var unlocked_facilities: Array[String] = []

# ── Quest ─────────────────────────────────────────────────────────────

const QUEST_HP_COST: int = 40


func take_quest() -> void:
	if state == "dead":
		return
	max_hp = max(max_hp - QUEST_HP_COST, 0)
	if max_hp <= 0:
		state = "dead"


func complete_quest() -> void:
	if state == "dead":
		return
	max_hp = max(max_hp - QUEST_HP_COST, 0)
	if max_hp <= 0:
		state = "dead"


# ── Rebirth ───────────────────────────────────────────────────────────

func rebirth() -> void:
	max_hp = 100
	level = 1
	state = "alive"
	# Preserves unlocked_facilities
