# Wiki Index

| Page | Type | Updated | Summary |
|------|------|---------|---------|
| [game-design/game-design](game-design/game-design.md) | synthesis | 2026-05-11 | Core loop, free quest acceptance, completion HP cost, facilities, and win condition. |
| [game-design/prototype-systemic-design](game-design/prototype-systemic-design.md) | synthesis | 2026-05-11 | First playable prototype: Town, Starter Area, Forest Guard gate, Swordsman Guild life-spend chain, primitive/SVG art direction. |
| [architecture/architecture](architecture/architecture.md) | decision | 2026-05-08 | MVC + SOLID architecture pattern. |
| [architecture/spec-driven-dev](architecture/spec-driven-dev.md) | decision | 2026-05-10 | Spec-driven development workflow + TDD enforcement. |
| [architecture/test-runner](architecture/test-runner.md) | reference | 2026-05-11 | Minitest-style GDScript spec runner — loads specs, runs tests, reports results. |
| [architecture/gateway-definition](architecture/gateway-definition.md) | reference | 2026-05-11 | Pure gateway target and lock rules for direct map transitions. |

| [architecture/combat-system](architecture/combat-system.md) | reference | 2026-05-11 | Pure Field combat rules for enemy HP, Combat HP, defeat, and XP hooks. |
| [architecture/npc-placement](architecture/npc-placement.md) | reference | 2026-05-11 | Stable NPC map placement data, including Forest Guard gateway blocking. |
| [architecture/biome-definition](architecture/biome-definition.md) | reference | 2026-05-11 | Field grassland palette, enemy pool, props, and biome filters. |
| [architecture/quest-manager](architecture/quest-manager.md) | concept | 2026-05-11 | Quest catalog, multi-quest tracking, free acceptance, completion HP cost. |
| [architecture/game-balance](architecture/game-balance.md) | reference | 2026-05-11 | Shared pure constants model for quest cost and animation timings. |
| [assets/lpc-sprite-generator](assets/lpc-sprite-generator.md) | reference | 2026-05-09 | LPC sprite generator tool — prompt-driven character spritesheet pipeline. |
| [assets/assets-viewer](assets/assets-viewer.md) | reference | 2026-05-11 | In-project gallery scene that recursively displays enemy PNG assets as thumbnails. |
| [assets/slime-asset-view](assets/slime-asset-view.md) | reference | 2026-05-11 | Focused SLIME asset scene with AnimatedSprite2D previews from 64×64 animation strips. |
| [scenes/main-menu](scenes/main-menu.md) | reference | 2026-05-11 | Main menu scene — title, New Game button, Quit button. Transitions to town hub. |
| [scenes/town-hub](scenes/town-hub.md) | reference | 2026-05-12 | Prototype Town scene — reborn prompt, three old institutions, worldbuilding NPC dialog, and deferred direct Field gateway. |
| [scenes/field](scenes/field.md) | reference | 2026-05-12 | Playable Field reset slice — movement, camera follow, deferred Town gateway, Forest Guard gate, no enemies while EnemySystem is rebuilt. |
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
