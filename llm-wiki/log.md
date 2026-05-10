# Wiki Log

## [2026-05-08] init | Wiki initialized

- Created `SCHEMA.md` with proposed schema
- Created `index.md` (empty catalog)
- Created `raw-sources/index.md` (empty registry)

## [2026-05-08] ingest | Game Design Session 1

- Registered `raw-sources/conversations/2026-05-08-game-design-sess1.md`
- Compiled `game-design/game-design.md`
- Updated `index.md`
- Updated `raw-sources/index.md`

## [2026-05-08] ingest | Architecture Decision

- Compiled `architecture/architecture.md` — MVC + SOLID pattern
- Compiled `architecture/spec-driven-dev.md` — Spec-driven development workflow
- Compiled `architecture/test-runner.md` — JSON spec runner
- Updated `index.md`

## [2026-05-08] ingest | Test Runner

- Registered `scripts/managers/test_runner.gd`
- Registered `resources/specs/test_spec.json`
- Compiled `architecture/test-runner.md`
- Updated `index.md`

## [2026-05-10] ingest | QuestManager + TDD enforcement

- Created `architecture/quest-manager.md` — Quest catalog, multi-quest tracking, HP-based affordability
- Updated `architecture/spec-driven-dev.md` — Added TDD enforcement rules
- Updated `index.md` — Added QuestManager page
- Updated `docs/STATUS.md` — QuestManager docs, TDD rules, commit history

## [2026-05-10] update | Minitest-style Test Runner

- Moved test assertions to `tests/test_helper.gd`
- Moved the CI entrypoint to `tests/test_runner.gd` attached to `tests/test_runner.tscn`
- Split playable demo behavior into `scripts/controllers/demo_controller.gd`
- Updated test runner architecture docs

## [2026-05-11] style | Center main menu layout, font sizing, button spacing

- CenterContainer → VBoxContainer with alignment=CENTER, buttons via SHRINK_CENTER size flags
- Buttons: custom_minimum_size Vector2(200, 40)
- Title: 36px font via `add_theme_font_size_override`
- VBoxContainer separation: 16px via `add_theme_constant_override`
- All 64 tests pass

## [2026-05-11] feat | Town Hub + Player Character

- Created `scenes/town_scene.tscn` — town hub with 1280×720 background, player, stats UI
- Fleshed out `scenes/player.tscn` — Sprite2D with player.png LPC atlas (13×21), CircleShape2D (radius 20)
- Attached `player_movement.gd` to player sprite — click-to-move, 8-directional animation
- Created `scripts/controllers/town_scene_controller.gd` — stats display, quest count updates
- Updated `main_menu_controller.gd` — transitions to town_scene.tscn
- Fixed `player_movement.gd` — `get_node_or_null()` for destination marker

## [2026-05-11] feat | Click-to-move for player

- Added `_unhandled_input` handler in `player_movement.gd` for left-click movement
- Screen position converted to world position via `get_global_mouse_position()`
- Added `DestinationMarker` sprite to town scene — shows during movement, hides when idle
- Added `can_move` flag for toggling movement (set by scene controller)

## [2026-05-11] refactor | Codebase review: all issues fixed

