# Wiki Log

## [2026-05-12] decision | Make Life the combat health resource

- Corrected prototype docs: combat now damages current Life, while quests/progression reduce Max Life.
- Removed Combat HP wording from prototype combat, run state, Field, inventory, UI, Town, and system docs.
- Updated combat-system wiki and index to describe current Life damage and Max Life pressure.
- Design consequence: spending Max Life for progress makes future combat harder; preserving Max Life improves combat survivability but blocks progression.

## [2026-05-12] change | Update Field enemy target set

- Changed Field grassland enemy pool from Chick/Rabbit/Slime to Slime/Bat/Rat (`slime_spiked`, `bat`, `rat`).
- Updated prototype Field docs, combat docs, game systems docs, biome wiki, Field scene wiki, and wiki index.
- Added RED biome spec first, then updated `BiomeDefinition.field_grassland()`.
- Validation: `223 tests, 223 passed, 0 failed`.

## [2026-05-12] fix | Defer gateway scene changes outside physics callbacks

- Updated Town and Field gateway controllers to call deferred scene-change helpers from `body_entered` transitions.
- Added specs covering the deferred transition path for Town -> Field and Field -> Town gateways.
- Updated `scenes/town-hub.md`, `scenes/field.md`, and `index.md` with the gateway transition behavior note.
- Validation: `204 tests, 204 passed, 0 failed`; MCP main-scene play reports no errors.

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

## [2026-05-11] feat | Complete NPC dialog and quest UI

- Attempted planner/scout subagents for NPC system completion; both failed due child pi provider auth (`No API key found for azure-openai-responses`).
- RED: added `tests/specs/town_scene_dialog_test.gd` and NPC metadata coverage.
- Added NPC metadata exports: display name, role, dialog text, quest fields.
- Added `DialogPanel` UI to `town_scene.tscn` with name/body labels and Accept/Complete/Close buttons.
- `TownSceneController` now connects NPC interactions to dialog UI and wires QuestGiver accept/complete to `QuestManager` + `PlayerStats`.
- Vendor/Guard show dialog without quest controls.
- Updated `plans/npc-system.md`, `plans/npc-interaction-animation-fix.md`, and NPC wiki docs.
- All 115 tests pass.

## [2026-05-11] feat | RO-style NPC approach interaction

- RED: added specs for CharacterMovement stop/facing/move lock, NpcController talk range/talk point/name label, and TownSceneController pending approach/modal dialog flow.
- Added `CharacterMovement.stop_moving()` and `face_target()` for dialog control.
- Added NPC talk helpers: `talk_radius`, `solid_radius`, `talk_stop_buffer`, `is_player_in_talk_range()`, and `talk_point_for()`.
- Added overhead `NameLabel` to `scenes/npc.tscn`; `NpcController._ready()` syncs it from `display_name`.
- Changed town interaction to RO-style: far click moves player toward NPC, pending dialog opens inside talk range, near click opens immediately.
- Dialog now stops movement, disables click-to-move while open, faces player/NPC toward each other, and restores movement on close.
- Updated `plans/ro-style-npc-interaction.md`, `architecture/npc-system.md`, `architecture/player-movement.md`, and `scenes/town-hub.md`.
- All 128 tests pass.

## [2026-05-11] fix | Quest HP cost moves from accept to complete

- RED: updated PlayerStats, QuestManager, and TownScene dialog specs to assert accepting a quest costs no HP.
- Changed `PlayerStats.take_quest()` to no-op and kept `complete_quest()` as 40 Max HP cost.
- Changed `QuestManager.take_quest()` to ignore HP affordability; it fails only when no quest is available.
- Updated QuestGiver UI flow: accept keeps HP at 100; complete changes HP 100 → 60 and removes active quest.
- Updated game-design, quest-manager, NPC, and plan docs.
- Manual QA passed in `scenes/town_scene.tscn`: far/near NPC interaction, modal movement lock, free accept, 40 HP completion cost, Vendor/Guard dialogs, and name labels.
- All 126 tests pass.

