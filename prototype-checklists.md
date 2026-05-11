# Prototype Checklists

## Primary Prototype Goal

- [ ] Player-facing goal: `Reach the Forest.`
- [ ] Prototype truth: `Spend your life to unlock the Swordsman Guild.`
- [ ] End beat: `Was it a life well spent?`

## Main Flow

- [ ] Opening cinematic placeholder/TBD.
- [ ] Player starts in Town.
- [ ] Player talks to NPCs optionally.
- [ ] Player sees reborn prompt in Town.
- [ ] Player talks to Guildmaster, Shopkeeper, and Smith for simple worldbuilding dialog.
- [ ] Player leaves Town to Starter Area through glowing portal.
- [ ] Player fights Chick/Rabbit/Slime optionally.
- [ ] Player approaches Forest path.
- [ ] Forest Guard blocks player.
- [ ] Guard sends player back to Town for Swordsman Guild certification.
- [ ] Guard encounter unlocks Swordsman Guild quest in Town.
- [ ] Player returns to Town.
- [ ] Player completes 3-step Swordsman Guild quest chain.
- [ ] Each quest completion costs Life.
- [ ] Final completion unlocks Swordsman Guild and triggers Game Over.
- [ ] Game Over asks if life was well spent.
- [ ] Reborn starts new run.

## Stage 1: Ideation — Core Idea

- [ ] Core idea documented: `Spend your life to become worthy.`
- [ ] Prototype question documented: `Was it a life well spent?`
- [ ] No XP gating for Swordsman Guild.
- [ ] Swordsman Guild unlock comes from quest chain completion.
- [ ] XP is score/accomplishment measure, not gate.
- [ ] Life is thematic currency, not combat HP.

## Stage 1: Ideation — Activities

- [ ] Move through Town and Starter Area.
- [ ] Talk to NPCs.
- [ ] Explore Starter Area.
- [ ] Fight starter enemies.
- [ ] Approach Forest path.
- [ ] Get blocked by Forest Guard.
- [ ] Return to Town.
- [ ] Accept Swordsman Guild quest.
- [ ] Complete guild quest steps.
- [ ] Spend Life.
- [ ] Age through sprite states.
- [ ] Die when Life reaches 0.
- [ ] Reborn into next run.

## Stage 1: Ideation — Resources

- [ ] Life: starts at 100, cannot heal, spent by major choices.
- [ ] Combat HP: tactical health, healable by consumables.
- [ ] XP: score/accomplishment measure, never gates Swordsman Guild.
- [ ] Inventory slots: 1 weapon, 1 armor, 1 consumable stack.
- [ ] Unlocks: Swordsman Guild legacy/progression state.
- [ ] Quest State: Forest Guard seen, guild quest unlocked, chain step 0–3.

## Stage 1: Ideation — Systems

- [ ] Run State System.
- [ ] Life / Aging System.
- [ ] Town System.
- [ ] Starter Area System.
- [ ] Forest Gate System.
- [ ] Swordsman Guild Quest System.
- [ ] Combat System.
- [ ] Inventory System.
- [ ] UI System.
- [ ] Rebirth System.

## Components

- [ ] Player.
- [ ] Town.
- [ ] Starter Area.
- [ ] Forest Guard.
- [ ] Swordsman Guild NPC.
- [ ] Run State.
- [ ] Combat.
- [ ] Inventory.
- [ ] UI.
- [ ] Rebirth.

## Verbs

- [ ] Move.
- [ ] Talk.
- [ ] Leave.
- [ ] Return.
- [ ] Fight.
- [ ] Equip.
- [ ] Consume.
- [ ] Approach.
- [ ] Block.
- [ ] Unlock.
- [ ] Accept.
- [ ] Complete.
- [ ] Spend.
- [ ] Age.
- [ ] Die.
- [ ] Judge.
- [ ] Reborn.

## Setting and Locations

- [ ] Setting: small fantasy town at edge of dangerous Forest.
- [ ] Tone: cozy, simple, bittersweet, not grimdark.
- [ ] Town: safe base and first scene.
- [ ] Starter Area: beginner field outside Town.
- [ ] Forest Gate: boundary inside Starter Area.
- [ ] Forest: visible promise, not playable in prototype.
- [ ] Game Over: result screen, not physical location.

## Objects

- [ ] Player body.
- [ ] Player aging sprite 0: Born.
- [ ] Player aging sprite 1: after 1 guild quest.
- [ ] Player aging sprite 2: after 2 guild quests.
- [ ] Destination marker.
- [ ] Wooden Sword.
- [ ] Cloth Armor.
- [ ] Apple stack.
- [ ] Swordsman Guild NPC.
- [ ] Forest Guard.
- [ ] Chick.
- [ ] Rabbit.
- [ ] Slime.
- [ ] Town exit.
- [ ] Starter Area return path.
- [ ] Forest path.
- [ ] Forest blocker / gate.
- [ ] Swordsman Guild building/sign.
- [ ] NPC interaction zones.
- [ ] Enemy spawn points.

