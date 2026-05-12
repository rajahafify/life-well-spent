# Life Well Spent - Project Status

> Last updated: 2026-05-13

## QA Status

- Automated suite: `341 tests, 341 passed, 0 failed`
- Manual QA: pass for MVP flow
- Godot warnings/errors: headless suite passes. Current known non-failing output includes existing `assets-gallery.tscn` invalid UID fallback warnings and resource cleanup warnings.

## Current MVP State

Life Well Spent now has a playable MVP foundation:

1. Main menu routes to town hub.
2. Town hub supports click-to-move player movement.
3. NPCs support RO-style approach interaction and modal dialog.
4. Quest acceptance costs no HP; quest completion spends Max HP.
5. Daily task panel grants XP through `LifeTracker` and `ProgressionModel`.
6. Linked quests can complete from real-life task completion.
7. Save/load serialization exists for player, quests, and life tracking state.
8. Settings, audio, and scene transition boundaries exist as minimal systems.
9. GDAI MCP remains enabled for editor use while headless tests skip runtime startup.
10. Legacy demo scene/controller have been removed; `town_scene.tscn` is the playable MVP flow.
11. Field is playable with shared HUD, Slime/Bat/Rat combat, drops, respawn polling, Forest Guard gate, and extracted camera/spawn/combat helper controllers.
12. Swordsman Guild certification is playable from the Guildmaster after the Forest Guard checkpoint, spends Max Life in three quest-completion steps, unlocks `swordsman_guild`, and changes the Forest gate to a `To be continued` endpoint.

## Architecture

MVC + SOLID remains active convention:

| Layer | Directory | Rule |
|-------|-----------|------|
| Model | `scripts/models/` | Pure logic where possible; no scene orchestration. |
| Controller | `scripts/controllers/` | Thin input/signal glue. |
| View | `scripts/views/` | UI/scene presentation and signals. |
| Manager | `scripts/managers/` | System boundaries: save, audio, external APIs. |

## Implemented Features

| Feature | Files | Status |
|---------|-------|--------|
| Test runner | `tests/test_helper.gd`, `tests/test_runner.gd` | Minitest-style GDScript specs; shadow warnings removed. |
| Main menu | `scenes/main_menu.tscn`, `scripts/controllers/main_menu_controller.gd` | New Game → town hub. |
| Town hub | `scenes/town_scene.tscn`, `scripts/controllers/town_scene_controller.gd` | Player, NPCs, dialog, daily task UI, settings panel, owned model cleanup. |
| Player movement | `scripts/views/character_movement.gd` | Click-to-move, facing, animation, movement lock, owned animation-model cleanup. |
| Animation model | `scripts/models/animation_controller.gd` | LPC idle/walk frame state. |
| Camera | `scripts/models/camera_model.gd`, `scripts/controllers/camera_controller.gd` | Smooth follow model + Camera2D glue with owned model cleanup. |
| Player stats | `scripts/models/player_stats.gd` | HP, level, death/rebirth, game-over request, XP, persistent facilities, serialization. |
| Quest lifecycle | `scripts/models/quest_manager.gd` | Catalog, active quests, linked life-task quests, side-chain steps, certifications, serialization. |
| Life tracking | `scripts/models/life_tracker.gd` | Tasks, habits, daily completion, streaks, XP. |
| Progression | `scripts/models/progression_model.gd` | Task completion -> XP, linked quest completion, facility unlocks, Swordsman certification steps. |
| NPC data resources | `scripts/models/npc_definition.gd`, `resources/npc_definitions/` | Quest giver, vendor, facility role definitions. |
| Dialog view | `scripts/views/town_dialog_view.gd` | Dumb dialog panel with button signals. |
| Save manager | `scripts/managers/save_manager.gd` | Build/apply save data and JSON file round trip. |
| Audio manager | `scripts/managers/audio_manager.gd` | Minimal SFX/music request boundary. |
| Settings model | `scripts/models/settings_model.gd` | Volume clamp, fullscreen flag, serialization. |
| Scene transitions | `scripts/controllers/scene_transition_controller.gd` | Transition request/execute boundary. |
| CI output check | `.github/workflows/tests.yml` | Runs tests and checks Godot output for unexpected errors. |
| GDAI MCP runtime guard | `scripts/managers/gdai_mcp_runtime_guard.gd`, `project.godot` | Keeps Godot MCP enabled in editor while skipping runtime autoload in headless tests. |
| Field scene | `scenes/field.tscn`, `scripts/controllers/field.gd` | Thin scene glue for movement, gateways, HUD, dialog, and helper-controller delegation. |
| Field helper controllers | `scripts/controllers/field_camera_controller.gd`, `scripts/controllers/field_enemy_spawn_controller.gd`, `scripts/controllers/field_combat_controller.gd` | Camera shake/follow, enemy spawn polling, and combat tick orchestration. |
| Enemy catalog/state/behavior | `scripts/models/enemy_library.gd`, `scripts/models/enemy_definition.gd`, `scripts/models/enemy_state.gd`, `scripts/models/enemy_behavior_system.gd`, `scripts/models/enemy_random_sequence.gd` | Registry-backed enemy definitions, data-only enemy resources, runtime state, mutating behavior system, and deterministic random sequencing. |
| Drop system | `scripts/models/drop_system.gd` | Pure chance-roll helper for enemy drops. |
| Inventory model/window | `scripts/models/inventory_model.gd`, `scripts/views/inventory_window_view.gd` | Public item row API plus inventory overlay rendering without direct model internals access. |

## Tests Added / Updated

- `tests/specs/life_tracker_test.gd`
- `tests/specs/save_manager_test.gd`
- `tests/specs/npc_definition_test.gd`
- `tests/specs/progression_model_test.gd`
- `tests/specs/settings_audio_transition_test.gd`
- `tests/specs/gdai_mcp_runtime_guard_test.gd`
- `tests/specs/town_scene_dialog_test.gd`
- `tests/specs/field_scene_test.gd`
- `tests/specs/enemy_library_test.gd`
- `tests/specs/enemy_state_test.gd`
- `tests/specs/drop_system_test.gd`
- Existing model specs updated for serialization/progression support, cleanup, and legacy demo removal guard.

## Manual QA Checklist

Passed for MVP:

- Main menu loads and New Game enters town.
- Player moves on ground click.
- Quest Giver opens dialog after approach.
- Accept Quest keeps HP at `100 / 100`.
- Complete Quest changes HP to `60 / 60`.
- Vendor/Guard dialogs open without quest button.
- Daily task completion updates XP.
- Options button opens settings panel.

## Remaining Production Work

See `todo.md` for current truth. Major remaining work:

1. Wire real save/load flow into startup/menu/autosave.
2. Build full daily task CRUD and date-aware UX.
3. Build real vendor/shop/facility gameplay.
4. Add visible town improvement progression.
5. Replace placeholder art/audio with production assets.
6. Wire settings controls to actual display/audio behavior.

## Run Tests

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```
