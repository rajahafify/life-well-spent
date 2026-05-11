---
title: Prototype Systemic Design
type: synthesis
updated: 2026-05-11
sources:
  - prototype-checklists.md
  - prototype/components/README.md
  - Designing a Systemic Game - Playtank
  - conversation: prototype systems and art direction

tags: [game-design, prototype, systemic-design]
---

# Prototype Systemic Design

## Overview

First playable prototype goal: **spend your life to unlock the Swordsman Guild**. Player starts in **Town**, leaves for **Starter Area**, finds Forest blocked by Guard, returns to Town, completes a 3-step Swordsman Guild quest chain, spends all Life, unlocks Swordsman Guild, and reaches Game Over asking: **Was it a life well spent?**

## Stage 1: Ideation

### Core Idea

`Spend your life to become worthy.`

Player-facing objective: `Reach the Forest.`

Prototype truth: Forest access requires Swordsman Guild certification, and certification costs one life.

### Activities

- Move through Town and Starter Area.
- Talk to NPCs.
- Explore Starter Area.
- Fight Chick/Rabbit/Slime.
- Approach Forest path.
- Get blocked by Forest Guard.
- Return to Town.
- Accept and complete Swordsman Guild quest steps.
- Spend Life.
- Age through sprite states.
- Die when Life reaches 0.
- Reborn into next run.

### Resources

- **Life** — starts at 100, cannot heal, spent by major choices.
- **Combat HP** — tactical health, healable with consumables.
- **XP** — score/accomplishment measure; does not gate Swordsman Guild.
- **Inventory slots** — 1 weapon, 1 armor, 1 consumable stack.
- **Unlocks** — Swordsman Guild legacy/progression state.
- **Quest State** — Forest Guard seen, guild quest unlocked, chain step 0–3.

## Systems

- **Run State** — owns Life, XP, Forest Gate seen, Swordsman chain, aging, unlock, game-over request.
- **Life / Aging** — maps Life/chain progress to born/older/old/dead presentation.
- **Town** — safe first scene; Swordsman Guild NPC; exit to Starter Area.
- **Starter Area** — beginner combat field; Chick/Rabbit/Slime; Forest Gate.
- **Forest Gate** — Guard blocks Forest and unlocks guild quest.
- **Swordsman Guild Quest** — 3 ordered quest steps; each completion costs Life; final unlock ends run.
- **Combat** — field combat uses Combat HP only and grants XP.
- **Inventory** — Wooden Sword, Cloth Armor, Apple x3.
- **UI** — HUD, dialog, quest status, Game Over.
- **Rebirth** — restarts run; persistence rules still open.

## Swordsman Guild Quest Chain

- Step 1: Life 100 → 60, Sprite 0 → Sprite 1.
- Step 2: Life 60 → 20, Sprite 1 → Sprite 2.
- Step 3: Life 20 → 0, no new sprite, Swordsman Guild unlocked, Game Over.

## Art Direction

Prototype uses primitives and SVG only, except generated character sprites.

Style target: **clean symbolic fantasy diorama**.

Rules:

- No detailed tiles.
- No painterly backgrounds.
- Use `ColorRect`, `Polygon2D`, `Line2D`, simple SVG `Sprite2D`, and collision/debug-friendly shapes.
- Strong color zones communicate location and meaning.

Color language:

- Town: warm tan/brown/orange = safe.
- Starter Area: bright green/dirt brown = beginner field.
- Forest Gate: dark green/blue shadow = danger/not ready.
- Danger: red.
- Interactable: yellow.
- Locked: gray.
- Life: crimson.
- Combat HP: red/pink.
- XP: gold.

## Related

- `prototype-checklists.md`
- `prototype/components/README.md`
- `prototype/components/town.md`
- `prototype/components/run_state.md`
- `prototype/components/swordsman_guild_quest.md`
