---
title: Persistence, Audio, Settings, and Scene Transitions
type: reference
tags: [architecture, managers, polish]
sources: [scripts/managers/save_manager.gd, scripts/managers/audio_manager.gd, scripts/models/settings_model.gd, scripts/controllers/scene_transition_controller.gd, tests/specs/save_manager_test.gd, tests/specs/settings_audio_transition_test.gd]
---

# Persistence, Audio, Settings, and Scene Transitions

## Overview
Small system boundaries added for product foundation and polish: save/load serialization, audio request tracking, settings validation, and scene transition requests.

## API
```gdscript
SaveManager.build_save_data(player, quests, life)
SaveManager.apply_save_data(data, player, quests, life)
SaveManager.save_to_file(path, player, quests, life)
SaveManager.load_from_file(path)

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
- SettingsModel stays pure and clamps values.
- AudioManager currently records requested audio names; future work can attach streams/buses.
- SceneTransitionController separates transition requests from callers.

## Test Coverage
- `tests/specs/save_manager_test.gd`: build/apply/file round trip.
- `tests/specs/settings_audio_transition_test.gd`: settings clamp, SFX request, transition request.

## Related
- [LifeTracker](life-tracker.md)
- [ProgressionModel](progression-model.md)