## [2026-05-11] refactor | Extract TownDialogView from TownSceneController

- Deleted `reviews/solid-1.md` per request.
- RED: added TownScene dialog specs for `TownDialogView` scene wiring and `show_dialog()` presentation API.
- Created `scripts/views/town_dialog_view.gd` for dialog labels, panel visibility, button visibility, and button request signals.
- Attached `TownDialogView` to `scenes/town_scene.tscn` `UI/DialogPanel`.
- Refactored `TownSceneController` to delegate dialog presentation while keeping quest orchestration and movement lock behavior.
- Updated `scenes/town-hub.md`, `architecture/npc-system.md`, and `index.md`.
- All 128 tests pass.

## [2026-05-11] feat | Life tracking foundation and TODO completion

- RED: added specs for LifeTracker, SaveManager, NpcDefinition, ProgressionModel, settings/audio/scene transitions, and town daily task UI.
- Created `scripts/models/life_tracker.gd` for tasks, habits, daily completions, streaks, XP, and serialization.
- Created `scripts/models/progression_model.gd` for task completion rewards, linked quest completion, HP spend, and facility unlock rules.
- Created `scripts/models/npc_definition.gd` plus resource examples in `resources/npc_definitions/` for quest giver, vendor, and facility NPC roles.
- Created `scripts/managers/save_manager.gd` and `scripts/managers/audio_manager.gd`.
- Created `scripts/models/settings_model.gd` and `scripts/controllers/scene_transition_controller.gd`.
- Added daily task and settings UI to `scenes/town_scene.tscn`; `TownSceneController` now seeds tasks, completes tasks, updates XP, and plays SFX request.
- Updated `QuestManager` and `PlayerStats` serialization/progression APIs.
- Disabled GDAI MCP autoload/editor plugin in `project.godot` to remove headless `gdaimcp` capture error.
- Added `README.md`, `assets/task_complete.svg`, CI output checking, and updated `todo.md`.
- Created wiki pages: `architecture/player-stats.md`, `architecture/life-tracker.md`, `architecture/progression-model.md`, `architecture/npc-definition.md`, `architecture/settings-model.md`, `architecture/persistence-audio-settings.md`.
- Updated `scenes/town-hub.md`, plan docs, and index.
- All 152 tests pass.

## [2026-05-11] docs | QA pass and commit preparation

- Updated `docs/STATUS.md` with current MVP state, QA result, implemented feature list, and remaining production work.
- Updated `todo.md` to distinguish complete, MVP/stub, and open items.
- Manual QA marked pass for main menu, town movement, NPC dialog, quest accept/complete, daily task XP, and settings panel.
- Known cleanup warnings remain documented as non-blocking MVP issues.

## [2026-05-11] fix | Guard GDAI MCP runtime in headless tests

- RED: added `tests/specs/gdai_mcp_runtime_guard_test.gd` for headless skip, non-headless allow, and autoload path.
- Created `scripts/managers/gdai_mcp_runtime_guard.gd` wrapper around `GDAIRuntimeServer` startup.
- Re-enabled GDAI MCP plugin/autoload in `project.godot`, pointing autoload to the guard.
- Headless tests no longer emit `ERROR: Capture not registered: 'gdaimcp'` while editor MCP remains enabled.
- Created `architecture/gdai-mcp-runtime-guard.md`; updated index, todo, and status docs.
- All 155 tests pass.

## [2026-05-11] fix | Remove Godot cleanup leaks

- Fixed owned model cleanup in `CharacterMovement` (`AnimationController`) via `NOTIFICATION_PREDELETE`.
- Fixed owned model cleanup in `CameraController` (`CameraModel`) via `NOTIFICATION_PREDELETE`.
- Fixed owned model cleanup in `TownSceneController` (`PlayerStats`, `QuestManager`, `LifeTracker`, `ProgressionModel`, `SettingsModel`) via `NOTIFICATION_PREDELETE`.
- Tightened CI output check to fail on any Godot `ERROR:` or `WARNING:` after cleanup warnings were removed.
- Updated `todo.md`, `docs/STATUS.md`, `architecture/player-movement.md`, and `scenes/town-hub.md`.
- Full verbose suite: `155 tests, 155 passed, 0 failed`, no leak/resource warnings.

