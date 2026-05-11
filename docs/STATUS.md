# Life Well Spent - Project Status

> Last updated: 2026-05-11

## QA Status

- Automated suite: `155 tests, 155 passed, 0 failed`
- Manual QA: pass for MVP flow
- Godot cleanup warnings: fixed. Current run has no `ObjectDB instances leaked` or `resources still in use` output.

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
| Test runner | `tests/test_helper.gd`, `tests/test_runner.gd` | Minitest-style GDScript specs. |
| Main menu | `scenes/main_menu.tscn`, `scripts/controllers/main_menu_controller.gd` | New Game → town hub. |
| Town hub | `scenes/town_scene.tscn`, `scripts/controllers/town_scene_controller.gd` | Player, NPCs, dialog, daily task UI, settings panel, owned model cleanup. |
| Player movement | `scripts/views/character_movement.gd` | Click-to-move, facing, animation, movement lock, owned animation-model cleanup. |
| Animation model | `scripts/models/animation_controller.gd` | LPC idle/walk frame state. |
| Camera | `scripts/models/camera_model.gd`, `scripts/controllers/camera_controller.gd` | Smooth follow model + Camera2D glue with owned model cleanup. |
| Player stats | `scripts/models/player_stats.gd` | HP, level, death/rebirth, XP, facilities, serialization. |
| Quest lifecycle | `scripts/models/quest_manager.gd` | Catalog, active quests, linked life-task quests, serialization. |
| Life tracking | `scripts/models/life_tracker.gd` | Tasks, habits, daily completion, streaks, XP. |
| Progression | `scripts/models/progression_model.gd` | Task completion → XP, linked quest completion, facility unlocks. |
| NPC data resources | `scripts/models/npc_definition.gd`, `resources/npc_definitions/` | Quest giver, vendor, facility role definitions. |
| Dialog view | `scripts/views/town_dialog_view.gd` | Dumb dialog panel with button signals. |
| Save manager | `scripts/managers/save_manager.gd` | Build/apply save data and JSON file round trip. |
| Audio manager | `scripts/managers/audio_manager.gd` | Minimal SFX/music request boundary. |
| Settings model | `scripts/models/settings_model.gd` | Volume clamp, fullscreen flag, serialization. |
| Scene transitions | `scripts/controllers/scene_transition_controller.gd` | Transition request/execute boundary. |
| CI output check | `.github/workflows/tests.yml` | Runs tests and checks Godot output for unexpected errors. |
| GDAI MCP runtime guard | `scripts/managers/gdai_mcp_runtime_guard.gd`, `project.godot` | Keeps Godot MCP enabled in editor while skipping runtime autoload in headless tests. |

## Tests Added / Updated

- `tests/specs/life_tracker_test.gd`
- `tests/specs/save_manager_test.gd`
- `tests/specs/npc_definition_test.gd`
- `tests/specs/progression_model_test.gd`
- `tests/specs/settings_audio_transition_test.gd`
- `tests/specs/gdai_mcp_runtime_guard_test.gd`
- `tests/specs/town_scene_dialog_test.gd`
- Existing model specs updated for serialization/progression support and cleanup.

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

1. Fix Godot cleanup warnings fully.
2. Wire real save/load flow into startup/menu/autosave.
3. Build full daily task CRUD and date-aware UX.
4. Build real vendor/shop/facility gameplay.
5. Add visible town improvement progression.
6. Replace placeholder art/audio with production assets.
7. Wire settings controls to actual display/audio behavior.
8. Remove CI warning ignores after cleanup issues are fixed.

## Run Tests

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```
