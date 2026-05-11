# Town

## Core Idea

Town is safe base and first scene. The Demon King is dead, heroes won long ago, and the old starting town has grown quiet. Guilds, shops, and roads are not dead — only waiting.

Player begins here after rebirth. First Town slice is about mood, orientation, and worldbuilding: talk to three NPCs, understand the old world, then enter the glowing portal to Starter Area.

## Start Prompt

Town opens with:

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
- Provide glowing portal to Starter Area.

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
│                            [Glowing Portal]  │
│                             Starter Area     │
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

### Lower Right / Right Edge — Starter Area Portal

The Town exit is a glowing RO-style portal, not a physical gate.

Portal prompt:

```text
Enter Starter Area?
[Yes] [No]
```

- Yes records/request Starter Area transition target.
- No hides the prompt.

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
- HUD or start prompt banner
- Dialog Panel
- Shop building
- Shopkeeper NPC with generated LPC sprite: `assets/npcs/shopkeeper.png`
- Swordsman Guild building
- Guildmaster NPC with generated LPC sprite: `assets/npcs/guildmaster.png`
- Blacksmith building
- Smith NPC with generated LPC sprite: `assets/npcs/smith.png`
- Glowing Starter Area Portal
- Swordsman Guild sign/emblem
- Primitive paths

## Devices

- NPC interaction zones for Guildmaster, Shopkeeper, and Smith.
- Starter Area Portal interaction zone.
- Portal body-enter trigger shows `Enter Starter Area?` prompt.
- Dialog Next button advances paged dialog.
- Dialog close button hides dialog.
- Portal Yes button records Starter Area target.
- Portal No button hides prompt.

## Town State Read/Write

First Town slice reads:

- current scene/run start state only.

First Town slice writes:

- requested transition to Starter Area.

Future Town reads:

- `forest_gate_seen`
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

- Life
- Combat HP
- XP
- Weapon slot
- Armor slot
- Consumable count

If HUD is deferred, Town must still show start prompt and NPC dialog.

## Rules

- Town is safe.
- No enemies in Town.
- Player can talk to Guildmaster, Shopkeeper, and Smith.
- NPCs are dialog-only in first slice.
- Player can leave Town via Starter Area Portal.
- Shop and Blacksmith services are not available yet.
- Swordsman Guild quest mechanics are not active in first Town slice.

Future rules:

- Swordsman Guild quest is locked until Forest Guard encounter.
- Guildmaster offers chain only when `forest_gate_seen = true`.
- Each guild quest step costs 40 Life / remaining Life.
- Step 3 triggers Swordsman Guild unlock and Game Over.

## Conditions

First Town slice:

- On scene start: show reborn prompt.
- On ground click while dialog is closed: route Player movement to `CharacterMovement`.
- Camera follows Player with RO-style upward offset.
- On ground click while dialog is open: block movement.
- On far NPC click: Player walks toward NPC talk point, dialog remains closed.
- On pending NPC reaching talk range: Player stops, faces NPC, NPC faces Player, paged dialog opens.
- On near Guildmaster interact: show Guildmaster worldbuilding dialog.
- On near Shopkeeper interact: show Shopkeeper worldbuilding dialog.
- On near Smith interact: show Smith worldbuilding dialog.
- On Portal body entered by Player: show prompt to enter Starter Area.
- On portal Yes: record `res://scenes/starter_area.tscn` as requested scene path and keep prompt visible.
- On portal No: prompt disappears without changing scene.

Future conditions:

- If `forest_gate_seen = false`: Guildmaster does not offer trial.
- If `forest_gate_seen = true` and `swordsman_chain_step = 0`: Guildmaster offers step 1.
- If `swordsman_chain_step = 1`: Guildmaster offers step 2.
- If `swordsman_chain_step = 2`: Guildmaster offers step 3.
- If `swordsman_chain_step = 3`: Swordsman Guild is unlocked, Game Over requested.

