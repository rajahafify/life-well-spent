---
title: Main Menu Scene
type: reference
updated: 2026-05-11
tags: [scenes, ui, entry-point]
---

# Main Menu Scene

## Overview
The entry point scene for Life Well Spent. Displays the game title with New Game and Quit buttons. On New Game, transitions to the town hub scene.

## Scene Structure
```
MainMenu (Control)
├── CenterContainer
│   └── UI (VBoxContainer)
│       ├── Title (Label)
│       ├── NewGameButton (Button)
│       └── QuitButton (Button)
```

## Controller: MainMenuController

```gdscript
class_name MainMenuController
extends Control

@onready var _title: Label = $CenterContainer/UI/Title
@onready var _new_game_btn: Button = $CenterContainer/UI/NewGameButton
@onready var _quit_btn: Button = $CenterContainer/UI/QuitButton

func _ready() -> void:
    _title.text = "Life Well Spent"
    _new_game_btn.text = "New Game"
    _quit_btn.text = "Quit"
    _new_game_btn.pressed.connect(_on_new_game_pressed)
    _quit_btn.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/town_hub.tscn")

func _on_quit_pressed() -> void:
    get_tree().quit()
```

## Design Decisions
- **Thin controller:** Only handles button signals. No game logic.
- **Scene transition:** Hardcoded path to `town_hub.tscn`. Will be configurable when GameState model exists.
- **Quit button:** Calls `get_tree().quit()` — standard behavior.

## Specs
- `tests/specs/main_menu_test.gd` — 8 specs covering scene structure and button text
- All 64 tests in suite pass

## Related
- `scenes/town_hub.tscn` — next scene after New Game
- `scripts/models/player_stats.gd` — player state for game session
