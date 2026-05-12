# Field

## Core Idea

Field is the first area outside Town. It is not a dungeon yet; it is the old beginner field where new adventurers once learned courage. The Demon King is gone, but the grasslands still have small dangers, quiet roads, and the first blocked path toward the Forest.

Player enters Field from Town through a glowing portal. The current Field slice teaches movement outside safety, shows mild enemies, reveals the Forest path, and introduces the Forest Guard as a narrative gate.

## Current Status

Field is implemented on branch `prototype/field`.

- Scene: `scenes/field.tscn`
- Controller: `scripts/controllers/field.gd`
- Root: `Field`
- Controller class: `class_name Field`
- Map source: `D:\godot\kenney_tiny-town\field.tmj`
- Imported visual scene: `scenes/maps/field_map.tscn`
- Imported collision scene: `scenes/maps/field_collision.tscn`
- Latest full-suite validation: `295 tests, 295 passed`
- Latest local Field work: shared inventory slots/shortcut bar, Apple chance drops and use, larger enemy footprint/spacing, regenerated enemy SpriteFrames, combat feedback, 10x Field combat readability tuning, and enemy HP bar polish

The current map is an imported Tiny Town Tiled map, not primitive art. It is `96x68` tiles at `32x32` pixels.

## Start Prompt

Field opens with:

```text
Objective: Find the Forest path.
```

## Tone

Gentle adventure.

- Bright grassland.
- Beginner danger.
- Old roads partly reclaimed by nature.
- Field feels safe enough to explore, but not fully harmless.
- Forest edge hints at a larger unknown world.

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

## Map And Collision

Field uses a layered Tiled map imported into native Godot scenes.

Current Tiled layers include:

- `Ground`
- `Paths`
- `Props`
- `Bushes`
- `C-Trees`
- `C-Fence`

Import rules:

- Visual map generation renders normal visual layers.
- Layers whose names start with `C-` are both renderable and collidable.
- Collision generation merges solid `C-` tiles into larger `StaticBody2D` blocker rectangles.
- The previous visible `ForestBlocker` node was removed; imported `FieldCollision` owns map blockers.

Current generated collision includes blockers from `C-Trees` and `C-Fence`.

## Layout

The current Field is an expanded single map.

```text
          [Town Gateway]
               |
               |
        north-south road
               |
        open grassland field
        enemies spread around
               |
               +----------------------.
                                      |
                                      v
                         [Forest Guard]
                         [Forest Gateway]
```

Important coordinates in `scenes/field.tscn`:

- Town gateway: `Vector2(1552, 64)`
- Field spawn from Town: `Vector2(1552, 160)`
- Forest gateway: `Vector2(2768, 2112)`
- Forest Guard: `Vector2(2768, 2000)`
- Enemy spawn zone: `Rect2(Vector2(380, 300), Vector2(2480, 1640))`

## Functional Zones

### North Road - Town Gateway

Return portal back to Town. This is the safe exit.

Entering the Town Gateway transitions directly back to Town.

### North Road Spawn

Player appears just south of the Town gateway when entering Field from Town, far enough away to avoid immediately retriggering the portal.

### Open Field

Open movement/combat playground with small enemies spread apart.

### Southeast Road - Forest Gate

Forest Guard stands near the blocked Forest path. He blocks progression and points player back to Swordsman Guild.

## Enemy System Slice

Field currently implements a real enemy/combat slice through `CombatSystem`, `EnemyLibrary`, data-only `EnemyDefinition`, `EnemyState`, `EnemyBehaviorSystem`, `EnemyRandomSequence`, and `DropSystem`.

Scene orchestration is split so `scripts/controllers/field.gd` stays as scene glue:

- `FieldCameraController` owns camera follow offset and hit shake.
- `FieldEnemySpawnController` owns spawn slot registration, live respawn polling, and random spawn placement.
- `FieldCombatController` owns player auto-attack and enemy behavior/combat tick orchestration.

Field tests use public query helpers such as `enemy_state()`, `enemy_view()`, `player_target_id()`, and `is_camera_shaking()` instead of reaching directly into controller dictionaries or private timers.

Current runtime enemies:

- Five Slimes from catalog id `slime_spiked`.
- Two Bats from catalog id `bat`.
- Two Rats from catalog id `rat`.

Current combat behavior:

