---
title: Town Hub Scene
type: reference
updated: 2026-05-11
tags: [scenes, hub, player]
---

# Town Hub Scene

## Overview
The town hub is the central gameplay area where players interact with the world. Features a 1280×720 room with a player character and stats overlay.

## Scene Structure
```
TownScene (Node2D)
├── Background (ColorRect) — 1280×720, Color(0.15, 0.12, 0.1)
├── UI (CanvasLayer)
│   ├── StatsTitle (Label) — "Stats" title
│   ├── HPLabel (Label) — "HP: 100 / 100"
│   └── QuestLabel (Label) — "Quests: 0 active"
└── Player (CharacterBody2D) — instanced from player.tscn, scale 2×
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
@onready var _player: CharacterBody2D = $Player

func _ready() -> void:
    _title_label.add_theme_font_size_override("font_size", 24)
    _update_stats()

func _update_stats() -> void:
    var ps: PlayerStats = PlayerStats.new()
    _hp_label.text = "HP: %d / %d" % [ps.max_hp, ps.max_hp]
    _quest_label.text = "Quests: 0 active"
    ps.free()

func update_quest_count(count: int) -> void:
    _quest_label.text = "Quests: %d active" % count

func get_player() -> CharacterBody2D:
    return _player
```

## Player Movement (`player_movement.gd`)
- Extends Sprite2D
- **Mouse click-to-move:** Left-click anywhere to set destination
- Screen→world conversion via `get_global_mouse_position()`
- LPC spritesheet: 13 columns × 21 rows, 64×64 cells
- Walk rows: 8-11, Idle: rows 0-3
- Destination marker: shows during movement, hides when idle
- `can_move` flag: toggle movement on/off

## Design Decisions
- **Simple background:** Solid ColorRect for now. Will be replaced with TileMap.
- **Stats overlay:** Absolute positioned labels in top-left corner.
- **Player scale:** 2× for visibility (64px → 128px).
- **Player movement:** Click-to-move with LPC animation rows.

## Specs
- Player scene integration tested via manual play

## Related
- `scripts/models/player_stats.gd` — HP, level, quest state
- `scripts/models/quest_manager.gd` — quest catalog, take/complete lifecycle
- `scripts/controllers/player_movement.gd` — movement + animation
