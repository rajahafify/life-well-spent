# Prototype Game Systems

Append this file whenever a new game system is introduced or materially changed.

## System Format

Each system should list:

- Core idea
- Verbs
- Components
- Resources
- Rules
- Conditions

---

## 1. Town System

**Core idea:** safe rebirth base; quiet old world waiting to be rebuilt.

### Verbs

- Spawn
- Move
- Talk
- Leave

### Components

- Town scene
- Player
- Camera
- Shop building
- Swordsman Guild building
- Blacksmith building
- Field Gateway
- UI layer

### Resources

- screen space
- world positions
- gateway target path

### Rules

- Town has no combat.
- Town starts with rebirth prompt.
- Town contains 3 old institutions.
- Town exits through Field Gateway.
- Ground clicks move player.
- UI/dialog can block movement.

### Conditions

- On scene start: show rebirth prompt.
- On Field Gateway enter: transfer to Field.

---

## 2. Gateway System

**Core idea:** controls movement between maps/areas, including locked routes.

### Verbs

- Enter
- Exit
- Block
- Unlock
- Transfer

### Components

- Gateway
- source map
- target map
- target spawn
- prompt text if needed
- lock state
- unlock condition
- optional blocker NPC/dialog

### Resources

- `gateway_id`
- `source_map`
- `target_map`
- `target_spawn_id`
- `is_locked`
- `unlock_conditions`
- `requested_scene_path`

### Rules

- Gateway can be open or locked.
- Open gateway transfers map immediately.
- Locked gateway blocks transfer.
- Locked gateway may show dialog or hint.
- Gateway can be portal, gate, road, cave entrance, or forest path.

### Conditions

- If player enters open gateway: transfer to target map/spawn.
- If player enters locked gateway: show blocked response.
- If unlock conditions are met: gateway becomes open.

### Prototype Examples

- Town → Field: open.
- Field → Town: open.
- Field → Forest: locked by Swordsman Guild certification.

---

## 3. NPC System

**Core idea:** non-enemy characters are stable identities placed on maps.

### Verbs

- Stand
- Face
- Approach
- Talk
- Offer
- Block
- Relocate
- Idle

### Components

- NPC definition
- NPC instance
- `NpcController`
- `NpcState`
- `CharacterMovement`
- CharacterID
- map/location
- sprite
- dialog set
- interaction radius
- optional gateway blocker role

### Resources

- `character_id`
- `display_name`
- `role`
- `map_id`
- `position: Vector2`
- `facing`
- `dialog_id`
- `sprite_id`
- `talk_radius`
- `solid_radius`
- `talk_stop_buffer`

### Rules

- NPC identity is stable across maps/runs.
- NPC placement is map + x/y.
- NPC dialogs depend on game state.
- NPC can block gateway if assigned to gateway.
- Far NPC click moves player to talk point.
- Dialog opens only inside talk range.
- NPC faces player when talked to.
- Player faces NPC when dialog opens.
- Overhead name labels hidden by default.
- NPC name appears in dialog.

### Conditions

- If player clicks NPC outside talk range: player approaches.
- If player reaches talk range: dialog opens.
- If player clicks NPC inside talk range: dialog opens immediately.
- If NPC has blocker role and gateway locked: show blocker dialog.

### Prototype Characters

- `guildmaster` in Town.
- `shopkeeper` in Town.
- `smith` in Town.
- `forest_guard` in Field.

---

## 4. Dialog System

**Core idea:** state-driven conversation UI for NPC/world text, readable at 1080p.

### Verbs

- Show
- Page
- Advance
- Choose
- Close
- Trigger
- Present

### Components

- Dialog definition
- `TownDialogView` / shared dialog view
- speaker
- pages
- portrait texture rect
- choices/buttons
- conditions
- effects

### Resources

- `dialog_id`
- `speaker_character_id`
- `pages`
- `portrait_texture`
- `choices`
- `conditions`
- `effects`
- current page index
- button visibility

### Rules

- Dialog text splits into pages on blank lines.
- `Next` advances pages.
- `Next` hides on final page.
- `Close` appears only on the final page and hides dialog.
- Dialog action buttons stay at the bottom-right of the dialog panel.
- Dialog blocks player movement.
- Text must be readable at 1080p.
- Portrait appears above dialog box.
- Portrait uses face crop from character LPC spritesheet.
- Choices can trigger effects.

### Conditions

- On dialog open: page index = 0.
- If more pages exist: show Next.
- If more pages exist: hide Close.
- If final page: hide Next and show Close.
- If choice selected: run effect.
- If Close pressed on the final page: hide dialog and portrait.

---

## 5. Movement / Camera System

**Core idea:** RO-style click movement with camera following player.

### Verbs

- Click
- Move
- Stop
- Follow
- Face

### Components

- `CharacterMovement`
- Player `CharacterBody2D`
- Destination
- `Camera2D`
- scene controller input routing

### Resources

- destination
- move speed
- player position
- camera offset
- can_move flag

### Rules

- Clicking ground moves player.
- World primitive Controls ignore mouse input.
- Dialog blocks movement.
- Camera follows player with upward offset.
- Movement stops at destination or collision.
- Facing direction comes from movement vector.

### Conditions

- If dialog closed and ground clicked: move to target.
- If dialog open and ground clicked: ignore.
- Each physics tick: camera position = player position + offset.

