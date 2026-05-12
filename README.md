# Life Well Spent

Personal life-tracking / productivity game built in Godot 4.6.2.

## Current State

- Main menu routes to town hub.
- Town hub has click-to-move player, camera follow, NPC dialog, daily task panel, and settings panel.
- Field is playable with Town/Forest gateways, shared HUD, Slime/Bat/Rat enemy spawns, enemy HP bars, hit feedback, drops, and respawn polling.
- Quests can link to real-life tasks.
- Completing life tasks grants XP; linked quest completion spends HP.
- SaveManager serializes player, quest, and life-tracking state.
- GDAI MCP remains enabled for editor use and is skipped during headless tests.
- Test baseline: `328 tests, 328 passed, 0 failed`.

## Run Tests

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```

## Architecture

- `scripts/models/` - pure business logic.
- `scripts/controllers/` - thin scene/input glue.
- `scripts/controllers/field_*_controller.gd` - Field camera, spawn, and combat helper controllers extracted from scene glue.
- `scripts/views/` - UI/scene presentation.
- `scripts/managers/` - persistence/audio/system boundaries.
- `tests/specs/` - executable Minitest-style GDScript specs.

## TDD Rule

Every behavior starts with a failing spec, then minimal implementation, then refactor.
