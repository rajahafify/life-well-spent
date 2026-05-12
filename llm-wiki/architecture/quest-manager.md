---
title: QuestManager
type: concept
updated: 2026-05-12
sources:
  - scripts/models/quest_manager.gd
  - scripts/managers/quest_system.gd
  - tests/specs/quest_manager_test.gd
  - AGENTS.md
tags: [architecture, game-design]
---

# QuestManager

## Overview

`QuestManager` is pure quest state and rules. Legacy catalog quests still support free acceptance, active quest tracking, linked life-task quests, and save serialization.

The model now also owns the prototype's core progression: main quest `Explore the World`, current objective, main quest checkpoints, `Rebuilding Swordsman Guild` side quest chain, and earned certifications. `QuestSystem` is the game-wide autoload boundary used by scenes.

## API

```gdscript
class_name QuestManager
extends Object

var quest_catalog: Array[Dictionary]
var active_quests: Array[Dictionary]
var quests_taken: int
var last_rejection
var main_quests: Dictionary
var side_quest_chains: Dictionary
var certifications: Dictionary

func add_quest(name: String, cost: int, description: String) -> void
func add_life_task_quest(name: String, cost: int, description: String, life_task_id: String) -> void
func take_quest(current_hp: int) -> bool
func complete_quest() -> bool
func complete_quest_for_life_task(life_task_id: String) -> bool
func abandon_quest() -> bool
func reset_for_life() -> void

func setup_core_quests() -> void
func current_main_objective_id(main_id: String = "explore_the_world") -> String
func current_main_objective_text(main_id: String = "explore_the_world") -> String
func advance_main_quest_objective(main_id: String, objective_id: String) -> bool
func mark_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func has_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func current_main_checkpoint_text(main_id: String = "explore_the_world") -> String
func is_side_quest_active(chain_id: String) -> bool
func side_quest_step(chain_id: String) -> int
func advance_side_quest_step(chain_id: String) -> bool
func complete_side_quest_chain(chain_id: String) -> bool
func has_certification(certification_id: String) -> bool

func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- `QuestManager` stays model-only: no Node references, no scene calls, no UI decisions.
- `QuestSystem` exists because Field and Town both need the same quest state across scene changes.
- The main quest starts as `Explore the World` with objective `Find the Forest path.`
- Reaching the Field Forest Gate marks the `forest_guard` checkpoint, advances the objective to `Get Swordsman Certification.`, and activates the `Rebuilding Swordsman Guild` side quest chain.
- The `Rebuilding Swordsman Guild` side chain tracks ordered step state from 0 to 3.
- Completing `Rebuilding Swordsman Guild` grants `swordsman_certification`.
- Acceptance remains free; Max Life spending belongs to quest completion/progression callers.

## Test Coverage

- `tests/specs/quest_manager_test.gd` covers catalog quests, active quest lifecycle, free acceptance, reset, core main quest setup, Forest Guard checkpoint state, Forest Gate objective advancement, side chain activation, side-chain step advancement/bounds, certification grant, and save round-trip.
- `tests/specs/field_scene_test.gd` covers Field using `QuestSystem` and advancing the main objective when the player enters the Forest Gateway.
- `tests/specs/town_scene_dialog_test.gd` covers the Guildmaster reacting to the `Get Swordsman Certification` objective.

## Related

- `PlayerStats`
- `LifeTracker`
- `ProgressionModel`
- `Field Scene`
- `Town Scene`
