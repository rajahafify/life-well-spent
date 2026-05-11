# Wiki Index

| Page | Type | Updated | Summary |
|------|------|---------|---------|
| [game-design/game-design](game-design/game-design.md) | synthesis | 2026-05-11 | Core loop, free quest acceptance, completion HP cost, facilities, and win condition. |
| [game-design/prototype-systemic-design](game-design/prototype-systemic-design.md) | synthesis | 2026-05-11 | First playable prototype: Town, Starter Area, Forest Guard gate, Swordsman Guild life-spend chain, primitive/SVG art direction. |
| [architecture/architecture](architecture/architecture.md) | decision | 2026-05-08 | MVC + SOLID architecture pattern. |
| [architecture/spec-driven-dev](architecture/spec-driven-dev.md) | decision | 2026-05-10 | Spec-driven development workflow + TDD enforcement. |
| [architecture/test-runner](architecture/test-runner.md) | reference | 2026-05-11 | Minitest-style GDScript spec runner — loads specs, runs tests, reports results. |
| [architecture/quest-manager](architecture/quest-manager.md) | concept | 2026-05-11 | Quest catalog, multi-quest tracking, free acceptance, completion HP cost. |
| [architecture/game-balance](architecture/game-balance.md) | reference | 2026-05-11 | Shared pure constants model for quest cost and animation timings. |
| [assets/lpc-sprite-generator](assets/lpc-sprite-generator.md) | reference | 2026-05-09 | LPC sprite generator tool — prompt-driven character spritesheet pipeline. |
| [scenes/main-menu](scenes/main-menu.md) | reference | 2026-05-11 | Main menu scene — title, New Game button, Quit button. Transitions to town hub. |
| [scenes/town-hub](scenes/town-hub.md) | reference | 2026-05-11 | Town hub — player click-to-move, stats overlay, TownDialogView NPC dialog/quest UI, RO-style approach interaction. |
| [architecture/animation-controller](architecture/animation-controller.md) | reference | 2026-05-11 | LPC spritesheet animation state machine. Idle cycling + walking frame advance via `tick(delta)`. |
| [architecture/player-movement](architecture/player-movement.md) | reference | 2026-05-11 | CharacterMovement Sprite2D view. Click-to-move/static facing, collision/dialog stop, modal move lock, AnimationController frames. |
| [architecture/npc-system](architecture/npc-system.md) | reference | 2026-05-11 | NPC scene/controller/dialog wiring with TownDialogView, RO-style pending approach, talk range, name labels, modal quest UI. |
| [architecture/player-stats](architecture/player-stats.md) | reference | 2026-05-11 | Player HP, level, death/rebirth, XP, unlocked facilities, and serialization. |
| [architecture/life-tracker](architecture/life-tracker.md) | reference | 2026-05-11 | Daily tasks, habits, completions, streaks, and XP rewards. |
| [architecture/progression-model](architecture/progression-model.md) | reference | 2026-05-11 | Life task completion, player XP, linked quest completion, HP spend, and facility unlock rules. |
| [architecture/npc-definition](architecture/npc-definition.md) | reference | 2026-05-11 | Resource-backed NPC role variants for quest givers, vendors, and facilities. |
| [architecture/settings-model](architecture/settings-model.md) | reference | 2026-05-11 | User options state with volume clamp and fullscreen flag. |
| [architecture/persistence-audio-settings](architecture/persistence-audio-settings.md) | reference | 2026-05-11 | SaveManager, AudioManager, SettingsModel, and SceneTransitionController system boundaries. |
| [architecture/gdai-mcp-runtime-guard](architecture/gdai-mcp-runtime-guard.md) | reference | 2026-05-11 | Keeps GDAI MCP enabled in editor while skipping runtime startup during headless tests. |
