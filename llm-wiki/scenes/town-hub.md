---
title: Town Scene
type: reference
updated: 2026-05-12
tags: [scenes, town, prototype]
---

# Town Scene

## Overview

`scenes/town_scene.tscn` is the first-slice **Town** scene for the prototype. It replaces the previous MVP town-hub task/quest UI with a systemic prototype slice: hopeful post-Demon-King worldbuilding, three old institutions, shared gameplay HUD, QuestSystem-aware Guildmaster dialog, and a direct glowing gateway to Field.

First-slice goal:

1. Player is reborn in Town.
2. Player sees Shop, Swordsman Guild, Blacksmith, and Field Gateway.
3. Player talks to Guildmaster, Shopkeeper, and Smith.
4. Player exits through the gateway toward Field.

## Naming

- Scene file: `scenes/town_scene.tscn`
- Root node: `Town`
- Controller script: `scripts/controllers/town_scene_controller.gd`
- Controller class: `Town`
- No `TownModel` yet; future pure rules belong in `RunState`, inventory, combat, and quest-chain models.

## Scene Structure

```text
Town (Node2D, Town)
├── Ground (ColorRect)
├── Paths (Node2D)
│   ├── MainPath (ColorRect)
│   └── PortalPath (ColorRect)
├── Buildings (Node2D)
│   ├── Shop (ColorRect)
│   ├── SwordsmanGuild (ColorRect)
│   └── Blacksmith (ColorRect)
├── TownMap (instance: scenes/maps/town_map.tscn)
├── TownCollision (instance: scenes/maps/town_collision.tscn)
├── SpawnPoints
│   ├── FromFieldGateway (Marker2D)
│   └── Default (Marker2D)
├── Player (instance: player.tscn, starts at FromFieldGateway)
├── Shopkeeper (NpcController, `assets/npcs/shopkeeper.png`, in front of bottom Tiny Town house)
├── Guildmaster (NpcController, `assets/npcs/guildmaster.png`, in front of castle/guild)
├── Smith (NpcController, `assets/npcs/smith.png`, in front of right Tiny Town house)
├── FieldGateway (Area2D, south road exit)
│   ├── CollisionShape2D
│   ├── Visual (ColorRect)
│   └── Label — "Field"
├── Camera2D
└── UI (CanvasLayer)
    ├── LifeLabel / InventoryButton / QuestWindow / InventoryWindow
    └── DialogPanel (TownDialogView)
```

## NPC Dialog

### Guildmaster

Before the player reaches the Forest Gate, the Guildmaster reveals old institutions / rebuilding hope.

```text
The Swordsman Guild still stands.

Not as it was.
The halls are quiet, and the old names fade from the register.

But a guild is not stone or banners.
It lives when someone chooses the path.

Perhaps one day, someone will help me raise it again.
```

After Field advances the main quest objective to `Get Swordsman Certification.`, the Guildmaster offers quest-completion certification steps for the `Rebuilding Swordsman Guild` side quest chain:

```text
You found the Forest gate, and now you need Swordsman Certification.

Certification is not earned with coin.
It is earned with life.

Complete certification step 1 to help rebuild the Swordsman Guild.
```

Each completion spends 40 Max Life until the third step spends the remaining Life, grants `swordsman_certification`, unlocks `swordsman_guild`, and shows `SWORDSMAN GUILD UNLOCKED`.

### Shopkeeper

Reveals ordinary life worth protecting.

```text
Welcome, traveler.

This shop once packed bags for heroes.
Now I sell apples, candles, and thread.

It is quieter, yes.
But quiet days are worth protecting too.
```

### Smith

Reveals old tools waiting / practical nostalgia.

```text
I used to shape steel for adventurers.

Now I mend plows, hinges, and cooking pots.
Honest work.

Still, I keep the sword molds clean.
Old roads have a way of calling again.
```

## Controller

`Town` is thin glue:

- opens the reborn copy in `TownDialogView` only on the first Town visit for the current runtime
- connects worldbuilding NPC `interacted(npc)` signals
- routes ground clicks to `CharacterMovement` while dialog is closed
- continues updating the move destination while the left mouse button is held and no dialog is open
- ignores world movement input while the pointer is over HUD controls
- follows player with a camera offset for RO-style play
- blocks click-to-move while dialog is open
- handles RO-style NPC approach after sprite click: far NPC click moves Player to the NPC talk point, near/in-range sprite click opens dialog
- shows paged NPC dialog via `TownDialogView.show_dialog()`
- reads `QuestSystem.current_main_objective_id()` so Guildmaster dialog can react to the Forest Gate objective
- routes Guildmaster quest-completion button presses through `ProgressionModel.complete_swordsman_certification_step()`
- updates the shared HUD after certification changes Life / Max Life
- updates `SharedHUDView` with player Life and the current main quest objective
- starts Player at named spawn point `SpawnPoints/FromFieldGateway`, up the south road and outside the FieldGateway trigger
- records Field transition request through `request_field()`
- records the direct Field transition when the Player enters `FieldGateway`, then defers the actual scene change outside the physics callback
- hides NPC overhead names; names appear in dialog only
- passes NPC sprite texture to `TownDialogView` for face portrait display above the dialog box
- hides NPC dialog when `TownDialogView.close_requested` emits

