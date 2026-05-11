---
title: Town Hub Scene
type: reference
updated: 2026-05-11
tags: [scenes, hub, player]
---

# Town Hub Scene

## Overview
The town hub is the central gameplay area where players interact with the world. Features a 1280×720 room with a player character, stats overlay, daily task panel, settings panel, static NPCs, RO-style approach-to-talk interaction, modal dialog/quest UI, and deterministic cleanup for owned model objects.

## Scene Structure
```
TownScene (Node2D)
├── Background (ColorRect) — 1280×720, Color(0.15, 0.12, 0.1)
├── UI (CanvasLayer)
│   ├── StatsTitle (Label) — "Stats" title
│   ├── HPLabel (Label) — "HP: 100 / 100"
│   ├── QuestLabel (Label) — "Quests: 0 active"
│   ├── DailyTaskPanel (PanelContainer) — task buttons + XP label
│   ├── SettingsPanel (PanelContainer) — options overlay
│   └── DialogPanel (PanelContainer, TownDialogView) — NPC name/body + quest buttons
├── Player (CharacterBody2D) — instanced from player.tscn, scale 2×
├── DestinationMarker (Sprite2D)
├── Camera2D
├── QuestGiver (NpcController)
├── Vendor (NpcController)
└── Guard (NpcController)
```

## Player Scene (`player.tscn`)
```
Player (CharacterBody2D)
├── Sprite (Sprite2D) — player.png, hframes=13, vframes=21, script=player_movement.gd
└── CollisionShape2D — CircleShape2D, radius=20
```

## Controller: TownSceneController

```gdscript
class_name TownSceneController
extends Node2D

@onready var _hp_label: Label = $UI/HPLabel
@onready var _quest_label: Label = $UI/QuestLabel
@onready var _title_label: Label = $UI/StatsTitle
@onready var _dialog_view = $UI/DialogPanel
@onready var _daily_task_list: VBoxContainer = $UI/DailyTaskPanel/VBox/TaskList
@onready var _xp_label: Label = $UI/DailyTaskPanel/VBox/XPLabel
@onready var _settings_panel: Control = $UI/SettingsPanel
@onready var _player: CharacterBody2D = $Player

func _ready() -> void:
    _title_label.add_theme_font_size_override("font_size", 24)
    _connect_dialog_buttons()
    _connect_npcs()
    _dialog_view.hide_dialog()
    _update_stats()

func _physics_process(delta) -> void:
    # If pending NPC is now in range, stop movement and open dialog.

func _on_npc_interacted(npc) -> void:
    # Far: set _pending_npc and move player to npc.talk_point_for(player_pos)
    # Near: open dialog immediately.

func _open_dialog(npc) -> void:
    # Stop movement, face player/NPC, disable CharacterMovement.can_move.
    # Delegates dialog labels/buttons to TownDialogView.show_dialog().

func _on_close_dialog_pressed() -> void:
    # Hide dialog, clear active/pending NPC, restore movement.

func complete_daily_task(task_id, date) -> bool:
    # Complete LifeTracker task through ProgressionModel, play SFX, refresh XP/quest/HP labels.

func _on_options_pressed() -> void:
    # Show settings panel.

func get_player() -> CharacterBody2D:
    return _player

func _notification(NOTIFICATION_PREDELETE) -> void:
    # Frees owned PlayerStats, QuestManager, LifeTracker, ProgressionModel, and SettingsModel.
```

## Player Movement (`player_movement.gd`)
- Extends Sprite2D
- **Mouse click-to-move:** Left-click anywhere to set destination
- Screen→world conversion via `get_global_mouse_position()`
- LPC spritesheet: 13 columns × 21 rows, 64×64 cells
- Walk rows: 8-11, Idle: rows 0-3
- Destination marker: shows during movement, hides when idle
- `can_move` flag: toggle movement on/off

## Dialog View (`scripts/views/town_dialog_view.gd`)
- Extends `PanelContainer` and is attached to `UI/DialogPanel`.
- Owns dialog presentation only: name/body labels, button visibility, panel hide/show.
- Emits `accept_quest_requested`, `complete_quest_requested`, and `close_requested` so `TownSceneController` keeps quest orchestration.
- Provides `show_dialog(display_name, body_text, can_offer_quest, has_active_quest)`, `configure_buttons()`, `set_body()`, `hide_dialog()`, and `is_open()`.

## Design Decisions
- **Simple background:** Solid ColorRect for now. Will be replaced with TileMap.
- **Stats overlay:** Absolute positioned labels in top-left corner.
- **Daily task panel:** Buttons call `complete_daily_task()` and update XP via `LifeTracker` + `ProgressionModel`.
- **Settings panel:** Lightweight options overlay; model validation lives in `SettingsModel`.
- **Player scale:** 2× for visibility (64px → 128px).
- **Player movement:** Click-to-move with LPC animation rows.

## Specs
- `tests/specs/town_scene_dialog_test.gd` covers dialog visibility, `TownDialogView` scene wiring, NPC metadata, quest accept/complete, pending approach, modal movement lock, close restore, mutual facing, daily task UI, XP update, and settings panel opening.
- `tests/specs/scene_smoke_test.gd` covers town NPC interaction wiring.

## Related
- `scripts/models/player_stats.gd` — HP, level, quest state
- `scripts/models/quest_manager.gd` — quest catalog, take/complete lifecycle
- `scripts/models/life_tracker.gd` — daily tasks, habits, completions, streaks, XP
- `scripts/models/progression_model.gd` — task completion rewards, linked quest completion, facility unlocks
- `scripts/views/character_movement.gd` — movement + animation
- `scripts/views/town_dialog_view.gd` — dialog panel presentation + button signals
