---
title: Spec-Driven Development
type: decision
updated: 2026-05-09
sources:
  - AGENTS.md
  - tests/specs/
tags: [architecture]
---

# Spec-Driven Development

## Decision
Every feature starts with a spec. No code is written until the spec is approved. Specs are **executable Godot `TestCase` scripts**, not JSON data. This ensures clarity, prevents scope creep, and keeps the MVC layers properly separated.

## Spec Format
Specs are GDScript files extending `TestCase`, stored in `tests/specs/`.

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

func test_zero_hp_triggers_death():
	player.max_hp = 40
	player.take_quest()  # deducts 40 → 0
	assert_eq(player.state, "dead")
```

### Spec Conventions
- **Naming:** `test_<method_name>.gd` — one spec file per model/feature
- **Class name:** `Test<ClassName>` — matches the class under test
- **Methods:** `func test_<behavior_description>():` — one assertion per method
- **Assertions:** `assert_eq()`, `assert_neq()`, `assert_true()`, `assert_false()`, `assert_is()`, `assert_is_not()`, `assert_in()`, `assert_has()`, `assert_raises()`
- **Setup/Teardown:** `func setup():` before each test, `func teardown():` after
- **Class setup:** `func class_setup():` once before all tests in the class

### Workflow
1. **Red** — Write the spec. It should fail (assertion will not pass yet).
2. **Green** — Write the minimum code to make the spec pass.
3. **Refactor** — Clean up, add more edge-case specs, ensure nothing breaks.

### Workflow (Feature Level)
1. **Draft** — Write the `acceptance_criteria` list in a spec JSON or markdown file.
2. **Approve** — User confirms the criteria are complete and unambiguous.
3. **Implement** — Model first (pure logic), then Controller (thin glue), then View (UI update).
4. **Verify** — Run the full spec suite. All must pass.

## Rule
> If the spec doesn't cover it, it doesn't exist. Never add "just one more thing" without updating the spec.

## Rationale
- Specs force you to think through edge cases before implementation.
- They serve as living documentation for each feature.
- They make it trivial to verify "done" — just check each criterion.
- They keep the spec as the single source of truth, not scattered conversation.
