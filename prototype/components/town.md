# Town

## Core Idea

Town is safe base and first scene. The Demon King is dead, heroes won long ago, and the old starting town has grown quiet. Guilds, shops, and roads are not dead — only waiting.

Player begins here after rebirth. First Town slice is about mood, orientation, and worldbuilding: talk to three NPCs, understand the old world, then enter the glowing gateway to Field.

## Start Dialog

Town opens a dialog box with:

```text
You have been reborn.
Will you spend this life well?
```

## Tone

Hopeful nostalgia.

- The great story ended.
- People rested.
- Old roads grew quiet.
- Old institutions faded.
- Player arrives to care for what remains.

Key feeling:

```text
The great story ended.
Now someone must care for what remains.
```

## Purpose

- Spawn player.
- Introduce post-hero world.
- Show old Town institutions: Shop, Swordsman Guild, Blacksmith.
- Let player talk to simple worldbuilding NPCs.
- Provide glowing gateway to Field.

Future purpose, not first slice:

- React to Forest Guard state.
- Convert Guard encounter into Swordsman Guild quest chain.
- Frame Life sacrifice as restoration, not punishment.

## Naming Decision

- Scene file stays `scenes/town_scene.tscn` for now.
- Root node should be `Town`.
- Controller script stays `scripts/controllers/town_scene_controller.gd` for now.
- Controller class should become `class_name Town`.
- No `TownModel` yet. Town-specific pure rules live in `RunState`, inventory, combat, and quest-chain models.

## Layout

```text
┌──────────────────────────────────────────────┐
│                                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐ │
│  │  SHOP    │   │SWORDSMAN │   │BLACKSMITH│ │
│  │          │   │  GUILD   │   │          │ │
│  └────┬─────┘   └────┬─────┘   └────┬─────┘ │
│       │              │              │       │
│ [Shopkeeper]   [Guildmaster]      [Smith]   │
│                                              │
│                                              │
│                                              │
│                 [Player Spawn]               │
│                                              │
│                            [Glowing Gateway] │
│                             Field            │
└──────────────────────────────────────────────┘
```

## Functional Zones

### Top Row — Old Institutions

Three buildings define the Town:

- Shop
- Swordsman Guild
- Blacksmith

Swordsman Guild sits center and should be most visually important.

### Lower Center — Player Spawn

Player starts lower center, facing Town. From spawn, player can see the old institutions and the portal.

### Lower Right / Right Edge — Field Gateway

The Town exit is a glowing RO-style gateway. Entering it transitions directly to Field.

- Player body entering the gateway records/requests Field transition target.
- No confirmation prompt appears.

## Buildings and NPCs

All Town NPCs are simple dialog-only in first Town slice. No quest, shop, or forge mechanics yet.

Each NPC reveals a different aspect of the world.

### Swordsman Guild

NPC: **Guildmaster**

- Male.
- Old.
- Knightly.
- Patient.
- Quietly hopeful.
- Wants someone to help rebuild the Swordsman Guild.

World aspect: old institutions / rebuilding hope.

Dialog:

```text
The Swordsman Guild still stands.

Not as it was.
The halls are quiet, and the old names fade from the register.

But a guild is not stone or banners.
It lives when someone chooses the path.

Perhaps one day, someone will help me raise it again.
```

### Shop

NPC: **Shopkeeper**

- Female.
- Young.
- Pretty.
- Cheerful.
- Practical.
- Hopeful.

World aspect: ordinary life worth protecting.

Dialog:

```text
Welcome, traveler.

This shop once packed bags for heroes.
Now I sell apples, candles, and thread.

It is quieter, yes.
But quiet days are worth protecting too.
```

### Blacksmith

NPC: **Smith**

- Male.
- Middle-aged.
- Tough.
- Practical.
- Nostalgic, but not sentimental in public.

World aspect: old tools waiting / practical nostalgia.

Dialog:

```text
I used to shape steel for adventurers.

Now I mend plows, hinges, and cooking pots.
Honest work.

Still, I keep the sword molds clean.
Old roads have a way of calling again.
```

## Objects

- Player
- Camera
- Shared HUD
- Player aging sprites: `assets/player_age_1.png`, `assets/player_age_2.png`, `assets/player_age_3.png`
- Start/reborn dialog
- Dialog Panel
- Shop building
- Shopkeeper NPC with generated LPC sprite: `assets/npcs/shopkeeper.png`
- Swordsman Guild building
- Guildmaster NPC with generated LPC sprite: `assets/npcs/guildmaster.png`
- Blacksmith building
- Smith NPC with generated LPC sprite: `assets/npcs/smith.png`
- Glowing Field Gateway
- Swordsman Guild sign/emblem
- Primitive paths