- Shared HUD UI: `Life: x/y`, Inventory button/window, and Quest Tracker. Enemy HP bars stay hidden at full HP and appear below enemy sprites after the enemy takes damage.
- Combat feedback uses reusable components for enemy hit flash, larger RO-style parabolic floating damage text, global SFX requests, short camera shake, and loot toast. Enemy damage numbers are white; player damage numbers are red.
- Field combat readability scales enemy HP and Player outgoing attack 10x.
- Player Life stays at `100/100`, and enemy attack values against Player are unchanged.
- Slime starts at 140 HP and takes 30 visible damage from Player attack 40 against defense 10; Bat starts at 80 HP; Rat starts at 60 HP.
- Clicking an enemy engages it and moves Player toward attack range.
- Player auto-attacks while in range.
- First player hit aggros the enemy.
- Aggro enemy chases Player if Player moves away.
- Enemy attacks current Life on its attack interval.
- Enemy HP `<= 0` plays death, removes the enemy after its death duration, and grants XP once.
- Enemy movement and spawn placement reject imported `FieldCollision` blockers.
- Field registers persistent spawn slots with `EnemySpawnManager`.
- Defeated enemy slots stay gone across portal changes and become available after the global 60 second respawn timer.
- Respawned slots pick a fresh valid random position in `SpawnZones/Grassland`.
- Field polls the spawn manager while loaded, so eligible enemies respawn after the timer without requiring another portal transition.
- Slime, Bat, and Rat each keep their guaranteed material drop and have a 1-in-5 chance to also drop `apple`.
- Enemy sprites render larger in Field, with larger click collision and wider player/enemy spacing so enemies do not stand underneath the player sprite.
- Shortcut slot `1` starts mapped to `apple`; pressing `1` in Field uses one Apple if available and current Life is below Max Life.

Still future:

- Equipment combat effects in Field.
- More complete item/shortcut UI states.

## Field Enemies

All Field enemies use real click-attack combat through `CombatSystem`.

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
- Uses catalog id `bat`.

### Rat

Role: fast/medium starter enemy.

- Low to ground.
- Slightly more aggressive than Slime.
- Uses catalog id `rat`.

## Forest Guard

NPC: **Forest Guard**

- Protective, not hostile.
- Not an antagonist.
- Blocks Forest because uncertified adventurers die there.
- Uses clickable NPC interaction, not proximity dialog.
- Far click makes Player approach before dialog opens.

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

- Advance `Explore the World` to `Get Swordsman Certification`.
- Activate the `Rebuilding Swordsman Guild` side quest chain in Town.

## Objects

Implemented:

- Player
- Camera
- Objective prompt
- Life HUD and enemy HP bars
- Inventory button/window
- Shortcut bar
- Dialog Panel
- Imported `FieldMap`
- Imported `FieldCollision`
- Slime enemies
- Bat enemies
- Rat enemies
- Forest Guard NPC
- Forest Gateway
- Town Gateway

Removed / replaced:

- Primitive grass field
- Primitive dirt paths
- Primitive props
- Visible `ForestBlocker` node

## Devices

- Town Gateway interaction zone.
- Gateway body-enter transitions directly to Town.
- Enemy click interaction engages target and starts approach/auto-attack.
- Forest Gateway interaction zone.
- Imported `FieldCollision` blockers.
- Forest Guard interaction zone.
- Dialog Next button advances paged dialog.
- Dialog close button hides dialog.

## Field State Read/Write

Current Field reads:

- current scene/runtime state.
- `QuestSystem` main quest objective.
- `InventorySystem` global item counts and shortcut slots.

Current Field writes:

- requested transition to Town.
- current Life damage.
- XP rewards.
- `QuestSystem` main quest objective and side quest chain activation when the Forest Gateway is reached.
- `QuestSystem` `forest_guard` checkpoint when the Forest Gateway is reached.
- `InventorySystem` item counts when enemy drops are granted or Apple is consumed.

Future Field reads:

- `swordsman_guild_unlocked`
- `life`
- `max_life`
- `xp`

Future Field writes:

- enemy defeated events
- equipment combat effects

## Verbs

Implemented:

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
- Loot
- Consume
- Use Shortcut

Future verbs:

- Equip

## Resources Shown

Current Field shows:

- objective text
- top-right Quest Window
- Life / Max Life
- enemy HP bars
- Inventory button/window
- Shortcut slots `1` through `9`
- XP is awarded internally on enemy death

Future Field may show:

- equipped weapon effect
- armor mitigation
- consumable count on the shortcut bar
- broader enemy targeting/status UI

## Rules

