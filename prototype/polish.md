# Polish

## Core Idea

The prototype progression loop is playable from beginning to end. The next branch, `prototype/polish`, should make that loop feel intentional, readable, and stable instead of adding a new major content arc.

Polish is not "more features." It is the pass that makes the current promise land:

```text
Town -> Field -> Forest Guard -> Swordsman Guild trials -> Game Over -> Summary -> Rebirth or End Game -> Forest access
```

The player should always understand what happened, what changed, and what to do next.

## Tone

Clear, gentle, and satisfying.

- The world should feel quiet but responsive.
- Life spending should feel ceremonial, not like a bug or random damage.
- Rewards should feel visible immediately.
- Combat should feel readable enough to trust.
- UI should stay out of the way until it matters.

Key feeling:

```text
The first life has a clean shape.
Every sacrifice, reward, and unlock is visible.
```

## Purpose

- Improve readability of the existing playable loop.
- Reduce friction in player input, dialog, inventory, combat, and transitions.
- Make quest rewards and equipment effects obvious.
- Make Game Over and Rebirth feel like a deliberate endpoint.
- Stabilize manual QA so future content can build on a reliable prototype.

## Current Status

Implemented foundation:

- Town, Field, and Forest endpoint scenes exist.
- Main Menu can continue the saved run or start a confirmed progress reset.
- Town and Field share HUD, quest tracker, inventory, options modal, Life display, and shortcut bar.
- Town and Field support controller basics: left stick / D-pad movement, `A` interaction, `X` Inventory, and `Start` Options.
- Menu/dialog surfaces support controller actions: D-pad selects menu rows, `A` confirms/advances, and `B` cancels or closes where available.
- Forest Guard blocks access until Swordsman Guild certification.
- Guildmaster owns a 3-step quest chain:
  - Defeat 10 Slimes
  - Own 2 Bat Wings
  - Defeat 2 Rats
- Rewards are:
  - Training Sword
  - Leather Armor
  - Swordsman Guild unlock
- Training Sword adds attack and changes the player sprite.
- Leather Armor adds defense and changes the player sprite when sword is equipped.
- Final certification opens a dedicated Game Over scene, then a Summary scene.
- Rebirth resets run state and preserves Swordsman Guild.
- Summary `Rebirth` resets the ended run into a fresh Town start.
- Summary `End Game` returns to Main Menu without rebirth; Main Menu Continue can then auto-rebirth while preserving persistent unlocks.
- Main Menu keeps Continue/New Game/Quit centered, shows the young-to-old player image lower below the menu, and uses an icon-green background.
- Quest markers appear above Town NPCs: yellow for a new quest, white for active incomplete quest, and green for completed unclaimed quest.
- Certified Forest path opens to the Forest endpoint.
- Prototype SFX cues exist for loot, equipment, rewards, Guild unlock, Game Over, Summary open, Rebirth, New Game, dialog paging/closing, Forest opening, Apple use, quest updates, player attacks, enemy hits, player hurt, and enemy defeats.
- Generated melody cues were rejected during QA and are not part of the playable audio set.

Latest validation baseline:

```text
511 tests, 511 passed, 0 failed
```

Known non-failing test output:

- `assets-gallery.tscn` UID fallback warnings.
- Godot resource cleanup warnings at test process exit.

## Non-Goals

Do not use this branch for:

- Full Forest combat content.
- New guilds.
- Shop economy.
- Blacksmith crafting.
- Daily task expansion.
- Save slot UI.
- Large architecture rewrites unrelated to player-facing polish.

Those can follow after the first loop feels good.

## Polish Pillars

### 1. Flow Clarity

The player should never wonder why the objective changed.

Targets:

- Reborn dialog appears once and does not interrupt later Town returns.
- Forest Guard block clearly updates the quest tracker only after dialog closes.
- Guildmaster quest starts only when talking to Guildmaster after the Guard block.
- Quest tracker updates immediately after each claim.
- Forest Guard / Forest Gateway never revert the quest to an older objective after certification.
- Game Over summary explains what the life achieved.

Acceptance:

- QA can complete the full loop without asking what to do next.
- Each objective text matches the active player action.
- No stale quest text appears after scene transitions.

### 2. Dialog Feel

Dialog should guide, not trap.

Current rules to preserve:

- Dialog blocks movement.
- `Close` appears only on the final dialog page.
- `Claim Reward` appears only on the final dialog page and replaces `Close` when a reward is claimable.
- Reward panels are separate from quest panels.
- Dialog buttons stay bottom-right.

Polish targets:

- Dialog copy should avoid repeating the same sentence every visit.
- Post-completion Guildmaster copy should differ from active quest copy.
- Reward panels should feel like a moment, not just a text swap.
- Button labels should use player-facing verbs:
  - `Next`
  - `Close`
  - `Claim Reward`
  - `Rebirth`
  - `End Game`

