---
title: NPC System
type: reference
tags: [architecture, game-design]
---

# NPC System

## Overview
Static NPCs for town hub (quest givers, vendors). Reusable CharacterBody2D scene with Sprite2D anim, solid collision, proximity Area2D. Uses CharacterMovement view (`is_static=true` for NPCs). Interact click/proximity emits `interacted` and faces player.

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
face_player(target_pos: Vector2)
```
Tick anim always, move if not static.

**Controller (`scripts/controllers/npc_controller.gd`):**
```gdscript
signal interacted()
@export character_movement_path: NodePath = ^"Sprite"

_interact() → npc_state.interacting=true, face_player(mouse), emit interacted
```

**Scene (`scenes/npc.tscn`):**
CharacterBody2D Npc
├ Sprite2D Sprite (CharacterMovement, player.png)
├ CollisionShape2D Collision (Circle20 solid)
└ Area2D Proximity
  └ CollisionShape2D AreaCollision (Circle60)

## Design Decisions
- Static only (no patrol).
- Reuse player_movement (anim/facing).
- MVC: model pure, view dumb, controller signals.
- Collision solid + Area detect.
- Emits interaction signal; dialog/quest UI remains future controller work.
- Horizontal dir prefer (abs(x)>=y).

## Test Coverage
- `npc_state_test.gd` (14): initial, face_player dirs/edge, quest assign/clear-to-null, interacting.
- `scene_smoke_test.gd`: player scene separated from NPC controller.
- Full suite: 98 tests pass.

## Related
- [player-movement.md](player-movement.md)
- [quest-manager.md](quest-manager.md)
- [animation-controller.md](animation-controller.md)