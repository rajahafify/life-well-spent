# Field

## Core Idea

Field is the first area outside Town. It is not a dungeon yet; it is the old beginner field where new adventurers once learned courage. The Demon King is gone, but the grasslands still have small dangers, quiet roads, and the first blocked path toward the Forest.

Player enters Field from Town through a glowing portal. First Field slice should teach movement outside safety, show harmless-to-mild enemies, reveal the Forest path, and introduce the Forest Guard as a narrative gate.

## Start Prompt

Field may open with a small objective banner:

```text
Objective: Find the Forest path.
```

## Tone

Gentle adventure.

- Bright grassland.
- Beginner danger.
- Old roads partly reclaimed by nature.
- Field feels safe enough to explore, but not fully harmless.
- Forest edge hints at larger unknown world.

Key feeling:

```text
The world is peaceful, not empty.
Small dangers still teach first lessons.
```

## Purpose

- Receive player from Town.
- Let player move in a larger outdoor space.
- Show path back to Town.
- Show Forest path as player-facing objective.
- Block Forest with Guard.
- Send player back to Town with Swordsman Guild certification requirement.

## EnemySystem Slice

Field currently implements the first enemy/combat slice with one visible Slime.

Current implementation:

- One Slime spawned under `Enemies/Slime` from catalog id `slime_spiked`.
- Simple text UI: `Life: x/y` and `Slime: x/y`.
- Clicking Slime engages it and moves Player toward it.
- Player auto-attacks while in range.
- Aggro Slime chases Player if Player moves away.
- Slime attacks current Life on its attack interval.
- Slime HP <= 0 removes Slime and grants XP once.

Future purpose:

- Add Bat/Rat placements.
- Add item drops.
- Trigger `forest_gate_seen` for Town Swordsman Guild quest unlock.

## Naming Decision

- Terminology is **Field**, not Starter Area.
- Scene file should be `scenes/field.tscn`.
- Root node should be `Field`.
- Controller script should be `scripts/controllers/field.gd`.
- Controller class should be `class_name Field`.
- Town portal text/target changed from `Starter Area` to `Field`.
- No `FieldModel` yet. Field-specific pure rules live in combat, enemy, gateway, respawn, NPC placement, and biome models.

## Layout

```text
┌──────────────────────────────────────────────┐
│                         Forest Edge          │
│               dark trees / blocked path      │
│                         [Forest Guard]       │
│                              ▲               │
│                              │               │
│        [Bat]            Forest Path          │
│                                              │
│                  Grass / field               │
│                                              │
│   [Slime]                         [Rat]      │
│                                              │
│                                              │
│           [Player Spawn]                     │
│                                              │
│ [Town Portal]                                │
└──────────────────────────────────────────────┘
```

## Functional Zones

### Bottom Left — Town Portal

Return portal back to Town. This is the safe exit.

Entering the Town Gateway transitions directly back to Town.

### Lower Center — Player Spawn

Player appears here when entering from Town.

### Middle — Beginner Field

Open movement/combat playground with small enemies spread apart.

### Top / Top Right — Forest Edge

Darker tree line and blocked path. Forest is not playable in prototype.

### Forest Gate — Guard Blocker

Forest Guard stands near the blocked Forest path. He blocks progression and points player back to Swordsman Guild.

## Field Enemies

All enemies are prototype placeholders with real click-attack combat through `CombatSystem`.

### Slime

Role: tanky/simple tutorial enemy.

- Slow.
- Obvious fantasy starter monster.
- Uses catalog id `slime_spiked`.

### Bat

Role: mobile aerial starter enemy.

- Small.
- Quick-looking.
- Teaches Field has threats beyond ground blobs.

### Rat

Role: fast/medium starter enemy.

- Low to ground.
- Slightly more aggressive than Slime.

## Forest Guard

NPC: **Forest Guard**

- Male or armored neutral placeholder.
- Protective, not hostile.
- Not an antagonist.
- Blocks Forest because uncertified adventurers die there.