Acceptance:

- No quest action appears before the last page.
- No dialog page leaves the player without an available next/close action.
- Closing dialog restores movement predictably.

### 3. Combat Readability

Combat should remain simple but trustworthy.

Current rules to preserve:

- Player must move close before attacking.
- Once close enough, the player can attack a moving enemy within the larger ready zone.
- Enemy defeat grants drops once.
- Weapon increases player damage.
- Armor reduces incoming damage.
- Apple heals current Life only.

Polish targets:

- Enemy click/attack zones should feel aligned with the sprite.
- Player should not visibly drift forever around moving enemies.
- Damage numbers should be readable and not overlap too heavily.
- Enemy HP bars should remain visible and scaled consistently.
- Loot toast should not hide important HUD information.

Acceptance:

- Player can reliably attack Slime, Bat, and Rat without awkward reposition loops.
- Equipment changes are observable in combat.
- Apple use clearly changes Life and inventory count.

### 4. Reward And Equipment Feedback

Rewards should be visible immediately after the player claims them.

Targets:

- Training Sword reward appears in inventory after Quest 1.
- Leather Armor reward appears in inventory after Quest 2.
- Equipment rows show useful actions only when the item is owned.
- Equipping Training Sword visibly changes sprite and damage.
- Equipping Leather Armor visibly changes sprite and defense.
- Armor should read as brown leather, not grey metal.

Acceptance:

- A player can find and equip every rewarded item without hidden instructions.
- Inventory starts empty on New Game/Rebirth.
- Swordsman Guild unlock persists after Rebirth.

### 5. Game Over And Rebirth

The end of the first life should feel like a completed run.

Targets:

- Game Over is a dedicated scene before Summary.
- Summary scene lists meaningful items, Life spent, and unlocks.
- Rebirth resets Life, Max Life, inventory, shortcuts, and age sprite.
- Rebirth preserves Swordsman Guild.
- End Game on Summary returns to Main Menu without rebirth.

Acceptance:

- Both Summary choices reach a valid next state.
- The player can enter Forest after Rebirth or after End Game followed by Main Menu Continue.

### 6. Visual Consistency

The prototype should look like one coherent game.

Targets:

- Town, Field, and Forest endpoint keep consistent scale.
- Player aging sprites share size, origin, and equipment treatment.
- Dialog, quest tracker, inventory, shortcut bar, and Game Over panel use consistent font size and spacing.
- No text overlaps buttons or panel bounds at 1080p.
- HUD clicks never move the player.
- Options modal opens from the HUD and can end the run back to Main Menu.

Acceptance:

- A 1080p QA pass shows no obvious UI overlap.
- Inventory and Game Over panels are readable over Town and Field backgrounds.
- Player and enemy sprites maintain clear click targets.

## Proposed Work Order

### P-01 - QA Baseline And Bug List

Run the full beginning-to-end QA script and record issues as checklist items inside this file or a dedicated polish tracker.

Done when:

- QA pass includes both Rebirth and End Game branches.
- Every observed issue has a short reproduction step.
- Automated suite still passes.

### P-02 - Dialog And Quest Feedback

Tighten dialog copy, action timing, and post-completion states.

Progress:

- Guildmaster now has distinct active and claim-ready copy for each Swordsman Guild trial:
  - Stance training: Defeat 10 Slimes.
  - Guard training: Own 2 Bat Wings.
  - Life oath: Defeat 2 Rats.
- Existing reusable quest dialog structure remains: incomplete quest, claimable quest, then separate Reward panel.
- Reward panels now use a clearer three-line format: `Reward`, the awarded item or unlock, and a short result line.
- Certified Guildmaster dialog now points the player to the open Forest path instead of repeating trial copy.

Done when:

- Guildmaster has distinct copy for active, claimable, rewarded, and completed states.
- Quest tracker updates are immediate and correct.
- Dialog buttons remain final-page-only where appropriate.

### P-03 - Combat Feel

Improve the attack-ready zone, enemy movement edge cases, and combat feedback readability.

Done when:

- Player attacks moving enemies without visible drift loops.
- Damage/HP/loot feedback remains readable.
- Weapon and armor effects are obvious in a short QA fight.

### P-04 - Inventory And Equipment UX

Make inventory use clearer without adding a full item system.

Done when:

- Empty slots read cleanly.
- Owned equipment rows have clear `Equip` actions.
- Equipped state is obvious.
- Apple shortcut use is visible and reliable.

Progress:

- Empty slots display `Empty`.
- Inventory rows use player-facing item names.
- Equipped rows show disabled `Equipped` buttons.

### P-05 - Game Over Presentation

