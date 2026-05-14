---
title: Field Runtime Context
type: reference
tags: [architecture, field, controller-boundary]
sources:
  - scripts/controllers/field_runtime_context.gd
  - scripts/controllers/field.gd
  - tests/specs/field_runtime_context_test.gd
---

# Field Runtime Context

## Overview

`FieldRuntimeContext` is the controller-side construction boundary for Field runtime collaborators. It owns the pure model and helper-controller instances used by `Field`, keeping the scene controller focused on node binding, signal routing, and view updates.

## API

```gdscript
var behavior
var combat
var drop_system
var camera_controller
var spawn_controller
var combat_controller
var player_aging
var equipment_stats

func randomize_runtime() -> void
func dispose() -> void
```

## Design Decisions

- `Field` still owns scene nodes and direct scene interactions.
- `FieldRuntimeContext` lives under `scripts/controllers/` because it preloads helper controllers as well as pure models.
- `FieldRuntimeContext` owns collaborator construction and cleanup for enemy behavior, combat, drops, camera, spawning, combat ticking, player aging, and equipment stats.
- Cleanup uses `is_instance_valid()` before freeing each collaborator.
- Field tuning constants live in `GameBalance`, not in the scene controller.
- This is intentionally a small extraction. It reduces controller construction debt without changing runtime behavior.

## Test Coverage

- `tests/specs/field_runtime_context_test.gd` covers required collaborator construction and cleanup.
- `tests/specs/game_balance_test.gd` covers centralized Field tuning constants.
- `tests/specs/field_scene_test.gd` covers Field behavior after the extraction.

## Related

- [Field Controller Boundaries](field-controller-boundaries.md)
- [Field Scene](../scenes/field.md)
- [GameBalance](game-balance.md)
