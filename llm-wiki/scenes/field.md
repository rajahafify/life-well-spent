---
title: Field Scene
type: reference
updated: 2026-05-13
tags: [scenes, field, prototype]
---

# Field Scene

## Overview

`scenes/field.tscn` is the playable Field outside Town. Current slice has click movement, camera follow, generated Tiny Town field art/collision, Forest Guard blocking the southeast Forest path, a direct Town gateway centered on the north road entry, shared gameplay HUD, QuestSystem Forest Gate progression, and the first Slime/Bat/Rat combat flow.

## Scene Structure

```text
Field (Node2D, Field)
- FieldMap (instance: scenes/maps/field_map.tscn)
- FieldCollision (instance: scenes/maps/field_collision.tscn)
- SpawnZones/Grassland (hidden ColorRect enemy spawn region)
- SpawnPoints/FromTownGateway, SpawnPoints/Default
- Player (player.tscn, starts at FromTownGateway, south of TownGateway trigger)
- TownGateway (north road entry)
- ForestGateway (southeast road end)
- ForestGuard (NpcController, forest_guard.png, southeast road end)
- Enemies
  - Slime*5 (EnemyView with HpBar, spawned by Field controller)
  - Bat*2 (EnemyView with HpBar, spawned by Field controller)
  - Rat*2 (EnemyView with HpBar, spawned by Field controller)
- Camera2D
- UI (shared_hud.tscn)
  - LifeLabel
  - InventoryButton
  - InventoryWindow
  - QuestWindow
  - DialogPanel (TownDialogView)
```

## Generated Map

The UI is an instance of `scenes/ui/shared_hud.tscn`. It owns common gameplay HUD controls: player Life, Inventory button/window, and the top-right Quest Tracker using `QuestWindowView`.

`FieldMap` and `FieldCollision` are generated from:

```text
D:\godot\kenney_tiny-town\field.tmj
```

The field map is `96x68` tiles at `32x32` pixels. It uses Tiny Town visual layers, with collision generated only from tile layers whose names start with `C-` such as `C-Trees` and `C-Fence`. It is imported with:

```powershell
python tools\import_tiny_town_tmj.py --tmj D:\godot\kenney_tiny-town\field.tmj --map-scene scenes\maps\field_map.tscn --collision-scene scenes\maps\field_collision.tscn --update-scene scenes\field.tscn --map-node-name FieldMap --collision-node-name FieldCollision --insert-before SpawnZones --position "0, 0" --scale "1, 1"
```

Legacy primitive Field art nodes (`Ground`, `Paths`, `ForestEdge`, and `Props`) have been removed; imported map layers now own terrain visuals. The previous visible `ForestBlocker` bar under the Forest Guard was removed; blockers now come from the generated `FieldCollision` scene.

## Controller

`Field` is thin glue:

- starts Player at named spawn point `SpawnPoints/FromTownGateway`, near TownGateway
- keeps Player outside the TownGateway trigger on scene load
- routes ground clicks to `CharacterMovement`
- continues updating the move destination while the left mouse button is held and no dialog is open
- ignores world movement input while the pointer is over HUD controls
- delegates camera follow and shake to `FieldCameraController`
- uses `TownDialogView` for Forest Guard dialog
- updates `SharedHUDView` with player Life and `QuestSystem.current_main_objective_text()`
- handles far-click Guard approach before dialog
- marks the `forest_guard` checkpoint only after the Forest Guard dialog is closed, whether reached by NPC click or Forest Gateway collision
- direct Town gateway request to `res://scenes/town_scene.tscn`, with the scene-tree change deferred outside the physics callback
- blocks Forest gateway at the southeast road end, marks the `forest_guard` checkpoint, advances `Explore the World` to `Get Swordsman Certification.`, activates `Rebuilding Swordsman Guild`, and opens Guard warning
- after `swordsman_certification`, Forest Guard and Forest gateway no longer repeat the Guard block, preserve the `enter_forest` objective, and show the prototype endpoint copy: `The path to forest is open.`
- delegates enemy slot registration, spawn polling, and random spawn placement to `FieldEnemySpawnController`
- spawns five Slimes, two Bats, and two Rats from `EnemyLibrary.for_id()`
- routes enemy click to player approach + auto-attack
- keeps player approach points outside the enlarged enemy footprint (`96px` stop distance)
- delegates player auto-attack and enemy behavior/combat loops to `FieldCombatController`
- applies `CombatSystem` damage to enemy HP and player Life through the combat helper
- uses prototype balance scaling: player attack is 40 and enemy HP is 10x larger, while player Life and enemy attack values stay unchanged
- grants item drops into the game-wide `InventorySystem` when enemy rewards are granted
- delegates chance-based drop rolls to the pure `DropSystem`
- uses the shared HUD inventory window opened from the `Inventory` button or `I` key
- handles shared HUD shortcut slot `1` as Apple use: consumes one Apple, heals current Life by up to 20 without exceeding Max Life, refreshes Life UI, and shows a toast
- emits enemy hit feedback through reusable `HitFeedbackComponent` / `DamageTextComponent` children
- adds lightweight combat feedback: enemy hit flash, floating damage text, short camera shake on hits, SFX requests through `FeedbackSystem`, and a temporary loot toast when drops are granted
- plays enemy death animation before removal and grants XP once when HP reaches zero

