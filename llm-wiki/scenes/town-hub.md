---
title: Town Scene
type: reference
updated: 2026-05-11
tags: [scenes, town, prototype]
---

# Town Scene

## Overview

`scenes/town_scene.tscn` is the first-slice **Town** scene for the prototype. It replaces the previous MVP town-hub task/quest UI with a systemic prototype slice: hopeful post-Demon-King worldbuilding, three old institutions, simple NPC dialog, and a glowing portal to Starter Area.

First-slice goal:

1. Player is reborn in Town.
2. Player sees Shop, Swordsman Guild, Blacksmith, and Starter Area Portal.
3. Player talks to Guildmaster, Shopkeeper, and Smith.
4. Player exits through the portal toward Starter Area.

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
├── Player (instance: player.tscn)
├── Shopkeeper (NpcController)
├── Guildmaster (NpcController)
├── Smith (NpcController)
├── StarterAreaPortal (Area2D)
│   ├── CollisionShape2D
│   ├── Visual (ColorRect)
│   └── Label — "Starter Area"
├── Camera2D
└── UI (CanvasLayer)
    ├── RebornPrompt — "You have been reborn.\nWill you spend this life well?"
    ├── PortalPrompt — "Enter Starter Area?"
    ├── PortalChoices
    │   ├── YesButton
    │   └── NoButton
    └── DialogPanel (TownDialogView)
```

## NPC Dialog

### Guildmaster

Reveals old institutions / rebuilding hope.

```text
The Swordsman Guild still stands.

Not as it was.
The halls are quiet, and the old names fade from the register.

But a guild is not stone or banners.
It lives when someone chooses the path.

Perhaps one day, someone will help me raise it again.
```

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

- sets reborn prompt and portal prompt copy in `_ready()`
- connects worldbuilding NPC `interacted(npc)` signals
- routes ground clicks to `CharacterMovement` while dialog is closed
- follows player with a camera offset for RO-style play
- blocks click-to-move while dialog is open
- handles RO-style NPC approach: far click moves to NPC talk point, near/in-range opens dialog
- shows paged NPC dialog via `TownDialogView.show_dialog()`
- records Starter Area transition request through portal Yes / `request_starter_area()`
- shows portal prompt and Yes/No choices when the Player enters `StarterAreaPortal`
- hides portal prompt when No is pressed
- hides NPC dialog when `TownDialogView.close_requested` emits

No quest, shop, forge, or life-spend logic is active in this slice.

## Art Direction

Prototype Town uses primitives/SVG only, except generated character sprites. Project viewport is 1920×1080 for prototype readability. World primitive `Control` nodes set `mouse_filter = ignore` so ground clicks reach Town movement.

- warm tan ground
- brown path strips
- rectangle buildings
- central Swordsman Guild landmark
- blue/green glowing portal
- parchment/dark dialog panel

## Tests

- `tests/specs/town_prototype_test.gd` covers root/class naming, buildings, NPCs, dialog copy, reborn prompt, portal prompt, 1080p viewport, and primitive mouse filter settings.
- `tests/specs/town_scene_dialog_test.gd` covers paged NPC dialog, RO-style far-click NPC approach, pending dialog open in talk range, camera follow, first-slice quest buttons hidden, click-to-move routing/blocking, dialog close behavior, portal prompt visibility, and Starter Area target request.
- `tests/specs/scene_smoke_test.gd` covers Town dialog smoke behavior.

Current validation after Town rewrite: `168 tests, 168 passed, 0 failed`.

## Manual QA

Passed on 2026-05-11:

- Town opens with reborn prompt.
- Ground click-to-move works after world primitives set `mouse_filter = ignore`.
- Far NPC click moves Player toward NPC before dialog opens.
- Dialog opens in talk range.
- Dialog pages advance with Next.
- Close hides dialog.
- Dialog blocks movement.
- Camera follows Player with RO-style offset.
- Starter Area Portal shows Yes/No prompt.
- No hides portal prompt.
- Godot MCP current-scene play reports no errors.

## Related

- `prototype/components/town.md`
- `scripts/controllers/town_scene_controller.gd`
- `scripts/views/town_dialog_view.gd`
- `scripts/controllers/npc_controller.gd`
- `scenes/npc.tscn`
