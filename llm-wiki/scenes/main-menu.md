---
title: Main Menu Scene
type: reference
updated: 2026-05-15
tags: [scenes, ui, entry-point]
---

# Main Menu Scene

## Overview

The entry point scene for Life Well Spent. It displays the game title with Continue, New Game, and Quit buttons. Continue preserves progress and normalizes any ended run through rebirth before Town. New Game opens a reset confirmation and starts from zero only after confirmation.

## Scene Structure

```text
MainMenu (Control)
  CenterContainer
    UI (VBoxContainer)
      Title (Label)
      ContinueButton (Button)
      NewGameButton (Button)
      NewGameConfirmPanel (PanelContainer)
        VBox
          MessageLabel
          ConfirmButton
          CancelButton
      QuitButton (Button)
```

## Controller: MainMenuController

```gdscript
class_name MainMenuController
extends Control

func continue_existing_run(profile_system, inventory_system) -> bool
func start_new_game_from_zero(profile_system, inventory_system) -> bool
```

## Design Decisions

- **Thin controller:** Handles button signals and delegates continue/reset rules to small helpers before scene transition.
- **Centered layout:** CenterContainer to VBoxContainer with centered buttons.
- **Continue:** If `ProfileSystem.player().game_over_requested` is true, Continue calls `PlayerStats.rebirth()`, resets `InventorySystem`, saves the profile, and preserves persistent unlocks such as `swordsman_guild`.
- **New Game:** Opens a confirmation panel. Confirming resets `PlayerStats` through `apply_dict({})`, resets `InventorySystem`, saves the profile, and enters Town from zero progress.
- **Quit button:** Calls `get_tree().quit()`.

## Specs

- `tests/specs/main_menu_test.gd` covers scene structure, button text, Continue auto-rebirth preservation, New Game confirmation, and confirmed progress reset.

## Related

- [Main Menu Flow](../architecture/main-menu-flow.md)
- `scenes/town_scene.tscn`
- `scripts/models/player_stats.gd`
