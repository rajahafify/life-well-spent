---
title: Main Menu Flow
type: reference
updated: 2026-05-15
sources:
  - scenes/main_menu.tscn
  - scripts/controllers/main_menu_controller.gd
  - tests/specs/main_menu_test.gd
tags: [architecture, ui, flow]
---

# Main Menu Flow

## Overview

`MainMenuController` separates continuing a saved run from starting over. The scene keeps the menu controls centered and presents the player aging premise through a smaller `icon.png` image lower below the buttons. On short/720p viewports, the aging image shrinks and sits lower so it does not cover the menu. `Continue` preserves persistent progress and uses auto-rebirth only when the saved player ended a run. `New Game` is destructive and requires confirmation before resetting progress.

## API

```gdscript
func continue_existing_run(profile_system, inventory_system) -> bool
func start_new_game_from_zero(profile_system, inventory_system) -> bool
```

## Design Decisions

- `Continue` keeps the previous prototype behavior: if `game_over_requested` is true, it calls `PlayerStats.rebirth()`, resets runtime inventory, saves, and enters Town while preserving unlocked facilities.
- `New Game` opens a confirmation panel with the warning `starting a new game will reset progress`.
- Confirming New Game resets `PlayerStats` through `apply_dict({})`, clears runtime inventory, saves the profile, and enters Town with no unlocked facilities.
- The destructive path is explicit so End Game from Summary can return to Main Menu without silently resetting or rebirthing the player.
- The visual treatment stays in the scene/controller boundary: `Background` uses the icon's green tone, shrink-centered action controls keep the menu aligned, and `IconContainer` positions the young-to-old player art lower with a responsive 720p size.
- Controller menu support uses D-pad up/down to select buttons, `A` to activate, and `B` to cancel the New Game confirmation.

## Test Coverage

- `tests/specs/main_menu_test.gd` covers aging image wiring below the menu, lower image spacing, 720p-safe aging image sizing, centered action controls, icon-colored background, Continue button structure/text, Continue auto-rebirth preservation, active-run Continue no-op, controller New Game confirmation selection, New Game confirmation visibility, and confirmed New Game progress reset.

## Related

- [Game Over Summary Flow](game-over-summary-flow.md)
- [ProfileSystem](profile-system.md)
- [PlayerStats](player-stats.md)
