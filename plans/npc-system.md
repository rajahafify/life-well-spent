# NPC System Implementation Plan

**Status:** Draft — approval required. No code/spec yet.

**Goal:** NPC system for town hub (quest givers, vendors, etc.). Refactor player movement/animation into reusable Character base for Player + NPC (Sprite2D or Body). NPCs idle/walk, face player, interact on click/near, show quest panel.

## Why
- Current: only player. No world actors.
- Design: NPCs for quests, facilities, story.
- Reuse: idle anim + facing (from player code). No movement needed.
- Extensible: different NPC types (QuestGiver, Vendor) via resources.

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
1. NPC as reusable scene/component (Sprite2D + anim + CollisionShape/Area2D).
2. Static only (no movement/patrol). Idle anim + 4-dir facing.
3. NPCs in town_scene: 3 static examples (quest giver, vendor, guard).
4. Interact: click or proximity (Area2D) → signal "interacted", show dialog/quest UI.
5. Face player: auto turn to face on interact or enter area.
6. Collision: solid body (blocks player movement) + Area for detection. No pathfinding.
7. Pure logic in models where possible (e.g. NPCState).
8. Specs first: model + integration tests.
9. Follows player camera, no perf hit.

## Architecture (Refactor + New)
**Refactor:**
- Rename `player_movement.gd` → `character_movement.gd` (or keep + base).
- Create `scripts/models/character.gd` (pure: state, direction, position? or keep view).
- Better: keep views separate. New `scripts/views/character_view.gd` base? Or composition.

**Chosen (MVC + reuse):**
- **Model:** `scripts/models/npc_state.gd` (pure: idle/walk, facing, quest ref). Extend or compose with PlayerStats?
- **View:** Refactor `player_movement.gd` to `character_movement.gd` (generic Sprite2D idle/anim/facing; drop move_to). Player uses it. New `npc.tscn` (Sprite2D + CollisionShape2D solid + Area2D proximity).
- **Controller:** `scripts/controllers/npc_controller.gd` (thin: input for interact, face logic, patrol).
- Reuse: AnimationController + movement logic shared via script attach or inheritance (GDScript allows extends).
- Player stays CharacterBody2D + Sprite child (movement on sprite for now, or move script to body).
- NPC: simple Sprite2D (no body yet) or CharacterBody2D for consistency.

**Why?**
- SRP: movement/anim reusable.
- LSP: Player/NPC both "Characters".
- ISP: small interfaces.
- Future: enemies extend same.

## Files
- `plans/npc-system.md` (this).
- `scripts/models/npc_state.gd` (new, pure).
- `tests/specs/npc_state_test.gd` (new spec, RED first).
- `scripts/views/character_movement.gd` (refactor from player_movement.gd).
- `scenes/npc.tscn` (new, reusable).
- `scripts/controllers/npc_controller.gd` (new).
- Update `scenes/player.tscn`, `town_scene.tscn` (add NPCs, attach).
- Update `player_movement.gd` references (or delete after refactor).
- `llm-wiki/architecture/npc-system.md` (post GREEN).
- Update STATUS.md, log.md, index.md.

## TDD Workflow
1. **RED** — Write `npc_state_test.gd` (model behaviors: state, face, quest).
2. **GREEN** — Minimal `npc_state.gd`.
3. **REFACTOR** — Extract common from player_movement into character_movement; update player.
4. Add integration spec for view/controller.
5. Scene + attach.
6. Full suite pass.
7. Wiki + commit (ref spec).

## Spec Outline (npc_state_test.gd)
```gdscript
class_name TestNpcState
extends TestCase

var npc: NpcState

func setup(): npc = NpcState.new()

func test_initial_state_idle():
    assert_eq("idle", npc.state)

func test_face_player():
    npc.face_player(Vector2(100,0))  # player right of npc
    assert_eq("right", npc.facing)

func test_assign_quest():
    npc.assign_quest("fetch_wood")
    assert_eq("fetch_wood", npc.current_quest)
```

## Implementation Steps (Post-Approval)
1. Create NpcState model (state machine: idle/walk/interact, facing dir, quest_id).
2. Refactor player_movement.gd → character_movement.gd (generic, no player-specific).
   - Keep move_to, tick anim, _dir_from_vector.
   - Add face_toward(target_pos).
3. Update player.tscn / movement attach (or keep name alias).
4. Create npc.tscn: Sprite2D (LPC), CollisionShape2D (solid, mask=player), Area2D (talk range ~60px), attach character_movement (static) + npc_controller.
5. NpcController: _ready set idle anim, on Area entered or click → face player (set_direction), emit interacted.
6. TownSceneController: place 3 static NPCs, connect interacted → open dialog/quest UI.
7. Test click + proximity in editor (face + signal).
8. Update docs/wiki.
9. Commit.

## Design Details
- **Facing:** 4-dir. On interact or Area enter: set_direction toward player global pos.
- **Interact:** Click (unhandled_input) or Area2D body_entered + prompt. Signal `interacted(npc)`.
- **Collision:** CollisionShape2D (solid, prevents player overlap) + Area2D (detection radius). No movement code.
- **Quest link:** NpcState.quest_id; on interact → QuestManager / dialog.
- **Reuse:** LPC + AnimationController (idle only). Shared with player.
- **Perf:** No _process/_physics (static). Only _ready + signals.
- **Future:** NPCResource (name, portrait, quests list, shop items).

## Related
- `PlayerMovement` / `TownSceneController` — interact hook.
- `QuestManager` — assign/complete via NPC.
- `AnimationController` — shared.
- Design: facilities/NPC interaction.

**Approval checklist:**
- [ ] Refactor scope clear (player → character).
- [ ] Specs cover model + reuse.
- [ ] No code written.
- [ ] Fits SOLID/MVC.

Approve → start RED spec.