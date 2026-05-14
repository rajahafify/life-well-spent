# Rebirth

## Core Idea

Run restart after Life is spent.

## Trigger

- Life reaches 0.
- Swordsman Guild unlock shown.
- Game Over screen asks if life was well spent.

## Verbs

- Die
- Judge
- Reborn
- Restart

## Rules

On Reborn:
- Life resets to 100.
- Max Life resets to 100 unless meta rules later preserve sacrifices differently.
- Aging sprite resets to Born.
- Inventory resets to empty equipment, consumable, shortcut, and item stacks.
- Swordsman Guild unlock persists through `ProfileSystem`.
- Current run XP reset/persist remains TBD.

## Current Implementation

- Town shows `UI/RebirthPanel` as the Game Over run summary after final Swordsman Guild certification.
- The panel summarizes run items and unlocked facilities.
- The Rebirth button calls `PlayerStats.rebirth()` and resets run inventory.
- The End Game button returns to the main menu.
- Starting New Game after End Game auto-rebirths the ended run before Town loads, preserving persistent unlocks.
- `ProfileSystem` saves the persistent player profile to `user://life_well_spent_profile.json`.

## Open Decisions

- Does XP reset per run or track lifetime too?
- What does Reborn No do?
