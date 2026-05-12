# Next Agent Instructions — Prototype / Field

## Mission

Build the next prototype slice: **Field**.

Field replaces the old term `Starter Area`.

Goal: player exits Town through the portal, enters Field, can move around, can fight basic enemies through real combat, can see Forest Gate blocked by Guard, and can return to Town.

## Must Read First

Read these files before coding:

1. `AGENTS.md` — project architecture, MVC, TDD, wiki rules.
2. `prototype/components/Field.md` — Field source of truth.
3. `prototype/field-development-decisions.md` — confirmed decisions.
4. `prototype/game-systems.md` — systemic design terms and current systems.
5. `prototype/components/town.md` — current Town slice and reusable patterns.
6. `llm-wiki/scenes/town-hub.md` — current implemented Town details.

## Key Decisions Already Made

### Terminology

Use **Field**, not Starter Area.

- Scene path: `res://scenes/field.tscn`
- Controller path: `res://scripts/controllers/field.gd`
- Controller class: `class_name Field`
- Root node: `Field`

Update Town portal text/target from Starter Area to Field when wiring transition.

### Gateway Behavior

Gateways transition directly.

- No confirmation prompt.
- Player enters gateway area.
- Scene changes immediately.

This replaces current Town portal prompt/Yes/No behavior.

### Field Scope

Field includes **real combat** through a `CombatSystem`.

Do not make Field just decorative placeholders.

Field should support:

- RO-style click movement.
- Camera follow.
- Enemies: Slime, Bat, Rat.
- Real combat model.
- Forest Guard blocks Forest.
- Return to Town gateway.

### Development Style

Model-first minimal systems, then scene/controller wiring.

Follow RED → GREEN → REFACTOR:

1. Write failing specs.
2. Run tests and confirm RED.
3. Implement minimal code.
4. Run full suite.
5. Update wiki/docs.

## Systems To Implement / Introduce

Use `prototype/game-systems.md` terminology.

### Gateway System

Handles entry/exit and locked routes.

Build minimal model first:

- `scripts/models/gateway_definition.gd`
- tests: `tests/specs/gateway_system_test.gd`

Expected fields:

- `gateway_id`
- `source_map`
- `target_map`
- `target_scene_path`
- `target_spawn_id`
- `is_locked`
- `unlock_conditions`
- `blocked_dialog_id`

Expected behavior:

- open gateway allows transfer target.
- locked gateway blocks transfer.
- unlock conditions can determine open/locked later.

Prototype gateways:

- `town_to_field`
- `field_to_town`
- `field_to_forest_locked`

### Enemy System

Defines enemy identity/stats.

Build:

- `scripts/models/enemy_definition.gd`
- tests: `tests/specs/enemy_system_test.gd`

Prototype enemies:

- Slime (`slime_spiked`)
- Bat (`bat`)
- Rat (`rat`)

Suggested initial stats (can tune later):

```text
Slime: hp 14, attack 1, defense 1, xp 5
Bat:   hp 8,  attack 2, defense 0, xp 4
Rat:   hp 6,  attack 2, defense 0, xp 3
```

### Combat System

Real combat model.

Build:

- `scripts/models/combat_system.gd`
- tests: `tests/specs/combat_system_test.gd`

Combat rules:

- Life is the combat health resource.
- Quests/progression reduce Max Life, making later combat harder.
- Current Life cannot exceed Max Life.
- Player attack damages enemy HP.
- Enemy attack damages current Life.
- Damage minimum should probably be 1.
- Enemy defeat grants XP hook/result.

Suggested model API:

```gdscript
func player_attack_enemy(player_stats: Dictionary, enemy_state: Dictionary) -> Dictionary
func enemy_attack_player(enemy_state: Dictionary, player_state: Dictionary) -> Dictionary
```

Or cleaner object API if you create `Combatant`/state dictionaries. Keep pure and testable.

### Random Enemy Respawn System

Keeps Field populated.

Build minimal model:

- `scripts/models/random_enemy_respawn_system.gd`
- tests: `tests/specs/random_enemy_respawn_test.gd`

Rules:

- spawn zone has enemy pool
- max active enemies
- respawn interval
- biome filter later