World aspect: old places still have danger; rebuilding requires responsibility.

Dialog:

```text
Stop.

The Demon King is gone.
But old places do not become safe overnight.

The Forest remembers what we forgot.
Return to Town.
Earn certification from the Swordsman Guild.
```

Future effect:

- Set `forest_gate_seen = true`.
- Unlock Swordsman Guild quest in Town.

## Objects

- Player
- Camera
- HUD or objective banner
- Dialog Panel
- Slime placeholder
- Bat placeholder
- Rat placeholder
- Forest Guard NPC
- Forest Edge / dark tree wall
- Forest Blocker
- Town Portal
- Primitive grass field
- Primitive dirt paths
- Rocks / bushes / grass patches

## Devices

- Town Gateway interaction zone.
- Gateway body-enter transitions directly to Town.
- Enemy click interaction runs one player attack and possible enemy counterattack.
- Forest Gate interaction zone.
- Forest Blocker collision.
- Forest Guard interaction zone.
- Dialog Next button advances paged dialog.
- Dialog close button hides dialog.

## Field State Read/Write

First Field slice reads:

- current scene/run state only.

First Field slice writes:

- requested transition to Town.
- future `forest_gate_seen` when Guard blocks player.

Future Field reads:

- `swordsman_guild_unlocked`
- `life`
- `max_life`
- `inventory`
- `xp`

Future Field writes:

- enemy defeated events
- XP rewards
- current Life damage
- Forest gate seen flag

## Verbs

- Move
- Explore
- Approach
- Talk
- Block
- Return

- Fight
- Attack
- Take Damage
- Defeat
- Gain XP

Future verbs:

- Consume

## Resources Shown

First Field slice shows:

- objective text
- Life / Max Life
- XP

Future Field may show:

- equipped weapon
- consumable count

If HUD is deferred, Field must still show player movement, enemy placeholders, Forest Guard, and return portal.

## Rules

- Player can move by clicking ground.
- Player can return to Town via portal.
- Forest is blocked in prototype.
- Forest Guard dialog explains certification requirement.
- Forest Guard is dialog-only in current slice.
- Field uses the same RO-style movement, camera, NPC, dialog, and portal systems as Town.

Future rules:

- Expanded EnemySystem adds Bat/Rat, respawn, drops, and richer feedback.
- Forest Guard sets `forest_gate_seen = true`.
- Forest remains inaccessible until future slice.

## Conditions

First Field slice:

- On scene start: show objective prompt.
- On ground click while dialog is closed: route Player movement to `CharacterMovement`.
- Camera follows Player with RO-style upward offset.
- On ground click while dialog is open: block movement.
- On far Forest Guard click: Player walks toward Guard talk point, dialog remains closed.
- On pending Forest Guard reaching talk range: Player stops, faces Guard, Guard faces Player, paged dialog opens.
- On Town Gateway body entered by Player: record `res://scenes/town_scene.tscn` and transition directly.
- On Slime click: Player targets Slime, moves into range, and auto-attacks.
- On Slime aggro: Slime chases Player until attack range.
- On Slime attack interval: Slime damages current Life.
- On Slime HP <= 0: Slime dies, is removed, and grants XP once.

Future conditions:

- If player approaches Forest Gate and `swordsman_guild_unlocked = false`: Guard blocks path and explains certification requirement.
- If player approaches Forest Gate after future unlock: behavior TBD.

## Permissions

Player can:

- move by clicking ground if no dialog/game over open
- talk to Forest Guard
- return to Town through glowing gateway

Player cannot:

- enter Forest in first slice
- unlock Swordsman Guild directly from Field

## Primitive / SVG Art Direction

Field uses primitive/SVG world art plus generated LPC character sprites.