- Player can move by clicking ground.
- Player can return to Town via portal.
- Forest is blocked in prototype.
- Forest Guard dialog explains certification requirement.
- Forest Guard is dialog-only in current slice.
- Field uses the same RO-style movement, camera, NPC, dialog, and portal systems as Town.
- Enemy movement must respect `FieldCollision`.
- Enemy spawn placement must avoid Player, Town portal, Forest Guard, nearby enemies, and imported collision blockers.
- Tiled layers beginning with `C-` are renderable and collidable.
- Field enemy visual scale, click collision, attack range, and player approach spacing are tuned together to avoid sprite overlap.
- Apple heals 20 current Life up to Max Life.
- Apple cannot restore Max Life.
- Apple cannot be used when count is 0.
- Apple cannot be consumed when current Life is already full.

Future rules:

- Forest remains inaccessible until future slice.
- Equipment rules should make weapon and armor slots affect combat.

## Conditions

Current Field slice:

- On scene start: show objective prompt.
- On ground click while dialog is closed: route Player movement to `CharacterMovement`.
- While left mouse is held and dialog is closed: keep updating Player movement destination to the mouse position.
- Camera follows Player with RO-style upward offset.
- On ground click while dialog is open: block movement.
- On far Forest Guard click: Player walks toward Guard talk point, dialog remains closed.
- On pending Forest Guard reaching talk range: Player stops, faces Guard, Guard faces Player, and paged dialog opens.
- On Forest Guard dialog close: QuestSystem records the Forest Guard checkpoint and updates the objective.
- On Town Gateway body entered by Player: record `res://scenes/town_scene.tscn` and transition directly.
- On enemy click: Player targets enemy, moves into range, and auto-attacks.
- On first player hit: enemy aggros.
- On aggro: enemy chases Player until attack range.
- On enemy attack interval: enemy damages current Life.
- On enemy HP `<= 0`: enemy dies, is removed after death animation timing, and grants XP once.
- On enemy reward grant: guaranteed material drops and rolled chance drops are added to `InventoryModel`.
- On shortcut `1` with Apple available and Life below Max Life: consume one Apple, heal up to 20 current Life, refresh Life HUD, and show a loot toast.
- On shortcut `1` with no Apple: show `No apple`.
- On shortcut `1` at full Life: show `Life is full` and do not consume Apple.
- On enemy movement into collision: movement is rejected.
- On Forest Gateway body entered by Player: scene transition remains blocked, QuestSystem marks `forest_guard`, advances `Explore the World` to `Get Swordsman Certification`, `Rebuilding Swordsman Guild` becomes active, and Guard warning opens.

Certified endpoint:

- If player approaches Forest Gate after Swordsman Certification: show `The Forest path opens. To be continued.`

## Permissions

Player can:

- move by clicking ground if no dialog/game over open
- talk to Forest Guard
- return to Town through glowing gateway
- click enemies to fight

Player cannot:

- enter Forest in current prototype; certification changes the block into a `To be continued` endpoint
- unlock Swordsman Guild directly from Field

## Art Direction

Field now uses Kenney Tiny Town tile art imported from Tiled.

- Ground/path/props/trees/fences come from `field.tmj`.
- `C-Trees` and `C-Fence` are visible and collidable.
- Town portal remains a gameplay portal visual with `mouse_filter = ignore`.
- Slime uses cataloged enemy sprite asset `slime_spiked`.
- Bat uses cataloged enemy sprite asset `bat`.
- Rat uses cataloged enemy sprite asset `rat`.
- Enemy sprites are enlarged for gameplay readability, with HP bars repositioned below the larger footprint.
- Forest Guard uses `assets/npcs/forest_guard.png`.
- HUD/dialog uses the same Town dialog styling.

Color language:

- Field = bright grass green / dirt road.
- Forest edge = dense tree boundary.
- Interactable = portal/area affordances.
- XP = gold.

## Current Non-Goals

- Enemy drops are model-backed and shown through the inventory window / loot toast, not world pickup sprites.
- No playable Forest.
- Swordsman Guild quest completion UI lives in Town, not Field.
- No drop pickup animation yet.
- No weapon/armor combat effect yet.

## Deliverables

### Documentation

- `prototype/components/Field.md` is the Field source of truth.
- `llm-wiki/scenes/field.md` records implementation details.
- `llm-wiki/assets/tiny-town-map-import.md` records Tiny Town import workflow.

### Spec

