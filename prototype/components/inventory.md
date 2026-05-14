# Inventory

## Core Idea

Tiny equipment system. Supports combat without becoming main game.

Current implementation:

- `scripts/models/inventory_model.gd` stores stackable item counts.
- `scripts/managers/inventory_system.gd` owns the game-wide runtime inventory instance.
- `scenes/ui/inventory_window.tscn` is the reusable inventory overlay scene.
- `scenes/ui/shared_hud.tscn` owns the shared Inventory button and `I` key toggle.
- Town and Field both use the shared HUD.
- Inventory state has three dedicated slots: `weapon_slot`, `armor_slot`, and `consumable_slot`.
- Inventory state has 9 shortcut slots mapped to number keys `1` through `9`; all shortcuts start empty.
- Weapon, Armor, and Consumable slots start empty.
- Slime has a 20% chance to drop `slime_gel`.
- Bat has a 20% chance to drop `bat_wing`.
- Rat has a 20% chance to drop `rat_tail`.
- Slime has a 5% chance to drop `apple`.
- Bat has a 5% chance to drop `training_sword`.
- Rat has a 5% chance to drop `leather_armor`.
- The inventory window lists current slots above global item stacks.
- Weapon and armor rows show an Equip button when the item is owned.
- Equipping `training_sword` updates the Weapon slot; equipping `leather_armor` updates the Armor slot; equipping `apple` updates the Consumable slot and shortcut slot `1`.
- Equipping `training_sword` adds attack and switches the player to an age-matched sword spritesheet.
- Equipping `leather_armor` adds defense and, when Training Sword is also equipped, switches the player to the age-matched sword+armor spritesheet.
- The shared HUD shortcut bar renders pronounced white slots with dark borders.
- Pressing shortcut `1` uses Apple in Field when available.

## Slots

- Weapon: 1 item
- Armor: 1 item
- Consumable: 1 item stack

## Starting Loadout

- No weapon
- No armor
- No consumable
- No item stacks

## Verbs

- Equip
- Consume
- Display

## Rules

- Enemy material drops are deterministic in the first slice.
- Apple is a chance drop from every current Field enemy: 1 in 5.
- Drop rewards are granted once per enemy defeat.
- Weapon modifies attack.
- Armor reduces combat damage.
- Apple heals 20 current Life only.
- Apple cannot restore Max Life.
- Consumable cannot be used at full current Life.
- Consumable cannot be used when count is 0.
- No backpack/grid in prototype.

## UI

HUD shows:
- weapon name/icon
- armor name/icon
- consumable name/icon/count
- shortcut bar slots `1` through `9`

Current shared HUD:

- `Inventory` button
- bottom shortcut bar with white bordered slots; pressing `1` through `9` emits the mapped shortcut slot
- modal inventory overlay listing Weapon, Armor, Consumable, and item stacks
