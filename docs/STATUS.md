# Life Well Spent - Project Status

> Last updated: 2026-05-10

## Game Design

A "Your Life is a Currency" roguelite set in a Frieren-like world where the Demon King is gone but Heroes have died. Goal: beat the new Demon King.

### Core Loop
1. **Start** - Level 1 Novice, Max HP 100
2. **Questing** - Choose 1 Quest. Cost: 40 Max HP
3. **Death** - Player dies by combat. Max HP is gone
4. **Rebirth** - Restart at Level 1. Unlocked facilities remain

### Quests & Costs
- **Cost per Quest:** 40 Max HP
- **Life Economy:** Quest cost = 40 Max HP. No hard limit per life - pickup blocked by HP affordability. Message: "You have no more life to sacrifice."
- **Facilities:** Shop, Blacksmith, Storage, Swordsman Guild

### Progression
- **Meta:** Facilities are permanent once unlocked
- **Combat:** Swordsman class unlocks after Guild is opened
- **Win Condition:** Open the path to the Demon King via facilities

---

## Architecture

**MVC (Rails-style) + SOLID**

| Layer | Directory | Rule |
|-------|-----------|------|
| **Model** | `scripts/models/` | Pure logic, no `Node` refs, no Godot APIs |
| **Controller** | `scripts/controllers/` | Thin glue - input → model calls → view updates |
| **View** | `scripts/views/` | Dumb UI - reads model data, emits signals |

### Spec-Driven Development
Every feature starts with a spec (`tests/specs/<name>_test.gd`) extending `TestCase`. Red → Green → Refactor.

### TDD Enforcement
All code changes must follow the red-green-refactor cycle:

1. **RED** - Write a failing spec that describes the new behavior. If the spec doesn't fail, the behavior already exists.
2. **GREEN** - Write minimal code to make the spec pass. No refactoring yet.
3. **REFACTOR** - Clean up duplication, improve structure. Run specs after each change.

**Rules:**
- No implementation without a failing spec first
- Bug fixes start with a spec that reproduces the bug
- Model logic always has specs; demo/view scripts get integration tests where practical
- Specs use Minitest-style `assert_*` helpers (`assert_eq`, `assert_true`, `assert_null`, etc.)
- One behavior per spec method; name methods after the behavior (`test_take_quest_checks_hp_cost`, not `test_take_quest`)
- Run full suite: `Godot --headless --quit tests/test_runner.tscn`

---

## Current State

### ✅ Done

| Feature | Files | Status |
|---------|-------|--------|
| **Test Infrastructure** | `tests/test_helper.gd`, `tests/test_runner.gd`, `tests/test_runner.tscn` | Minitest-style `TestCase` with `assert_*` helpers, fresh instance per test, compact output, and CI failure exit codes. |
| **PlayerStats Model** | `scripts/models/player_stats.gd` | HP, level, state, quest cost, rebirth, facility preservation. 13/13 specs pass. |
| **PlayerStats Spec** | `tests/specs/player_stats_test.gd` | 13 tests covering initialization, quest cost, death, rebirth, facility preservation. |
| **Player Sprite** | `assets/player.png` | Full LPC spritesheet, 13 columns × 21 rows, animated through `frame_coords`. |
| **HP Display** | `scenes/test_runner_scene.tscn` | Live `Label` showing status, level, HP. Updates on quest/rebirth. |
| **Click-to-Move** | `scripts/controllers/player_movement.gd` | Sprite2D with `move_to(target)` - smooth movement at 200px/s with destination marker. |
| **Quest/Rebirth Input** | `scripts/controllers/demo_controller.gd` | Q = take quest, C = complete, A = abandon, R = rebirth, F = debug move. |

### 🔴 Not Started

