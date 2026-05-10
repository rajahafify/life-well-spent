---
title: NPC System
type: reference
updated: 2026-05-11
tags: [architecture, game-design]
---

# NPC System

## Overview
Static NPCs for town hub (quest givers, vendors). Reusable CharacterBody2D scene with Sprite2D idle animation, overhead name label, solid collision, and talk-range Area2D. Uses CharacterMovement view (`is_static=true` for NPCs). Interaction is RO-style: far click queues approach movement to a talk point; dialog opens only in talk range; dialog is modal and locks player movement until closed.

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
@export var talk_radius: float = 60.0
@export var solid_radius: float = 20.0
@export var talk_stop_buffer: float = 24.0
@export var name_label_path: NodePath = ^"NameLabel"

interact_with_player(player_global_pos) → face_toward_player(player_global_pos), emit interacted(self)
face_toward_player(player_global_pos) → state.interacting=true, state.face_player(delta), view.set_facing(state.facing)
is_player_in_talk_range(player_global_pos) -> bool
talk_point_for(player_global_pos) -> Vector2
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

_pending_npc: NpcController
_physics_process(delta)  # opens pending dialog after player reaches talk range
_on_npc_interacted(npc)
_open_dialog(npc)
_on_accept_quest_pressed()
_on_complete_quest_pressed()
_on_close_dialog_pressed()
```
QuestGiver dialog accepts quests for free and charges 40 Max HP on completion via `QuestManager` + `PlayerStats`; Vendor/Guard show role-specific text without quest controls. `_open_dialog()` stops movement, faces NPC/player toward each other, and sets `CharacterMovement.can_move = false`; close restores movement.

**Scene (`scenes/npc.tscn`):**
CharacterBody2D Npc
├ Sprite2D Sprite (CharacterMovement, player.png)
├ Label NameLabel (overhead display name)
├ CollisionShape2D Collision (Circle20 solid)
└ Area2D Proximity
  └ CollisionShape2D AreaCollision (Circle60)

## Design Decisions
- Static only (no patrol); NPC Sprite has `is_static=true` and empty marker path.
- Solid collision radius is 20px; talk/proximity Area2D radius is 60px so interaction can trigger before collision blocks movement.
- Far-click approach point is `solid_radius + talk_stop_buffer`, clamped inside talk radius.
- Dialog is modal: opening calls `stop_moving()` and disables player movement; closing re-enables it.
- Reuse CharacterMovement for player/NPC facing and animation.
- MVC: model pure, view dumb, controller signals.
- Collision solid + Area detect.
- Emits interaction signal with NPC instance; town controller owns dialog/quest UI and model calls.
- Horizontal dir prefer (abs(x)>=y).

## Test Coverage
- `npc_state_test.gd` (14): initial, face_player dirs/edge, quest assign/clear-to-null, interacting.
- `npc_controller_test.gd` (8): explicit player target faces right/up, syncs state/view, emits actor, exposes dialog metadata defaults, talk range true/false, talk point, visible overhead name label.
- `scene_smoke_test.gd`: player scene separated from NPC controller; NPC Sprite static and markerless; collision/talk radii; town UI wiring.
- `town_scene_dialog_test.gd` (13): dialog panel, NPC metadata, vendor no quest button, accept-free/complete-cost quest UI, close behavior, far-click pending approach, automatic open in range, near-click immediate open, modal movement lock, mutual facing.
- Full suite: 126 tests pass.

## Related
- [player-movement.md](player-movement.md)
- [quest-manager.md](quest-manager.md)
- [animation-controller.md](animation-controller.md)