- Ground: bright green `ColorRect`/primitive plane.
- Paths: brown strips from Town portal to Forest edge.
- Grass patches: simple green circles/polygons.
- Rocks: gray circles/polygons.
- Bushes: darker green circles/polygons.
- Forest Edge: dark green tree wall / dense shape cluster.
- Forest Blocker: barricade rectangles or dark collision line.
- Town Portal: warm/blue portal with `Town` label.
- Slime uses cataloged enemy sprite asset `slime_spiked`; Bat/Rat are cataloged for future placement.
- Forest Guard: generated LPC or reused guard placeholder sprite.
- Interactable zones: faint yellow rings.
- HUD/dialog: same Town dialog styling.
- World primitive `Control` nodes use `mouse_filter = ignore` so ground clicks reach Field movement.

Color language:

- Field = bright grass green / dirt brown.
- Forest Edge = dark green / blue shadow.
- Interactable = yellow.
- Danger/blocked = red or dark gray.
- Portal = blue/green glow.
- XP = gold.

## First Slice Non-Goals

- No Bat/Rat runtime placement yet.
- No enemy drops.
- No inventory use.
- No playable Forest.
- No Swordsman Guild quest chain.
- No permanent state change until Guard flag is implemented.

## Deliverables

### Documentation

- `prototype/components/Field.md` is the Field source of truth.
- Field terminology replaces Starter Area in docs and UI.
- Field first-slice scope and non-goals are documented here.

### Spec

RED specs cover root naming, controller class naming, player/camera, return gateway, enemy placeholders/combat, Forest Guard, Forest blocker, dialog copy, and objective prompt.

### Scene

- Create `scenes/field.tscn`.
- Root node should be named `Field`.
- Scene should contain Player, Camera, UI, Field enemies, Forest Guard, Forest blocker, and Town Portal.

### Script

- Create `scripts/controllers/field.gd`.
- Script should expose `class_name Field`.
- No `FieldModel` yet.

### First-Slice Acceptance

Player can:

1. Spawn in Field.
2. Read objective prompt.
3. Move around Field.
4. See Slime.
5. Click Slime to start approach + auto-attack.
6. See Slime chase and attack back against Life.
7. Kill Slime and see it removed.
8. See Forest Edge and blocked Forest path.
9. Talk to Forest Guard.
10. Use portal to request Town transition.

## First Slice

1. Enter Field from Town portal.
2. Show objective prompt: `Objective: Find the Forest path.`
3. Click ground to move around Field; camera follows Player.
4. See Slime, Forest Edge, Forest Guard, and Town Portal in 1080p viewport.
5. Click Slime; Player approaches and auto-attacks in range.
6. Slime aggros, chases if Player moves, attacks current Life, then dies/removes at HP <= 0.
7. Click Forest Guard from far away; Player approaches before dialog opens.
8. Talk to Forest Guard for paged certification warning dialog.
9. Use `Next` to advance dialog pages; use `Close` to exit dialog.
10. Walk into Town Gateway.
11. Gateway transitions directly to Town.

## Tests

- [ ] Field scene loads.
- [ ] Field scene root is named `Field`.
- [ ] Field script class is `Field`.
- [ ] Player spawns lower center.
- [ ] Camera exists and follows Player.
- [ ] Town Portal exists.
- [ ] Objective prompt displays on scene start.
- [ ] Enemy container exists with Slime.
- [ ] Simple Life and Slime HP text exists.
- [ ] Clicking Slime engages Player target and movement.
- [ ] Player auto-attack damages Slime.
- [ ] Slime attacks current Life.
- [ ] Aggro Slime chases Player when Player moves away.
- [ ] Slime HP <= 0 removes Slime and grants XP.
- [ ] Forest Edge exists.
- [ ] Forest Blocker exists.
- [ ] Forest Guard NPC exists.
- [ ] Forest Guard dialog matches first-slice warning text.
- [ ] Forest Guard dialog is paged.
- [ ] Far Forest Guard click moves Player toward Guard without opening dialog immediately.
- [ ] Pending Guard dialog opens when Player reaches talk range.
- [ ] Player entering Town Gateway records Town target path directly.
- [ ] Field controller exposes no stale enemy attack API.
- [ ] World primitives ignore mouse input so ground click-to-move works.