Shop and forge logic are not active in this slice. Town can now read QuestSystem state, present the Guildmaster certification prompt after the Forest Gate is reached, and complete the three-step Swordsman Guild Life-spend chain.

## Art Direction

Prototype Town uses primitives/SVG world art with generated LPC sprites for Player and NPCs. Project viewport is 1920×1080 for prototype readability. World primitive `Control` nodes set `mouse_filter = ignore` so ground clicks reach Town movement.

Tiny Town visual art is imported as `TownMap`, an instanced generated scene from `tools/import_tiny_town_tmj.py`. The same importer generates `TownCollision` from solid Tiny Town layers as merged native `StaticBody2D` blockers. Tiled remains the editable source, while Town keeps ownership of Player, NPCs, gateways, spawn points, camera, and UI.

- warm tan ground
- brown path strips
- rectangle buildings
- central Swordsman Guild landmark
- blue/green glowing portal
- parchment/dark dialog panel

## Tests

- `tests/specs/town_prototype_test.gd` covers root/class naming, buildings, NPCs, custom NPC sprite textures, NPC scale matching player, dialog copy, absence of persistent reborn HUD label, Field gateway label, 1080p viewport, and primitive mouse filter settings.
- `tests/specs/town_prototype_test.gd` also covers the generated Tiny Town `TownMap` and `TownCollision` instance paths, position, scale, and collision blocker shape.
- `tests/specs/town_prototype_test.gd` covers the Tiny Town-facing NPC placements: Shopkeeper at `Vector2(512, 1140)`, Guildmaster at `Vector2(960, 450)`, and Smith at `Vector2(1472, 820)`.
- `tests/specs/town_prototype_test.gd` covers the south-road Field gateway at `Vector2(960, 1320)` and its safe spawn at `Vector2(960, 980)`, far enough to avoid auto-transition.
- `tests/specs/town_scene_dialog_test.gd` covers startup reborn dialog, no repeated reborn dialog on later Town entry, readable 1080p dialog text, bottom-right dialog buttons, shared HUD, HUD pointer blocking for movement, top-right Quest Tracker, NPC face portrait crop above the box, paged NPC dialog, RO-style sprite-click NPC approach, pending dialog open in talk range after click, camera follow, held-mouse destination updates, desynced NPC idle timing, hidden overhead NPC names, first-slice quest buttons hidden, QuestSystem Guildmaster certification prompt, certification Life spend, final Swordsman Guild unlock, click-to-move routing/blocking, dialog close behavior, and direct Field gateway request.
- `tests/specs/npc_controller_test.gd` and `tests/specs/scene_smoke_test.gd` cover removal of proximity-based NPC dialog triggers.
- `tests/specs/scene_smoke_test.gd` covers Town dialog smoke behavior.

Current validation after south portal placement: `246 tests, 246 passed, 0 failed`; MCP main-scene play reports no errors.

Systems introduced by Town are cataloged in `prototype/game-systems.md` using systemic design terms: verbs, components, resources, rules, and conditions.

## Manual QA

Passed on 2026-05-11:

- Town opens with the reborn copy in the dialog box.
- Ground click-to-move works after world primitives set `mouse_filter = ignore`.
- Far NPC sprite click moves Player toward NPC before dialog opens.
- Dialog opens in talk range after an NPC sprite click.
- Dialog pages advance with Next.
- Close appears on the final page and hides dialog.
- Dialog blocks movement.
- Camera follows Player with RO-style offset.
- Field Gateway transitions directly to Field without physics-callback removal errors.
- Godot MCP current-scene play reports no errors.

## Related

- `prototype/game-systems.md`
- `prototype/components/town.md`
- `scripts/controllers/town_scene_controller.gd`
- `scripts/views/town_dialog_view.gd`
- `scripts/controllers/npc_controller.gd`
- `scenes/npc.tscn`
- `llm-wiki/architecture/quest-system.md`
