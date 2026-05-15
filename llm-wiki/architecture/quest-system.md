---
title: QuestSystem
type: reference
updated: 2026-05-15
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
func activate_swordsman_guild_chain() -> bool
func mark_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func has_main_checkpoint(main_id: String, checkpoint_id: String) -> bool
func current_main_checkpoint_text(main_id: String = "explore_the_world") -> String
func is_side_quest_active(chain_id: String) -> bool
func side_quest_step(chain_id: String) -> int
func current_side_quest_objective_text(chain_id: String) -> String
func record_enemy_defeated(enemy_id: String) -> bool
func record_item_gathered(item_id: String, quantity: int = 1) -> bool
func sync_current_item_objective(item_id: String, quantity: int) -> bool
func is_current_side_quest_step_complete(chain_id: String) -> bool
func advance_side_quest_step(chain_id: String) -> bool
func complete_side_quest_chain(chain_id: String) -> bool
func has_certification(certification_id: String) -> bool
func to_dict() -> Dictionary
func apply_dict(data: Dictionary) -> void
```

## Design Decisions

- The autoload owns runtime state; `QuestManager` owns pure rules.
- Field marks the `forest_guard` checkpoint and advances `Explore the World` from `Find the Forest path.` to `Get Swordsman Certification.` when the player enters the Forest Gateway.
- That objective does not activate `Rebuilding Swordsman Guild` by itself; Town starts the side chain through `activate_swordsman_guild_chain()` when the player returns and talks to Guildmaster.
- Town reads the current objective so the Guildmaster can point the player toward rebuilding the Swordsman Guild and then start that chain.
- Field reports enemy defeats through `record_enemy_defeated()` and material drops through `record_item_gathered()`, allowing shared quest state to track the 10-Slime, 2-Bat-Wing, and 2-Rat Guildmaster objectives across scene changes.
- Town syncs the Bat Wing objective from current inventory through `sync_current_item_objective()`, so already-owned Bat Wings count toward the Guildmaster guard trial.
- Town gates the Guildmaster `Claim Reward` button through `is_current_side_quest_step_complete()` so Max Life cannot be spent before the active objective is complete.
- Town quest markers use a large, outlined, pulsing `!` placed close above the NPC head: yellow for a new quest, white for active incomplete quest, and green for completed unclaimed quest. The Smith shows a yellow marker after rebirth with the Swordsman Guild unlocked.
- Town selects Guildmaster dialog copy from the current Swordsman Guild side-chain step so stance training, guard training, and the final Life oath read as distinct trials while using the same `QuestDialogFlow` panel structure.
- Reward panels use a consistent three-line format that names the reward and immediate result, and certified Guildmaster dialog points to the Forest path without repeating completed objectives.

## Test Coverage

- `tests/specs/quest_manager_test.gd` covers pure quest progression rules.
- `tests/specs/field_scene_test.gd` covers Field integration, including Forest Guard checkpoint, no early Guildmaster chain activation, Quest Window refresh, and enemy defeat objective progress.
- `tests/specs/town_scene_dialog_test.gd` covers Town dialog integration, Guildmaster chain activation, step-specific Guildmaster copy, polished reward panels, post-certification copy, `Claim Reward` button copy, reward-claim gating, and NPC quest marker colors.

## Related

- [QuestManager](quest-manager.md)
- [Field Scene](../scenes/field.md)
- [Town Scene](../scenes/town-hub.md)
