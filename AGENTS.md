# Life Well Spent — Agent Guide

## Project Overview

- **Engine:** Godot 4.6.2 (Forward Plus)
- **Physics:** Jolt Physics (3D)
- **Language:** GDScript
- **Render:** Direct3D 12

A personal life-tracking / productivity game built in Godot.

## Project Structure

```
res://
├── .godot/          # Godot auto-generated cache
├── addons/          # Plugins & MCP integration
│   └── gdai-mcp-plugin-godot/
├── scenes/          # All scene files
├── scripts/         # All GDScript files
│   ├── controllers/ # UI / scene controllers (thin, delegate)  — M
│   ├── models/      # Pure business logic & data (no node refs) — M
│   ├── views/       # UI scene scripts (reads model state)    — V
│   └── managers/    # Systems (Save, Audio, Input, etc.)
├── tests/           # Test scenes + spec files
│   ├── test_runner.tscn
│   └── specs/       # TestCase-based GDScript spec files
├── assets/          # Images, fonts, audio, models
├── resources/       # Custom resources, themes, data
└── shaders/         # Custom shader files
```

## Architecture — MVC (Rails-style)

Godot's scene tree is the **View**. Scripts are split into three layers:

### View (`scripts/views/*.gd`)
- Attached to scene nodes (Control, CharacterBody2D, etc.)
- **Dumb:** No business logic. Only reads model data and emits signals.
- Examples: `PlayerView.gd` — moves a sprite; `QuestUI.gd` — updates text labels.
- **Rule:** If it doesn't touch a `Node` or call a Godot method, it doesn't belong here.

### Model (`scripts/models/*.gd`)
- **Pure logic.** No `Node` references. No `print()`. No Godot APIs.
- Exposed via a singleton controller (see below) or direct injection.
- Examples: `PlayerStats.gd` — HP, level, experience; `QuestManager.gd` — quest state, costs.
- **Rule:** If you can `import` it and test it without Godot running, it's a model.

### Controller (`scripts/controllers/*.gd`)
- **Thin glue.** Listens to input/signals, calls model methods, updates views.
- One controller per scene or logical subsystem.
- Examples: `GameController.gd` — bootstraps the game, switches scenes; `CombatController.gd` — handles attack input.

### Spec-Driven Development

Every feature starts with a spec. No code written until the spec is approved. Specs are **executable GDScript** files extending `TestCase`, not JSON data.

#### TDD Enforcement

**These rules are non-negotiable. Every commit must pass them.**

| Rule | Enforcement |
|------|-------------|
| 1. **RED first** | Write a failing spec BEFORE any implementation. If spec passes immediately, it's not a real test — it tests nothing. |
| 2. **One behavior per spec** | Name after behavior: `test_take_quest_checks_hp_cost`. Never `test_take_quest` (too vague). |
| 3. **No implementation without failing spec** | If there's no spec that fails for the new behavior, do not write code. |
| 4. **Bug fixes start with a reproducing spec** | Before fixing a bug, write a spec that reproduces it. Then fix. |
| 5. **Model always has specs** | Every `scripts/models/*.gd` file must have a corresponding `tests/specs/*_test.gd` with coverage of its public API. |
| 6. **Run full suite after every change** | `Godot --headless --quit tests/test_runner.tscn`. All tests must pass before committing. |
| 7. **Minitest-style assertions** | Use `assert_eq(expected, actual)`, `assert_true()`, `assert_null()`, `assert_not_null()`, `assert_in()`, `assert_has()`. |
| 8. **Refactor only after GREEN** | Never refactor while RED. Get to GREEN first, then clean up. |

**Pre-commit checklist (verify each line):**
- [ ] Every new behavior has a spec that was RED before the code existed
- [ ] Every bug fix has a spec that reproduces the bug
- [ ] All specs pass (`48 tests, 48 passed, 0 failed`)
- [ ] LLM wiki updated with the change
- [ ] Commit message references the spec file

#### Spec Format (`tests/specs/test_<name>.gd`)

```gdscript
# tests/specs/test_player_stats.gd
class_name TestPlayerStats
extends TestCase

var player: PlayerStats

func setup():
	player = PlayerStats.new()

func test_initial_max_hp_is_100():
	assert_eq(100, player.max_hp)

func test_quest_deducts_40_hp():
	player.take_quest()
	assert_eq(60, player.max_hp)
```

#### Red → Green → Refactor Workflow

1. **Red** — Write the spec. It fails (assertion does not pass yet).
2. **Green** — Write the minimum code to make it pass.
3. **Refactor** — Clean up, add more edge-case specs, ensure nothing breaks.

At the feature level:
1. **Draft** the acceptance criteria (in a markdown or spec JSON for approval).
2. **Approve** — user confirms the criteria are complete and unambiguous.
3. **Implement** — write the **Model** first (pure logic), then the **Controller** (thin glue), then the **View** (UI update).
4. **Verify** — run the full spec suite. All must pass. The runner exits non-zero when any spec fails.

#### Rule
> If the spec doesn't cover it, it doesn't exist. Never add "just one more thing" without updating the spec.

### SOLID Rules

| Principle | Rule |
|-----------|------|
| **SRP** | One responsibility per script. A model doesn't draw. A view doesn't calculate. |
| **OCP** | Open for extension: use `Resource` subtypes for quests, enemies, items. |
| **LSP** | Subclasses must not break contracts. E.g., `Swordsman` extends `Player` without changing base behavior. |
| **ISP** | Small interfaces. Split `IQuest` into `IQuestProvider` and `IQuestResolver` if a class only needs one. |
| **DIP** | Depend on abstractions. `CombatSystem` takes `IDamageProvider`, not `Player`. |

