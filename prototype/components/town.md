# Town

## Core Idea

Town is safe base and first scene. Player starts here, learns goal, talks to NPCs, leaves for Starter Area, then returns to sacrifice Life for Swordsman Guild certification.

## Purpose

- Spawn player.
- Display current run state.
- House Swordsman Guild NPC.
- Provide exit to Starter Area.
- Receive player after Forest Guard blocks Forest path.
- Convert Guard encounter into Swordsman Guild quest chain.

## Objects

- Player
- Camera
- HUD
- Dialog Panel
- Quest Status Panel
- Swordsman Guild NPC
- Starter Area Exit
- Optional Vendor
- Optional Elder
- Optional Town Guard
- Swordsman Guild sign/building placeholder

## Verbs

- Move
- Talk
- Accept
- Complete
- Spend Life
- Age
- Leave
- Return
- Reborn

## Resources Shown

- Life
- Combat HP
- XP
- Weapon slot
- Armor slot
- Consumable count
- Swordsman quest state
- Aging state

## Rules

- Town is safe.
- No enemies in Town.
- Player can leave Town to Starter Area.
- Swordsman Guild quest is locked until Forest Guard encounter.
- Guild NPC offers chain only when `forest_gate_seen = true`.
- Each guild quest step costs 40 Life.
- Step 3 triggers Swordsman Guild unlock and Game Over.

## Conditions

- If `forest_gate_seen = false`: Guild NPC says certification unavailable / come back later.
- If `forest_gate_seen = true` and `swordsman_chain_step = 0`: Guild NPC offers step 1.
- If `swordsman_chain_step = 1`: Guild NPC offers step 2.
- If `swordsman_chain_step = 2`: Guild NPC offers step 3.
- If `swordsman_chain_step = 3`: Swordsman Guild is unlocked, Game Over requested.

## Permissions

Player can:
- move if no dialog/game over open
- talk to NPCs
- leave to Starter Area
- start/continue guild quest when unlocked

Player cannot:
- fight in Town
- enter Forest from Town
- heal Life
- skip guild quest steps

## UI

HUD:
- Life
- Combat HP
- XP
- equipped weapon
- equipped armor
- consumable/count
- quest status

Dialog:
- NPC name
- body text
- Accept/Complete/Close buttons

## First Slice

1. Start in Town.
2. Talk to Guild NPC.
3. Guild NPC says certification unavailable.
4. Leave to Starter Area.
5. Return after Forest Guard encounter.
6. Guild NPC offers Swordsman Guild quest.