Keep it pure. Scene can instantiate placeholder nodes later.

### NPC System Extension

Field needs Forest Guard placement.

Build minimal placement model if useful:

- `scripts/models/npc_placement.gd`
- tests: `tests/specs/npc_placement_test.gd`

Fields:

- `character_id`
- `map_id`
- `position`
- `dialog_id`
- `sprite_id`

Forest Guard:

- `character_id = forest_guard`
- `map_id = field`
- blocks Forest Gateway

Forest Guard gets generated LPC sprite. Use `tools/lpc-sprite-gen` per workflow if not already generated.

### Dialog System Extension

Forest Guard uses existing `TownDialogView` for now unless renamed/shared later.

Guard dialog:

```text
Stop.

The Demon King is gone.
But old places do not become safe overnight.

The Forest remembers what we forgot.
Return to Town.
Earn certification from the Swordsman Guild.
```

Future effect:

- set `forest_gate_seen = true`
- unlock Swordsman Guild quest in Town

Do not implement Town quest unlock until Field gate flow is stable unless scoped.

### Biome System

Build minimal model:

- `scripts/models/biome_definition.gd`
- tests: `tests/specs/biome_system_test.gd`

Field biome:

- `biome_type = grassland`
- palette: bright green / dirt brown
- enemy_pool: Slime, Bat, Rat
- props: rocks, bushes, grass patches

## Scene Deliverables

Create:

- `scenes/field.tscn`
- `scripts/controllers/field.gd`

Field scene should contain:

- `Field` root
- `Player` instance
- `Camera2D`
- green primitive ground
- dirt paths
- Town Gateway/Portal
- Forest path
- Forest blocker
- Forest Guard NPC
- Slime/Bat/Rat enemy placeholders
- UI/DialogPanel compatible with existing dialog view
- objective prompt: `Objective: Find the Forest path.`

Field must reuse Town patterns:

- click-to-move
- camera follow
- far NPC click approach
- paged dialog
- dialog blocks movement
- world primitives `mouse_filter = ignore`

## Art Decisions

- Forest Guard: generated LPC sprite.
- Monsters: SVG/primitive, not LPC.

Monster placeholder art:

- Slime: catalog sprite `slime_spiked`.
- Bat: catalog sprite `bat`.
- Rat: catalog sprite `rat`.

No detailed tiles yet.

## Town Changes Needed

After Field exists:

- Change Town portal label from `Starter Area` to `Field`.
- Change Town target path to `res://scenes/field.tscn`.
- Remove confirmation prompt if implementing direct gateway behavior now.
- Add tests for direct scene transition/request behavior.

## Tests To Add First

Suggested RED specs:

1. `tests/specs/gateway_system_test.gd`
2. `tests/specs/enemy_system_test.gd`
3. `tests/specs/combat_system_test.gd`
4. `tests/specs/random_enemy_respawn_test.gd`
5. `tests/specs/npc_placement_test.gd`
6. `tests/specs/biome_system_test.gd`
7. `tests/specs/field_scene_test.gd`

Field scene spec should cover:

- Field scene loads.
- root named `Field`.
- script class `Field`.
- Player exists.
- Camera exists.
- Town Gateway exists.
- Forest Gateway/Blocker exists.
- Forest Guard exists.
- Slime/Bat/Rat placeholders exist.
- objective prompt exists.
- Forest Guard dialog text matches spec.
- world primitives ignore mouse.

## Manual QA Target

When done, manual QA should pass:

1. Play from Town.
2. Walk into Field portal.
3. Scene changes to Field.
4. Player can click-move in Field.
5. Camera follows player.
6. Slime/Bat/Rat visible.
7. Click Forest Guard from far: player approaches.
8. Guard dialog opens only in talk range.
9. Guard dialog pages work with Next/Close.
10. Forest path is blocked.
11. Walk into Town portal: returns to Town.
12. Godot output has no errors.

## Important Constraints

- No implementation without failing spec first.
- Models stay pure: no Node references, no scene tree calls.
- Controllers glue signals/scene to models.
- Views display and emit signals.
- Update `prototype/game-systems.md` if system rules change.
- Update `llm-wiki/log.md` and relevant wiki pages before commit.
- Run full suite before commit.
