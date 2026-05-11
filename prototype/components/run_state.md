# Run State

## Core Idea

Single source of truth for prototype run progression.

## State

- `life: int = 100`
- `combat_hp: int`
- `xp: int = 0`
- `forest_gate_seen: bool = false`
- `swordsman_quest_unlocked: bool = false`
- `swordsman_chain_step: int = 0`
- `aging_state: int = 0`
- `swordsman_guild_unlocked: bool = false`
- `game_over_requested: bool = false`

## Verbs

- Start Run
- Mark Forest Gate Seen
- Unlock Guild Quest
- Complete Guild Step
- Spend Life
- Update Aging
- Request Game Over
- Reborn

## Rules

- New run starts with `life = 100`.
- Forest Guard encounter sets `forest_gate_seen = true` and unlocks guild quest.
- Guild step completion spends Life.
- Aging state is derived from Life/chain progress.
- Life reaching 0 requests Game Over.

## Aging Mapping

- Step 0 / Life 100–61: Sprite 0, Born
- Step 1 / Life 60–21: Sprite 1
- Step 2 / Life 20–1: Sprite 2
- Step 3 / Life 0: Game Over, no new sprite

## Open Decision

- Does `swordsman_guild_unlocked` persist after Reborn?
