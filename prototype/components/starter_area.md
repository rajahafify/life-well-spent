# Starter Area

> Superseded by `prototype/components/Field.md`; kept as historical draft.

## Core Idea

Beginner field outside Town. Player learns movement/combat, sees Forest path, and gets blocked by Guard.

## Purpose

- Let player leave safe Town.
- Introduce simple enemies.
- Reveal Forest as goal.
- Trigger Forest Guard gate.
- Send player back to Town with new objective.

## Objects

- Player spawn
- Return-to-Town trigger
- Chick enemy
- Rabbit enemy
- Slime enemy
- Forest path
- Forest Guard
- Forest blocker
- Enemy spawn points
- Basic terrain props

## Verbs

- Move
- Fight
- Consume
- Approach
- Block
- Return

## Rules

- Player can fight Chick/Rabbit/Slime.
- Combat damages current Life; quests/progression reduce Max Life.
- Enemy defeat grants XP.
- Player cannot enter Forest in prototype.
- Approaching Forest triggers Guard dialog and unlocks guild quest.

## Conditions

- If player approaches Forest and guild not unlocked: Guard blocks path.
- If Guard blocks path: `forest_gate_seen = true`, `swordsman_quest_unlocked = true`.
- If player returns to Town: Town sees updated run state.
