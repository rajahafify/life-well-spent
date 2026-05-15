---
title: Main Menu Scene
type: reference
updated: 2026-05-15
tags: [scenes, ui, entry-point]
---

# Main Menu Scene

## Overview

The entry point scene for Life Well Spent. It keeps Continue, New Game, and Quit center stage, then shows `icon.png` lower below the menu as a young-to-old player aging image. The background color follows the green tone of the icon. Continue preserves progress and normalizes any ended run through rebirth before Town. New Game opens a reset confirmation and starts from zero only after confirmation.

## Scene Structure

```text
MainMenu (Control)
  Background (ColorRect, icon-green)
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
  IconContainer (CenterContainer, lower screen band)
    AgingImage (TextureRect, icon.png)
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
- **Centered actions:** CenterContainer to VBoxContainer with shrink-centered title/buttons so the wide image does not pull the controls left.
- **Aging image:** `IconContainer` is separate from the menu container and starts lower on the screen so `AgingImage` can sit below the centered controls without cropping the Quit button.
- **Icon-matched background:** The full-screen `Background` uses the icon's green family to make the image feel native to the menu.
- **Continue:** If `ProfileSystem.player().game_over_requested` is true, Continue calls `PlayerStats.rebirth()`, resets `InventorySystem`, saves the profile, and preserves persistent unlocks such as `swordsman_guild`.
- **New Game:** Opens a confirmation panel. Confirming resets `PlayerStats` through `apply_dict({})`, resets `InventorySystem`, saves the profile, and enters Town from zero progress.
- **Quit button:** Calls `get_tree().quit()`.

## Specs

- `tests/specs/main_menu_test.gd` covers scene structure, aging image wiring below the menu, lower image spacing, centered title/buttons, icon-colored background, button text, Continue auto-rebirth preservation, New Game confirmation, and confirmed progress reset.

## Related

- [Main Menu Flow](../architecture/main-menu-flow.md)
- `scenes/town_scene.tscn`
- `scripts/models/player_stats.gd`
