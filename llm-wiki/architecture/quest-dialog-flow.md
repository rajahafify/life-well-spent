---
title: QuestDialogFlow
type: reference
updated: 2026-05-14
sources:
  - scripts/models/quest_dialog_flow.gd
  - tests/specs/quest_dialog_flow_test.gd
  - scripts/controllers/town_scene_controller.gd
tags: [architecture, dialog, quests]
---

# QuestDialogFlow

## Overview

`QuestDialogFlow` is the pure dialog-state model for quest-giver panels. It standardizes future quest NPCs around four panel states: normal dialog, incomplete quest, completed quest with claim action, and reward result.

## API

```gdscript
func normal_panel(title: String, body: String) -> Dictionary
func quest_panel(title: String, intro_text: String, claim_text: String, objective_text: String, is_complete: bool) -> Dictionary
func reward_item_panel(display_name: String, quantity: int = 1) -> Dictionary
func reward_unlock_panel(display_name: String) -> Dictionary
func reward_text_panel(body: String) -> Dictionary
```

## Design Decisions

- The flow model returns plain Dictionaries so scene controllers can pass the same state to `TownDialogView` without coupling the model to Nodes.
- Incomplete quest panels show objective copy with Close only.
- Completed quest panels expose `Claim Reward`; `TownDialogView` only shows that action on the final page of the dialog flow.
- Reward panels use the standard `Reward` title and no quest action button.
- Town still owns side effects such as granting items, spending Life, saving the profile, and showing rebirth; the flow model only owns panel shape and copy assembly.

## Test Coverage

- `tests/specs/quest_dialog_flow_test.gd` covers normal, incomplete quest, completed quest, item reward, and unlock reward panel states.
- `tests/specs/town_dialog_view_test.gd` covers final-page-only Claim Reward and Close button visibility.
- `tests/specs/town_scene_dialog_test.gd` covers Town applying the reusable flow to Guildmaster dialogs.

## Related

- [NPC System](npc-system.md)
- [QuestSystem](quest-system.md)
- [Town Hub](../scenes/town-hub.md)