`tests/specs/field_scene_test.gd` covers root naming, controller class naming, player/camera, generated map/collision, portal placement, shared HUD, Apple shortcut use, enlarged enemy footprint/spacing, enemy combat, Forest Guard, dialog copy, and objective prompt.

### Scene

- `scenes/field.tscn` exists.
- Root node is named `Field`.
- Scene contains Player, Camera, UI, generated Field map/collision, Field enemies, Forest Guard, Forest Gateway, and Town Gateway.

### Script

- `scripts/controllers/field.gd` exists.
- Script exposes `class_name Field`.
- No `FieldModel` yet.

### Current Acceptance

Player can:

1. Spawn in Field.
2. Read objective prompt.
3. Move around Field.
4. See Slime, Bat, and Rat enemies.
5. Click an enemy to start approach + auto-attack.
6. See enemy chase and attack back against Life.
7. Kill an enemy and see it removed after death timing.
8. Earn drops into global inventory, with Apple as a chance drop.
9. Press `1` to use Apple when available and damaged.
10. See Forest edge and blocked Forest path.
11. Talk to Forest Guard.
12. Use portal to request Town transition.

## First Slice Flow

1. Enter Field from Town portal.
2. Show objective prompt: `Objective: Find the Forest path.`
3. Click ground to move around Field; camera follows Player.
4. See enemies, Forest edge, Forest Guard, and Town Portal.
5. Click enemy; Player approaches and auto-attacks in range.
6. Enemy aggros after first hit, chases if Player moves, attacks current Life, then dies/removes at HP `<= 0`.
7. Enemy death grants guaranteed material drop plus possible Apple chance drop.
8. Press `1` to consume Apple if hurt.
9. Click Forest Guard from far away; Player approaches before dialog opens.
10. Talk to Forest Guard for paged certification warning dialog.
11. Use `Next` to advance dialog pages; use `Close` to exit dialog.
12. Walk into Town Gateway.
13. Gateway transitions directly to Town.

## Tests

- [x] Field scene loads.
- [x] Field scene root is named `Field`.
- [x] Field script class is `Field`.
- [x] Player spawns near the Town gateway on the north road.
- [x] Camera exists and follows Player.
- [x] Town Portal exists.
- [x] Objective prompt displays on scene start.
- [x] Top-right Quest Window displays current main quest objective.
- [x] Generated `FieldMap` is instanced.
- [x] Generated `FieldCollision` is instanced.
- [x] `C-` map layers render and generate collision through the importer.
- [x] Enemy container exists with Slime, Bat, and Rat enemies.
- [x] Simple Life HUD and enemy HP bars exist.
- [x] Shared Inventory button/window exists.
- [x] Shortcut bar exists.
- [x] Shortcut `1` uses Apple when available and damaged.
- [x] Clicking enemy engages Player target and movement.
- [x] Player approach spacing keeps Player outside the enlarged enemy footprint.
- [x] Enemy sprite scale/click collision are enlarged for readability.
- [x] Player auto-attack damages enemy.
- [x] Enemy attacks current Life.
- [x] Aggro enemy chases Player when Player moves away.
- [x] Enemy HP `<= 0` removes enemy and grants XP.
- [x] Enemy HP `<= 0` grants deterministic item drop.
- [x] Enemy movement rejects `FieldCollision` blockers.
- [x] Defeated enemies stay gone across portal changes until their global respawn timer expires.
- [x] Eligible enemies respawn while Field remains loaded.
- [x] Forest edge exists through imported `C-Trees`.
- [x] Forest blocker behavior exists through imported `FieldCollision`.
- [x] Forest Guard NPC exists.
- [x] Forest Guard dialog matches first-slice warning text.
- [x] Forest Guard dialog is paged.
- [x] Far Forest Guard click moves Player toward Guard without opening dialog immediately.
- [x] Pending Guard dialog opens when Player reaches talk range.
- [x] Player entering Town Gateway records Town target path directly.
- [x] World primitive art nodes are removed/replaced by imported map art.
- [x] Forest Gateway advances QuestSystem to `Get Swordsman Certification`.
- [x] Forest Gateway records the `forest_guard` checkpoint.
- [x] `Rebuilding Swordsman Guild` activates from the Forest Gateway flow.
- [x] Enemy drops exist.
- [x] Inventory/consume behavior exists in Field.
- [x] Certified Forest Gateway shows `To be continued` instead of the original Guard block.
- [ ] Weapon/armor equipment effects exist in Field.
