---
title: SettingsModel
type: reference
tags: [architecture, models, settings]
sources: [scripts/models/settings_model.gd, tests/specs/settings_audio_transition_test.gd]
---

# SettingsModel

## Overview
Pure model for user options state. Currently tracks master volume, fullscreen flag, and the gameplay speed preset.

## API
```gdscript
var master_volume: float = 1.0
var fullscreen: bool = false
var game_speed: String = "normal"

func set_master_volume(value: float) -> void
func set_fullscreen(value: bool) -> void
func set_game_speed(value: String) -> void
func game_speed_multiplier() -> float
static func multiplier_for_game_speed(speed_id: String) -> float
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions
- Clamps volume to `0.0..1.0` in model so UI/controller callers cannot store invalid values.
- Game speed is restricted to `normal`, `fast`, or `ultra`, mapped to `1x`, `2x`, and `4x` runtime multipliers.
- Serialization mirrors SaveManager-compatible dictionary shape.

## Test Coverage
- `tests/specs/settings_audio_transition_test.gd`: default values, volume clamp, game speed validation, and multiplier mapping.

## Related
- [Persistence, Audio, Settings, and Scene Transitions](persistence-audio-settings.md)
