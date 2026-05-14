---
title: Persistence, Audio, Settings, and Scene Transitions
type: reference
tags: [architecture, managers, polish]
sources: [scripts/managers/save_manager.gd, scripts/managers/profile_system.gd, scripts/managers/audio_manager.gd, scripts/models/settings_model.gd, scripts/controllers/scene_transition_controller.gd, tests/specs/save_manager_test.gd, tests/specs/settings_audio_transition_test.gd]
---

# Persistence, Audio, Settings, and Scene Transitions

## Overview
Small system boundaries added for product foundation and polish: save/load serialization, persistent profile state, audio request tracking, settings validation, and scene transition requests.

## API
```gdscript
SaveManager.build_save_data(player, quests, life)
SaveManager.apply_save_data(data, player, quests, life)
SaveManager.save_to_file(path, player, quests, life)
SaveManager.load_from_file(path)
SaveManager.build_profile_data(player)
SaveManager.apply_profile_data(data, player)
SaveManager.save_profile_to_file(path, player)

ProfileSystem.player()
ProfileSystem.set_profile_path(path)
ProfileSystem.save_profile(path = "")
ProfileSystem.load_profile(path = "")

AudioManager.play_sfx(name)
AudioManager.play_music(track_name)
AudioManager.stop_music()

SettingsModel.set_master_volume(value)
SettingsModel.set_fullscreen(value)

SceneTransitionController.request_transition(scene_path)
SceneTransitionController.execute_transition()
```

## Design Decisions
- SaveManager is manager boundary because it uses `FileAccess` and `JSON`.
- ProfileSystem is the autoload boundary for persistent player profile state. Town reads its `PlayerStats` instance when running in the scene tree.
- SettingsModel stays pure and clamps values.
- AudioManager currently records requested audio names; future work can attach streams/buses.
- SceneTransitionController separates transition requests from callers.

## Test Coverage
- `tests/specs/save_manager_test.gd`: build/apply/file round trip, corrupted/missing file recovery, empty data handling, and profile data preserving Swordsman Guild unlock.
- `tests/specs/profile_system_test.gd`: redirected profile path save/load.
- `tests/specs/settings_audio_transition_test.gd`: settings clamp, SFX request, transition request.

## Related
- [LifeTracker](life-tracker.md)
- [ProgressionModel](progression-model.md)
