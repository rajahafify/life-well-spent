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
│   └── specs/       # JSON spec files (loaded by TestRunner)
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

Every feature starts with a spec. No code written until the spec is approved.

#### Spec Format (`tests/specs/*.json`)

```json
{
  "id": "feature_name",
  "title": "Feature Name",
  "description": "What this spec tests",
  "acceptance_criteria": ["Criterion 1", "Criterion 2"],
  "model_dependencies": ["ModelClass"],
  "view_dependencies": ["ControlNode"],
  "priority": 1,
  "status": "pending"
}
```

#### Workflow

1. **Draft** the spec — write the `acceptance_criteria` first.
2. **Approve** — user confirms the criteria are complete and unambiguous.
3. **Implement** — write the **Model** first (pure logic), then the **Controller** (thin glue), then the **View** (UI update).
4. **Verify** — walk through each acceptance criterion. If any fail, revert and fix.

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

## CI / GitHub Actions

- **Workflow:** `.github/workflows/tests.yml`
- **Trigger:** Push/PR to `master` or `main` when `tests/**` changes
- **Run:** `Godot --headless --quit tests/test_runner.tscn` on Ubuntu

## Tooling

- **MCP:** `uv run` + `gdai_mcp_server.py` — enables AI-assisted scene/script editing
- **Config:** `.mcp.json` in project root

## Adding Features

1. Create the scene (`godot_mcp_create_scene`) or script (`godot_mcp_create_script`)
2. Place under the appropriate directory (`scenes/`, `scripts/`)
3. Attach script to node if needed (`godot_mcp_attach_script`)
4. Test with `godot_mcp_play_scene` (current) or `godot_mcp_play_scene` (main)
5. Check errors with `godot_mcp_get_godot_errors`

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