### Example: Quest Flow

```
[Scene] QuestGiver (Node)
  └── QuestUI.gd (View)    → reads QuestModel.state
  └── QuestController.gd   → accepts() → QuestModel.accept_quest()
                              → QuestModel.complete_quest() → emits "quest_completed"
  └── QuestModel.gd (Model) → deducts MaxHP, updates state, emits signal
```

### Conventions

- **Naming:** `snake_case` for scripts and nodes, PascalCase for custom classes
- **Scripts:** One script per scene; keep them thin, delegate to helpers
- **Nodes:** Use descriptive names, group related nodes under a named parent
- **Signals:** Prefer signals over direct node references for loose coupling
- **Autoloads:** Register in Project Settings → AutoLoad; keep them minimal

### LLM Wiki Documentation

**Every commit that touches code must update the wiki. This is not optional.**

#### Wiki Update Rules

| Rule | Enforcement |
|------|-------------|
| 1. **New model → new wiki page** | Any new `scripts/models/*.gd` gets a page in `llm-wiki/architecture/` covering API, design decisions, and test coverage. |
| 2. **Changed behavior → update existing page** | If a public API changes, update the corresponding wiki page. |
| 3. **New architecture → new wiki page** | New patterns, systems, or conventions get a dedicated page. |
| 4. **Log every operation** | Append to `llm-wiki/log.md` with date, operation type, and affected pages. |
| 5. **Update index** | Add new pages to `llm-wiki/index.md` with type, date, summary. |

#### Wiki Page Format

```markdown
---
title: <Page Title>
type: concept | decision | reference | synthesis
tags: [architecture | game-design | tech]
---

# <Title>

## Overview
One paragraph summary.

## API
Public interface in code blocks.

## Design Decisions
Why things are the way they are.

## Test Coverage
List of specs and what they cover.

## Related
Cross-links to other wiki pages.
```

#### Pre-commit Checklist (continued)
- [ ] `llm-wiki/` updated for this change
- [ ] `llm-wiki/log.md` has an entry for today
- [ ] `llm-wiki/index.md` includes new pages
- [ ] Pages have frontmatter with type, tags, sources

## CI / GitHub Actions

- **Workflow:** `.github/workflows/tests.yml`
- **Trigger:** Push/PR to `master` or `main` when `tests/**` changes
- **Run:** `Godot --headless --quit tests/test_runner.tscn` on Ubuntu

### Running Tests

Prefer Godot MCP for agent validation:

1. Open `tests/test_runner.tscn`.
2. Run `godot_mcp_play_scene`.
3. Run `godot_mcp_get_godot_errors`.
4. Read the output log for the Minitest-style summary.

Use the headless command for CI/local shell fallback:

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```

Filtered run:

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn -- --filter TestCase
```

`godot_mcp_play_scene` starts the runner scene but does not directly return the test output. `godot_mcp_get_godot_errors` is required to see the test summary.

## Tooling

- **MCP:** `uv run` + `gdai_mcp_server.py` — enables AI-assisted scene/script editing
- **Config:** `.mcp.json` in project root

## Adding Features

1. **RED** — Write a failing spec in `tests/specs/` for the new behavior
2. **GREEN** — Write minimal code to make the spec pass
3. **Refactor** — Clean up, ensure all specs still pass
4. Create the scene (`godot_mcp_create_scene`) or script (`godot_mcp_create_script`)
5. Place under the appropriate directory (`scenes/`, `scripts/`)
6. Attach script to node if needed (`godot_mcp_attach_script`)
7. Test with `godot_mcp_play_scene` (current) or `godot_mcp_play_scene` (main)
8. Check errors with `godot_mcp_get_godot_errors`
9. Update LLM wiki if model/architecture changed
10. Run full spec suite: `Godot --headless --quit tests/test_runner.tscn`
11. Commit with message referencing the spec file

## Sprite Generation

Character spritesheets are generated via a local tool — not the web UI.

**Location:** `tools/lpc-sprite-gen/`
**Full workflow:** see [`tools/lpc-sprite-gen/spritegen.workflow.md`](tools/lpc-sprite-gen/spritegen.workflow.md)

### Quick reference

```bash
cd tools/lpc-sprite-gen

# See all available layer options
python generate.py catalog

# Generate a sprite (AI picks the layers, calls this directly)
python generate.py make '<json_config>' --out output/<name>.png
```

JSON config shape:
```json
{
  "body_type": "male",
  "selections": {
    "shadow":  { "id": "shadow" },
    "body":    { "id": "body" },
    "head":    { "id": "heads_human_male" },
    "hair":    { "id": "hair_wavy", "palette_variant": "auburn" },
    "armour":  { "id": "torso_armour_leather" },
    "legs":    { "id": "legs_pants" },
    "shoes":   { "id": "feet_boots_basic" },
    "weapon":  { "id": "weapon_sword_longsword" }
  }
}
```

Output is an 832px-wide LPC spritesheet PNG, ready for the Godot [LPCAnimatedSprite2D](https://github.com/alextrevisan/LPCAnimatedSprite2D) plugin.
Always include `shadow` and `body`. See `spritegen.workflow.md` for archetype recipes and palette variant guidance.

## Notes

- No scenes exist yet — this is a fresh project scaffold
- The `GDAIMCPRuntime` autoload is registered for MCP integration
- Keep the project lean; every feature should serve the core life-tracking vision
