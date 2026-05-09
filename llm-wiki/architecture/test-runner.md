---
title: Test Runner
type: reference
updated: 2026-05-09
sources:
  - tests/test_runner.gd
  - tests/test_helper.gd
  - tests/test_runner.tscn
  - AGENTS.md
tags: [architecture]
---

# Test Runner

## Purpose
Discovers and executes all `TestCase`-based specs from `tests/specs/`, reports pass/fail with Minitest-style output, and exits non-zero for CI failures.

## Usage
- **Preferred for agents:** use Godot MCP. Open `tests/test_runner.tscn`, run `godot_mcp_play_scene`, then call `godot_mcp_get_godot_errors` and read the output log.
- **Headless/local fallback:** `godot --headless --quit tests/test_runner.tscn`
- **Filtered run:** pass `--filter <substring>` as a user arg to run matching file/class/test names.

Successful output:

```text
Running 40 tests
........................................

40 tests, 40 passed, 0 failed
```

Windows local command:

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```

Filtered Windows local command:

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn -- --filter TestCase
```

## Spec Format
GDScript files extending `TestCase`, stored in `tests/specs/`:

```gdscript
# tests/specs/test_player_stats.gd
class_name TestPlayerStats
extends TestCase

var player: PlayerStats

func setup():
	player = PlayerStats.new()

func test_initial_max_hp_is_100():
	assert_eq(100, player.max_hp)

func test_quest_deducts_hp():
	player.take_quest()
	assert_eq(60, player.max_hp)
```

## Runner Behavior
1. Scans `tests/specs/` for `.gd` files named `test_*.gd` or `*_test.gd`.
2. Loads each spec class and discovers `test_*` methods.
3. Creates a fresh spec instance for each test method.
4. Calls the framework reset hook, then `setup()`, the test method, and `teardown()`.
5. Aggregates structured results with file, class, method, message, expected, and actual values.
6. Prints compact progress output: `.` for pass, `F` for fail, followed by failure details.
7. In the CI scene, exits `1` when any spec fails.

## Assertions Available
| Method | Description |
|--------|-------------|
| `assert_eq(expected, actual)` | `actual == expected` |
| `assert_neq(unexpected, actual)` | `actual != unexpected` |
| `assert_true(x)` | `x == true` |
| `assert_false(x)` | `x == false` |
| `assert_in(item, collection)` | `item in collection` |
| `assert_has(dict, key)` | `key in dict` |
| `assert_null(value)` | `value == null` |
| `assert_not_null(value)` | `value != null` |

## File Types
- Specs: `tests/specs/test_<name>.gd` — must extend `TestCase`
- Helper: `tests/test_helper.gd` — defines `TestCase` and assertions
- Runner script: `tests/test_runner.gd` — discovers and executes specs
- Runner scene: `tests/test_runner.tscn` — tiny Godot entrypoint for CI
- Spec metadata (optional): `tests/specs/<name>_spec.json` — acceptance criteria reference, not execution
