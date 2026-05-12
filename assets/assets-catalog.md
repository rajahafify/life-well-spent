# Assets Catalog — EnemySystem Rebuild Tasks

## Goal

EnemySystem is being rebuilt from scratch. Field currently contains **no enemies**, no combat HUD, and no enemy click combat. Enemy assets are cataloged here so future work can integrate them cleanly.

## Current Enemy Assets

New enemy assets use per-animation PNG strips plus preview GIFs. Most animation strips appear to use 64×64 frames.

### Bat

- `assets/enemies/Bat/BatComplete.gif` — preview, 1024×640
- `assets/enemies/Bat/Bat_Fly.png` — 256×64, likely 4 frames
- `assets/enemies/Bat/Bat_Attack.png` — 256×128, likely 4×2 frames
- `assets/enemies/Bat/Bat_Hit.png` — 256×128, likely 4×2 frames
- `assets/enemies/Bat/Bat_Death.png` — 256×192, likely 4×3 frames
- FX: `Bat_Attack_FX.png`, `Bat_Death_FX.png`
- Full sheet: `Bat_Full.png` — 320×320

### Crab

- `assets/enemies/Crab/CrabComplete.gif` — preview, 1024×640
- `Crab_Idle.png` — 256×64
- `Crab_Run.png` — 256×128
- `Crab_Hit.png` — 192×64
- `Crab_Death.png` — 256×128
- Attacks: `Crab_AttackA.png`, `Crab_AttackB.png`, `Crab_AttackC.png`
- Ability: `Crab_Ability.png`
- FX: attack FX strips
- Full sheet: `Crab_Full.png` — 448×448

### Golem

- `assets/enemies/Golem/GolemComplete.gif` — preview
- Armored variant: `assets/enemies/Golem/Armored/*`
- No-armor variant: `assets/enemies/Golem/No Armor/*`
- Includes idle, run, hit, attack, death, reset, upgrade, armor break, and FX strips.

### Pebble

- `assets/enemies/Pebble/Pebble_Idle.png` — 256×64
- `Pebble_Run.png` — 256×128
- `Pebble_Hit.png` — 256×128
- `Pebble_Death.png` — 256×128
- Full sheet: `Pebble_Full.png` — 320×320

### Rat

- `assets/enemies/Rat/RatComplete.gif` — preview, 1024×640
- `Rat_Idle.png` — 256×64
- `Rat_Run.png` — 256×128
- `Rat_Hit.png` — 256×64
- `Rat_Attack.png` — 256×128
- `Rat_Ability.png` — 256×192
- `Rat_Death.png` — 256×128
- FX: attack/death FX strips
- Full sheet: `Rat_Full.png` — 384×384

### Skull

- `assets/enemies/Skull/Bones_SingleSkull_Idle.png`
- `Bones_SingleSkull_Fly.png`
- `Bones_SingleSkull_Hit.png`
- `Bones_SingleSkull_Death.png`
- `Bones_SingleSkull_Full.png`
- FX: full/death FX strips

### Slime

- `assets/enemies/Slime/SlimeComplete.gif` — preview, 64×64
- `Slime_Spiked_Idle.png` — 256×64
- `Slime_Spiked_Run.png` — 256×64
- `Slime_Spiked_Hit.png` — 256×64
- `Slime_Spiked_Jump.png` — 256×128
- `Slime_Spiked_Death.png` — 256×128
- `Slime_Spiked_Ability.png` — 256×64
- FX: ability/jump FX strips
- Full sheet: `Slime_Spiked_Full.png` — 384×320

## Viewers

- `assets/assets-viewer.tscn` opens a scrollable gallery of PNG enemy assets.
- `assets/assets_viewer.gd` scans `res://assets/enemies` recursively.
- `assets/asset-view.tscn` opens a focused single-preview animated enemy viewer.
- `assets/asset_view.gd` defines `AssetView`, loads selected enemy metadata, and swaps the single preview sprite from the selected enemy `*_sprite_frames.tres`.
- `assets/assets-gallery.tscn` opens a looping editor-visible SpriteFrames gallery with one saved `AnimatedSprite2D` node per V1 metadata enemy.
- `assets/asset_gallery.gd` defines `AssetGallery`, one root Control that initializes all gallery sprites and plays their idle loops.
- V1 metadata enemy IDs: `slime_spiked`, `rat`, `bat`, `crab`, `golem_armored`, `golem`, `pebble`, `skull`.
- Metadata files exist beside each imported enemy folder: `*.asset.json`.
- Godot-native `SpriteFrames` resources exist beside each metadata file: `*_sprite_frames.tres`; open `assets-gallery.tscn` and select the matching sprite node, such as `BatSprite`, to tweak FPS/loop in Godot's SpriteFrames editor.
- GIF previews are cataloged in this document but not shown in the gallery yet.

## Rebuild Tasks

### 1. Define EnemySystem acceptance criteria

- Decide combat style before writing code:
  - click-to-target + auto-attack?
  - turn-based encounter popup?
  - action cooldown in world?
- Define minimum Field enemy behavior.
- Define what feedback is required: HP bars, hit flash, damage numbers, death animation.

### 2. Write RED specs for new EnemySystem

Suggested specs:

- `tests/specs/enemy_asset_catalog_test.gd`
- `tests/specs/enemy_catalog_test.gd`
- `tests/specs/enemy_actor_test.gd`
- `tests/specs/enemy_encounter_test.gd`
- `tests/specs/field_enemy_spawn_test.gd`

### 3. Build pure models first

V1 started with `EnemySpriteCatalog` and `slime_spiked.asset.json`. Continue without gameplay scene nodes until metadata validation is stable.

Possible model boundaries:

- `EnemyAssetCatalog` — animation keys, texture paths, frame size, frame count.
- `EnemyCatalog` — enemy IDs, stats, art key, behavior tags.
- `EnemyCombatant` — runtime HP/status state.
- `EnemyEncounter` — attack/cooldown/range/defeat result.
- `EnemySpawnRule` — map spawn intent, not node instantiation.

### 4. Build view layer second

Only after model specs pass:

- reusable enemy scene
- `AnimatedSprite2D` or `Sprite2D` animation-strip player
- selection/highlight feedback
- HP bar/damage number view

### 5. Wire Field last

- Add enemies back to Field only after model + view specs pass.
- Start with one enemy type.
- Recommended first enemy: Slime (`Slime_Spiked_Idle/Run/Hit/Death`) because it is readable and small.
- Add only one spawn zone first.
- Keep Forest Guard and Town Gateway behavior untouched.

## Acceptance For Reintroduction

- Full test suite passes.
- Field scene loads with no Godot errors.
- Field has no hardcoded enemy stats in controller.
- Enemy art path is not hardcoded in combat logic.
- Player gets visible feedback for targeting, hit, damage, and defeat.
