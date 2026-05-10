# Wiki Index

| Page | Type | Updated | Summary |
|------|------|---------|---------|
| [game-design/game-design](game-design/game-design.md) | synthesis | 2026-05-08 | Core loop, quest costs, facilities, and win condition. |
| [architecture/architecture](architecture/architecture.md) | decision | 2026-05-08 | MVC + SOLID architecture pattern. |
| [architecture/spec-driven-dev](architecture/spec-driven-dev.md) | decision | 2026-05-10 | Spec-driven development workflow + TDD enforcement. |
| [architecture/test-runner](architecture/test-runner.md) | reference | 2026-05-08 | JSON spec runner — loads specs, runs criteria, reports results. |
| [architecture/quest-manager](architecture/quest-manager.md) | concept | 2026-05-10 | Quest catalog, multi-quest tracking, HP-based affordability. |
| [assets/lpc-sprite-generator](assets/lpc-sprite-generator.md) | reference | 2026-05-09 | LPC sprite generator tool — prompt-driven character spritesheet pipeline. |
| [scenes/main-menu](scenes/main-menu.md) | reference | 2026-05-11 | Main menu scene — title, New Game button, Quit button. Transitions to town hub. |
| [scenes/town-hub](scenes/town-hub.md) | reference | 2026-05-11 | Town hub — background, player character with click-to-move, stats overlay. |
| [architecture/animation-controller](architecture/animation-controller.md) | reference | 2026-05-11 | LPC spritesheet animation state machine. Idle cycling + walking frame advance via `tick(delta)`. |
| [architecture/player-movement](architecture/player-movement.md) | reference | 2026-05-11 | Click-to-move Sprite2D view. Consumes AnimationController for frame calculation. Static `_dir_from_vector()` utility. |
