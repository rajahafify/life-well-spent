# NPC Interaction + Animation Fix Plan

**Status:** Implemented via TDD on 2026-05-11. Superseded by completed NPC dialog/quest UI work. Full suite: 115 tests pass.

## Goal
Fix bugs against `plans/npc-system.md`:
- Player walk animation stops when movement is blocked by NPC collision or click is consumed by NPC.
- NPCs have idle animation.
- NPCs face the player on click/proximity interaction.
- NPCs are static actors and do not drive destination marker state.

## Acceptance Criteria
1. Clicking an NPC triggers NPC interaction and does not also route the click to player movement.
2. Player movement stops if `move_and_slide()` collides before reaching destination.
3. Static NPC sprites do not use the shared `DestinationMarker`.
4. `AnimationController` idle state advances idle frames over time while preserving direction.
5. NPC interaction faces an explicit player/global target, not the mouse fallback for proximity.
6. `NpcState.facing` and `CharacterMovement` direction stay synchronized after interaction.
7. Full suite passes.
8. Interaction emits `interacted(npc)` and town UI shows visible placeholder feedback.
9. NPC solid collision radius is 20px and talk/proximity radius is 60px.

## RED Specs First
1. `tests/specs/animation_controller_test.gd`
   - Add `test_idle_advances_frame_after_interval`.
   - Add/adjust `test_idle_preserves_direction_when_animating`.

2. `tests/specs/player_movement_test.gd`
   - Add static instance tests if possible:
     - `move_to()` ignored when `is_static`.
     - `face_player()` updates frame direction when parent body exists.

3. `tests/specs/npc_controller_test.gd` (new)
   - Instantiate `scenes/npc.tscn` under a root with fake `Player` body.
   - Call controller interaction with player global position.
   - Assert `npc_state.facing` and sprite frame face player.
   - Assert click handler marks viewport input handled (if testable).

4. `tests/specs/scene_smoke_test.gd`
   - Assert NPC scene Sprite `is_static == true`.
   - Assert NPC Sprite marker path is empty or absent from marker updates.
   - Assert collision/talk radii.
   - Assert town scene placeholder interaction label updates.

## Implementation Steps
1. `scripts/models/animation_controller.gd`
   - Implement idle frame timer using `IDLE_CYCLE_INTERVAL` and `IDLE_FRAME_COUNT`.
   - Ensure `stop_walking()` resets to idle frame 0.

2. `scripts/views/character_movement.gd`
   - Add public `set_facing(dir)` or `face_toward(target_pos)` that updates `_anim` and applies frame immediately.
   - In `_physics_process()`, if moving and `body.move_and_slide()` collides, stop walking and clear `moving`.
   - For `is_static`, skip marker visibility updates or hide marker.

3. `scripts/controllers/npc_controller.gd`
   - On click, call `get_viewport().set_input_as_handled()` before `_interact()`.
   - Resolve player global position from body_entered or by finding `../Player` / group fallback.
   - `_interact(target_pos)` calls both `npc_state.face_player(target_pos - global_position)` or equivalent and view facing with same target.
   - Emit `interacted(self)` after state/view update.

4. `scenes/npc.tscn`
   - Set `Sprite.is_static = true`.
   - Set `Sprite.marker_path = NodePath("")` or ensure static sprites do not touch destination marker.

5. `scripts/controllers/town_scene_controller.gd`
   - Connect NPC `interacted(npc)` signals.
   - Update `QuestLabel` with `Talking to: <NPC>` placeholder feedback.

6. Docs/Wiki
   - Update `llm-wiki/architecture/npc-system.md`.
   - Update `llm-wiki/architecture/player-movement.md`.
   - Append `llm-wiki/log.md`.

## Validation
```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```
Expected: `115 tests, 115 passed, 0 failed`.

## Risks
- Scene/unit tests for input-handled state may be hard headless; prefer behavior specs around controller helper methods.
- Godot click propagation may need manual scene validation after automated specs.
