# Progression

## Core Idea

Progression is the bridge between the player's ordinary life, the old adventure world, and permanent rebuilding.

The prototype does not use gold, gear score, or generic level gates as the primary progression pressure. It uses Life. Field asks the player to return to Town for certification. Town asks the player to spend part of a life to rebuild an old institution. Rebirth then turns that sacrifice into long-term world progress.

The next progression slice should close the first complete arc:

```text
Town -> Field -> Forest Guard blocks path -> Town -> Swordsman Guild certification -> Guild unlock -> Forest gate state changes
```

## Tone

Earnest sacrifice.

- Progress should feel meaningful, not grindy.
- Spending Life should feel like choosing what this life is for.
- Unlocking an old institution should feel like restoring something useful to the world.
- Rebirth should frame loss as continuity, not failure.

Key feeling:

```text
A life is limited.
What it restores can outlast it.
```

## Purpose

- Give Field exploration a clear consequence.
- Turn the Forest Guard block into a Town quest chain.
- Make Swordsman Guild certification the first major prototype progression arc.
- Teach the player that Max Life is a spendable strategic resource.
- Establish the pattern for future town restoration systems.
- Define which unlocks persist after rebirth.

## Current Status

Current implemented pieces:

- `QuestSystem` tracks the main objective and side quest chain activation.
- Field Forest Gateway records the `forest_guard` checkpoint.
- Field advances the main objective to `Get Swordsman Certification`.
- Field activates `Rebuilding Swordsman Guild`.
- Field enemy defeats update the active Guildmaster kill objective.
- `PlayerStats` supports Life, Max Life, XP, death, rebirth, facilities, and serialization.
- `ProgressionModel` links real-life task completion, XP, quest completion, and facility unlock hooks.
- `PlayerAgingModel` maps Max Life pressure to normal hair, grey hair/beard, and white hair/beard sprite stages.
- Town Guildmaster can react to `QuestSystem.current_main_objective_id()`.
- Shared HUD shows Life / Max Life through Town and Field.

Still missing:

- Dedicated rebirth/game-over screen after final certification.
- Profile-level save/load for the persistent `swordsman_guild` unlock.
- Full Forest scene after the prototype endpoint.

## Progression Arc

### Step 0 - Explore

Player begins in Town with the main objective:

```text
Find the Forest path.
```

Player can talk to Town NPCs, leave through the Field Gateway, and explore Field.

### Step 1 - Blocked By Forest Guard

Player reaches the Forest Gateway in Field.

Forest Guard blocks the way and explains certification:

```text
Stop.

The Demon King is gone.
But old places do not become safe overnight.

The Forest remembers what we forgot.
Return to Town.
Earn certification from the Swordsman Guild.
```

Effects:

- Record checkpoint `forest_guard`.
- Advance main objective to `Get Swordsman Certification`.
- Activate side quest chain `Rebuilding Swordsman Guild`.
- Keep Forest blocked.

### Step 2 - Return To Town

Player returns to Town through the Field Town Gateway.

Guildmaster dialog changes because the Forest Guard checkpoint and Swordsman Guild quest chain are active.

Guildmaster should now explain:

```text
Certification is not earned with coin.
It is earned with life.
```

### Step 3 - Guildmaster Quest 1: Slime Stance Trial

Player completes the first Guildmaster certification objective in Field:

```text
Defeat 10 Slimes for Guildmaster stance training.
```

Effects:

- Max Life: `100 -> 60`
- Current Life clamps to `60`
- `swordsman_chain_step = 1`
- Player sprite changes to aging stage 2, `assets/player_age_2.png`
- Swordsman Guild remains locked

### Step 4 - Guildmaster Quest 2: Bat Guard Trial

Player completes the second Guildmaster certification objective in Field:

```text
Defeat 2 Bats for Guildmaster guard training.
```

Effects:

- Max Life: `60 -> 20`
- Current Life clamps to `20`
- `swordsman_chain_step = 2`
- Player sprite changes to aging stage 3, `assets/player_age_3.png`
- Swordsman Guild remains locked

### Step 5 - Guildmaster Quest 3: Rat Life Oath Trial