## [2026-05-11] refactor | Remove legacy demo scene/controller

- RED: changed `tests/specs/scene_smoke_test.gd` to assert `test_runner_scene.tscn` and `demo_controller.gd` stay removed; confirmed failure while files still existed.
- Deleted `scenes/test_runner_scene.tscn`, `scripts/controllers/demo_controller.gd`, and orphan `scripts/controllers/demo_controller.gd.uid`.
- Updated current docs/wiki references to remove DemoController as active architecture.
- Updated `docs/STATUS.md` to reflect no-warning validation and legacy demo removal.

## [2026-05-11] fix | Remove test runner shadow warning

- Renamed `_find_test_methods()` local `name` variable to `method_name` to avoid shadowing `Node.name` during GDScript reload.
- Renamed `AudioManager.play_sfx(name)` parameter to `sfx_name` to avoid `Node.name` shadow warning.
- Updated `architecture/test-runner.md` successful output example to current 155-test suite.

## [2026-05-11] docs | Prototype systemic design and art direction

- Created `prototype-checklists.md` with systemic design checklist, component inventory, rules, permissions, restrictions, conditions, and primitive/SVG art direction.
- Created `prototype/components/` one-page specs for Town, Run State, Starter Area, Forest Gate, Swordsman Guild Quest, Inventory, Combat, UI, and Rebirth.
- Created `llm-wiki/game-design/prototype-systemic-design.md` and updated wiki index.

## [2026-05-11] feat | Prototype Town first slice

- RED: added `tests/specs/town_prototype_test.gd` for Town root/class naming, buildings, NPCs, dialog copy, reborn prompt, and Starter Area Portal.
- Rewrote `scenes/town_scene.tscn` as first-slice Town: Shop, Swordsman Guild, Blacksmith, Guildmaster, Shopkeeper, Smith, reborn prompt, dialog panel, and glowing portal.
- Rewrote `scripts/controllers/town_scene_controller.gd` as `class_name Town`, thin glue for worldbuilding NPC dialog and portal transition request.
- Updated `tests/specs/town_scene_dialog_test.gd` and `tests/specs/scene_smoke_test.gd` for first-slice systemic Town behavior.
- Updated `prototype/components/town.md`, removed duplicate `prototype/town.md`, and updated `scenes/town-hub.md` wiki page.
- Completed pre-Starter Town behavior: 1920×1080 viewport, RO-style camera follow, click-to-move while dialog is closed, world primitives ignore mouse so ground clicks move, dialog blocks movement, far NPC click approaches before dialog, paged NPC dialog with Next/Close, Player entering Starter Area Portal shows Yes/No prompt, No hides it, and Yes records Starter Area target path.
- Generated distinct LPC sprites for Guildmaster, Shopkeeper, and Smith using `tools/lpc-sprite-gen` and wired them into `scenes/town_scene.tscn`.
- Scaled Town NPC instances to `Vector2(2, 2)` so they match player size.
- Enlarged dialog typography for 1080p and moved NPC face portrait above the dialog box using cropped LPC spritesheet face frame.
- Reworked idle animation to use calm standing walk-row frames instead of LPC spellcast/prayer frames; Town NPCs use varied idle timing for desync.
- Hid NPC overhead name labels by default; NPC names remain in dialog.
- Validation: `173 tests, 173 passed, 0 failed`; MCP play current scene reports no errors.
- Manual QA passed: ground click movement, RO-style NPC approach, paged dialog Next/Close, dialog movement lock, camera follow, and portal Yes/No prompt.
- Created `prototype/game-systems.md` as append-only system inventory using systemic design terms: verbs, components, resources, rules, and conditions.
- Added `prototype/components/Field.md` and `prototype/field-development-decisions.md` documenting Field terminology, real combat scope, direct gateway transitions, model-first implementation order, Guard LPC sprite, and SVG/primitive monsters.