## Characters

- [ ] Player: new adventurer seeking Forest access.
- [ ] Forest Guard: gatekeeper who blocks Forest path.
- [ ] Swordsman Guild NPC: first-slice worldbuilding NPC; later certification quest giver.
- [ ] Vendor: optional placeholder.
- [ ] Elder: optional theme explainer.
- [ ] Town Guard: optional tutorial hint.
- [ ] Chick: easiest enemy.
- [ ] Rabbit: fast starter enemy.
- [ ] Slime: tanky starter enemy.

## Props

- [ ] Swordsman Guild sign.
- [ ] Swordsman Guild door/building placeholder.
- [ ] Glowing Starter Area portal.
- [ ] Notice board placeholder.
- [ ] Vendor stall placeholder.
- [ ] Benches/crates/barrels.
- [ ] Training dummy near guild.
- [ ] Grass patches.
- [ ] Rocks.
- [ ] Bushes.
- [ ] Dirt path.
- [ ] Return-to-Town sign.
- [ ] Forest path sign.
- [ ] Wooden barricade / gate.
- [ ] Guard post.
- [ ] Warning sign.
- [ ] Dense tree line / dark forest edge.

## Devices

- [ ] Starter Area Portal Trigger.
- [ ] Starter Area Return Trigger.
- [ ] Forest Gate Trigger.
- [ ] Forest Blocker.
- [ ] Guard Dialog Trigger.
- [ ] Swordsman Guild Quest Trigger.
- [ ] Dialog Buttons: Accept / Complete / Close.
- [ ] Enemy Hitbox / Hurtbox.
- [ ] Consumable Use Button.
- [ ] Reborn Button.
- [ ] HUD.
- [ ] Quest Panel.
- [ ] Game Over Panel.

## States

- [ ] Run states: `new_run`, `in_town`, `in_starter_area`, `forest_gate_seen`, `guild_quest_unlocked`, `guild_quest_active`, `swordsman_guild_unlocked`, `game_over`, `reborn`.
- [ ] Life states: `life_full`, `life_spent_once`, `life_spent_twice`, `life_depleted`.
- [ ] Aging states: `born`, `older`, `old`, `dead`.
- [ ] Guild quest states: `locked`, `available`, `step_1_ready`, `step_1_complete`, `step_2_ready`, `step_2_complete`, `step_3_ready`, `completed`, `unlocked`.
- [ ] Forest gate states: `unseen`, `approached`, `blocked`, `guild_requirement_revealed`, `passable_future`.
- [ ] Combat states: `idle`, `engaged`, `player_attacking`, `enemy_attacking`, `enemy_defeated`, `player_combat_down`, `fleeing`.
- [ ] Inventory states: `starter_loadout`, `weapon_equipped`, `armor_equipped`, `consumable_available`, `consumable_empty`.
- [ ] UI states: `hud_visible`, `dialog_open`, `quest_panel_visible`, `transitioning`, `game_over_visible`.

## Rules

- [ ] New run starts in Town.
- [ ] New run starts with `Life = 100`.
- [ ] New run starts with starter inventory.
- [ ] Game Over happens when `Life <= 0`.
- [ ] Reborn starts new run.
- [ ] Life cannot heal.
- [ ] Combat damage does not reduce Life.
- [ ] Swordsman Guild quest completion costs `40 Life`.
- [ ] Life thresholds drive aging.
- [ ] Forest is blocked at prototype start.
- [ ] First Forest entry attempt triggers Guard dialog.
- [ ] Guard dialog unlocks Swordsman Guild quest in Town.
- [ ] Forest remains inaccessible in prototype.
- [ ] Swordsman Guild quest has 3 ordered steps.
- [ ] Quest completion, not XP, unlocks Swordsman Guild.
- [ ] Combat uses Combat HP, not Life.
- [ ] Enemy defeat grants XP.
- [ ] Inventory cannot restore Life.
- [ ] Dialog blocks movement.
- [ ] Game Over blocks gameplay input.

## Permissions

- [ ] Player can move if no dialog/game-over open.
- [ ] Player can talk to nearby/clicked NPCs.
- [ ] Player can leave Town to Starter Area.
- [ ] Player can return to Town from Starter Area.
- [ ] Player can fight Chick/Rabbit/Slime in Starter Area.
- [ ] Player can approach Forest Gate.
- [ ] Player can use Apple if Combat HP below max and apples remain.
- [ ] Player cannot enter Forest in prototype.
- [ ] Player cannot heal Life.
- [ ] Player cannot unlock Swordsman Guild via XP.
- [ ] Player cannot complete guild quest before Guard encounter.
- [ ] Enemies can attack Combat HP only.
- [ ] UI displays state but does not decide outcomes.
- [ ] Models own rules.
- [ ] Controllers route signals.
- [ ] Views display state and emit signals.