## Devices

- NPC interaction zones for Guildmaster, Shopkeeper, and Smith.
- Field Gateway interaction zone.
- Gateway body-enter triggers direct Field transition.
- Dialog Next button advances paged dialog.
- Dialog close button hides dialog.

## Town State Read/Write

Current Town reads:

- current scene/run start state.
- `QuestSystem.current_main_objective_id()`.

Current Town writes:

- requested transition to Field.

Future Town reads:

- `swordsman_chain_step`
- `life`
- `swordsman_guild_unlocked`
- `game_over_requested`

Future Town writes:

- Swordsman quest completion requests.
- Game Over request after final quest step.

## Verbs

- Move
- Talk
- Leave

Future verbs:

- Accept
- Complete
- Spend Life
- Age
- Return
- Reborn

## Resources Shown

First Town slice may show:

- Life / Max Life
- XP
- Weapon slot
- Armor slot
- Consumable count

Town must show the start/reborn copy through the dialog panel.

## Rules

- Town is safe.
- No enemies in Town.
- Player can talk to Guildmaster, Shopkeeper, and Smith.
- NPCs are dialog-only in first slice.
- Player can leave Town via Field Gateway.
- Shop and Blacksmith services are not available yet.
- Guildmaster reacts when QuestSystem says the main objective is `Get Swordsman Certification`.
- Guildmaster certification uses quest completion: each complete press spends Max Life and advances the `Rebuilding Swordsman Guild` side-chain step.
- Guildmaster certification refreshes the player sprite after Max Life changes.

Future rules:

- Swordsman Guild quest completion is locked until the `Rebuilding Swordsman Guild` side quest chain is active.
- Guildmaster offers the chain after Field advances `Explore the World` to `Get Swordsman Certification`.
- Each guild quest step costs 40 Life / remaining Life.
- Step 3 triggers Swordsman Guild unlock and Game Over.

## Conditions

First Town slice:

- On first scene start for the current runtime: show reborn copy in a dialog box.
- On later Town entries: do not replay the reborn copy.
- On ground click while dialog is closed: route Player movement to `CharacterMovement`.
- While left mouse is held and dialog is closed: keep updating Player movement destination to the mouse position.
- While the pointer is over HUD controls: do not route mouse input to Player movement.
- Camera follows Player with RO-style upward offset.
- On ground click while dialog is open: block movement.
- On far NPC click: Player walks toward NPC talk point, dialog remains closed.
- On pending NPC reaching talk range: Player stops, faces NPC, NPC faces Player, paged dialog opens.
- On near Guildmaster interact: show Guildmaster worldbuilding dialog.
- On near Shopkeeper interact: show Shopkeeper worldbuilding dialog.
- On near Smith interact: show Smith worldbuilding dialog.
- On Field Gateway body entered by Player: record `res://scenes/field.tscn` and transition directly.

Future conditions:

- If main objective is `Find the Forest path`: Guildmaster shows worldbuilding dialog.
- If main objective is `Get Swordsman Certification` and `swordsman_chain_step = 0`: Guildmaster offers certification step 1.
- If `swordsman_chain_step = 1`: Guildmaster offers step 2.
- If `swordsman_chain_step = 2`: Guildmaster offers step 3.
- If `swordsman_chain_step = 3`: Swordsman Guild is unlocked, Game Over requested.
- If Max Life is `100`: Player uses `player_age_1.png`.
- If Max Life is `60`: Player uses `player_age_2.png`.
- If Max Life is `20` or lower: Player uses `player_age_3.png`.

## Permissions

Player can:

- move by clicking ground if no dialog/game over open
- talk to Guildmaster, Shopkeeper, Smith
- leave to Field through glowing gateway

Player cannot:

- fight in Town
- enter Forest from Town
- heal Life
- use Shop inventory in first slice
- use Blacksmith services in first slice
- complete Swordsman Guild quest steps before the Forest Guard checkpoint

## Primitive / SVG Art Direction

Town uses primitive/SVG world art plus generated LPC character sprites for Player and NPCs.