---

## 6. Animation System

**Core idea:** LPC sprites animate as calm RO-style standing/walking characters.

### Verbs

- Idle
- Walk
- Tick
- Face
- Desync

### Components

- `AnimationController`
- `CharacterMovement`
- LPC spritesheet
- frame coordinates
- idle cycle interval
- walk frame duration

### Resources

- animation state
- direction
- idle frame
- walk frame
- frame timer
- per-character idle timing

### Rules

- Idle uses calm walk-row standing frames, not spellcast/prayer rows.
- Walking uses LPC walk rows.
- NPCs can have different idle cycle intervals.
- Direction is preserved across idle/walk.
- Sprite frame coords update from model state.

### Conditions

- If state idle and timer passes interval: advance idle frame.
- If state walking and timer passes walk duration: advance walk frame.
- If direction changes: update frame row.

---

## 7. Combat System

**Core idea:** real combat model for Field encounters.

### Verbs

- Engage
- Attack
- Defend
- Take Damage
- Defeat
- Reward

### Components

- `CombatSystem`
- player combat stats
- enemy combat stats
- damage calculation
- defeat result
- reward hook

### Resources

- player Life
- player Max Life
- enemy HP
- player attack
- enemy attack
- defense
- XP reward

### Rules

- Combat damage reduces current Life.
- Quests/progression reduce Max Life, making future combat harder.
- Current Life cannot exceed Max Life.
- Player can damage enemies.
- Enemies can damage player Life.
- Enemy defeat grants reward/XP hook.
- Healing can restore current Life up to Max Life only.

### Conditions

- If player attacks: enemy HP decreases.
- If enemy attacks: current Life decreases.
- If enemy HP <= 0: enemy defeated and reward hook fires.
- If Life <= 0: player defeat / Game Over flow TBD.

---

## 8. Enemy System

**Core idea:** defines enemies as map actors with identity, stats, visuals, and rewards.

### Verbs

- Spawn
- Idle
- Engage
- Attack
- Take Damage
- Die
- Reward

### Components

- Enemy definition
- Enemy instance
- sprite/visual
- collision/hitbox
- combat stats
- reward table

### Resources

- `enemy_id`
- `display_name`
- `hp`
- `attack`
- `defense`
- `xp_reward`
- `spawn_position`
- `biome_tags`

### Rules

- Enemies belong to a map/location.
- Enemies can be passive/hostile later.
- Defeated enemies grant rewards.
- Prototype enemy set is Slime, Bat, Rat.
- Prototype monster art uses cataloged enemy sprite assets.

### Conditions

- If enemy HP <= 0: enemy defeated.
- If defeated: grant reward and notify respawn system.

---

## 9. Random Enemy Respawn System

**Core idea:** keeps Field populated over time.

### Verbs

- Spawn
- Despawn
- Respawn
- Roll
- Limit

### Components

- spawn zone
- enemy pool
- spawn timer
- max active count
- biome filter

### Resources

- `spawn_zone_id`
- `enemy_pool`
- `respawn_interval`
- `max_active`
- `active_count`
- `biome_type`

### Rules

- Spawn zones roll enemies from pool.
- Active enemies cannot exceed max.
- Dead enemies can respawn after delay.
- Enemy pool can depend on biome.

### Conditions

- If active_count < max_active and timer elapsed: spawn enemy.
- If enemy defeated: schedule respawn.
- If player leaves map: pause or clear respawn TBD.

---

## 10. Biome System

**Core idea:** map regions define visual style, enemy pools, props, and environmental rules.

### Verbs

- Define
- Tint
- Filter
- Spawn
- Signal

### Components

- biome definition
- color palette
- enemy pool
- prop set
- ambient rules
- map region

### Resources

- `biome_type`
- `palette`
- `enemy_pool`
- `prop_pool`
- `music_id`
- `ambient_tags`

### Rules

- Each map/region has biome type.
- Biome influences enemy spawn pool.
- Biome influences props/colors.
- Biome can influence music/ambience later.

### Conditions

- If map loads: apply biome palette/props.
- If spawn system rolls enemy: filter by biome enemy pool.
- If player enters biome region: update ambience/UI TBD.

### Prototype Biomes

- Town: warm/safe.
- Field: grassland/beginner.
- Forest: dark/locked/danger.

---

## 11. Prototype Visual System

**Core idea:** readable prototype art with primitives/SVG world and LPC characters.

### Verbs

- Show
- Signal
- Differentiate
- Read

### Components

- primitive `ColorRect`s
- simple paths/buildings
- generated LPC NPC sprites
- SVG/primitive monsters
- 1920×1080 viewport
- dark/padded UI panels

### Resources

- color palette
- sprite textures
- visual scale
- UI spacing

### Rules

- World uses primitives/SVG, not detailed tiles.
- Characters use generated LPC sprites.
- Field monsters use SVG/primitive visuals.
- NPCs scale to match player.
- Warm colors communicate Town safety.
- Field colors communicate grassland/beginner zone.
- Forest colors communicate danger/lock.
- Dialog uses padding and large text.

### Conditions

- If object is world primitive Control: mouse filter ignore.
- If NPC is in Town/Field: use unique generated sprite where available.
- If UI is dialog: use padded dark panel.
