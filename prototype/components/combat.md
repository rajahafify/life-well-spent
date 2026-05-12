# Combat

## Core Idea

Simple starter combat for Field engagement. Combat uses Life directly: enemies damage current Life, while quests/progression reduce Max Life. This makes every life-spend decision affect survival.

## Actors

- Player
- Slime
- Bat
- Rat

## Resources

- Life
- Max Life
- Enemy HP
- Attack
- Defense
- XP

## Verbs

- Fight
- Attack
- Take Damage
- Defeat
- Gain XP
- Consume Apple

## Rules

- Enemy attacks damage current Life.
- Player is defeated when current Life reaches 0.
- Quests/progression spend Max Life, not temporary combat HP.
- Current Life cannot exceed Max Life.
- Enemy defeat grants XP.
- Weapon adds attack.
- Armor reduces incoming Life damage.
- Apple heals current Life up to Max Life if consumables are enabled later.

## Prototype Enemies

- Slime: tanky/simple tutorial
- Bat: quick aerial starter
- Rat: fast/medium ground starter

## Open Decision

- Exact defeat behavior when Life reaches 0: Game Over/rebirth immediately, return to Town first, or show summary panel TBD.
