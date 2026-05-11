# TODO

Status: **Partially done. MVP foundation exists, production-complete work remains.**

Current validation: `155 tests, 155 passed, 0 failed`.

## P0 — Cleanup / Correctness

- [ ] Fully fix Godot cleanup warnings.
  - Current: `ObjectDB instances leaked` still appears.
  - Current: `6 resources still in use` still appears.
- [x] Investigate `ERROR: Capture not registered: 'gdaimcp'.`
  - Fixed with `scripts/managers/gdai_mcp_runtime_guard.gd`: GDAI MCP stays enabled for editor, runtime skips in headless tests.
- [x] Update stale plan test counts to current baseline: `152 tests, 152 passed, 0 failed`.
- [x] Mark `plans/camera-controller.md` implemented or rewrite its status.
- [x] Add missing `README.md`.

## P1 — Product Foundation

- [~] Add save/load manager.
  - MVP model exists: `scripts/managers/save_manager.gd`.
  - Remaining: wire into real game flow, menu, autosave/load UX.
- [x] Add core life-tracking model.
  - [x] Habits.
  - [x] Tasks.
  - [x] Daily completion.
  - [x] Streaks.
  - [x] XP / rewards.
- [x] Write specs first for life-tracking model.
- [~] Add UI for daily task list.
  - MVP UI exists in town scene.
  - Remaining: real task creation/edit/delete, completion state, dates, polish.
- [~] Wire New Game → town/life dashboard flow.
  - Main menu reaches town with daily task panel.
  - Remaining: dedicated dashboard flow and persisted run state.

## P2 — Gameplay Depth

- [~] Connect quests to real-life actions.
  - Model link exists via `life_task_id`.
  - Remaining: full UX for linked quest/task state.
- [~] Add persistence for player stats and quests.
  - Serialization exists.
  - Remaining: real save slots/load on startup.
- [~] Add NPC quest giver variants via resources.
  - Resource examples exist.
  - Remaining: use resources consistently in scenes/tools.
- [~] Add vendor/shop/facility NPC types.
  - Roles/factories exist.
  - Remaining: actual shop/facility gameplay and placed facility NPC.
- [~] Add progression loop: complete task → reward → improve town/player.
  - Model loop exists.
  - Remaining: visible town improvement UX and balancing.

## P3 — Polish

- [~] Add more art/assets.
  - Added one SVG placeholder.
  - Remaining: real game art pass.
- [~] Add audio manager.
  - Stub manager exists.
  - Remaining: real sound streams, buses, volume integration.
- [~] Add settings/options menu.
  - Minimal panel/model exists.
  - Remaining: actual controls wired to settings and persistence.
- [~] Add scene transition controller.
  - Request/execute controller exists.
  - Remaining: fade/loading UX and scene integration.
- [~] Add CI check for Godot warnings/errors, not only exit code.
  - CI checks output and ignores known cleanup warnings.
  - Remaining: remove ignores after cleanup warnings are fixed.

## Legend

- [x] Complete enough for now.
- [~] MVP/stub done, needs production work.
- [ ] Not complete.