- Ground: warm tan `ColorRect`/primitive plane.
- Path: brown strips from spawn to buildings and portal.
- Buildings: simple rectangles with triangle roofs.
- Guild: largest/center building with sword/guild emblem SVG.
- Shop: warm storefront, apple/sign SVG optional.
- Blacksmith: darker building, anvil/hammer SVG optional.
- Portal: glowing blue/green ring with `Field` label.
- Interactable NPC zones: faint yellow rings.
- HUD/dialog: dark translucent or parchment-like rectangles.
- Dialog text uses 1080p-readable sizes: name 28, body 30, buttons 24.
- Dialog buttons stay at the bottom-right of the dialog panel.
- NPC overhead name labels are hidden by default; names appear in dialog only.
- Dialog shows NPC face portrait above the dialog box using an AtlasTexture face crop from the NPC LPC spritesheet.
- Dialog pages split on blank lines and advance with `Next`.
- Character idle uses calm walk-row standing frames instead of LPC spellcast/prayer rows.
- Player visual aging uses normal hair, grey hair/beard, and white hair/beard LPC sprites as Max Life is spent.
- Town NPC idle cycles use different intervals for subtle desync.
- World primitive `Control` nodes use `mouse_filter = ignore` so ground clicks reach Town movement.
- Project viewport: 1920×1080.

Color language:

- Town = warm tan / brown / soft orange.
- Interactable = yellow.
- Portal = blue/green glow.
- Life = crimson.
- XP = gold.

## First Slice Non-Goals

- No Swordsman Guild quest completion mechanics.
- No standalone Forest Guard return flag; QuestSystem main objective owns that progression.
- No shop inventory.
- No blacksmith services.
- No save-slot UI.
- No interiors.
- No combat in Town.

## Deliverables

### Documentation

- `prototype/components/town.md` is the Town source of truth.
- Town naming decision is documented here.
- Town first-slice scope and non-goals are documented here.

### Spec

- `tests/specs/town_prototype_test.gd` defines RED acceptance specs before implementation.
- Specs cover root naming, controller class naming, buildings, NPCs, dialog copy, reborn start dialog, and portal.

### Scene

- `scenes/town_scene.tscn` remains the scene file.
- Root node should be named `Town`.
- Scene should contain Player, Camera, UI, three buildings, three NPCs, and Field Gateway.

### Script

- `scripts/controllers/town_scene_controller.gd` remains the controller file.
- Script should expose `class_name Town`.
- No `TownModel` yet.

### First-Slice Acceptance

Player can:

1. Spawn in Town.
2. Read reborn start dialog.
3. See Shop, Swordsman Guild, Blacksmith, and glowing Field Gateway.
4. Talk to Guildmaster, Shopkeeper, and Smith.
5. Use gateway to request Field transition.

## First Slice

1. Start in Town.
2. Show reborn start dialog.
3. Click ground to move around Town; camera follows Player.
4. See Shop, Swordsman Guild, Blacksmith, and glowing Field Gateway in 1080p viewport.
5. Click an NPC from far away; Player approaches before dialog opens.
6. Talk to Guildmaster for paged rebuilding hope dialog.
7. Talk to Shopkeeper for paged ordinary-life dialog.
8. Talk to Smith for paged old-tools dialog.
9. Use `Next` to advance dialog pages; `Close` appears only on the last dialog page.
10. Walk into glowing Field gateway.
11. Gateway records Field target and transitions directly.

## Tests

- [ ] Town scene loads.
- [ ] Town scene root is named `Town`.
- [ ] Town script class is `Town`.
- [ ] Player spawns lower center.
- [ ] Shop, Swordsman Guild, and Blacksmith buildings exist.
- [ ] Shopkeeper, Guildmaster, and Smith NPCs exist.
- [ ] Field Gateway exists.
- [ ] Reborn start dialog displays on scene start.
- [ ] Guildmaster dialog matches first-slice worldbuilding text.
- [ ] Shopkeeper dialog matches first-slice worldbuilding text.
- [ ] Smith dialog matches first-slice worldbuilding text.
- [ ] Player entering Field Gateway requests Field target path directly.
- [ ] Confirmation prompt/choices are absent.
- [ ] Dialog close signal hides dialog.
- [ ] Dialog Next button advances pages.
- [ ] Dialog text is readable at 1080p.
- [ ] NPC overhead name labels are hidden.
- [ ] Dialog shows NPC face portrait cropped from the NPC spritesheet above the dialog box.
- [ ] Character idle does not use prayer/spellcast frames.
- [ ] Town NPC idle animation timing differs per NPC.
- [ ] Click-to-move works while dialog closed.
- [ ] Dialog blocks click-to-move.
- [ ] Far NPC click moves Player toward NPC without opening dialog immediately.
- [ ] Pending NPC dialog opens when Player reaches talk range.
- [ ] Camera follows Player with RO-style offset.
- [ ] Project viewport is 1920×1080.
- [ ] World primitives ignore mouse input so ground click-to-move works.
- [ ] Guildmaster, Shopkeeper, and Smith use distinct generated LPC sprites.
- [ ] Guildmaster, Shopkeeper, and Smith scale to `Vector2(2, 2)` to match player size.
- [x] Player starts with age stage 1 sprite.
- [x] Certification Max Life spend updates the player aging sprite.
