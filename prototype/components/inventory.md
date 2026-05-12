# Inventory

## Core Idea

Tiny equipment system. Supports combat without becoming main game.

Current implementation:

- `scripts/models/inventory_model.gd` stores stackable item counts.
- `scripts/managers/inventory_system.gd` owns the game-wide runtime inventory instance.
- `scenes/ui/inventory_window.tscn` is the reusable inventory overlay scene.
- `scenes/ui/shared_hud.tscn` owns the shared Inventory button and `I` key toggle.
- Town and Field both use the shared HUD.
- Slime drops `slime_gel`.
- Bat drops `bat_wing`.
- Rat drops `rat_tail`.
- The inventory window lists current global item stacks.

## Slots

- Weapon: 1 item
- Armor: 1 item
- Consumable: 1 item stack

## Starting Loadout

- Wooden Sword
- Cloth Armor
- Apple x3

## Verbs

- Equip
- Consume
- Display

## Rules

- Enemy drops are deterministic in the first slice.
- Drop rewards are granted once per enemy defeat.
- Weapon modifies attack.
- Armor reduces combat damage.
- Apple heals current Life only.
- Apple cannot restore Max Life.
- Consumable cannot be used at full current Life.
- Consumable cannot be used when count is 0.
- No backpack/grid in prototype.

## UI

HUD shows:
- weapon name/icon
- armor name/icon
- consumable name/icon/count

Current shared HUD:

- `Inventory` button
- modal inventory overlay listing item stacks