## Enemy Combat Slice

Current Field combat scope is five Slimes, two Bats, and two Rats.

- Slime id: `slime_spiked`
- Bat id: `bat`
- Rat id: `rat`
- Starting enemy stats: Slime 140 HP / 1 attack / 10 defense; Bat 80 HP / 2 attack / 0 defense; Rat 60 HP / 2 attack / 0 defense.
- Player outgoing attack is 40; against Slime defense 10, visible enemy hit text is 30.
- Player Life remains `100/100`; enemy damage to Player is unchanged.
- Enemy sprites render larger at 4x world scale. Enemy click collision uses a larger circular footprint, and Field map-collision checks grow blockers by a larger enemy radius so enemies do not visually overlap trees, fences, or the player as tightly.
- Enemy attack ranges are widened for the larger footprint: Slime 96, Bat 104, Rat 96.
- UI: shared HUD with `Life: x/y`, Inventory button/window, and Quest Tracker. Enemy HP is shown with thin per-enemy `HpBar` progress bars below enemy sprites only after that enemy has taken damage; the old temporary `SlimeHpLabel` HUD text and enemy `HpLabel` text are removed.
- RO-style damage numbers appear above Player and enemies using the readable 36px feedback component default.
- Hits add a brief camera shake, enemy flash, and RO-style parabolic floating damage text for combat readability.
- Enemy damage numbers are white; player damage numbers are red.
- Player click targets an enemy and moves toward it without aggroing immediately.
- Player auto-attacks with LPC `slash` animation while in range.
- First player hit aggros the enemy.
- Aggro enemy chases if player moves away.
- Enemy attacks current Life on its attack interval.
- Enemy death plays `death`, waits `death_duration`, removes the node, awards XP, and marks the persistent spawn slot defeated.
- Enemy death also grants item drops from `EnemyDefinition.drop_table`, with chance rolls handled by `DropSystem`.
- Current material drops are 20% chance: Slime -> `slime_gel`, Bat -> `bat_wing`, Rat -> `rat_tail`.
- Current chance drop: all Field enemies have a 1-in-5 chance to also drop `apple`.
- Drop grants show a short `+ item xN` loot toast.
- Pressing shortcut `1` uses Apple if the player has one and current Life is below Max Life. Apple heals up to 20 current Life, consumes one stack item, and cannot restore Max Life.
- Inventory overlay: `scenes/ui/inventory_window.tscn`, opened by `SharedHUDView`.
- Initial spawn positions are random inside `SpawnZones/Grassland`, avoiding Player, Town portal, Forest Guard, imported collision blockers, and nearby enemy overlap.
- Defeated enemy slots do not respawn on portal changes; they become available after the global 60 second respawn timer.
- Field polls the spawn manager once per second while loaded and respawns eligible missing slots without requiring a portal change.

## Test Coverage

- `tests/specs/field_scene_test.gd` covers scene load, root/class, Player/Camera/gateways, generated `FieldMap` and `FieldCollision`, north TownGateway placement, shared HUD, Inventory button/window and `I` key toggle, HUD pointer blocking for movement, Apple shortcut use, removal of legacy primitive Field art and the old visible ForestBlocker bar, southeast Forest Guard/gateway placement, enemy collision rejection, spawn zone, enlarged Slime/Bat/Rat sprite and collision footprint, player approach spacing, per-enemy HP bars, removal of text-based enemy HP labels, click targeting without immediate aggro, player auto-attack, first-hit aggro, enemy Life damage, hit shake/flash, loot toast, chase, death removal/XP/drop grant, Guard dialog, bottom-right dialog buttons, QuestSystem Forest Guard checkpoint and Forest Gate objective progression, certified Forest Guard/Gateway open-path endpoint, Quest Window refresh, movement/camera, dialog paging/movement lock, deferred direct Town gateway, and blocked Forest gateway.
- Gateway, NPC placement, biome, movement, enemy behavior, combat, drop, and dialog systems remain covered by their model/scene specs.

Latest Field validation: Field scene specs included in the full suite. Full suite currently reports `354 tests, 354 passed, 0 failed`.

## Related

- `assets/assets-catalog.md`
- `llm-wiki/scenes/town-hub.md`
- `llm-wiki/assets/tiny-town-map-import.md`
- `llm-wiki/architecture/gateway-definition.md`
- `llm-wiki/architecture/enemy-behavior-system.md`
- `llm-wiki/architecture/enemy-spawn-system.md`
- `llm-wiki/architecture/field-controller-boundaries.md`
- `llm-wiki/architecture/drop-system.md`
- `llm-wiki/architecture/quest-system.md`
- `llm-wiki/architecture/shared-hud-view.md`
- `llm-wiki/architecture/inventory-system.md`
- `llm-wiki/architecture/feedback-components.md`
