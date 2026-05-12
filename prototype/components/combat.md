# Combat

## Core Idea

Simple starter combat for Field engagement. Combat uses Life directly: enemies damage current Life, while quests/progression reduce Max Life. This makes every life-spend decision affect survival.

Current Field tuning scales enemy HP and Player outgoing attack by 10x for combat readability. Player Life and enemy attack damage to Player are not scaled.

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
- Field Player attack is currently 40.
- Field enemy HP is currently Slime 140, Bat 80, Rat 60.
- Field enemy attack values remain Slime 1, Bat 2, Rat 2.
- Enemy sprites render larger in Field and use wider attack/click spacing so they do not stand underneath the player sprite.
- Weapon adds attack.
- Armor reduces incoming Life damage.
- Apple heals current Life up to Max Life from shortcut slot 1.

## Prototype Enemies

- Slime: tanky/simple tutorial
- Bat: quick aerial starter
- Rat: fast/medium ground starter

## Open Decision

- Exact defeat behavior when Life reaches 0: Game Over/rebirth immediately, return to Town first, or show summary panel TBD.
