# Prototype / Town

Focus: first playable scene.

## Goal

Town is safe base. Player starts here, learns core premise, can talk to NPCs, sees locked Swordsman Guild path, and can leave to Starter Area.

## Scene Requirements

- [ ] Create/rename scene concept as `Town`.
- [ ] Player spawns in Town.
- [ ] Town has visible exit to Starter Area.
- [ ] Town has Swordsman Guild NPC/location.
- [ ] Town has basic NPC dialog flow.
- [ ] Town HUD shows run state.
- [ ] Town can receive state from Starter Area after Forest Guard encounter.

## Town Nodes

- [ ] `Town` root controller.
- [ ] `Player` instance.
- [ ] `Camera2D` following player.
- [ ] `UI` layer.
- [ ] `HUD`.
- [ ] `DialogPanel`.
- [ ] `QuestStatusPanel`.
- [ ] `StarterAreaExit` trigger/click zone.
- [ ] `SwordsmanGuildNpc`.
- [ ] Optional `Vendor` placeholder.
- [ ] Optional `TownGuard` placeholder.
- [ ] Optional `Elder` placeholder.

## HUD

- [ ] Life: `100 / 100`.
- [ ] Combat HP.
- [ ] XP score.
- [ ] Weapon slot.
- [ ] Armor slot.
- [ ] Consumable slot/count.
- [ ] Current aging sprite state.
- [ ] Active quest chain step if unlocked.

## NPC Dialogs

### Swordsman Guild NPC

- [ ] Before Forest Guard encounter: says certification not available / come back later.
- [ ] After Forest Guard encounter: offers `SWORDSMAN GUILD: QUEST`.
- [ ] Shows chain step 1/3, 2/3, 3/3.
- [ ] Completing each step costs 40 Life.
- [ ] Step 1 completion changes player to Sprite 1.
- [ ] Step 2 completion changes player to Sprite 2.
- [ ] Step 3 completion unlocks Swordsman Guild and goes to Game Over.

### Optional Flavor NPCs

- [ ] Vendor: placeholder shop line only.
- [ ] Town Guard: warns about outside danger.
- [ ] Elder: explains “life spent” theme.

## Town State

- [ ] `life = 100` on new run.
- [ ] `swordsman_quest_unlocked = false` initially.
- [ ] `swordsman_chain_step = 0` initially.
- [ ] `forest_gate_seen = false` initially.
- [ ] `aging_sprite_state = 0` initially.
- [ ] State updates when returning from Starter Area after Guard blocks Forest.

## Starter Area Exit

- [ ] Player can leave Town to Starter Area.
- [ ] Transition preserves run state.
- [ ] Return path from Starter Area lands at Town entrance spawn.

## Inventory Display

- [ ] Weapon: `Wooden Sword`.
- [ ] Armor: `Cloth Armor`.
- [ ] Consumable: `Apple x3`.
- [ ] Inventory UI is read-only for first Town slice.

## First Playable Slice

1. Player starts in Town.
2. HUD shows Life, HP, XP, and starter inventory.
3. Player talks to Swordsman Guild NPC.
4. NPC says certification unavailable until needed.
5. Player exits to Starter Area.
6. Later return from Guard encounter unlocks guild quest.
7. Swordsman Guild NPC offers quest chain.

## Tests

- [ ] Town scene loads.
- [ ] Player exists in Town.
- [ ] HUD labels exist and display starting state.
- [ ] StarterAreaExit exists.
- [ ] SwordsmanGuildNpc exists.
- [ ] Guild NPC does not offer quest before Forest Guard encounter.
- [ ] Guild NPC offers quest after `forest_gate_seen = true`.
- [ ] Quest step 1 costs 40 Life and sets aging sprite state to 1.
- [ ] Quest step 2 costs 40 Life and sets aging sprite state to 2.
- [ ] Quest step 3 costs 40 Life, unlocks Swordsman Guild, and requests Game Over.

## Open Decisions

- [ ] Town layout: top-down free movement vs menu-like hub zones.
- [ ] Exact Swordsman Guild NPC name.
- [ ] Exact dialogue lines.
- [ ] Whether first Town slice includes combat HP or hides until Starter Area.