| Feature | Priority | Notes |
|---------|----------|-------|
| **QuestManager Model** | `scripts/models/quest_manager.gd` | Catalog, multi-quest tracking, HP-based affordability. 8 active quests max. 55/55 specs pass. |
| **QuestManager Spec** | `tests/specs/quest_manager_test.gd` | 8 specs: catalog, take, complete, abandon, HP check, rejection message, reset. |
| **NPC Interaction** | Medium | Quest panel, click-to-interact |
| **PlayerMovement (full)** | Medium | Pathfinding, direction flip, animation frames |
| **HUD** | Medium | HP bar, quest tracker, level display |
| **Combat System** | Low | Enemy encounters, damage, death |
| **Facilities** | Low | Shop, blacksmith, storage, guild |
| **Class System** | Low | Swordsman unlocks, skills |

### Progress Matrix

```
Prototype Spec Criteria:
  [✅] Quest cost deducts 40 HP (model + UI)
  [✅] Rebirth resets to level 1
  [✅] Facilities survive rebirth
  [✅] HP display
  [✅] Click-to-move
  [❌] Pathfinding
  [❌] NPC → quest panel
  [❌] Quest panel (name + Take button)
  [✅] Complete quest deducts 40 HP
  [✅] Escape quits
  [✅] Multiple active quests
  [✅] HP-based quest affordability
  [✅] Rejection message on insufficient HP
```

---

## Scene: TestRunnerScene

`res://scenes/test_runner_scene.tscn` - the interactive demo scene.

```
TestRunnerScene (Node2D, 1280×720)
├── UI (Control, full-screen)
│   └── HPLabel (Label)         ← Status, level, HP
├── Player (Sprite2D)            ← Player sprite, 2× scale
│   └── player_movement.gd      ← Click-to-move
└── DestinationMarker (Sprite2D) ← Yellow dot, follows target
```

**Controls:**
- **Left-click** → Move player to clicked position
- **Q** → Take quest (-40 HP, if HP ≥ cost)
- **C** → Complete first active quest
- **A** → Abandon first active quest
- **R** → Rebirth (reset HP to 100, level 1, clear quests)
- **F** → Debug: move to bottom-right
- **Ctrl+C** → Quit

---

## Key Scripts

### `scripts/models/player_stats.gd`
Pure business logic. No Godot APIs.

```gdscript
class_name PlayerStats
extends Object

var max_hp: int = 100
var level: int = 1
var state: String = "alive"
var unlocked_facilities: Array[String] = []

func take_quest() -> void:
    max_hp -= 40
    if max_hp <= 0:
        max_hp = 0
        state = "dead"

func complete_quest() -> void:
    max_hp -= 40
    if max_hp <= 0:
        max_hp = 0
        state = "dead"

func rebirth() -> void:
    max_hp = 100
    level = 1
    state = "alive"
```

### `scripts/models/quest_manager.gd`
Quest catalog and lifecycle management. No hard limit per life - affordability checked via HP.

```gdscript
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary] = []
var active_quests: Array[Dictionary] = []
var quests_taken: int = 0
var last_rejection = null
const QUEST_HP_COST: int = 40

func add_quest(name: String, cost: int, description: String) -> void
func take_quest(current_hp: int) -> bool   # returns false if HP < cost
func complete_quest() -> bool               # removes first active quest
func abandon_quest() -> bool                # removes first active quest
func reset_for_life() -> void               # clears active quests + counter
```

**Design decisions:**
- `active_quests` is an array - player can have multiple active quests
- `take_quest(current_hp)` checks affordability - rejects with `last_rejection = "not_enough_hp"`
- `complete_quest()` and `abandon_quest()` remove the **first** active quest (FIFO)
- No hard limit per life - progression scales with HP
- `reset_for_life()` clears active quests and counter for rebirth

### `scripts/controllers/player_movement.gd`
Handles click-to-move animation with destination marker.

```gdscript
class_name PlayerMovement
extends Sprite2D

@export var move_speed: float = 200.0
var destination: Vector2 = Vector2.ZERO
var moving: bool = false
```

### `scripts/controllers/demo_controller.gd`
Scene controller - input → model calls → view updates.