## [2026-05-11] feat | Playable Field MVP

- RED: added specs for gateway, enemy, combat, respawn, NPC placement, biome, Field scene, and direct Town → Field gateway behavior.
- Created pure models: `GatewayDefinition`, `EnemyDefinition`, `CombatSystem`, `RandomEnemyRespawnSystem`, `NpcPlacement`, and `BiomeDefinition`.
- Created `scenes/field.tscn` and `scripts/controllers/field.gd` with click movement, camera follow, direct Town gateway, blocked Forest gateway, Forest Guard dialog, Chick/Rabbit/Slime placeholders, and click-attack combat.
- Updated Town gateway from Starter Area prompt flow to direct Field transition.
- Generated `assets/npcs/forest_guard.png` with local LPC sprite generator.
- Updated prototype docs and wiki pages for new models, Field scene, and Town gateway behavior.
- Validation: `202 tests, 202 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] art | SVG enemy placeholders for Field

- RED: added `tests/specs/field_scene_test.gd` coverage requiring Chick/Rabbit/Slime SVG art resources.
- Created `assets/enemies/chick.svg`, `assets/enemies/rabbit.svg`, and `assets/enemies/slime.svg` plus import metadata.
- Replaced Field enemy `ColorRect` visuals with `TextureRect` SVG visuals while preserving mouse-filter ignore behavior.
- Updated Field prototype docs and scene wiki.
- Validation: `203 tests, 203 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] fix | Editor preview LPC sprites and test runner UID warning

- RED: added `tests/specs/scene_smoke_test.gd` coverage requiring Player/NPC scene sprites to store LPC sheet slicing and standing-down preview frame.
- Updated `scenes/player.tscn` and `scenes/npc.tscn` with `hframes = 13`, `vframes = 21`, and `frame_coords = Vector2i(1, 10)` so Field editor view no longer displays full LPC sheets tiled across the map.
- Removed stale UID from `tests/test_runner.tscn` ext_resource so headless runs do not warn and fall back to text path.
- Updated player movement wiki docs.
- Validation: `203 tests, 203 passed, 0 failed`.

## [2026-05-11] feat | Enemy art registry and Slime spritesheet integration

- Created `assets/assets-catalog.md` with enemy sprite integration tasks and current asset list.
- RED: added specs for `EnemyArtDefinition`, `EnemyView`, and Field Slime spritesheet wiring.
- Created `scripts/models/enemy_art_definition.gd` for art-only enemy metadata and Field factories.
- Created `scripts/views/enemy_view.gd` and `scenes/enemy.tscn` as reusable `Area2D` visual/click target.
- Wired Field Slime to `assets/enemies/slime_water_blue_spritesheet.png` through `EnemyView`; Chick/Rabbit remain SVG fallbacks.
- Updated Field scene wiki, architecture pages, and index.
- Validation: `210 tests, 210 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] reset | Remove Field enemies for EnemySystem rebuild

- RED: updated `tests/specs/field_scene_test.gd` to require no `Enemies` node, no `CombatHud`, and no stale Field enemy attack/connect API.
- Removed all enemy placements from `scenes/field.tscn`.
- Removed enemy/combat wiring from `scripts/controllers/field.gd`.
- Removed first-pass EnemySystem implementation files/specs: `EnemyDefinition`, `RandomEnemyRespawnSystem`, `EnemyArtDefinition`, `EnemyView`, and related wiki pages.
- Kept enemy art assets in `assets/enemies/` for future rebuild.
- Updated `assets/assets-catalog.md`, Field prototype docs, wiki Field scene page, and index.

## [2026-05-11] feat | Enemy assets viewer gallery

- RED: added `tests/specs/assets_viewer_test.gd` for asset viewer scene load, recursive PNG collection, and gallery card generation.
- Created `assets/assets-viewer.tscn`.
- Created `assets/assets_viewer.gd` with `AssetsViewer.collect_asset_paths()` and `rebuild_gallery()`.
- Viewer scans `res://assets/enemies` recursively and builds a scrollable thumbnail grid for PNG assets.
- Updated `assets/assets-catalog.md`, wiki assets viewer page, index, and log.
- Validation: `198 tests, 198 passed, 0 failed`.

