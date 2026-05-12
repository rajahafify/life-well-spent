# Prototype Components

One-page component specs for first playable prototype.

System inventory lives in [`../game-systems.md`](../game-systems.md). Append it whenever a new game system is introduced or materially changed.

Field development decisions live in [`../field-development-decisions.md`](../field-development-decisions.md).

## Components

- `town.md` — safe base and first scene.
- `Field.md` — beginner field and Forest approach.
- `forest_gate.md` — Guard blocker and quest unlock trigger.
- `swordsman_guild_quest.md` — 3-step Life-spend chain.
- `run_state.md` — single source of truth for run progression.
- `inventory.md` — 1 weapon, 1 armor, 1 consumable stack.
- `combat.md` — simple combat HP enemy loop.
- `ui.md` — HUD/dialog/game over presentation.
- `rebirth.md` — Game Over restart flow.

## Primary Prototype Goal

```text
Spend your life to unlock the Swordsman Guild.
```

## Main Flow

```text
Town → Field → Forest Guard blocks path → Return Town → Swordsman Guild Quest x3 → Game Over → Reborn
```