## Restrictions

- [ ] No playable Forest.
- [ ] No XP gates.
- [ ] No full shop.
- [ ] No crafting.
- [ ] No inventory grid/backpack.
- [ ] No save-slot UI.
- [ ] No building interiors.
- [ ] No daily task CRUD.
- [ ] No extra enemy types beyond Chick/Rabbit/Slime.
- [ ] Life cannot exceed 100 in prototype.
- [ ] Life can only be spent by Swordsman Guild quest chain.
- [ ] Quest steps cannot be skipped.
- [ ] Apple cannot restore Life.
- [ ] Combat down behavior TBD; do not implement permadeath from Combat HP yet.

## Conditions

- [ ] Start: `Life = 100`.
- [ ] Start: Combat HP full.
- [ ] Start: Wooden Sword, Cloth Armor, Apple x3.
- [ ] Start: `forest_gate_seen = false`.
- [ ] Start: `swordsman_quest_unlocked = false`.
- [ ] Start: `swordsman_chain_step = 0`.
- [ ] Start: `swordsman_guild_unlocked = false`.
- [ ] Start: aging state `born`.
- [ ] Forest approach before guild unlock blocks player and unlocks guild quest.
- [ ] Guild NPC does not offer quest before `forest_gate_seen`.
- [ ] Guild NPC offers step 1 when `forest_gate_seen = true` and chain step 0.
- [ ] Guild NPC offers step 2 when chain step 1.
- [ ] Guild NPC offers step 3 when chain step 2.
- [ ] Life 60 sets aging state to `older`.
- [ ] Life 20 sets aging state to `old`.
- [ ] Life 0 sets aging state to `dead` and shows Game Over.

## Scenes

- [ ] `Town`
  - [ ] player spawn
  - [ ] NPCs
  - [ ] Swordsman Guild NPC
  - [ ] glowing portal to Starter Area
- [ ] `Starter Area`
  - [ ] player spawn
  - [ ] Chick enemy
  - [ ] Rabbit enemy
  - [ ] Slime enemy
  - [ ] Forest path
  - [ ] Guard blocking Forest
  - [ ] return path to Town
- [ ] `Game Over`
  - [ ] unlock summary
  - [ ] “Was It A Life Well Spent?” prompt
  - [ ] Reborn Yes/No buttons

## Core Systems Implementation

- [ ] Area transition: Town ↔ Starter Area.
- [ ] Dialog system supports guard/NPC/guild quest lines.
- [ ] Quest chain system supports 3-step Swordsman Guild quest.
- [ ] Life system starts each run at 100.
- [ ] Combat HP system separate from Life.
- [ ] Simple combat loop.
- [ ] Tiny inventory.
- [ ] Rebirth/reset run flow.

## Models Implementation

- [ ] `RunState`
  - [ ] `life = 100`
  - [ ] `combat_hp`
  - [ ] `xp`
  - [ ] `swordsman_chain_step`
  - [ ] `forest_gate_seen`
  - [ ] `swordsman_quest_unlocked`
  - [ ] `unlocked_swordsman_guild`
  - [ ] `game_over_requested`
- [ ] `Inventory`
  - [ ] weapon slot
  - [ ] armor slot
  - [ ] consumable slot/count
- [ ] `CombatStats`
  - [ ] attack
  - [ ] defense
  - [ ] max HP/current HP
- [ ] `EnemyDefinition`
  - [ ] name
  - [ ] HP
  - [ ] attack
  - [ ] XP reward

## Tiny Inventory

- [ ] Weapon slot: 1 item.
- [ ] Armor slot: 1 item.
- [ ] Consumable slot: 1 item stack.
- [ ] Starting weapon: `Wooden Sword`.
- [ ] Starting armor: `Cloth Armor`.
- [ ] Starting consumable: `Apple x3`.
- [ ] Consumables heal Combat HP, not Life.

## Enemies

- [ ] Chick — easiest/tutorial enemy.
- [ ] Rabbit — fast/medium enemy.
- [ ] Slime — tanky/simple enemy.
- [ ] No goblin in prototype.

## NPCs

- [ ] Forest Guard.
- [ ] Swordsman Guild NPC.
- [ ] Optional Town flavor NPC: Vendor.
- [ ] Optional Town flavor NPC: Guard.
- [ ] Optional Town flavor NPC: Elder.

## Swordsman Guild Quest Chain

- [ ] Quest unlocks after Forest Guard blocks player.
- [ ] Quest 1 completion costs 40 Life.
  - [ ] Life: 100 → 60.
  - [ ] Player sprite changes from Sprite 0 to Sprite 1.