## [2026-05-11] feat | Focused Slime asset animation viewer

- RED: added `tests/specs/slime_asset_viewer_test.gd` for focused Slime viewer scene, animation path catalog, animated cards, playback, and 64×64 frame slicing.
- Created `assets/asset-view.tscn`.
- Created `assets/asset_view.gd` with `SlimeAssetView`, generated `SpriteFrames`, and `AnimatedSprite2D` preview cards for idle/run/hit/jump/death/ability.
- Updated `assets/assets-catalog.md`, wiki Slime asset view page, index, and log.
- Validation: `202 tests, 202 passed, 0 failed`.

## [2026-05-11] fix | Center Slime asset viewer animations

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require each animation card to reserve a `PreviewArea` and center `AnimatedSprite2D` at `Vector2(110, 80)`.
- Updated `assets/asset_view.gd` so animated sprites are children of a fixed preview area instead of direct VBox children, fixing clipped/overlapping previews.
- Reduced Slime preview scale to `Vector2(2.5, 2.5)` for cleaner card fit.
- Updated Slime asset viewer wiki docs.
- Validation: `202 tests, 202 passed, 0 failed`.

## [2026-05-12] feat | Enemy sprite metadata V1 for Spiked Slime

- RED: added `tests/specs/enemy_sprite_metadata_test.gd` for metadata schema, catalog loading, texture/dimension validation, and SpriteFrames generation.
- Updated `tests/specs/slime_asset_viewer_test.gd` so Slime viewer consumes metadata instead of hardcoded paths/frame size.
- Created `assets/enemies/Slime/slime_spiked.asset.json` with `schema_version = 1`, `enemy_id = slime_spiked`, `display_name = Spiked Slime`, `horizontal_2d` facing, flip support, frame size, scale, anchor, and animation actions.
- Created `scripts/models/enemy_sprite_catalog.gd` for JSON loading/normalization/validation.
- Created `scripts/views/enemy_sprite_frames_builder.gd` for metadata-driven `SpriteFrames` construction.
- Refactored `assets/asset_view.gd` to load `slime_spiked` through the catalog/builder.
- Added `llm-wiki/architecture/enemy-sprite-metadata.md` and updated asset viewer docs, catalog, index, and log.
- Validation: `208 tests, 208 passed, 0 failed`.

## [2026-05-12] refactor | Single-sprite Slime asset viewer controls

- RED: rewrote `tests/specs/slime_asset_viewer_test.gd` expectations so `asset-view.tscn` has one `AnimatedSprite2D`, defaults to `idle`, removes the old multi-card animation grid, and exposes one button per supported animation.
- Refactored `assets/asset_view.gd` to build one centered preview sprite with metadata-driven `SpriteFrames` containing all animations.
- Added `play_animation(animation_name)` and generated animation buttons for ability/death/hit/idle/jump/run.
- Updated Slime asset view wiki docs.
- Validation: `210 tests, 210 passed, 0 failed`.

## [2026-05-12] feat | Import Rat enemy sprite metadata

- RED: added `tests/specs/enemy_sprite_rat_test.gd` for Rat metadata schema, catalog loading, actions, texture path resolution, and validation.
- Created `assets/enemies/Rat/rat.asset.json` with V1 sprite/action metadata.
- Registered `rat` in `EnemySpriteCatalog`.
- Updated asset catalog and enemy sprite metadata wiki docs.
- Validation: `213 tests, 213 passed, 0 failed`.

