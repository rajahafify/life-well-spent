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
- Starter Area Portal
- UI layer

### Resources

- screen space
- world positions
- portal target path

### Rules

- Town has no combat.
- Town starts with rebirth prompt.
- Town contains 3 old institutions.
- Town exits through Starter Area Portal.
- Ground clicks move player.
- UI/dialog can block movement.

### Conditions

- On scene start: show rebirth prompt.
- On portal enter: show portal choice.
- On Yes: record Starter Area target.
- On No: hide prompt.

---

## 2. NPC System

**Core idea:** RO-style NPCs are world actors: visible, clickable, talkable, facing player.

### Verbs

- Stand
- Face
- Approach
- Talk
- Idle

### Components

- `NpcController`
- `NpcState`
- `CharacterMovement`
- NPC sprite
- NPC collision
- NPC talk radius
- NPC metadata:
  - display name
  - role
  - dialog text

### Resources

- NPC position
- player position
- talk radius
- solid radius
- talk stop buffer
- facing direction
- dialog text

### Rules

- NPC does not open dialog from far away.
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

---

## 3. Dialog System

**Core idea:** conversation UI for NPC/world text, readable at 1080p.

### Verbs

- Show
- Page
- Advance
- Close
- Present

### Components

- `TownDialogView`
- Dialog panel
- Name label
- Body label
- Portrait texture rect
- Next button
- Close button
- Hidden quest buttons for future use

### Resources

- speaker name
- dialog pages
- current page index
- portrait texture
- button visibility

### Rules

- Dialog text splits into pages on blank lines.
- `Next` advances pages.
- `Next` hides on final page.
- `Close` hides dialog.
- Dialog blocks player movement.
- Text must be readable at 1080p.
- Portrait appears above dialog box.
- Portrait uses face crop from NPC LPC spritesheet.
- Quest buttons hidden in Town first slice.

### Conditions

- On dialog open: page index = 0.
- If more pages exist: show Next.
- If final page: hide Next.
- If Close pressed: hide dialog and portrait.

---

## 4. Movement / Camera System

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
- Town controller input routing

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

## 5. Animation System

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

## 6. Portal System

**Core idea:** glowing RO-style portal from Town to Starter Area.

### Verbs

- Enter
- Prompt
- Confirm
- Cancel
- Request

### Components

- StarterAreaPortal `Area2D`
- `CollisionShape2D`
- portal visual
- portal label
- PortalPrompt label
- Yes button
- No button

### Resources

- portal visibility state
- requested scene path
- Starter Area path

### Rules

- Portal does not instantly transition.
- Player entering portal shows prompt.
- `Yes` records Starter Area target.
- `No` hides prompt.
- Actual scene transition is future work.

### Conditions

- If Player enters portal area: show prompt + choices.
- If Yes pressed: `requested_scene_path = res://scenes/starter_area.tscn`.
- If No pressed: hide prompt + choices.

---

## 7. Prototype Visual System

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
- NPCs scale to match player.
- Warm colors communicate Town safety.
- Portal uses blue/green glow.
- Dialog uses padding and large text.

### Conditions

- If object is world primitive Control: mouse filter ignore.
- If NPC is in Town: use unique generated sprite.
- If UI is dialog: use padded dark panel.
