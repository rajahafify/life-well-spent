# Wiki Index

| Page | Type | Updated | Summary |
|------|------|---------|---------|
| [game-design/game-design](game-design/game-design.md) | synthesis | 2026-05-11 | Core loop, free quest acceptance, completion HP cost, facilities, and win condition. |
| [game-design/prototype-systemic-design](game-design/prototype-systemic-design.md) | synthesis | 2026-05-12 | First playable prototype: Town, Field, Slime/Bat/Rat combat target set, Forest Guard gate, Swordsman Guild life-spend chain. |
| [architecture/architecture](architecture/architecture.md) | decision | 2026-05-08 | MVC + SOLID architecture pattern. |
| [architecture/spec-driven-dev](architecture/spec-driven-dev.md) | decision | 2026-05-10 | Spec-driven development workflow + TDD enforcement. |
| [architecture/test-runner](architecture/test-runner.md) | reference | 2026-05-11 | Minitest-style GDScript spec runner — loads specs, runs tests, reports results. |
| [architecture/ci](architecture/ci.md) | reference | 2026-05-16 | GitHub Actions test workflow plus tag/manual Web export deployment to GitHub Pages. |
| [architecture/gateway-definition](architecture/gateway-definition.md) | reference | 2026-05-12 | Pure gateway target, lock rules, and named spawn IDs for direct map transitions. |

