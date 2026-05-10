# Wiki Log

## [2026-05-08] init | Wiki initialized

- Created `SCHEMA.md` with proposed schema
- Created `index.md` (empty catalog)
- Created `raw-sources/index.md` (empty registry)

## [2026-05-08] ingest | Game Design Session 1

- Registered `raw-sources/conversations/2026-05-08-game-design-sess1.md`
- Compiled `game-design/game-design.md`
- Updated `index.md`
- Updated `raw-sources/index.md`

## [2026-05-08] ingest | Architecture Decision

- Compiled `architecture/architecture.md` — MVC + SOLID pattern
- Compiled `architecture/spec-driven-dev.md` — Spec-driven development workflow
- Compiled `architecture/test-runner.md` — JSON spec runner
- Updated `index.md`

## [2026-05-08] ingest | Test Runner

- Registered `scripts/managers/test_runner.gd`
- Registered `resources/specs/test_spec.json`
- Compiled `architecture/test-runner.md`
- Updated `index.md`

## [2026-05-10] ingest | QuestManager + TDD enforcement

- Created `architecture/quest-manager.md` — Quest catalog, multi-quest tracking, HP-based affordability
- Updated `architecture/spec-driven-dev.md` — Added TDD enforcement rules
- Updated `index.md` — Added QuestManager page
- Updated `docs/STATUS.md` — QuestManager docs, TDD rules, commit history

## [2026-05-10] update | Minitest-style Test Runner

- Moved test assertions to `tests/test_helper.gd`
- Moved the CI entrypoint to `tests/test_runner.gd` attached to `tests/test_runner.tscn`
- Split playable demo behavior into `scripts/controllers/demo_controller.gd`
- Updated test runner architecture docs

## [2026-05-11] style | Center main menu layout, font sizing, button spacing

- CenterContainer → VBoxContainer with alignment=CENTER, buttons via SHRINK_CENTER size flags
- Buttons: custom_minimum_size Vector2(200, 40)
- Title: 36px font via `add_theme_font_size_override`
- VBoxContainer separation: 16px via `add_theme_constant_override`
- All 64 tests pass
