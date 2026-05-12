---
title: QuestSystem
type: reference
updated: 2026-05-12
sources:
  - scripts/managers/quest_system.gd
  - scripts/models/quest_manager.gd
  - tests/specs/quest_manager_test.gd
  - tests/specs/field_scene_test.gd
  - tests/specs/town_scene_dialog_test.gd
tags: [architecture, quest, prototype]
---

# QuestSystem

## Overview

`QuestSystem` is the game-wide autoload for runtime quest progression. It wraps pure `QuestManager` state so Field and Town can share main quest, checkpoint, side quest chain, and certification state across scene changes.

## API

```gdscript
func reset() -> void
func setup_core_quests() -> void
func current_main_objective_id(main_id: String = "explore_the_world") -> String
func current_main_objective_text(main_id: String = "explore_the_world") -> String
func advance_main_quest_objective(main_id: String, objective_id: String) -> bool
func mark_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func has_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func current_main_checkpoint_text(main_id: String = "explore_the_world") -> String
func is_side_quest_active(chain_id: String) -> bool
func complete_side_quest_chain(chain_id: String) -> bool
func has_certification(certification_id: String) -> bool
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- The autoload owns runtime state; `QuestManager` owns pure rules.
- Field marks the `forest_guard` checkpoint and advances `Explore the World` from `Find the Forest path.` to `Get Swordsman Certification.` when the player enters the Forest Gateway.
- That objective activates `Rebuilding Swordsman Guild`, which is a side quest chain rather than a standalone `forest_gate_seen` flag.
- Town reads the current objective so the Guildmaster can point the player toward rebuilding the Swordsman Guild.

## Test Coverage

- `tests/specs/quest_manager_test.gd` covers pure quest progression rules.
- `tests/specs/field_scene_test.gd` covers Field integration, including Forest Guard checkpoint and Quest Window refresh.
- `tests/specs/town_scene_dialog_test.gd` covers Town dialog integration.

## Related

- [QuestManager](quest-manager.md)
- [Field Scene](../scenes/field.md)
- [Town Scene](../scenes/town-hub.md)
