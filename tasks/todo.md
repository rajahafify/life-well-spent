# Production TODO

Status: **MVP complete. These are remaining production tasks.**

Current validation: `155 tests, 155 passed, 0 failed`.

## P1 — Product Foundation

- [ ] Wire SaveManager into real game flow.
  - Add autosave on task/quest completion.
  - Add load on startup / Continue.
  - Add save slot UX.
- [ ] Upgrade daily task UI.
  - Add task create/edit/delete.
  - Show completed/incomplete state.
  - Disable completed task button for current day.
  - Use real current date instead of hardcoded date.
- [ ] Build dedicated life dashboard flow.
  - Persist run state.
  - Decide New Game vs Continue behavior.

## P2 — Gameplay Depth

- [ ] Complete quest ↔ real-life task UX.
  - Show required task in quest dialog.
  - Show linked task completion state.
  - Update quest UI when task completes.
- [ ] Persist player stats, quests, and life tracker at runtime.
  - Restore on startup.
  - Validate with integration specs.
- [ ] Use `NpcDefinition` resources consistently in scenes/tools.
  - Replace hardcoded town NPC exports with `.tres` resources.
- [ ] Build vendor/shop gameplay.
  - Vendor inventory.
  - Purchase flow.
  - Specs for buy/cannot-buy behavior.
- [ ] Build facility NPC gameplay.
  - Place facility NPC in town.
  - Unlock facility via progression.
  - Show unlocked state.
- [ ] Make town progression visible.
  - Visual changes after facility unlock.
  - Balance XP thresholds.

## P3 — Polish

- [ ] Replace placeholder art with real assets.
- [ ] Wire AudioManager to Godot audio.
  - Add sound streams.
  - Use audio buses.
  - Connect settings volume.
- [ ] Finish settings/options menu.
  - Add volume controls.
  - Add fullscreen toggle.
  - Persist settings.
- [ ] Integrate SceneTransitionController.
  - Main menu uses transition controller.
  - Add fade/loading UX.
- [ ] Add production QA checklist.
  - Save/load QA.
  - Task dashboard QA.
  - Quest/task integration QA.
  - Vendor/facility QA.
