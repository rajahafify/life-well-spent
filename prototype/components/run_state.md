# Run State

## Core Idea

Single source of truth for prototype run progression.

## State

- `life: int = 100`
- `max_life: int = 100`
- `xp: int = 0`
- `main_quest_objective: String = "find_forest_path"`
- `side_quest_chains: Dictionary`
- `swordsman_chain_step: int = 0`
- `swordsman_certification: bool = false`
- `aging_state: int = 0`
- `swordsman_guild_unlocked: bool = false`
- `game_over_requested: bool = false`

## Verbs

- Start Run
- Advance Main Quest Objective
- Activate Side Quest Chain
- Complete Guild Step
- Grant Certification
- Spend Max Life
- Take Life Damage
- Heal Life
- Update Aging
- Request Game Over
- Reborn

## Rules

- New run starts with `life = 100` and `max_life = 100`.
- Forest Gate encounter advances `Explore the World` to `Get Swordsman Certification` and activates `Rebuilding Swordsman Guild`.
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