```gdscript
## Q = quest, R = rebirth, Left-click = move
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _player_sprite.move_to(event.position)
    elif event.keycode == KEY_Q:
        _player.take_quest()
        _update_display()
    # ...
```

### `tests/test_helper.gd`
Shared Minitest-style test base class.

```gdscript
class_name TestCase
extends Object

func assert_eq(expected, actual, message: String = "") -> bool: ...
func assert_true(condition: bool, message: String = "") -> bool: ...
func assert_in(expected_item, collection, message: String = "") -> bool: ...
```

---

## Build & Run

### Development
```bash
# Open in Godot editor
# Run test_runner_scene.tscn
# Click to move, Q/R for quest/rebirth
```

### Test Suite (Godot MCP Preferred)
For agent work, prefer Godot MCP so results come from the running editor/runtime:

1. Open `tests/test_runner.tscn`.
2. Call `godot_mcp_play_scene`.
3. Call `godot_mcp_get_godot_errors`.
4. Read the output log.

Expected successful output:
```text
Running 40 tests
........................................

55 tests, 55 passed, 0 failed
```

### Test Suite (Headless / CI)
```bash
"C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" \
    --headless --quit tests/test_runner.tscn
```
The test runner exits with code `1` when any spec fails.

### Filtered Test Run
```bash
"C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" \
    --headless --quit tests/test_runner.tscn -- --filter TestCase
```

### CI/CD (GitHub Actions)
```yaml
# .github/workflows/tests.yml
- run: Godot --headless --quit tests/test_runner.tscn
  on: push to tests/**
```

---

## Sprite Generation

Generated via `tools/lpc-sprite-gen/generate.py`:

```bash
cd tools/lpc-sprite-gen
python generate.py make '{
  "body_type": "male",
  "selections": {
    "shadow": {"id": "shadow"},
    "body": {"id": "body"},
    "head": {"id": "heads_human_male"},
    "hair": {"id": "hair_wavy", "palette_variant": "auburn"},
    "clothes": {"id": "torso_clothes_leather"},
    "legs": {"id": "legs_pants"},
    "shoes": {"id": "feet_boots_basic"},
    "weapon": {"id": "weapon_sword_longsword"}
  }
}' --out output/player.png
```

Runtime uses the full `assets/player.png` sheet. Do not crop it to single-row animation strips.

---

## Commit History

| Hash | Message |
|------|---------|
| `c830273` | Guard null rejection reason in demo controller |
| `6c1e4a0` | active_quests array, multi-quest tracking |
| `d1b2f3e` | HP-based affordability, remove hard quest limit |
| `8e7a9c1` | Add 50 quests to demo for extended QA |
| `558c672` | Restructure test framework, Minitest assertions |
| `0c21cb3` | Stop tracking uid_cache.bin |
| `74ef677` | Ignore .godot/uid_cache.bin |
| `94ce4c5` | Bug fixes, movement, LPC sprite, idle animation |
| `ea28ccd` | Add .codex/ to .gitignore |
| `9ba5b9c` | Add .codex/ to .gitignore |
| `336ab9c` | Update Godot UID cache after animation controller changes |
| `fe4cfc3` | Add AnimationController with idle/walk animation system |
| `9a3748f` | Add Godot UID cache files for PlayerMovement script |
| `1b85cc5` | Add project status documentation (docs/STATUS.md) |
| `cde1a25` | Add click-to-move with player movement system |
| `22f71d2` | Add player sprite and HP display demo scene |
| `dbe8a84` | Rename spec to name_test.gd convention |
| `c2f9608` | Extract TestCase base class from spec duplication |
| `b80642c` | Add .gdignore to skip LPC spritesheets from Godot import |

---

## TODO

1. **NPC scene** — click-to-interact, quest panel
2. **PlayerAnimation** — frame switching (idle, walk, combat)
3. **HUD** — HP bar, quest tracker
4. **Combat** — enemy encounters, damage
5. **Facilities** — shop, blacksmith, storage, guild
6. **Class System** — swordsman unlocks, skills
