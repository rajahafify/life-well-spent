# Run State

## Core Idea

Single source of truth for prototype run progression.

## State

- `life: int = 100`
- `max_life: int = 100`
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
- Spend Max Life
- Take Life Damage
- Heal Life
- Update Aging
- Request Game Over
- Reborn

## Rules

- New run starts with `life = 100` and `max_life = 100`.
- Forest Guard encounter sets `forest_gate_seen = true` and unlocks guild quest.
- Guild step completion spends Max Life and clamps current Life to Max Life.
- Combat damage reduces current Life.
- Healing restores current Life up to Max Life only; it never restores Max Life.
- Aging state is derived from Max Life/chain progress.
- Life reaching 0 requests Game Over.

## Aging Mapping

- Step 0 / Max Life 100–61: Sprite 0, Born
- Step 1 / Max Life 60–21: Sprite 1
- Step 2 / Max Life 20–1: Sprite 2
- Step 3 / Max Life 0: Game Over, no new sprite

## Open Decision

- Does `swordsman_guild_unlocked` persist after Reborn?
