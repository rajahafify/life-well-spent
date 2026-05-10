# RO-Style NPC Interaction Plan

**Status:** Draft — awaiting implementation.

## Goal
Change NPC interaction from instant debug-style click dialog to Ragnarok Online-style MMO interaction:
- Click NPC from far away → player walks toward NPC first.
- Dialog opens only when player reaches talk range.
- Click NPC inside talk range → dialog opens immediately.
- NPC and player face each other when dialog opens.
- Dialog is modal and locks player movement until closed.

## What "RO-style" Means Here
Ragnarok Online NPC interaction is spatial and menu-driven:
- NPCs are clickable world actors, not remote UI buttons.
- Clicking an NPC outside range causes approach movement.
- Talking starts only within interaction/talk range.
- NPC turns toward player; player faces NPC.
- Dialog appears in a panel with NPC name, text pages, and choices.
- Choices depend on NPC role and quest state.
- Movement is disabled while dialog is open.
- Closing dialog restores movement.

## Acceptance Criteria
1. Clicking an NPC outside talk range does **not** open dialog immediately.
2. Clicking an NPC outside talk range sets player destination to a point near the NPC.
3. When player enters talk range for the pending NPC, movement stops and dialog opens automatically.
4. Clicking an NPC while already inside talk range opens dialog immediately.
5. When dialog opens, NPC faces player and player faces NPC.
6. While dialog is open, player click-to-move is disabled.
7. Closing dialog hides panel and re-enables player movement.
8. NPC name label is visible above each NPC.
9. QuestGiver menu still supports accept/complete quest.
10. Vendor/Guard still show role-specific dialog without quest buttons.
11. Full automated suite passes.

## TDD Plan

### 1. CharacterMovement API
Add specs in `tests/specs/player_movement_test.gd`:
- `test_stop_moving_clears_moving_and_walking_state`
- `test_face_player_updates_frame_direction`
- `test_can_move_false_blocks_move_to`

Implementation target:
- `scripts/views/character_movement.gd`
  - public `stop_moving()` wrapper around internal stop.
  - public `face_target(target_global_pos)` alias if useful.
  - ensure `can_move = false` prevents movement while dialog modal.

### 2. NPC Talk Range / Pending Interaction
Add specs in `tests/specs/npc_controller_test.gd`:
- `test_is_player_in_talk_range_true_inside_radius`
- `test_is_player_in_talk_range_false_outside_radius`
- `test_talk_point_is_offset_from_npc_toward_player`

Implementation target:
- `scripts/controllers/npc_controller.gd`
  - expose `talk_radius: float = 60.0` matching AreaCollision.
  - `is_player_in_talk_range(player_pos: Vector2) -> bool`
  - `talk_point_for(player_pos: Vector2) -> Vector2` returns position just outside solid collision / inside talk radius.

### 3. TownSceneController Approach Flow
Add specs in `tests/specs/town_scene_dialog_test.gd`:
- `test_click_npc_outside_range_sets_pending_npc_without_opening_dialog`
- `test_pending_npc_opens_dialog_when_player_enters_range`
- `test_click_npc_inside_range_opens_dialog_immediately`
- `test_dialog_open_disables_player_movement`
- `test_close_dialog_reenables_player_movement`

Implementation target:
- `scripts/controllers/town_scene_controller.gd`
  - track `_pending_npc: NpcController`.
  - on NPC interaction signal, if player outside range:
    - set pending NPC.
    - move player to `npc.talk_point_for(player.global_position)`.
    - do not show dialog yet.
  - in `_physics_process` or player movement callback/poll:
    - if pending NPC and player inside range, stop player and open dialog.
  - on dialog open:
    - disable player movement (`CharacterMovement.can_move = false`).
    - NPC faces player.
    - player faces NPC.
  - on dialog close:
    - clear pending NPC.
    - enable player movement.

### 4. NPC Name Label
Add scene smoke specs in `tests/specs/scene_smoke_test.gd`:
- `test_npc_scene_has_name_label`
- `test_town_npcs_override_display_names`

Implementation target:
- `scenes/npc.tscn`
  - add `Label` or `Label2D`/Control child above sprite (Godot 2D label approach).
  - ensure text reflects `display_name` on ready.
- `scripts/controllers/npc_controller.gd`
  - `@export var name_label_path: NodePath`.
  - `_ready()` updates name label text.

### 5. Dialog Choice State Regression
Keep/extend specs:
- Accept quest still deducts HP and adds active quest.
- Complete quest still deducts HP and removes active quest.
- Vendor/Guard show dialog without quest buttons.

## Implementation Order
1. RED specs for CharacterMovement stop/face/movement lock.
2. GREEN CharacterMovement API.
3. RED specs for NpcController talk range/talk point/name label.
4. GREEN NpcController + npc scene label.
5. RED specs for TownSceneController pending approach + modal lock.
6. GREEN approach flow.
7. Run full suite.
8. Manual QA in `scenes/town_scene.tscn`.
9. Update `llm-wiki/architecture/npc-system.md`, `player-movement.md`, and `log.md`.
10. Commit referencing new specs.

## Manual QA Steps
1. Click QuestGiver from far away.
   - Expected: player walks toward QuestGiver; dialog does not open immediately.
2. When player reaches talk range.
   - Expected: player stops, dialog opens, both face each other.
3. Close dialog.
   - Expected: dialog hides, player movement restored.
4. Click QuestGiver while already nearby.
   - Expected: dialog opens immediately.
5. Accept quest.
   - Expected: HP 100 → 60, quest count 1 active.
6. Complete quest.
   - Expected: HP 60 → 20, quest count 0 active.
7. Click Vendor/Guard.
   - Expected: dialog opens with role text; no quest accept button.
8. Try clicking ground while dialog open.
   - Expected: player does not move.
9. Confirm NPC names visible above NPCs.

## Risks / Notes
- Headless tests cannot perfectly simulate mouse propagation; prefer controller helper methods for deterministic specs and manual QA for click feel.
- Talk point selection can be simple at first: point along vector from NPC to player at `solid_radius + small_buffer`.
- No pathfinding yet; if obstacles exist later, approach movement may need navigation.
- Dialog pages/portrait/shop UI are future after this spatial interaction loop.

## Related
- `plans/npc-system.md`
- `plans/npc-interaction-animation-fix.md`
- `llm-wiki/architecture/npc-system.md`
- `scripts/controllers/npc_controller.gd`
- `scripts/controllers/town_scene_controller.gd`
- `scripts/views/character_movement.gd`