Player completes the final Guildmaster certification objective in Field:

```text
Defeat 2 Rats for the Guildmaster's Life oath.
```

Effects:

- Max Life: `20 -> 0`
- Current Life clamps to `0`
- `swordsman_chain_step = 3`
- `swordsman_guild_unlocked = true`
- `game_over_requested = true`
- Show `SWORDSMAN GUILD UNLOCKED`

### Step 6 - Rebirth

Player rebirths after the life is spent.

Prototype behavior:

- Current Life resets to `100`
- Max Life resets to `100`
- Aging state resets to starting sprite
- Inventory resets to starter loadout
- `swordsman_guild` remains in `PlayerStats.unlocked_facilities`
- Main objective advances to `Enter the Forest.`
- Forest Guard and Forest Gateway no longer use the original certification block after certification and show `The path to forest is open.`
- Certified Forest interactions preserve the `Enter the Forest.` objective instead of returning to `Get Swordsman Certification.`

## Functional Zones

Progression touches multiple scenes rather than owning a scene of its own.

### Town - Swordsman Guild

Primary progression UI for the current slice.

Guildmaster owns the player-facing certification dialog, but the rules live in models. Town controller only routes dialog choices into model calls and refreshes views.

### Field - Forest Gateway

Primary progression trigger for the current slice.

Field starts the certification arc by blocking Forest access, setting the checkpoint, updating the main objective, and activating the side quest chain.

### Shared HUD

Progression feedback surface.

HUD should show Life / Max Life changes immediately after certification steps.

### Rebirth Screen

Future completion surface.

This should eventually ask whether the life was well spent and offer rebirth after a run-ending sacrifice.

## State Read/Write

Progression reads:

- `QuestSystem.current_main_objective_id()`
- `QuestSystem` side quest chain state
- `QuestSystem` checkpoint state
- `PlayerStats.life`
- `PlayerStats.max_life`
- `PlayerStats.facilities`
- `PlayerStats.game_over_requested`
- future persistent profile unlock state

Progression writes:

- main objective changes
- side quest chain activation
- checkpoint completion
- Max Life spending
- current Life clamping
- aging sprite state
- Swordsman Guild unlock state
- game over request
- future persistent meta unlocks

## Verbs

Implemented:

- Explore
- Block
- Activate Quest
- Complete Quest
- Gain XP
- Unlock Facility
- Serialize
- Rebirth

Implemented in the certification slice:

- Certify
- Spend Max Life
- Age visually
- Unlock Guild
- Persist Unlock
- Change Gate State

Future verbs:

- Restore
- Upgrade
- Choose Legacy
- Continue Run
- Start New Life

## Resources Shown

Progression should show:

- current main objective
- active side quest chain
- Life / Max Life
- certification step
- unlock message
- game over / rebirth prompt

Progression should not require showing:

- hidden internal checkpoint ids
- raw dictionary state
- debug quest ids

## Rules

- Forest access is blocked until Swordsman Guild certification is complete.
- Forest Guard is the only current trigger for the certification chain.
- Certification steps must complete in order.
- Each certification step has a kill objective that must be complete before the Guildmaster completion button appears.
- Certification cannot start before `Rebuilding Swordsman Guild` is active.
- Certification spends Max Life, not current Life only.
- Current Life clamps down to Max Life after each certification step.
- Step 1 costs 40 Max Life.
- Step 2 costs 40 Max Life.
- Step 3 costs all remaining Max Life.
- Step 3 unlocks Swordsman Guild and requests game over.
- Apples and healing cannot restore Max Life.
- Combat damage cannot reduce Max Life.
- Swordsman Guild unlock should persist after rebirth for the prototype.
- Scene controllers must not own progression rules; they delegate to models/managers.

Future rules:

- Other institutions can use the same pattern: discover need, activate chain, spend Life, unlock persistent town capability.
- Some future unlocks may require real-life task completion instead of direct Life spend.
- The player may eventually choose which restoration to pursue first.

## Conditions

Current implemented conditions:

