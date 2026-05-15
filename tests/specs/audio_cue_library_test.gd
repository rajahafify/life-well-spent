# tests/specs/audio_cue_library_test.gd
# Spec: prototype named sound cues.

class_name TestAudioCueLibrary
extends TestCase

const AUDIO_CUE_LIBRARY := preload("res://scripts/models/audio_cue_library.gd")


func test_core_prototype_sound_cues_have_assets() -> void:
	for cue in ["loot_drop", "equip_item", "quest_reward", "guild_unlock", "game_over", "rebirth", "forest_open", "apple_use", "quest_update", "dialog_next", "dialog_close", "summary_open", "new_game", "player_attack", "enemy_hit", "player_hurt", "enemy_defeat"]:
		assert_true(AUDIO_CUE_LIBRARY.has_cue(cue), "%s should be registered" % cue)
		assert_true(FileAccess.file_exists(AUDIO_CUE_LIBRARY.path_for(cue)), "%s should point to an audio asset" % cue)


func test_battle_sound_cues_are_quieter_than_ui_feedback() -> void:
	for cue in ["player_attack", "enemy_hit", "player_hurt", "enemy_defeat"]:
		assert_eq(-12.0, AUDIO_CUE_LIBRARY.volume_db_for(cue))
	assert_eq(0.0, AUDIO_CUE_LIBRARY.volume_db_for("quest_reward"))