- Created `scripts/models/game_balance.gd` — shared constants (QUEST_HP_COST, animation timings)
- Extracted `_deduct_hp()` private method in `player_stats.gd` — `take_quest()` and `complete_quest()` now call it
- Removed default param `current_hp = 100` from `quest_manager.take_quest()` — callers must pass HP explicitly
- Updated `quest_manager_test.gd` — all `take_quest()` calls now pass explicit HP
- Added walking frame advance to `AnimationController.tick()` — `_tick_walking()` advances `walk_frame` each frame
- Updated `animation_controller_test.gd` — walking tick test renamed + expects frame advance
- Moved `player_movement.gd` from `scripts/controllers/` → `scripts/views/` — proper MVC placement
- Integrated `AnimationController` into `PlayerMovement` — removed duplicated LPC constants, delegates frames to model
- Fixed `town_scene_controller.gd` parse error (`const _` → `const _PMovement`)
- Added `_player_stats` + `_quest_manager` instance vars to `TownSceneController` — no more create+free per update
- Added `class_name DemoController` to `demo_controller.gd`
- Updated scene references in `player.tscn` and `test_runner_scene.tscn` for moved script
- Deleted orphan `tests/specs/test_spec.gd.uid`
- Added `PlayerMovement._dir_from_vector()` static utility with spec coverage (10 tests)
- Fixed zero-vector edge case in `_dir_from_vector` (was returning "up" instead of "down")
- Fixed equal-magnitude edge case (was vertical-preferring, now horizontal-preferring per spec)
- Updated docs: STATUS.md, AGENTS.md, quest-manager.md, test-runner.md — all test counts current
- All 74 tests pass

## [2026-05-11] create | Wiki pages for AnimationController and PlayerMovement

- Created `architecture/animation-controller.md`
- Created `architecture/player-movement.md`

## [2026-05-11] fix | PlayerMovement physics-based movement, export marker

- Switched `_process` → `_physics_process` — velocity + `move_and_slide()` via parent CharacterBody2D
- Replaced hardcoded `get_node_or_null` paths with `@export var marker_path: NodePath`
- Snap threshold (5.0) instead of raw distance-per-frame check
- Removed unused `_marker_paths` array
- Updated `architecture/player-movement.md` with new API and physics details
- All 74 tests pass

## [2026-05-11] fix | TDD review fixes: NPC quest null, scene wiring, GameBalance specs

- RED: added `tests/specs/scene_smoke_test.gd`; confirmed failing player/demo scene wiring.
- Added `tests/specs/game_balance_test.gd` coverage for `GameBalance`.
- Fixed `NpcState.current_quest` to clear to `null`.
- Fixed `test_runner_scene.tscn` to use `scripts/views/character_movement.gd`.
- Split `player.tscn` from NPC controller/proximity; root is `Player` with CharacterMovement sprite.
- Tightened `NpcController` and `DemoController` CharacterMovement typing.
- Cleaned QuestManager spec wording for HP-at-cost behavior.
- Created `architecture/game-balance.md`; updated NPC, movement, quest, test-runner wiki pages and index.
- All 98 tests pass.

## [2026-05-11] fix | NPC interaction facing, idle animation, and collision stop

- Created `plans/npc-interaction-animation-fix.md` with TDD acceptance criteria.
- RED: added idle-frame specs, CharacterMovement facing/static specs, NPC controller facing specs, and NPC scene static/marker smoke spec.
- Implemented idle frame cycling in `AnimationController` while preserving direction.
- Added `CharacterMovement.set_facing()` and collision-stop behavior so player animation returns to idle when blocked by solid NPCs.
- Marked NPC sprites static and markerless in `scenes/npc.tscn`.
- Updated `NpcController` to consume click input and face actual player/global position for click/proximity interactions.
- Updated wiki pages for animation, NPC system, and movement.
- Subagents were attempted but child pi provider auth failed (`No API key found for azure-openai-responses`).
- All 105 tests pass.

## [2026-05-11] fix | Visible NPC interaction and proximity range

- RED: added specs for `interacted(npc)` signal payload, NPC collision/talk radii, and town UI conversation feedback.
- Changed `NpcController.interacted` to emit the NPC instance.
- Connected town NPC interaction signals to `TownSceneController._on_npc_interacted()`.
- Interaction now updates `QuestLabel` to `Talking to: <NPC>` so QA has visible feedback.
- Set NPC solid collision radius to 20px and talk/proximity radius to 60px.
- Hardened `CharacterMovement.set_facing()` to initialize animation/frame layout before `_ready` if needed.
- All 108 tests pass.
