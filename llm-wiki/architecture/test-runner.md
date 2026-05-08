---
title: Test Runner
type: reference
updated: 2026-05-08
sources:
  - scripts/managers/test_runner.gd
  - AGENTS.md
tags: [architecture]
---

# Test Runner

## Purpose
Runs spec files from `resources/specs/` and reports pass/fail results.

## Usage
- **In-game:** Open `scenes/test_runner_scene.tscn` — runs all specs and displays results on screen.
- **Via code:** `TestRunner.run_all()` returns a `Dictionary` with pass/fail counts.
- **Via code:** `TestRunner.run_with_output()` prints results to console and returns results.

## Spec Format
JSON files in `resources/specs/`:
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

## Criterion Evaluation
Criteria are matched via `_evaluate_criterion()` in `test_runner.gd`:
- `"Assert true"` → always passes (baseline test)
- Extend the match statement to add new criterion types.

## File Types
Specs are loaded as JSON (`.json`) files. GDScript-based specs are not currently supported (Godot resource loading has too many edge cases).

## Screenshots
![Test Runner Output](architecture/test-runner-screenshot.png)