| [architecture/combat-system](architecture/combat-system.md) | reference | 2026-05-13 | Pure Field combat rules for enemy HP, current Life damage, 10x Field outgoing damage tuning, Max Life pressure, defeat, and XP hooks. |
| [architecture/enemy-sprite-metadata](architecture/enemy-sprite-metadata.md) | reference | 2026-05-12 | RO-ish sprite/action metadata pipeline for enemy animation strips; V1 covers Spiked Slime. |
| [architecture/enemy-behavior-system](architecture/enemy-behavior-system.md) | reference | 2026-05-13 | Runtime enemy definitions/states, 10x Field HP tuning for Slime/Bat/Rat, random spawn zones, and idle/wander/chase/attack/die behavior. |
| [architecture/enemy-spawn-system](architecture/enemy-spawn-system.md) | reference | 2026-05-12 | Game-wide persistent enemy spawn slots, biome max-active caps, and respawn timers across scene changes. |
| [architecture/drop-system](architecture/drop-system.md) | reference | 2026-05-13 | Pure chance-roll helper for Field enemy drops with deterministic test rolls. |
| [architecture/field-controller-boundaries](architecture/field-controller-boundaries.md) | reference | 2026-05-13 | Field scene glue boundaries for camera, spawn, and combat helper controllers. |
| [architecture/field-runtime-context](architecture/field-runtime-context.md) | reference | 2026-05-14 | Controller-side Field collaborator construction boundary for behavior, combat, drops, spawning, camera, aging, and equipment helpers. |
| [architecture/npc-placement](architecture/npc-placement.md) | reference | 2026-05-11 | Stable NPC map placement data, including Forest Guard gateway blocking. |
| [architecture/biome-definition](architecture/biome-definition.md) | reference | 2026-05-12 | Field grassland palette, Slime/Bat/Rat enemy pool, props, and biome filters. |
| [architecture/quest-manager](architecture/quest-manager.md) | concept | 2026-05-13 | Quest catalog, main objective progression, Guildmaster-started side chain activation, objective-backed certification steps, certification state, and free acceptance. |
| [architecture/quest-system](architecture/quest-system.md) | reference | 2026-05-15 | Game-wide quest autoload sharing main quest, Guildmaster side quest objective progress, certification state, and post-Guild job teaser markers across scenes. |
| [architecture/quest-dialog-flow](architecture/quest-dialog-flow.md) | reference | 2026-05-14 | Pure reusable quest dialog panel flow for normal, incomplete, claimable, and reward states. |
| [architecture/quest-window-view](architecture/quest-window-view.md) | reference | 2026-05-12 | Reusable top-right quest objective UI view for Town and Field. |
| [architecture/inventory-model](architecture/inventory-model.md) | reference | 2026-05-14 | Pure inventory model for stack counts, owned equipment checks, Weapon/Armor/Consumable slots, and 1-9 shortcut slots. |
| [architecture/inventory-system](architecture/inventory-system.md) | reference | 2026-05-14 | Game-wide inventory autoload for drops, empty starter slots, reset, and shared HUD inventory display. |
| [architecture/equipment-stats](architecture/equipment-stats.md) | reference | 2026-05-14 | Pure equipped item combat bonuses for Training Sword attack and Leather Armor defense. |
| [architecture/run-summary-model](architecture/run-summary-model.md) | reference | 2026-05-14 | Pure Game Over summary formatter for run items and unlocked facilities. |
| [architecture/game-over-summary-flow](architecture/game-over-summary-flow.md) | reference | 2026-05-14 | Dedicated Game Over and Summary scenes for the completed first-life loop. |
| [architecture/main-menu-flow](architecture/main-menu-flow.md) | reference | 2026-05-15 | Main Menu centered controls, young-to-old image, Continue preserves progress, and confirmed New Game resets profile progress. |
| [architecture/profile-system](architecture/profile-system.md) | reference | 2026-05-13 | Persistent player profile autoload for Swordsman Guild unlocks and rebirth state. |
| [architecture/inventory-window-view](architecture/inventory-window-view.md) | reference | 2026-05-14 | Reusable inventory overlay scene showing slots, item stacks, and equipment actions. |
| [architecture/shared-hud-view](architecture/shared-hud-view.md) | reference | 2026-05-13 | Reusable gameplay HUD for player Life, Inventory, Quest Tracker, and 1-9 shortcut bar. |
| [architecture/feedback-components](architecture/feedback-components.md) | reference | 2026-05-15 | Reusable combat feedback components for hit flash, floating damage text, loot toast, camera shake, and export-safe SFX playback. |
| [architecture/game-balance](architecture/game-balance.md) | reference | 2026-05-14 | Shared pure constants model for quest cost, animation timings, Field tuning, and item healing. |
| [assets/lpc-sprite-generator](assets/lpc-sprite-generator.md) | reference | 2026-05-09 | LPC sprite generator tool — prompt-driven character spritesheet pipeline. |
| [assets/assets-viewer](assets/assets-viewer.md) | reference | 2026-05-12 | In-project gallery scene that recursively displays enemy, NPC, and player PNG assets as thumbnails. |
| [assets/slime-asset-view](assets/slime-asset-view.md) | reference | 2026-05-12 | Enemy and character asset tools: focused AssetView preview plus looping AssetGallery SpriteFrames/LPC previews. |
| [assets/tiny-town-map-import](assets/tiny-town-map-import.md) | reference | 2026-05-12 | TMJ-to-Godot visual map importer for the Tiny Town TownMap scene. |
| [scenes/main-menu](scenes/main-menu.md) | reference | 2026-05-15 | Main menu scene with centered controls, young-to-old player image below the menu, and confirmed New Game reset. |
| [scenes/town-hub](scenes/town-hub.md) | reference | 2026-05-15 | Prototype Town scene - controller movement/actions, Guildmaster certification chain, Smith/Shopkeeper job teaser quests, reborn dialog, and direct Field gateway. |
| [scenes/field](scenes/field.md) | reference | 2026-05-15 | Playable Field slice - controller movement/actions, profile-backed age, equipped weapon attack animation, 12 active enemy slots, close-ready attack leash, enemy HP bars, Forest Guard gate, and Forest endpoint. |
| [scenes/forest](scenes/forest.md) | reference | 2026-05-13 | Forest endpoint scene reached after Swordsman certification, with return gateway to Field. |
| [architecture/animation-controller](architecture/animation-controller.md) | reference | 2026-05-12 | LPC spritesheet animation state machine. Idle, walking, slash/thrust attack frame advance via `tick(delta)`. |
| [architecture/player-movement](architecture/player-movement.md) | reference | 2026-05-11 | CharacterMovement Sprite2D view. Click-to-move/static facing, collision/dialog stop, modal move lock, AnimationController frames. |
| [architecture/npc-system](architecture/npc-system.md) | reference | 2026-05-15 | NPC scene/controller/dialog wiring with root-exported sprite texture assignment, TownDialogView, RO-style pending approach, talk range, name labels, modal quest UI. |
| [architecture/player-stats](architecture/player-stats.md) | reference | 2026-05-13 | Player HP, level, death/rebirth, game-over request, XP, persistent facilities, and serialization. |
| [architecture/life-tracker](architecture/life-tracker.md) | reference | 2026-05-11 | Daily tasks, habits, completions, streaks, and XP rewards. |
| [architecture/progression-model](architecture/progression-model.md) | reference | 2026-05-13 | Life task completion, player XP, linked quest completion, Swordsman certification, HP spend, and facility unlock rules. |
| [architecture/player-aging-model](architecture/player-aging-model.md) | reference | 2026-05-14 | Pure Max Life and equipped equipment to player sprite mapping for bare, Training Sword, and brown leather armor age-stage visuals. |
| [architecture/npc-definition](architecture/npc-definition.md) | reference | 2026-05-11 | Resource-backed NPC role variants for quest givers, vendors, and facilities. |
| [architecture/settings-model](architecture/settings-model.md) | reference | 2026-05-15 | User options state with volume clamp, fullscreen flag, and game speed multipliers. |
| [architecture/persistence-audio-settings](architecture/persistence-audio-settings.md) | reference | 2026-05-15 | SaveManager, AudioManager, SettingsModel speed presets, and SceneTransitionController system boundaries. |
| [architecture/gdai-mcp-runtime-guard](architecture/gdai-mcp-runtime-guard.md) | reference | 2026-05-11 | Keeps GDAI MCP enabled in editor while skipping runtime startup during headless tests. |
