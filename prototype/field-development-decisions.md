# Field Development Decisions

Date: 2026-05-11

## Confirmed Decisions

### Field Scope

Field should include **real combat** through a `CombatSystem`.

Field first implementation is not just placeholders. It should support:

- Player entering Field from Town.
- Player moving with RO-style click movement.
- Enemies existing in Field.
- Player fighting Field enemies through a real `CombatSystem`.
- Forest Guard blocking Forest path.
- Return path to Town.

### Gateway Behavior

Gateway transitions should be direct.

- Do not ask for confirmation.
- Player moves into portal/gateway.
- Scene changes immediately.

This replaces earlier prompt-only Town portal behavior.

### Development Approach

Use **model-first minimal systems**, then scene/controller wiring.

Order:

1. Document systems.
2. Write RED specs for pure model/system behavior.
3. Implement minimal models.
4. Write RED scene/controller specs.
5. Implement Field scene and gateway wiring.

Initial model/system set:

- `GatewayDefinition`
- `NpcPlacement`
- `BiomeDefinition`
- `EnemyLibrary`
- `EnemyDefinition`
- `EnemyState`
- `EnemyBehaviorSystem`
- `EnemyRandomSequence`
- `DropSystem`
- `CombatSystem`
- `RandomEnemyRespawnSystem`

Current controller split:

- `Field` remains scene glue for movement, gateways, HUD, dialog, inventory use, and helper delegation.
- `FieldCameraController` owns camera follow/shake.
- `FieldEnemySpawnController` owns spawn registration and polling.
- `FieldCombatController` owns combat tick orchestration.

### Naming

Use **Field**, not Starter Area.

- Display name: `Field`
- Scene path: `res://scenes/field.tscn`
- Controller path: `res://scripts/controllers/field.gd`
- Controller class: `Field`

Town portal should eventually point to `res://scenes/field.tscn` and use Field terminology.

### Art / Sprites

- Forest Guard gets a generated LPC sprite.
- Monsters use SVG/primitive art.

Monster prototype visuals:

- Slime: enemy catalog sprite `slime_spiked`.
- Bat: enemy catalog sprite `bat`.
- Rat: enemy catalog sprite `rat`.

## Field Systems To Build

### Gateway System

Handles entry/exit and locked routes.

Examples:

- Town → Field.
- Field → Town.
- Field → Forest locked by certification.

### Combat System

Real combat model for Field.

Responsibilities:

- player attack
- enemy attack
- damage calculation
- current Life damage
- Max Life pressure from quest progression
- enemy HP changes
- enemy defeat
- XP reward hook

### Enemy System

Defines enemy identity and stats.

Prototype enemies:

- Slime (`slime_spiked`)
- Bat (`bat`)
- Rat (`rat`)

### Random Enemy Respawn System

Keeps Field populated.

Responsibilities:

- spawn zones
- enemy pool
- max active enemies
- respawn interval
- biome-based filtering

### NPC System

Defines stable NPC identity and location.

Forest Guard uses:

- `character_id`
- `map_id`
- `position`
- `dialog_id`
- `sprite_id`

### Dialog System

Reused from Town.

Forest Guard dialog should be paged, portrait-capable, and movement-blocking.

### Biome System

Field uses grassland biome.

Biome affects:

- color palette
- prop palette
- enemy pool
- future ambience/music

## Non-Decisions / Still Open

- Exact combat input style.
- Combat timing: turn-based, click-to-attack, or contact/auto-attack.
- Player Life/Max Life starting values for Field tuning.
- Enemy HP/attack/XP values.
- Whether Field enemy respawn runs live while player remains in map or only when re-entering.
