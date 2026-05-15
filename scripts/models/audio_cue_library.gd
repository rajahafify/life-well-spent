## AudioCueLibrary - named prototype SFX asset paths.
class_name AudioCueLibrary
extends Object

const CUES := {
	"loot_drop": "res://assets/audio/loot_drop.wav",
	"equip_item": "res://assets/audio/equip_item.wav",
	"quest_reward": "res://assets/audio/quest_reward.wav",
	"guild_unlock": "res://assets/audio/guild_unlock.wav",
	"game_over": "res://assets/audio/game_over.wav",
	"rebirth": "res://assets/audio/rebirth.wav",
	"forest_open": "res://assets/audio/forest_open.wav",
	"apple_use": "res://assets/audio/apple_use.wav",
	"quest_update": "res://assets/audio/quest_update.wav",
	"dialog_next": "res://assets/audio/dialog_next.wav",
	"dialog_close": "res://assets/audio/dialog_close.wav",
	"summary_open": "res://assets/audio/summary_open.wav",
	"new_game": "res://assets/audio/new_game.wav",
	"player_attack": "res://assets/audio/player_attack.wav",
	"enemy_hit": "res://assets/audio/enemy_hit.wav",
	"player_hurt": "res://assets/audio/player_hurt.wav",
	"enemy_defeat": "res://assets/audio/enemy_defeat.wav",
}

const VOLUME_DB := {
	"player_attack": -12.0,
	"enemy_hit": -12.0,
	"player_hurt": -12.0,
	"enemy_defeat": -12.0,
}


static func path_for(sfx_name: String) -> String:
	return str(CUES.get(sfx_name, ""))


static func has_cue(sfx_name: String) -> bool:
	return CUES.has(sfx_name)


static func volume_db_for(sfx_name: String) -> float:
	return float(VOLUME_DB.get(sfx_name, 0.0))
