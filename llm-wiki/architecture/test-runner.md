---
title: Test Runner
type: reference
updated: 2026-05-09
sources:
  - scripts/managers/test_runner.gd
  - tests/test_runner.tscn
  - AGENTS.md
tags: [architecture]
---

# Test Runner

## Purpose
Discovers and executes all `TestCase`-based specs from `tests/specs/`, reports pass/fail with assertion details.

## Usage
- **In-game:** Open `tests/test_runner.tscn` — discovers specs, runs them, displays results.
- **Headless CI:** `godot --headless --quit res://tests/test_runner.tscn`
- **Via code:** `TestRunner.run_all()` returns a `Dictionary` with pass/fail counts.
- **Via code:** `TestRunner.run_with_output()` prints results to console and returns results.

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
	assert_eq(player.max_hp, 100)

func test_quest_deducts_hp():
	player.take_quest()
	assert_eq(player.max_hp, 60)
```

## Runner Behavior
1. Scans `tests/specs/` for `.gd` files containing classes that extend `TestCase`.
2. Loads each spec class, instantiates it, runs `class_setup()` once.
3. For each `test_*` method: calls `setup()`, runs the test, calls `teardown()`.
4. Aggregates results: total tests, passed, failed, and failure details (assertion + message).
5. Prints summary to console. Displays results in the test runner scene UI.

## Assertions Available
| Method | Description |
|--------|-------------|
| `assert_eq(a, b)` | `a == b` |
| `assert_neq(a, b)` | `a != b` |
| `assert_true(x)` | `x == true` |
| `assert_false(x)` | `x == false` |
| `assert_is(obj, cls)` | `obj is cls` |
| `assert_is_not(obj, cls)` | `obj is not cls` |
| `assert_in(item, collection)` | `item in collection` |
| `assert_has(dict, key)` | `key in dict` |
| `assert_raises(func, args)` | `func` raises an error |

## File Types
- Specs: `tests/specs/test_<name>.gd` — must extend `TestCase`
- Runner: `tests/test_runner.tscn` — scene that orchestrates discovery and display
- Spec metadata (optional): `tests/specs/<name>_spec.json` — acceptance criteria reference, not execution