## Permissions

Player can:

- move by clicking ground if no dialog/game over open
- talk to Guildmaster, Shopkeeper, Smith
- leave to Starter Area through glowing portal

Player cannot:

- fight in Town
- enter Forest from Town
- heal Life
- use Shop inventory in first slice
- use Blacksmith services in first slice
- start Swordsman Guild quest in first slice

## Primitive / SVG Art Direction

Town uses primitive/SVG world art plus generated LPC character sprites for Player and NPCs.

- Ground: warm tan `ColorRect`/primitive plane.
- Path: brown strips from spawn to buildings and portal.
- Buildings: simple rectangles with triangle roofs.
- Guild: largest/center building with sword/guild emblem SVG.
- Shop: warm storefront, apple/sign SVG optional.
- Blacksmith: darker building, anvil/hammer SVG optional.
- Portal: glowing blue/green ring with `Starter Area` label.
- Interactable NPC zones: faint yellow rings.
- HUD/dialog: dark translucent or parchment-like rectangles.
- Dialog text uses 1080p-readable sizes: name 28, body 30, buttons 24.
- NPC overhead name labels are hidden by default; names appear in dialog only.
- Dialog shows NPC face portrait above the dialog box using an AtlasTexture face crop from the NPC LPC spritesheet.
- Dialog pages split on blank lines and advance with `Next`.
- Character idle uses calm walk-row standing frames instead of LPC spellcast/prayer rows.
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

- No Swordsman Guild quest mechanics.
- No Forest Guard return state.
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
- Specs cover root naming, controller class naming, buildings, NPCs, dialog copy, reborn prompt, and portal.

### Scene

- `scenes/town_scene.tscn` remains the scene file.
- Root node should be named `Town`.
- Scene should contain Player, Camera, UI, three buildings, three NPCs, and Starter Area Portal.

### Script

- `scripts/controllers/town_scene_controller.gd` remains the controller file.
- Script should expose `class_name Town`.
- No `TownModel` yet.

### First-Slice Acceptance

Player can:

1. Spawn in Town.
2. Read reborn prompt.
3. See Shop, Swordsman Guild, Blacksmith, and glowing Starter Area Portal.
4. Talk to Guildmaster, Shopkeeper, and Smith.
5. Use portal to request Starter Area transition.

## First Slice

1. Start in Town.
2. Show reborn prompt.
3. Click ground to move around Town; camera follows Player.
4. See Shop, Swordsman Guild, Blacksmith, and glowing Starter Area Portal in 1080p viewport.
5. Click an NPC from far away; Player approaches before dialog opens.
6. Talk to Guildmaster for paged rebuilding hope dialog.
7. Talk to Shopkeeper for paged ordinary-life dialog.
8. Talk to Smith for paged old-tools dialog.
9. Use `Next` to advance dialog pages; use `Close` to exit dialog.
10. Walk into glowing portal.
11. Portal prompt appears: `Enter Starter Area?` with Yes/No buttons.
12. Yes records Starter Area target; No hides prompt.

## Tests

- [ ] Town scene loads.
- [ ] Town scene root is named `Town`.
- [ ] Town script class is `Town`.
- [ ] Player spawns lower center.
- [ ] Shop, Swordsman Guild, and Blacksmith buildings exist.
- [ ] Shopkeeper, Guildmaster, and Smith NPCs exist.
- [ ] Starter Area Portal exists.
- [ ] Reborn prompt displays on scene start.
- [ ] Guildmaster dialog matches first-slice worldbuilding text.
- [ ] Shopkeeper dialog matches first-slice worldbuilding text.
- [ ] Smith dialog matches first-slice worldbuilding text.
- [ ] Portal prompts for Starter Area transition.
- [ ] Portal prompt starts hidden.
- [ ] Player entering portal shows prompt.
- [ ] Portal request records Starter Area target path.
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