Make the run endpoint feel complete.

Done when:

- Game Over summary is readable and includes the important run outcomes.
- Town routes to Game Over, then Summary.
- Summary includes Life spent, readable item names, and unlocks.
- Rebirth and End Game both lead to valid continuation states.
- Swordsman Guild persistence is clear.

### P-06 - Visual And Audio Hooks

Add small feedback hooks only where they clarify actions.

Implemented hooks:

- Loot drop sound.
- Reward claimed sound.
- Guild unlock sound.
- Equipment equip sound.
- Apple use sound.
- Quest objective update sound after Forest Guard.
- Game Over panel reveal sound.
- Summary open sound.
- Rebirth sound.
- New Game sound.
- Dialog next/close sounds.
- Forest path open sound.

Done when:

- Feedback is not noisy.
- Sound cues are local assets in `assets/audio/`.
- Missing or unknown SFX names fail gracefully.

## QA Script

Run this after each polish slice:

1. Start from Main Menu.
2. Confirm the Main Menu controls are center stage, the player aging image sits below them, then click `Continue` to preserve progress, or `New Game` and confirm to reset progress.
3. Confirm Reborn dialog appears once.
4. Go to Field.
5. Trigger Forest Guard block.
6. Return to Town.
7. Talk to Guildmaster.
8. Confirm the Guildmaster quest marker is centered close above his head, pulsing, and yellow before accepting the quest.
9. Complete Quest 1 by defeating 10 Slimes.
10. Confirm the marker turns green before reward claim.
11. Claim Training Sword.
12. Equip Training Sword.
13. Complete Quest 2 by owning 2 Bat Wings.
14. Claim Leather Armor.
15. Equip Leather Armor.
16. Complete Quest 3 by defeating 2 Rats.
17. Claim Swordsman Guild unlock.
18. Confirm Game Over scene appears.
19. Click `Continue`.
20. Confirm Summary scene includes Life spent, Training Sword, Leather Armor, and Swordsman Guild.
21. Test Rebirth branch.
22. Confirm Forest path opens.
23. Confirm the Smith has a centered pulsing yellow marker after rebirth.
24. Talk to Smith and confirm the reopen-blacksmith quest mentions post-Guild weapon and armor demand.
25. Accept the Smith quest and confirm the Blacksmith Job future-update preview modal describes recipes, crafting orders, and material hunting.
26. Confirm the Shopkeeper has a centered pulsing yellow marker after rebirth.
27. Talk to Shopkeeper and confirm the merchant quest mentions reopening the shop for returning travelers.
28. Accept the Shopkeeper quest and confirm the Merchant Job future-update preview modal describes caves, ruins, exciting items, and selling in the shop.
29. Walk to the south Town road and confirm the Field exit reads as a deliberate map transition: the trigger fill is invisible, and a centered bright yellow arrow pulses at the road edge.
30. With a controller, confirm left stick / D-pad movement works in Town and Field.
31. With a controller, confirm `A` opens nearby NPC dialog, advances dialog pages, claims rewards on final pages, and closes final Close pages.
32. Stand near a Town NPC and confirm the interaction prompt says `Press A to talk`.
33. Stand near the Field guard and confirm the interaction prompt says `Press A to talk`.
34. Stand near a Field enemy with no NPC nearby and confirm the interaction prompt says `Press A to attack`; press `A` and confirm the player targets/attacks that enemy.
35. With a controller, confirm `X` toggles Inventory and `Start` toggles Options; in Options, use D-pad to select Close and `A` to close it.
36. On Game Over and Summary, confirm controller `A` and D-pad selection can continue without mouse input.
37. Repeat or restore near Summary.
38. Test New Game branch.
39. Confirm Forest path still opens.

## Automated Test Expectations

Every polish change should keep or add focused specs.

Expected coverage areas:

- Dialog final-page actions.
- Quest tracker updates.
- Inventory slot/equip display.
- Equipment combat bonuses.
- Apple consumption.
- Game Over summary.
- Rebirth and End Game continuation.
- Field combat movement edge cases.
- Controller interaction prompts for talk and attack.

Full suite must pass before commit:

```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
```

## Open Questions

- Should Game Over summary show all current inventory or only meaningful run gains?
- Should combat include a visible attack cooldown indicator?
- Should equipment show a small icon on HUD, or is text enough for prototype polish?
- Should Forest endpoint stay silent, or should entering it after certification show a short confirmation dialog?

## Completion Criteria

`prototype/polish` is complete when:

- The full progression loop is still playable end-to-end.
- Both Rebirth and End Game continuation branches work.
- The most visible UI/combat/dialog friction from QA is resolved.
- No new major systems are introduced.
- Documentation reflects the final polish behavior.
- Full automated suite passes.