- [ ] Quest 2 completion costs 40 Life.
  - [ ] Life: 60 → 20.
  - [ ] Player sprite changes from Sprite 1 to Sprite 2.
- [ ] Quest 3 completion costs 40 Life / remaining Life.
  - [ ] Life: 20 → 0.
  - [ ] No new aging sprite.
  - [ ] `SWORDSMAN GUILD: UNLOCKED` shown.
  - [ ] Game Over shown.

## Game Over Screen

- [ ] Shows unlocked reward:

```text
Your Life Was Spent To Unlock:
Swordsman Guild

Was It A Life Well Spent?

Reborn?
[Yes] [No]
```

- [ ] Yes starts new run/rebirth.
- [ ] No exits/returns to title TBD.

## UI

- [ ] HUD shows Life.
- [ ] HUD shows Combat HP.
- [ ] HUD shows XP score.
- [ ] HUD shows equipped weapon.
- [ ] HUD shows equipped armor.
- [ ] HUD shows consumable/count.
- [ ] Dialog panel.
- [ ] Quest status panel.
- [ ] Game Over summary.

## Art Style / Visual Direction

- [ ] Prototype uses primitives and SVG only, except generated character sprites.
- [ ] Style target: clean symbolic fantasy diorama.
- [ ] No detailed tiles.
- [ ] No painterly backgrounds.
- [ ] Use `ColorRect`, `Polygon2D`, `Line2D`, simple `Sprite2D` SVGs, and collision/debug-friendly shapes.
- [ ] Strong color zones communicate location and meaning.

## Visual Color Language

- [ ] Town: warm tan / brown / soft orange = safe.
- [ ] Starter Area: bright green / dirt brown = beginner field.
- [ ] Forest Gate: dark green / blue shadow = danger / not ready.
- [ ] Danger: red.
- [ ] Interactable: yellow.
- [ ] Locked: gray.
- [ ] Life: crimson.
- [ ] Combat HP: red/pink.
- [ ] XP: gold.

## Assets / Placeholders

### Generated Character Sprites

- [ ] Player Sprite 0.
- [ ] Player Sprite 1.
- [ ] Player Sprite 2.
- [ ] Guard/NPC sprite.

### Primitive World Art

- [ ] Town ground as warm `ColorRect`/primitive plane.
- [ ] Town paths as brown strips/polygons.
- [ ] Swordsman Guild building as primitive rectangle + triangle roof.
- [ ] Swordsman Guild sign/emblem.
- [ ] Starter Area ground as green primitive plane.
- [ ] Dirt paths as brown strips/polygons.
- [ ] Rocks as gray circles/polygons.
- [ ] Bushes as green circles/polygons.
- [ ] Forest edge as dark green tree-wall primitives.
- [ ] Forest blocker as barricade rectangles.
- [ ] Guard post as primitive prop.

### Enemy Placeholders

- [ ] Chick as primitive/SVG placeholder.
- [ ] Rabbit as primitive/SVG placeholder.
- [ ] Slime as primitive/SVG placeholder.

### SVG Icons

- [ ] Life icon.
- [ ] Combat HP icon.
- [ ] XP/star icon.
- [ ] Wooden Sword icon.
- [ ] Cloth Armor/shield icon.
- [ ] Apple icon.
- [ ] Guild emblem icon.
- [ ] Warning sign icon.
- [ ] Town arrow icon.
- [ ] Forest arrow icon.
- [ ] Lock icon.

## UI Art

- [ ] HUD uses dark translucent rectangles.
- [ ] Dialog panel uses parchment-ish primitive rectangle.
- [ ] Game Over uses black overlay + white text + guild emblem.

## Tests

- [ ] `RunState` life spend and unlock behavior.
- [ ] Swordsman Guild 3-chain quest behavior.
- [ ] Player aging sprite state mapping.
- [ ] Inventory slot behavior.
- [ ] Consumable heals Combat HP only.
- [ ] Combat damage calculation.
- [ ] Enemy defeat XP reward.
- [ ] Forest Guard unlocks Swordsman Guild quest after blocking Forest path.
- [ ] Reborn resets run state.
- [ ] Reborn persistence decision: whether Swordsman Guild unlock remains across runs.
- [ ] Town scene loads.
- [ ] Starter Area scene loads.
- [ ] Game Over screen loads.

## Open Decisions

- [ ] Does Swordsman Guild unlock persist after rebirth?
- [ ] What does Reborn `No` do: quit, title, or stay on summary?
- [ ] Does XP reset per run, persist lifetime, or both?
- [ ] What exact actions complete each Swordsman Guild quest chain step?
- [ ] Is opening cinematic skipped, stubbed, or text-only for prototype?
- [ ] What happens when Combat HP reaches 0?