## [2026-05-12] feat | Add Rat to asset-view selector

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require an `EnemySelector`, Rat metadata loading, Rat switching, and selected-enemy animation button rebuilding.
- Added `EnemySpriteCatalog.enemy_ids()` and registered selector order.
- Refactored `assets/asset_view.gd` to show an `OptionButton` for Spiked Slime/Rat and rebuild the single-sprite preview when selection changes.
- Updated Slime asset viewer wiki docs.
- Validation: `214 tests, 214 passed, 0 failed`.

## [2026-05-12] fix | Center asset-view panel layout

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require full-rect `Center/Panel/Margin/VBox` and fixed centered panel sizing.
- Updated `assets/asset_view.gd` to use a root-level full-rect `CenterContainer` + `PanelContainer`, center the VBox content, and use larger panel margins.
- Updated Slime asset view wiki docs.
- Validation: `215 tests, 215 passed, 0 failed`.

## [2026-05-12] feat | Add all enemy sprite metadata types

- RED: added `tests/specs/enemy_sprite_catalog_all_test.gd` requiring catalog entries and validation for all imported enemy types.
- Added V1 metadata for Bat, Crab, Armored Golem, Golem, Pebble, and Skull.
- Registered all enemy IDs in `EnemySpriteCatalog.enemy_ids()` for asset-view selector use.
- Updated asset catalog and enemy sprite metadata wiki docs.
- Validation: `217 tests, 217 passed, 0 failed`.

## [2026-05-12] refactor | Make asset-view nodes editor-visible

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require saved scene nodes for `EnemySelector`, `PreviewArea/AnimatedSprite2D`, and `AnimationButtons` before runtime setup.
- Rebuilt `assets/asset-view.tscn` with editor-visible `Center/Panel/Margin/VBox` hierarchy and preview sprite node.
- Refactored `assets/asset_view.gd` to populate existing scene nodes instead of creating the whole UI dynamically.
- Updated enemy asset view wiki docs.
- Validation: `218 tests, 218 passed, 0 failed`.

## [2026-05-12] refactor | Convert asset-view to editor-visible enemy gallery

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require one saved `AnimatedSprite2D` per catalog enemy with direct `.tres` resource references.
- Rebuilt `assets/asset-view.tscn` as a scrollable gallery with `SlimeSprite`, `RatSprite`, `BatSprite`, `CrabSprite`, `ArmoredGolemSprite`, `GolemSprite`, `PebbleSprite`, and `SkullSprite`.
- Refactored `assets/asset_view.gd` so animation buttons target the selected gallery sprite instead of swapping one runtime preview node.
- Updated asset catalog and enemy asset view wiki docs.
- Validation: `220 tests, 220 passed, 0 failed`.

## [2026-05-12] refine | Show one asset-view sprite at a time

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require only the selected enemy preview to be visible while hidden enemy sprite nodes remain editor-selectable.
- Updated `assets/asset_view.gd` to toggle preview container visibility from `enemy_id`.
- Reduced `assets/asset-view.tscn` back to a compact single-preview panel while preserving all per-enemy `AnimatedSprite2D` nodes and `.tres` references.
- Updated asset catalog and enemy asset view wiki docs.
- Validation: `221 tests, 221 passed, 0 failed`.

## [2026-05-12] refactor | Split AssetView and AssetGallery

- RED: updated `tests/specs/slime_asset_viewer_test.gd` for `AssetView` root naming and focused single-preview behavior.
- RED: added `tests/specs/asset_gallery_test.gd` requiring `assets-gallery.tscn` to expose all enemy sprites, direct `.tres` references, and looping idle playback.
- Renamed `SlimeAssetView` script/root semantics to `AssetView`.
- Added `assets/assets-gallery.tscn` and `assets/asset_gallery.gd` as one root Control for all looping enemy sprite previews.
- Updated asset catalog, enemy asset tools wiki, wiki index, and enemy sprite metadata docs.
- Validation: `223 tests, 223 passed, 0 failed`.
