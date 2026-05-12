# Wiki Index

| Page | Type | Updated | Summary |
|------|------|---------|---------|
| [game-design/game-design](game-design/game-design.md) | synthesis | 2026-05-11 | Core loop, free quest acceptance, completion HP cost, facilities, and win condition. |
| [game-design/prototype-systemic-design](game-design/prototype-systemic-design.md) | synthesis | 2026-05-12 | First playable prototype: Town, Field, Slime/Bat/Rat combat target set, Forest Guard gate, Swordsman Guild life-spend chain. |
| [architecture/architecture](architecture/architecture.md) | decision | 2026-05-08 | MVC + SOLID architecture pattern. |
| [architecture/spec-driven-dev](architecture/spec-driven-dev.md) | decision | 2026-05-10 | Spec-driven development workflow + TDD enforcement. |
| [architecture/test-runner](architecture/test-runner.md) | reference | 2026-05-11 | Minitest-style GDScript spec runner — loads specs, runs tests, reports results. |
| [architecture/gateway-definition](architecture/gateway-definition.md) | reference | 2026-05-12 | Pure gateway target, lock rules, and named spawn IDs for direct map transitions. |

| [architecture/combat-system](architecture/combat-system.md) | reference | 2026-05-13 | Pure Field combat rules for enemy HP, current Life damage, 10x Field outgoing damage tuning, Max Life pressure, defeat, and XP hooks. |
| [architecture/enemy-sprite-metadata](architecture/enemy-sprite-metadata.md) | reference | 2026-05-12 | RO-ish sprite/action metadata pipeline for enemy animation strips; V1 covers Spiked Slime. |
| [architecture/enemy-behavior-system](architecture/enemy-behavior-system.md) | reference | 2026-05-13 | Runtime enemy definitions/states, 10x Field HP tuning for Slime/Bat/Rat, random spawn zones, and idle/wander/chase/attack/die behavior. |
| [architecture/enemy-spawn-system](architecture/enemy-spawn-system.md) | reference | 2026-05-12 | Game-wide persistent enemy spawn slots, biome max-active caps, and respawn timers across scene changes. |
| [architecture/npc-placement](architecture/npc-placement.md) | reference | 2026-05-11 | Stable NPC map placement data, including Forest Guard gateway blocking. |
| [architecture/biome-definition](architecture/biome-definition.md) | reference | 2026-05-12 | Field grassland palette, Slime/Bat/Rat enemy pool, props, and biome filters. |
| [architecture/quest-manager](architecture/quest-manager.md) | concept | 2026-05-12 | Quest catalog, main objective progression, side chain activation, certification state, and free acceptance. |
| [architecture/quest-system](architecture/quest-system.md) | reference | 2026-05-12 | Game-wide quest autoload sharing main quest, side quest chain, and certification state across scenes. |
| [architecture/quest-window-view](architecture/quest-window-view.md) | reference | 2026-05-12 | Reusable top-right quest objective UI view for Town and Field. |
| [architecture/inventory-model](architecture/inventory-model.md) | reference | 2026-05-12 | Pure stackable item count model used by Field enemy drops. |
| [architecture/inventory-system](architecture/inventory-system.md) | reference | 2026-05-12 | Game-wide inventory autoload for drops and shared HUD inventory display. |
| [architecture/inventory-window-view](architecture/inventory-window-view.md) | reference | 2026-05-12 | Reusable inventory overlay scene opened from SharedHUDView with the Inventory button or I key. |
| [architecture/shared-hud-view](architecture/shared-hud-view.md) | reference | 2026-05-12 | Reusable gameplay HUD for player Life, Inventory button/window, and Quest Tracker. |
| [architecture/feedback-components](architecture/feedback-components.md) | reference | 2026-05-13 | Reusable combat feedback components for hit flash, floating damage text, loot toast, camera shake, and SFX requests. |
| [architecture/game-balance](architecture/game-balance.md) | reference | 2026-05-11 | Shared pure constants model for quest cost and animation timings. |
| [assets/lpc-sprite-generator](assets/lpc-sprite-generator.md) | reference | 2026-05-09 | LPC sprite generator tool — prompt-driven character spritesheet pipeline. |
| [assets/assets-viewer](assets/assets-viewer.md) | reference | 2026-05-12 | In-project gallery scene that recursively displays enemy, NPC, and player PNG assets as thumbnails. |
| [assets/slime-asset-view](assets/slime-asset-view.md) | reference | 2026-05-12 | Enemy and character asset tools: focused AssetView preview plus looping AssetGallery SpriteFrames/LPC previews. |
| [assets/tiny-town-map-import](assets/tiny-town-map-import.md) | reference | 2026-05-12 | TMJ-to-Godot visual map importer for the Tiny Town TownMap scene. |
| [scenes/main-menu](scenes/main-menu.md) | reference | 2026-05-11 | Main menu scene — title, New Game button, Quit button. Transitions to town hub. |
| [scenes/town-hub](scenes/town-hub.md) | reference | 2026-05-12 | Prototype Town scene — named gateway spawn, reborn start dialog, three old institutions, NPC dialog, and deferred direct Field gateway. |
| [scenes/field](scenes/field.md) | reference | 2026-05-13 | Playable Field slice — spawn zones, enemy HP bars, 10x enemy HP/player damage tuning, RO damage numbers, Forest Guard gate. |
| [architecture/animation-controller](architecture/animation-controller.md) | reference | 2026-05-12 | LPC spritesheet animation state machine. Idle, walking, slash/thrust attack frame advance via `tick(delta)`. |
| [architecture/player-movement](architecture/player-movement.md) | reference | 2026-05-11 | CharacterMovement Sprite2D view. Click-to-move/static facing, collision/dialog stop, modal move lock, AnimationController frames. |
| [architecture/npc-system](architecture/npc-system.md) | reference | 2026-05-11 | NPC scene/controller/dialog wiring with TownDialogView, RO-style pending approach, talk range, name labels, modal quest UI. |
| [architecture/player-stats](architecture/player-stats.md) | reference | 2026-05-11 | Player HP, level, death/rebirth, XP, unlocked facilities, and serialization. |
| [architecture/life-tracker](architecture/life-tracker.md) | reference | 2026-05-11 | Daily tasks, habits, completions, streaks, and XP rewards. |
| [architecture/progression-model](architecture/progression-model.md) | reference | 2026-05-11 | Life task completion, player XP, linked quest completion, HP spend, and facility unlock rules. |
| [architecture/npc-definition](architecture/npc-definition.md) | reference | 2026-05-11 | Resource-backed NPC role variants for quest givers, vendors, and facilities. |
| [architecture/settings-model](architecture/settings-model.md) | reference | 2026-05-11 | User options state with volume clamp and fullscreen flag. |
| [architecture/persistence-audio-settings](architecture/persistence-audio-settings.md) | reference | 2026-05-11 | SaveManager, AudioManager, SettingsModel, and SceneTransitionController system boundaries. |
| [architecture/gdai-mcp-runtime-guard](architecture/gdai-mcp-runtime-guard.md) | reference | 2026-05-11 | Keeps GDAI MCP enabled in editor while skipping runtime startup during headless tests. |
