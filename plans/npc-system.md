# NPC System Implementation Plan

**Status:** Core NPC system complete via TDD. Resource-backed NPC variants, vendor role, and facility role model are implemented; advanced shop/storage UI remains future work.

**Current test baseline:** 152 tests, 152 passed, 0 failed.

**Goal:** NPC system for town hub (quest givers, vendors, etc.). Refactor player movement/animation into reusable Character behavior for Player + NPC. NPCs idle, show overhead names, face player, support RO-style approach-to-talk interaction, and show modal dialog/quest UI.

## Why
- Current foundation now supports world actors.
- Design needs NPCs for quests, facilities, story.
- Reuse: idle anim + facing from shared `CharacterMovement` and `AnimationController`.
- Extensible future: different NPC types (QuestGiver, Vendor, Guard) via resources.

## Inspiration: Ragnarok Online NPC System
RO NPCs are sprite-based (body + head + accessories), clickable with name tag, and drive progression:
- **Dialog:** Text window with NPC portrait, multi-page story, player choices (menu buttons: Yes/No, list options).
- **Quest Giver:** Accept/complete quests via dialog options; updates quest log.
- **Shops:** Buy/sell tabs, item list with price, zeny currency.
- **Services:** Kafra (storage, warp to cities), healers, forges.
- **Behavior:** Idle animation loop (blink, breathe), auto-face player on talk, static or simple paths.
- **Interaction:** Click sprite or press space near; [NPC] label on hover.
- **Collision:** Solid (can't walk through) + talk range.

Incorporate: clickable LPC sprite + face player + collision, basic dialog/choice UI (reuse for quests/shops), quest assignment on talk. Later: shop tabs, storage. Matches "life currency" roguelite loop (NPCs gate facilities).

## Requirements (Acceptance Criteria)

| # | Criterion | Status |
|---|-----------|--------|
| 1 | NPC as reusable scene/component (Sprite2D + anim + CollisionShape/Area2D). | Done |
| 2 | Static only (no movement/patrol). Idle anim + 4-dir facing. | Done |
| 3 | NPCs in town_scene: 3 static examples (quest giver, vendor, guard). | Done |
| 4 | Interact: click or proximity → `interacted(npc)` signal + visible dialog/quest UI. | Done |
| 5 | Face player: auto turn to face on interact or enter area. | Done |
| 6 | Collision: solid body blocks player + wider Area2D talk range. No pathfinding. | Done |
| 7 | Pure logic in models where possible (`NpcState`). | Done |
| 8 | Specs first: model + integration tests. | Done |
| 9 | Follows player camera, no perf hit. | Done for current static actors |

## Implemented Architecture

### Model
`scripts/models/npc_state.gd`

Pure state:
```gdscript
var state: String = "idle"
var facing: String = "down"
var current_quest = null

func face_player(player_delta: Vector2) -> void
func assign_quest(quest_id: String) -> void
func clear_quest() -> void
func set_interacting(interacting: bool) -> void
```

### View
`scripts/views/character_movement.gd`

Reusable Sprite2D movement/facing/animation view for player and NPCs:
```gdscript
@export var move_speed: float = 200.0
@export var is_static: bool = false
@export var marker_path: NodePath = ^"../../DestinationMarker"

func move_to(target: Vector2) -> void
func set_facing(dir: String) -> void
func face_player(target_pos: Vector2) -> void
func face_target(target_pos: Vector2) -> void
func stop_moving() -> void
```

Behavior:
- Player: click-to-move, marker, collision stop.
- NPC: `is_static = true`, marker path empty, idle animation only.
- Delegates frame math to `AnimationController`.

### Controller
`scripts/controllers/npc_controller.gd`

Thin glue:
```gdscript
signal interacted(npc)
@export var character_movement_path: NodePath = ^"Sprite"
@export var player_path: NodePath = ^"../Player"

func interact_with_player(player_global_pos: Vector2) -> void
func face_toward_player(player_global_pos: Vector2) -> void
func is_player_in_talk_range(player_global_pos: Vector2) -> bool
func talk_point_for(player_global_pos: Vector2) -> Vector2
```

Behavior:
- Click on NPC consumes input via `get_viewport().set_input_as_handled()`.
- Proximity `body_entered` interacts when body name is `Player`.
- Faces actual player/global position, not mouse fallback.
- Syncs `NpcState.facing` and `CharacterMovement` frame direction.
- Emits `interacted(self)`.
- Exposes talk range and talk point helpers for pending approach flow.

### Scene
`scenes/npc.tscn`

```text
CharacterBody2D Npc (NpcController)
├ Sprite2D Sprite (CharacterMovement, is_static=true, marker_path="")
├ Label NameLabel (overhead display name)
├ CollisionShape2D Collision (Circle radius 20 solid)
└ Area2D Proximity
  └ CollisionShape2D AreaCollision (Circle radius 60 talk range)
```

`scenes/town_scene.tscn` includes:
- `QuestGiver`
- `Vendor`
- `Guard`

`TownSceneController` connects NPC `interacted(npc)` signals and shows `UI/DialogPanel` with NPC metadata and quest controls. Far NPC clicks set `_pending_npc` and move the player to `npc.talk_point_for(player.global_position)`; dialog opens only once the player enters talk range. QuestGiver interactions can accept quests for free and complete quests for a 40 Max HP cost through `QuestManager` + `PlayerStats`.

```gdscript
func _physics_process(delta: float) -> void
func _on_npc_interacted(npc: NpcController) -> void
func _open_dialog(npc: NpcController) -> void
func _on_accept_quest_pressed() -> void
func _on_complete_quest_pressed() -> void
func _on_close_dialog_pressed() -> void
```

## TDD Coverage

Implemented specs:
- `tests/specs/npc_state_test.gd` — model state, facing, quest assignment/clear, interaction state.
- `tests/specs/npc_controller_test.gd` — explicit player target faces right/up, state/view sync, signal emits NPC instance, talk range/talk point helpers, overhead name label.
- `tests/specs/player_movement_test.gd` — direction math, static movement guard, `set_facing()` frame update, `stop_moving()`, `face_target()`, movement lock.
- `tests/specs/animation_controller_test.gd` — idle frame cycling, walking frame advance, direction preservation.
- `tests/specs/scene_smoke_test.gd` — player/NPC scene wiring, NPC static+markerless, collision/talk radii, town interaction signal wiring.
- `tests/specs/town_scene_dialog_test.gd` — dialog panel visibility, NPC metadata, free quest accept, completion HP cost, HP/quest label updates, close behavior, far-click pending approach, near-click immediate dialog, modal movement lock, mutual facing.

Validation command:
```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```

Current expected output:
```text
126 tests, 126 passed, 0 failed
```

## Completed Implementation History
1. RED: `npc_state_test.gd` for pure NPC state.
2. GREEN: `NpcState` model.
3. Refactor: `player_movement.gd` → `character_movement.gd` shared view.
4. Added `scenes/npc.tscn` and three NPCs in town scene.
5. Fixed interaction bugs:
   - Click NPC consumes input.
   - Player animation stops on NPC collision.
   - NPC idle animation cycles.
   - NPC faces real player position.
   - NPC static sprites do not touch destination marker.
6. Added visible placeholder interaction feedback in town UI.
7. Added dialog panel, NPC metadata exports, quest accept/complete buttons, and HP/quest UI updates. Quest acceptance is free; quest completion costs 40 Max HP.
8. Wiki updated and commits made.
9. Added RO-style pending approach interaction, mutual facing, modal movement lock, and overhead NPC name labels.

## Remaining Future Work

Core NPC system is complete. Future enhancements are outside this plan's current acceptance criteria:
- Hover highlight/name emphasis.
- Dedicated `NPCResource` data assets instead of scene export overrides.
- Vendor/shop UI.
- Facility/service NPC behaviors.
- Portraits and multi-page dialog.
- Space/keyboard interaction near NPC.

## Related
- `plans/npc-interaction-animation-fix.md` — completed bugfix plan for interaction/facing/idle/collision.
- `llm-wiki/architecture/npc-system.md`
- `llm-wiki/architecture/player-movement.md`
- `llm-wiki/architecture/animation-controller.md`
- `QuestManager` — future quest accept/complete wiring.
