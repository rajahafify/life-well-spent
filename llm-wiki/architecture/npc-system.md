---
title: NPC System
type: reference
updated: 2026-05-11
tags: [architecture, game-design]
---

# NPC System

## Overview
Static NPCs for town hub (quest givers, vendors). Reusable CharacterBody2D scene with Sprite2D idle animation, solid collision, proximity Area2D. Uses CharacterMovement view (`is_static=true` for NPCs). Click/proximity interaction consumes click input, emits `interacted(npc)`, faces actual player position, and opens town dialog/quest UI.

## API
**Model (`scripts/models/npc_state.gd`):**
```gdscript
var state: String = "idle"  # idle/interacting
var facing: String = "down"
var current_quest = null

face_player(player_pos: Vector2)
assign_quest(id: String)
clear_quest()
set_interacting(bool)
```

**View (`scripts/views/character_movement.gd` → CharacterMovement):**
```gdscript
@export is_static: bool = false
move_to(target: Vector2)
set_facing(dir: String)
face_player(target_pos: Vector2)
```
Tick anim always, move if not static.

**Controller (`scripts/controllers/npc_controller.gd`):**
```gdscript
signal interacted(npc)
@export character_movement_path: NodePath = ^"Sprite"
@export player_path: NodePath = ^"../Player"
@export var display_name: String = "NPC"
@export var role: String = "generic"
@export_multiline var dialog_text: String = "Hello."
@export var quest_name: String = ""
@export var quest_cost: int = 40
@export_multiline var quest_description: String = ""

interact_with_player(player_global_pos) → state.interacting=true, state.face_player(delta), view.set_facing(state.facing), emit interacted(self)
```

**Town Dialog (`scenes/town_scene.tscn` + `TownSceneController`):**
```gdscript
DialogPanel
  VBox
    NameLabel
    BodyLabel
    Buttons
      AcceptQuestButton
      CompleteQuestButton
      CloseButton

_on_npc_interacted(npc)
_on_accept_quest_pressed()
_on_complete_quest_pressed()
_on_close_dialog_pressed()
```
QuestGiver dialog accepts and completes quests via `QuestManager` + `PlayerStats`; Vendor/Guard show role-specific text without quest controls.

**Scene (`scenes/npc.tscn`):**
CharacterBody2D Npc
├ Sprite2D Sprite (CharacterMovement, player.png)
├ CollisionShape2D Collision (Circle20 solid)
└ Area2D Proximity
  └ CollisionShape2D AreaCollision (Circle60)

## Design Decisions
- Static only (no patrol); NPC Sprite has `is_static=true` and empty marker path.
- Solid collision radius is 20px; talk/proximity Area2D radius is 60px so interaction can trigger before collision blocks movement.
- Reuse player_movement (anim/facing).
- MVC: model pure, view dumb, controller signals.
- Collision solid + Area detect.
- Emits interaction signal with NPC instance; town controller owns dialog/quest UI and model calls.
- Horizontal dir prefer (abs(x)>=y).

## Test Coverage
- `npc_state_test.gd` (14): initial, face_player dirs/edge, quest assign/clear-to-null, interacting.
- `npc_controller_test.gd` (4): explicit player target faces right/up, syncs state/view, emits actor, exposes dialog metadata defaults.
- `scene_smoke_test.gd`: player scene separated from NPC controller; NPC Sprite static and markerless; collision/talk radii; town UI wiring.
- `town_scene_dialog_test.gd` (7): dialog panel, NPC metadata, vendor no quest button, accept/complete quest UI, close behavior.
- Full suite: 115 tests pass.

## Related
- [player-movement.md](player-movement.md)
- [quest-manager.md](quest-manager.md)
- [animation-controller.md](animation-controller.md)