---
title: SettingsModel
type: reference
tags: [architecture, models, settings]
sources: [scripts/models/settings_model.gd, tests/specs/settings_audio_transition_test.gd]
---

# SettingsModel

## Overview
Pure model for user options state. Currently tracks master volume and fullscreen flag.

## API
```gdscript
var master_volume: float = 1.0
var fullscreen: bool = false

func set_master_volume(value: float) -> void
func set_fullscreen(value: bool) -> void
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions
- Clamps volume to `0.0..1.0` in model so UI/controller callers cannot store invalid values.
- Serialization mirrors SaveManager-compatible dictionary shape.

## Test Coverage
- `tests/specs/settings_audio_transition_test.gd`: default values and volume clamp.

## Related
- [Persistence, Audio, Settings, and Scene Transitions](persistence-audio-settings.md)