- If player enters Field Forest Gateway before certification: block scene transition, record `forest_guard`, advance the main objective, activate `Rebuilding Swordsman Guild`, and show Forest Guard warning.
- If player returns to Town after the Forest Guard block: Guildmaster can detect the certification objective.
- If linked real-life task completes: `ProgressionModel` can complete linked quest progress and grant XP.

Next slice conditions:

- If Guildmaster is clicked before Forest Guard checkpoint: show worldbuilding dialog.
- If Guildmaster is clicked after Forest Guard checkpoint and chain step is `0`: show the Slime stance objective.
- If 10 Slimes are defeated while the chain is active: step 1 can be completed, spending Max Life from `100` to `60`, clamping current Life, updating HUD, and setting chain step `1`.
- If chain step is `1`: show the Bat guard objective.
- If 2 Bats are defeated while step 1 is active: step 2 can be completed, spending Max Life from `60` to `20`, clamping current Life, updating HUD, and setting chain step `2`.
- If chain step is `2`: show the Rat Life oath objective.
- If 2 Rats are defeated while step 2 is active: step 3 can be completed, spending remaining Max Life, unlocking Swordsman Guild, advancing the main objective to `Enter the Forest.`, requesting game over, and showing the unlock message.
- If player rebirths after unlock: reset run Life state but preserve Swordsman Guild unlock in `PlayerStats.unlocked_facilities`.
- If player reaches Forest Gateway after unlock: show the open-path prototype endpoint instead of the original certification block.
- If player talks to Forest Guard after unlock: show the same endpoint and preserve the `Enter the Forest.` objective.

## Permissions

Player can:

- discover the certification requirement in Field
- return to Town to pursue certification
- complete certification steps in order
- complete Field kill objectives for each certification step
- spend Max Life to restore Swordsman Guild
- rebirth after the final sacrifice

Player cannot:

- certify before Forest Guard requests it
- skip certification steps
- complete a Guildmaster certification step before its kill objective is done
- restore Max Life with Apples
- enter Forest before the Guild unlock changes the gate state
- unlock Swordsman Guild through XP alone

## Model Boundaries

Progression should remain model-first.

Expected model ownership:

- `QuestSystem` / `QuestManager`: objectives, checkpoints, quest chain state.
- `PlayerStats`: Life, Max Life, facilities, game over request, serialization.
- `ProgressionModel`: coordination rules that connect quest completion, task completion, XP, and unlock effects.
- Future `RunState`: durable run-level progression snapshot if current singleton state becomes too spread out.

Expected controller ownership:

- Town controller routes Guildmaster dialog choices into model calls.
- Field controller routes Forest Gateway collision into progression calls.
- Shared HUD controller/view refreshes Life and objective text after model changes.

Expected view ownership:

- Dialog views show text and emit button/choice signals.
- HUD views render Life / Max Life and objective state.
- Views do not inspect internal quest dictionaries or mutate progression state.

## Art Direction

Progression should be visible through small world changes rather than a large menu.

Swordsman Guild unlock visual language:

- Guild building becomes warmer/brighter.
- Guild sign or sword emblem becomes more pronounced.
- Guildmaster dialog becomes less wistful and more active.
- HUD/objective text confirms the unlock.

Life-spend feedback:

- Life / Max Life changes must be immediately visible.
- Player appearance changes with Max Life loss: `100` uses `player_age_1.png`, `60` uses `player_age_2.png`, and `20` or lower uses `player_age_3.png`.
- Certification should not look like damage from an enemy.
- Use dialog copy and UI timing to frame it as a chosen sacrifice.

Color language:

- Life cost = crimson.
- Unlock/restoration = gold.
- Active objective = parchment/white text.
- Blocked Forest = dark green.

## Current Non-Goals

- No full Forest map.
- No complete facility management UI.
- No vendor/shop economy.
- No alternate certification routes.
- No permanent death system beyond prototype rebirth.
- No complex branching dialog.
- No production save slot UI.
- No equipment-based certification requirement.

## Deliverables

### Documentation

- `prototype/components/progression.md` is the source of truth for the first progression arc.
- Town and Field docs should link or reference this when their certification behavior changes.
- LLM wiki should get an architecture update when model APIs change.

### Spec

Specs cover:

- Forest Guard checkpoint activates certification progression.
- Guildmaster shows certification dialog only after the checkpoint.
- Certification step 1 spends Max Life to `60`.
- Certification step 2 spends Max Life to `20`.
- Certification step 3 spends remaining Max Life and unlocks Swordsman Guild.
- Rebirth resets Life state while preserving Swordsman Guild unlock.
- Forest Gateway state changes after unlock.

### Scene

No new Progression scene is required.

Town and Field scenes should expose the progression through:

- Guildmaster dialog choices.
- Life / Max Life HUD updates.
- Forest Gateway behavior.
- Swordsman Guild visual state.
- Optional game over / rebirth surface.

### Script

No `ProgressionController` was introduced. Coordination remains in models and thin scene glue.

Implemented script changes:

- Model methods for certification step completion.
- Thin Town controller glue for Guildmaster quest-completion button presses.
- Thin Field controller glue for Forest Gateway state.
- Shared HUD refresh calls after Life / objective changes.

## Next-Slice Acceptance

Player can:

1. Start in Town and enter Field.
2. Reach the Forest Gateway.
3. Get blocked by Forest Guard.
4. See the objective change to `Get Swordsman Certification`.
5. Return to Town.
6. Talk to Guildmaster and see certification-specific dialog.
7. Defeat 10 Slimes, return to Guildmaster, complete stance training, and see Max Life become `60`.
8. Defeat 2 Bats, return to Guildmaster, complete guard training, and see Max Life become `20`.
9. Defeat 2 Rats, return to Guildmaster, complete the Life oath, and see Swordsman Guild unlock.
10. See the objective change to `Enter the Forest.`
11. Rebirth with Life / Max Life reset to `100 / 100`.
12. Keep Swordsman Guild unlocked after rebirth.
13. Return to Field and see Forest Gateway no longer use the original certification block.

## First Slice Flow

1. Start in Town.
2. Walk through the Field Gateway.
3. Explore Field.
4. Reach Forest Gateway.
5. Forest Guard blocks entry and sends player back for certification.
6. Return to Town.
7. Talk to Guildmaster.
8. Defeat 10 Slimes, then choose completed stance training.
9. Life / Max Life updates to `60 / 60`.
10. Defeat 2 Bats, then choose completed guard training.
11. Life / Max Life updates to `20 / 20`.
12. Defeat 2 Rats, then choose the completed Life oath.
13. Swordsman Guild unlocks and game over is requested.
14. Rebirth resets the run while preserving the Guild unlock.

## Tests

- [x] Forest Gateway records the `forest_guard` checkpoint.
- [x] Forest Gateway advances the main objective to `Get Swordsman Certification`.
- [x] Forest Gateway activates `Rebuilding Swordsman Guild`.
- [x] Guildmaster shows worldbuilding dialog before the Forest Guard checkpoint.
- [x] Guildmaster shows certification dialog after the Forest Guard checkpoint.
- [x] Certification cannot complete before the side quest chain is active.
- [x] Certification cannot complete before the current kill objective is complete.
- [x] Slime kills advance the first Swordsman Guild objective.
- [x] Wrong enemy kills do not advance the current Swordsman Guild objective.
- [x] Certification step 1 spends Max Life from `100` to `60`.
- [x] Certification step 1 clamps current Life to `60`.
- [x] Certification step 1 sets `swordsman_chain_step` to `1`.
- [x] Certification step 2 spends Max Life from `60` to `20`.
- [x] Certification step 2 clamps current Life to `20`.
- [x] Certification step 2 sets `swordsman_chain_step` to `2`.
- [x] Certification step 3 spends remaining Max Life to `0`.
- [x] Certification step 3 unlocks Swordsman Guild.
- [x] Certification step 3 advances the main objective to `Enter the Forest.`
- [x] Certification step 3 requests game over.
- [x] Rebirth resets current Life to `100`.
- [x] Rebirth resets Max Life to `100`.
- [x] Rebirth preserves Swordsman Guild unlock.
- [x] Forest Gateway no longer shows the original certification block after Swordsman Guild unlock.
- [x] Shared HUD updates Life / Max Life after each certification step.
