---
title: QuestManager
type: concept
updated: 2026-05-13
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
var town_reborn_intro_seen: bool

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
func current_side_quest_objective_text(chain_id: String) -> String
func record_enemy_defeated(enemy_id: String) -> bool
func record_item_gathered(item_id: String, quantity: int = 1) -> bool
func is_current_side_quest_step_complete(chain_id: String) -> bool
func advance_side_quest_step(chain_id: String) -> bool
func complete_side_quest_chain(chain_id: String) -> bool
func has_seen_town_reborn_intro() -> bool
func mark_town_reborn_intro_seen() -> bool
func has_certification(certification_id: String) -> bool

func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- `QuestManager` stays model-only: no Node references, no scene calls, no UI decisions.
- `QuestSystem` exists because Field and Town both need the same quest state across scene changes.
- The main quest starts as `Explore the World` with objective `Find the Forest path.`
- Reaching the Field Forest Gate marks the `forest_guard` checkpoint, advances the objective to `Get Swordsman Certification.`, and activates the `Rebuilding Swordsman Guild` side quest chain.
- The `Rebuilding Swordsman Guild` side chain tracks ordered step state from 0 to 3, per-step objective progress, and exposes the current Guildmaster quest objective text:
  - Step 0: `Defeat 10 Slimes for Guildmaster stance training.`
  - Step 1: `Gather 2 Bat Wings for Guildmaster guard training.`
  - Step 2: `Defeat 2 Rats for the Guildmaster's Life oath.`
  - Step 3: `Swordsman Guild unlocked.`
- `record_enemy_defeated()` only advances defeat objectives when the defeated enemy matches the current objective. Wrong enemy defeats are ignored.
- `record_item_gathered()` advances gather objectives when the item id matches the current objective.
- `advance_side_quest_step()` refuses to advance the Swordsman Guild chain until `is_current_side_quest_step_complete()` is true.
- Completing `Rebuilding Swordsman Guild` grants `swordsman_certification`.
- After certification, the main objective can advance to `Enter the Forest.` for the prototype endpoint.
- Town reborn intro display is tracked once per runtime through quest state so returning to Town does not replay the intro.
- Acceptance remains free; Max Life spending belongs to quest completion/progression callers.

## Test Coverage

- `tests/specs/quest_manager_test.gd` covers catalog quests, active quest lifecycle, free acceptance, reset, core main quest setup, Forest Guard checkpoint state, Forest Gate objective advancement, side chain activation, defeat objective progress, gather objective progress, wrong-event filtering, side-chain step gating/bounds, certification grant, Town reborn intro once-state, Forest endpoint objective, and save round-trip.
- `tests/specs/field_scene_test.gd` covers Field using `QuestSystem`, advancing the main objective when the player enters the Forest Gateway, Slime defeat progressing the active Swordsman Guild objective, and Bat Wing drops progressing the gather objective.
- `tests/specs/town_scene_dialog_test.gd` covers the Guildmaster reacting to the `Get Swordsman Certification` objective and hiding completion until objective progress is ready.

## Related

- `PlayerStats`
- `LifeTracker`
- `ProgressionModel`
- `Field Scene`
- `Town Scene`
