---
title: Run Summary Model
type: reference
tags: [architecture, model, progression]
sources:
  - scripts/models/run_summary_model.gd
  - tests/specs/run_summary_model_test.gd
  - scripts/controllers/town_scene_controller.gd
---

# Run Summary Model

## Overview

`RunSummaryModel` is a pure model that formats the Game Over run summary shown after the prototype Swordsman Guild certification endpoint. It reads the current inventory item rows and player facility unlocks, then returns stable display lines for the Town Game Over panel.

## API

```gdscript
func summary_lines(player_stats, inventory) -> Array[String]
func summary_text(player_stats, inventory) -> String
```

## Design Decisions

- Town owns the Game Over panel, button wiring, scene transition, rebirth reset, and profile save side effects.
- The summary model only formats data. It does not depend on nodes, scenes, or autoloads.
- Prototype run items are summarized from the current inventory. Rebirth resets run inventory after the player chooses Rebirth.
- If the player chooses End Game instead, Main Menu auto-rebirths the ended run on the next New Game before entering Town.
- Facility IDs are mapped to readable unlock names such as `Swordsman Guild`.

## Test Coverage

- `tests/specs/run_summary_model_test.gd` covers item and unlock summary lines.
- `tests/specs/run_summary_model_test.gd` covers the empty-run fallback text.
- `tests/specs/town_scene_dialog_test.gd` covers the final certification Game Over panel summary, Rebirth reset, and End Game routing.

## Related

- [Town Hub](../scenes/town-hub.md)
- [Player Stats](player-stats.md)
- [Inventory Model](inventory-model.md)
