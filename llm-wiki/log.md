# Wiki Log

## [2026-05-14] fix | Gate quest claims to final dialog page

- RED: added TownDialogView and MainMenu specs for final-page-only claim actions and New Game auto-rebirth after an ended run.
- Dialog action buttons now appear only on the final page of a paged dialog, matching Close behavior.
- Main Menu New Game now auto-rebirths saved players with `game_over_requested`, resets run inventory, saves the profile, and preserves persistent unlocks such as Swordsman Guild.
- Documented prototype progression as playable end-to-end through Swordsman Guild unlock, Game Over summary, Rebirth or End Game, and certified Forest access.
- Validation: full suite `442 tests, 442 passed, 0 failed`.

## [2026-05-14] fix | Add Game Over run summary and leather armor color

- RED: added `RunSummaryModel`, Town dialog, and player aging asset specs for run summary output, Game Over buttons, inventory reset on Rebirth, and brown leather armor sprites.
- Added pure `RunSummaryModel` for Game Over summary text covering run items and unlocked facilities.
- Town final certification now shows a Game Over panel with run summary, Rebirth reset, and End Game routing to the main menu.
- Recolored sword+armor player sheets from generator-grey armor to brown leather armor while preserving the age and weapon layers.
- Validation: full suite `438 tests, 438 passed, 0 failed`.

## [2026-05-14] refactor | Systemize quest dialog flow

- RED: added `QuestDialogFlow` specs for normal, incomplete quest, complete quest, item reward, and unlock reward panels.
- Added pure `QuestDialogFlow` so future quest givers can reuse the same dialog structure instead of duplicating Guildmaster branching in controllers.
- Town now builds Guildmaster panels through the reusable flow and only keeps scene side effects such as reward grants, Life spend, profile save, and rebirth display.
- Validation: full suite `434 tests, 434 passed, 0 failed`.

## [2026-05-14] fix | Tighten progression QA blockers

- RED: added QuestManager, Town, Field, InventoryModel, InventoryWindowView, SharedHUD, EquipmentStats, and PlayerAging specs for immediate Guildmaster quest display, inventory-count Bat Wings, profile-backed Field aging, equipment actions, weapon visuals, equipment combat bonuses, and close-ready attack leash behavior.
- Town now refreshes Quest Window as soon as Guildmaster starts the chain and syncs the Bat Wing objective from current inventory.
- Field now reads ProfileSystem Max Life for Life/age state, and player auto-attack requires close range first before using a larger leash against moving enemies.
- Inventory starts with empty weapon, armor, consumable, and shortcut slots; inventory rows can equip owned `training_sword`, `leather_armor`, and `apple`.
- Guildmaster dialogs now separate normal copy, incomplete quest copy with Close only, completed quest copy with `Claim Reward`, and post-claim Reward panels.
- Guildmaster rewards are now Training Sword, Leather Armor, then Swordsman Guild unlock before game over/rebirth.
- Equipment now has gameplay and visual effects: Training Sword adds attack, Leather Armor adds defense, and equipped sprite selection supports bare, sword, and sword+armor variants.
- Generated nine complete LPC player sheets: three bare age sprites, three sword age sprites, and three sword+armor age sprites.
- Validation: full suite `429 tests, 429 passed, 0 failed`.

## [2026-05-13] fix | Delay Guildmaster quest activation

- RED: added QuestManager, Field, and Town specs for no early side-chain activation, Guildmaster-started activation, `Complete Quest` button copy, and hidden completion until the active objective is done.
- Field Forest Guard now records the checkpoint and certification objective only; Town Guildmaster activates `Rebuilding Swordsman Guild` after the player returns.
- Increased active Field enemies to 12 with five Bats so the 20% Bat Wing gather objective is practical to QA.
- Updated progression, Town, Field, Forest Gate, Run State, QuestManager, QuestSystem, and scene wiki docs.
- Validation: full suite `396 tests, 396 passed, 0 failed`.

## [2026-05-13] feature | Complete progression endpoint loop

- RED: added SaveManager, Town, Field, and Forest specs for profile unlock persistence, final rebirth panel, certified Forest transition, and Forest endpoint return.
- Added `ProfileSystem` autoload, profile save/load helpers, Town `RebirthPanel`, `scenes/forest.tscn`, and `Forest` controller.
- Certified Forest Gateway now transitions to Forest; Forest Guard still shows the open-path copy without reverting the objective.
- Validation: full suite `392 tests, 392 passed, 0 failed`.

## [2026-05-13] balance | Add rare enemy loot drops

- RED: updated EnemyBehaviorSystem and Field specs so enemy loot tables expose the requested 5% rare drops.
- Slime keeps `slime_gel` at 20% and now drops `apple` at 5%; Bat keeps `bat_wing` at 20% and can drop `training_sword` at 5%; Rat keeps `rat_tail` at 20% and can drop `leather_armor` at 5%.
- Updated prototype and wiki docs for the material and rare drop split.
- Validation: full suite `385 tests, 385 passed, 0 failed`.

## [2026-05-13] balance | Make material drops 20 percent

- RED: updated EnemyBehaviorSystem and Field specs so Slime, Bat, and Rat material drops use `chance_numerator = 1`, `chance_denominator = 5`.
- Material drops now roll at 20% instead of dropping 100%; Apple remains a separate 20% chance drop.
- Field quest gather specs force successful drop rolls where deterministic Bat Wing progress is needed.
- Validation: full suite `385 tests, 385 passed, 0 failed`.

## [2026-05-13] design | Change Guildmaster step two to gathering

- RED: added QuestManager and Field specs for Bat Wing gather objective progress and enemy-defeat filtering on gather objectives.
- Step two of the Swordsman Guild chain is now `Gather 2 Bat Wings for Guildmaster guard training.` instead of another kill-count task.
- Field reports matching material drops through `QuestSystem.record_item_gathered()`.
- Validation: full suite `384 tests, 384 passed, 0 failed`.

## [2026-05-13] feature | Add objective-backed Guildmaster quest chain

- RED: added QuestManager, ProgressionModel, Town, and Field specs for objective progress, wrong-enemy filtering, incomplete-objective rejection, completion-button gating, and Slime kill quest progress.
- `QuestManager` now tracks per-step Swordsman Guild objective progress: 10 Slimes, 2 Bat Wings, then 2 Rats.
- Field enemy defeats report into `QuestSystem`; Town and Field quest windows show side-objective progress.
- Guildmaster completion is hidden and model-rejected until the current objective is complete.
- Validation: full suite `381 tests, 381 passed, 0 failed`.

## [2026-05-13] feature | Name Guildmaster certification quest steps

- RED: added QuestManager and Town specs for three Guildmaster-owned Swordsman Guild quest objectives.
- `QuestManager` now exposes current side quest objective text for the `Rebuilding Swordsman Guild` chain.
- Guildmaster certification copy now shows old stance training, guard and footwork training, then the Life oath instead of generic numbered steps.
- Validation: full suite `375 tests, 375 passed, 0 failed`.

## [2026-05-13] feature | Add player aging sprites

- RED: added PlayerAgingModel, Town, and Field specs for Life-based player sprite aging.
- Generated `player_age_1.png`, `player_age_2.png`, and `player_age_3.png` as normal hair, grey hair/beard, and white hair/beard LPC age stages.
- Town and Field now apply age sprites from `PlayerAgingModel`; Town updates the sprite after certification Life spend.
- Validation: full suite `369 tests, 369 passed, 0 failed`.

## [2026-05-13] fix | Block HUD clicks from player movement

- RED: added SharedHUD, Town, and Field specs for Inventory button pointer blocking world movement.
- SharedHUD now exposes `blocks_world_mouse_at()` for visible HUD controls.
- Town and Field now ignore initial and held mouse movement while the pointer is over HUD controls.
- Validation: full suite `354 tests, 354 passed, 0 failed`.

## [2026-05-13] style | Stick dialog buttons bottom-right

- RED: added Town and Field scene specs for bottom-right dialog button layout.
- Dialog body labels now expand vertically and dialog button rows align to the right in both Town and Field scenes.
- Validation: full suite `351 tests, 351 passed, 0 failed`.

## [2026-05-13] fix | Gate dialog close to final page

- RED: added scene specs for paged dialog Close visibility and the certified Forest endpoint copy.
- Dialog Close now appears only on the last page while Next handles intermediate pages.
- Certified Forest endpoint copy now reads `The path to forest is open.`
- Validation: full suite `349 tests, 349 passed, 0 failed`.

## [2026-05-13] fix | Keep certified Forest objective stable

- RED: added a Field scene regression spec for talking to Forest Guard after Swordsman certification.
- Forest Guard now uses the certified `To be continued` endpoint after certification instead of re-running the certification checkpoint.
- Forest checkpoint progression now no-ops after certification or after the main objective has already advanced to `enter_forest`.
- Validation: full suite `348 tests, 348 passed, 0 failed`.

## [2026-05-13] fix | Polish progression QA issues

- RED: added specs for held-mouse movement in Town/Field, one-time Town reborn intro, Forest endpoint objective after certification, and Town HUD/objective behavior after the final Guild step.
- Town and Field now continue updating movement destination while the left mouse button is held and no dialog is open.
- Town reborn intro is tracked through quest runtime state so returning to Town does not replay it every entry.
- Swordsman certification step 3 now advances the main objective to `Enter the Forest.` after granting certification and unlocking `swordsman_guild`.
- Validation: full suite `347 tests, 347 passed, 0 failed`.

## [2026-05-13] feature | Complete Swordsman Guild certification progression

- RED: added model specs for side-chain steps, certification step completion, game-over request, and persistent `swordsman_guild` unlock after rebirth.
- RED: added scene specs for Guildmaster quest-completion certification, final achievement unlock, HUD Life update, and certified Forest `To be continued` endpoint.
- Added `QuestManager.side_quest_step()` / `advance_side_quest_step()` plus `QuestSystem` wrappers.
- Added `PlayerStats.game_over_requested` and idempotent `unlock_facility()`.
- Added `ProgressionModel.complete_swordsman_certification_step()` for the three Life-spend certification completions.
- Wired Town Guildmaster completion button to certification progression and Field Forest Gateway to the certified prototype endpoint.
- Updated prototype and LLM wiki documentation for progression, Town, Field, QuestManager, PlayerStats, and ProgressionModel.
- Validation: full suite `341 tests, 341 passed, 0 failed`.

## [2026-05-13] refactor | Fix Field SOLID and TDD review findings

- RED: added focused specs for `EnemyLibrary`, `EnemyState`, combat defense floors, InventoryWindow close signal, and SharedHUD input edge cases.
- Split broad Field scene coverage into smaller behavior-named specs for player/camera, gateways, HUD, enemy setup, spawn zones, combat feedback, and animation.
- Moved enemy catalog/factory responsibility from `EnemyDefinition` to registry-backed `EnemyLibrary`; `EnemyDefinition` is now data-only with dictionary config.
- Moved deterministic enemy random sequencing out of `EnemyState` into `EnemyRandomSequence`.
- Changed `EnemyBehaviorSystem.tick()` to a state-mutating contract instead of both mutating state and returning an event dictionary.
- Extracted `FieldCameraController`, `FieldEnemySpawnController`, and `FieldCombatController` from the Field scene controller.
- Added query/glue methods on Field so specs use public accessors instead of raw `enemy_states`, `enemy_views`, and target-id internals.
- Validation: full suite `328 tests, 328 passed, 0 failed`.

## [2026-05-13] refactor | Encapsulate inventory rows and extract drop rolls

- RED: added `InventoryModel.items_list()` coverage and `DropSystem` edge-case specs for guaranteed drops, zero numerator, roll boundary, failed rolls, and numerator clamping.
- Added `InventoryModel.items_list()` as the public read model for sorted stack rows.
- Updated `InventoryWindowView` to render item stacks through `items_list()` instead of reading `item_counts` directly.
- Added pure `DropSystem` and delegated Field chance-based drop rolls to it.
- Updated inventory, Field, and DropSystem wiki pages.
- Validation: full suite `301 tests, 301 passed, 0 failed`.

## [2026-05-13] fix | Regenerate enemy SpriteFrames resources

- Fixed the full-suite blocker in `EnemySpriteMetadataTest.test_builder_creates_sprite_frames_from_metadata`.
- Regenerated enemy `*_sprite_frames.tres` resources from metadata with `tools/generate_enemy_sprite_frames.gd` so the saved Slime death animation frame count matches the source strip.
- Validation: full suite `295 tests, 295 passed, 0 failed`.

## [2026-05-13] polish | Enlarge Field enemy footprint

- RED: updated Field and enemy behavior specs for larger enemy sprite scale, larger click collision, wider attack range, and wider player approach stop distance.
- Increased `EnemyView` world sprite scale to 4x and click collision radius to 76.
- Increased Field enemy blocker growth radius and player approach distance so enemies avoid tighter overlap with map blockers and the player sprite.
- Widened Field enemy attack ranges for the larger footprint: Slime 96, Bat 104, Rat 96.
- Validation: full suite now passes after regenerating enemy SpriteFrames resources.

## [2026-05-13] feature | Use Apple from shortcut bar

- RED: added Field scene coverage for shortcut `1` consuming an Apple, healing current Life, updating the HUD, and showing feedback.
- Added `InventoryModel.consume_item()` plus the `InventorySystem` wrapper.
- Wired `SharedHUDView.shortcut_pressed` into Field so Apple heals up to 20 current Life and consumes one stack item.
- Made shortcut bar slots more pronounced with white backgrounds and dark borders.
- Validation: full suite now passes after regenerating enemy SpriteFrames resources.

## [2026-05-13] feature | Add inventory shortcut bar

- RED: updated InventoryModel and SharedHUDView specs for 9 shortcut slots mapped to number keys `1` through `9`.
- Added `shortcut_slots` to `InventoryModel`, with slot 1 defaulting to `apple`, plus assignment, lookup, reset, and serialization.
- Added `ShortcutBar` to the shared HUD; pressing number keys emits `shortcut_pressed(slot_number, item_id)`.
- Validation: InventoryModel specs `7 tests, 7 passed`; SharedHUDView specs `4 tests, 4 passed`; Field scene specs `27 tests, 27 passed`.

## [2026-05-13] feature | Add inventory equipment slots

- RED: updated InventoryModel and InventoryWindowView specs for dedicated Weapon, Armor, and Consumable slots.
- Added starter slots to `InventoryModel`: `wooden_sword`, `cloth_armor`, and `apple`.
- Added slot setters, slot serialization, slot summary text, and reset behavior that restores starter slots.
- InventoryWindowView now renders the three slots above stackable item counts.
- Validation: InventoryModel specs `6 tests, 6 passed`; InventorySystem specs `3 tests, 3 passed`; InventoryWindowView specs `3 tests, 3 passed`.

## [2026-05-13] feature | Add Apple chance drops to Field enemies

- RED: updated EnemyBehaviorSystem specs so Slime, Bat, and Rat each include an `apple` drop with `chance_numerator = 1` and `chance_denominator = 5`.
- Updated Field drop granting to roll chance-based drops while keeping existing material drops guaranteed.
- Added deterministic Field scene coverage for the 1-in-5 drop roll helper.
- Validation: EnemyBehaviorSystem specs `9 tests, 9 passed`; Field scene specs `27 tests, 27 passed`.

## [2026-05-13] polish | Use enemy HP bars

- RED: updated Field scene specs to require per-enemy `HpBar` progress bars and removal of text-based enemy HP labels.
- Replaced `EnemyView` HP text with a local `ProgressBar` that tracks `state.hp / state.max_hp`.
- Moved enemy HP bars below enemy sprites and scaled them thinner for a quieter combat read.
- Enemy HP bars are hidden at full HP and become visible after that enemy takes damage.
- Removed the temporary Field `UI/SlimeHpLabel`; enemy HP now follows each enemy view.
- Validation: Field scene specs `27 tests, 27 passed`. Full suite remains blocked by the existing unrelated `EnemySpriteMetadataTest` frame-count mismatch.

## [2026-05-13] polish | Enlarge combat damage text

- RED: updated DamageTextComponent specs so new and existing damage labels must use a readable larger font.
- Added a `font_size` export to `DamageTextComponent`, defaulting to 36, and enforce it when the component resolves its label.
- Existing Field player damage labels now get resized by the component instead of staying at the earlier 24px label default.
- Validation: DamageTextComponent specs `3 tests, 3 passed`.

## [2026-05-13] tune | Scale Field enemy HP and player damage

- RED: updated EnemyBehaviorSystem and Field scene specs for 10x enemy HP and 10x visible player damage.
- Slime HP changed from 14 to 140, Bat from 8 to 80, and Rat from 6 to 60.
- Field player attack changed from 4 to 40; Slime defense changed from 1 to 10 so visible Slime damage remains exact 10x from 3 to 30.
- Player Life and enemy attack values are unchanged.
- Validation: EnemyBehaviorSystem specs `9 tests, 9 passed`; FieldScene specs `27 tests, 27 passed`; CombatSystem specs `4 tests, 4 passed`.

## [2026-05-13] feat | Add component-based combat juice

- RED: extended Field specs for enemy feedback components, hit flash, camera shake, and loot toast; added FeedbackSystem spec for global SFX requests.
- Added `HitFeedbackComponent` and `DamageTextComponent` as reusable enemy feedback children.
- Damage numbers now use RO-style parabolic motion; enemy damage is white and player damage is red.
- Added `FeedbackSystem` autoload as the global feedback/SFX request boundary.
- Field now starts short camera shake on player/enemy hits and shows a temporary loot toast when drops are granted.
- Updated Field and feedback architecture docs.
- Validation: Field scene specs `27 tests, 27 passed`; FeedbackSystem specs `1 test, 1 passed`; EnemySpriteFramesResource specs `2 tests, 2 passed`.

## [2026-05-12] change | Show reborn copy as Town start dialog

- RED: updated Town specs so the reborn copy must appear in `TownDialogView` on scene start and must not exist as a persistent HUD label.
- Removed `UI/RebornPrompt` from `scenes/town_scene.tscn`.
- Town now opens `You have been reborn.\nWill you spend this life well?` as a dialog named `Reborn` during `_ready()`.
- Updated Town scene and prototype docs.
- Validation: TownSceneDialog specs `20 tests, 20 passed`; TownPrototype specs `21 tests, 21 passed`.

## [2026-05-12] refactor | Add shared gameplay HUD

- RED: added SharedHUDView specs plus Field and Town coverage requiring a shared HUD with player Life, Inventory button/window, and Quest Tracker.
- Added `scenes/ui/shared_hud.tscn` and `scripts/views/shared_hud_view.gd`.
- Added `InventorySystem` as the game-wide inventory autoload and moved Field drops to the global inventory boundary.
- Field and Town now instance the shared HUD as `UI`; Field scene-specific objective/inventory text HUD nodes were removed.
- Updated shared HUD, inventory system, Field, Town, and prototype inventory docs.
- Validation: SharedHUDView specs `3 tests, 3 passed`; InventorySystem specs `2 tests, 2 passed`; Field scene specs `27 tests, 27 passed`; Town scene dialog specs `19 tests, 19 passed`.

## [2026-05-12] feat | Add reusable Inventory Window UI

- RED: added InventoryWindowView scene specs and Field scene coverage for the Inventory button plus `I` key toggle.
- Added `scenes/ui/inventory_window.tscn` and `scripts/views/inventory_window_view.gd` as a reusable inventory overlay scene.
- Field now instances the inventory window, opens it from the HUD Inventory button or `I`, and renders current InventoryModel stacks.
- Updated InventoryWindowView, Field, and prototype inventory docs.
- Validation: InventoryWindowView specs `3 tests, 3 passed`; Field scene specs `27 tests, 27 passed`.

## [2026-05-12] feat | Add InventoryModel and Field enemy drops

- RED: added InventoryModel specs, enemy drop definition checks, and Field scene coverage for inventory text plus Slime drop grants.
- Added `scripts/models/inventory_model.gd` for pure stackable item counts.
- Added deterministic drop tables to Slime, Bat, and Rat enemy definitions.
- Field now grants enemy drops once with XP rewards and shows a simple inventory summary label.
- Updated InventoryModel, Field, enemy behavior, and prototype inventory docs.
- Validation: InventoryModel specs `5 tests, 5 passed`; EnemyBehaviorSystem specs `9 tests, 9 passed`; Field scene specs `26 tests, 26 passed`.

## [2026-05-12] map | Reimport edited Field TMJ

- Re-rendered `D:\godot\kenney_tiny-town\field.tmj` with the Tiny Town layout skill renderer.
- Reimported the edited Field TMJ into `scenes/maps/field_map.tscn` and `scenes/maps/field_collision.tscn`.
- Refreshed `scenes/field.tscn` map/collision instances through `tools/import_tiny_town_tmj.py`.
- Validation: Field scene specs `26 tests, 26 passed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] fix | Complete Forest Guard dialog before quest progress

- RED: updated Field specs so Forest Guard dialog opening does not progress QuestSystem; closing the dialog does.
- Field now stores a pending Forest Guard checkpoint while the warning dialog is open and applies it from `close_dialog()`.
- QuestWindowView no longer renders checkpoint text; it shows only quest title and objective.
- Validation: Field scene specs `26 tests, 26 passed`; QuestWindowView specs `3 tests, 3 passed`; QuestManager specs `18 tests, 18 passed`.

## [2026-05-12] fix | Update quest when talking to Forest Guard

- RED: extended Field scene spec to cover Forest Guard click/talk path updating QuestSystem and QuestWindow.
- Field now marks the `forest_guard` checkpoint and advances the main quest whenever Forest Guard dialog opens, not only when the Forest Gateway body is entered.
- Validation: Field scene specs `25 tests, 25 passed`; QuestManager specs `18 tests, 18 passed`; QuestWindowView specs `3 tests, 3 passed`.

## [2026-05-12] feat | Add Forest Guard quest checkpoint

- RED: added QuestManager, Field, and QuestWindow specs for a `forest_guard` main quest checkpoint.
- QuestManager now tracks main quest checkpoints, serializes them, and exposes checkpoint text.
- QuestSystem proxies checkpoint APIs for scenes.
- Field marks the Forest Guard checkpoint before advancing the main objective and refreshing the Quest Window.
- QuestWindowView can display an optional checkpoint line.
- Validation: QuestManager specs `18 tests, 18 passed`; Field scene specs `25 tests, 25 passed`; QuestWindowView specs `3 tests, 3 passed`.

## [2026-05-12] feat | Add top-right Quest Window

- RED: added QuestWindowView, Field, and Town dialog specs for a dedicated top-right quest objective panel.
- Added `scripts/views/quest_window_view.gd` as a dumb reusable UI view.
- Added `UI/QuestWindow` to Town and Field and wired controllers to display the current QuestSystem main objective.
- Field refreshes the Quest Window after Forest Gateway progression changes the objective to `Get Swordsman Certification`.
- Updated Field, Town, UI, and Quest Window wiki docs.
- Validation: QuestWindowView specs `2 tests, 2 passed`; Field scene specs `25 tests, 25 passed`; Town dialog specs `19 tests, 19 passed`.

## [2026-05-12] feat | Add QuestSystem main and side quest progression

- RED: added QuestManager, Field, and Town dialog specs for main quest objective progression, Swordsman Guild side chain activation, certification state, and Guildmaster response.
- Added `QuestSystem` autoload wrapping pure `QuestManager` progression state.
- Field Forest Gateway now advances `Explore the World` to `Get Swordsman Certification` and activates `Rebuilding Swordsman Guild`.
- Town Guildmaster now reacts to that objective with certification guidance.
- Updated quest, Field, Town, Forest Gate, Run State, and prototype design docs.
- Validation: QuestManager specs `17 tests, 17 passed`; Field scene specs `25 tests, 25 passed`; Town dialog specs `18 tests, 18 passed`.

## [2026-05-12] fix | Move Field Town portal to north road

- Moved `TownGateway` to the north road entry at `Vector2(768, 64)`.
- Moved `SpawnPoints/FromTownGateway`, `SpawnPoints/Default`, and initial Player position to `Vector2(768, 160)` so Field load does not auto-trigger the Town portal.
- Removed legacy primitive Field terrain/prop visuals now covered by imported `FieldMap`.
- Updated Field specs for north portal placement, safe spawn distance, and removed primitive art nodes.
- Validation: `249 tests, 249 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] feature | Import Tiny Town Field map

- Generated `scenes/maps/field_map.tscn` and `scenes/maps/field_collision.tscn` from `D:\godot\kenney_tiny-town\field.tmj`.
- Instanced `FieldMap` and `FieldCollision` into `scenes/field.tscn`.
- Moved `ForestGateway`, `ForestBlocker`, and `ForestGuard` to the southeast road end.
- Generalized `tools/import_tiny_town_tmj.py` so it can update non-Town scenes and arbitrary generated map/collision scene paths.
- Added Field scene specs for generated map/collision and southeast forest-gate placement.
- Updated Field and Tiny Town import wiki pages.
- Validation: `248 tests, 248 passed, 0 failed`; Godot MCP main-scene play starts, with existing GDScript warnings reported by `get_godot_errors`.

## [2026-05-12] fix | Move Town spawn away from portal trigger

- Kept `FieldGateway` at the south road exit.
- Moved `SpawnPoints/FromFieldGateway`, `SpawnPoints/Default`, and initial Player position to `Vector2(960, 980)` so Town load does not auto-trigger the portal.
- Updated Town specs to require the spawn be clear of the portal trigger.
- Validation: `246 tests, 246 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] polish | Move Town portal to south road

- Moved `FieldGateway` to the south road exit at `Vector2(960, 1320)`.
- Moved Town Field-return spawn and default Player start to `Vector2(960, 1240)` near the south road.
- Moved Shopkeeper to the bottom Tiny Town house at `Vector2(512, 1140)`.
- Added Town specs for the south-road gateway/spawn and bottom-house Shopkeeper placement.
- Validation: `246 tests, 246 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] change | Remove proximity-based NPC dialog

- Removed the `Proximity` Area2D from `scenes/npc.tscn`.
- Removed `NpcController` proximity `body_entered` hookup so NPC dialog only starts from clicking the NPC sprite.
- Added specs covering the absence of proximity dialog triggers.
- Updated NPC system and Town scene wiki pages.
- Validation: `245 tests, 245 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] polish | Move Town NPCs in front of Tiny Town buildings

- Moved Shopkeeper, Guildmaster, and Smith from the old primitive-building coordinates to positions in front of the imported Tiny Town house/castle facades.
- Added a Town spec for the Tiny Town-facing NPC coordinates.
- Updated Town scene wiki with the new placement intent.
- Validation: `244 tests, 244 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] tooling | Automate Tiny Town map import

- Added `tools/import_tiny_town_tmj.py` to convert the external layered TMJ into `scenes/maps/town_map.tscn`.
- Extended the importer to generate `scenes/maps/town_collision.tscn` from solid Tiny Town layers using merged `StaticBody2D` rectangle blockers.
- Copied `tilemap_packed_2x.png` into `assets/tiny_town/` and imported it for Godot.
- Instanced generated `TownMap` and `TownCollision` into `scenes/town_scene.tscn` while preserving Player, NPCs, gateways, spawn points, camera, and UI ownership.
- Added Town specs for the generated map and collision instances.
- Updated Tiny Town import and Town scene wiki pages plus index.
- Validation: `243 tests, 243 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] feature | Add Bat/Rat and spawn zones

- Added Bat and Rat enemy definitions and spawned them alongside Slimes in Field.
- Fixed EnemyView configuration order so Bat/Rat load their own SpriteFrames instead of default Slime frames.
- Added hidden scene-authored `SpawnZones/Grassland` and randomized initial enemy positions across the larger map area.
- Expanded enemy idle timing/random movement so enemies do not move in synchronized batches.
- Updated Field and enemy behavior wiki pages plus index.
- Validation: `241 tests, 241 passed, 0 failed`.

## [2026-05-12] refactor | Add named gateway spawn points

- Added `SpawnPoints/FromFieldGateway` and `SpawnPoints/Default` to Town.
- Added `SpawnPoints/FromTownGateway` and `SpawnPoints/Default` to Field.
- Updated GatewayDefinition target spawn IDs to `from_town_gateway` and `from_field_gateway`.
- Documented spawn-point pattern so maps can support multiple portals without hardcoded player positions.
- Validation: `240 tests, 240 passed, 0 failed`.

## [2026-05-12] tune | Slime wander and first-hit aggro

- Changed Slime wander from synchronized rightward movement to per-instance pseudo-random idle timing and wander targets.
- Disabled default proximity aggro with `aggro_radius = 0.0`; Slime now aggros on first player hit, not on click/target.
- Updated enemy behavior and Field scene wiki pages.
- Validation: `239 tests, 239 passed, 0 failed`.

## [2026-05-12] polish | RO-style Field combat and character asset previews

- Added LPC SpriteFrames builder and wired Player/Forest Guard into AssetView, AssetGallery, and AssetsViewer.
- Added player slash attack animation support through AnimationController and CharacterMovement.
- Updated Field to start with five Slimes, stop canceling slash animation, show RO-style damage numbers above actors, and delay Slime removal until death animation plays.
- Updated Field, animation, asset tooling, and enemy behavior wiki pages plus index.
- Validation: `237 tests, 237 passed, 0 failed`.

## [2026-05-12] feature | Add first Slime combat flow

- Added EnemyDefinition, EnemyState, EnemyBehaviorSystem, EnemyView, and reusable enemy scene for first Field Slime.
- Wired Field click-to-engage, player approach/auto-attack, Slime aggro chase, Slime interval attacks against Life, death removal, and XP reward.
- Updated combat tests from Combat HP to current Life damage.
- Added enemy behavior specs and Field scene combat-flow specs.
- Updated Field scene wiki, enemy behavior wiki, wiki index, and this log.
- Validation: `232 tests, 232 passed, 0 failed`.

## [2026-05-12] decision | Make Life the combat health resource

- Corrected prototype docs: combat now damages current Life, while quests/progression reduce Max Life.
- Removed Combat HP wording from prototype combat, run state, Field, inventory, UI, Town, and system docs.
- Updated combat-system wiki and index to describe current Life damage and Max Life pressure.
- Design consequence: spending Max Life for progress makes future combat harder; preserving Max Life improves combat survivability but blocks progression.

## [2026-05-12] change | Update Field enemy target set

- Changed Field grassland enemy pool from Chick/Rabbit/Slime to Slime/Bat/Rat (`slime_spiked`, `bat`, `rat`).
- Updated prototype Field docs, combat docs, game systems docs, biome wiki, Field scene wiki, and wiki index.
- Added RED biome spec first, then updated `BiomeDefinition.field_grassland()`.
- Validation: `223 tests, 223 passed, 0 failed`.

## [2026-05-12] fix | Defer gateway scene changes outside physics callbacks

- Updated Town and Field gateway controllers to call deferred scene-change helpers from `body_entered` transitions.
- Added specs covering the deferred transition path for Town -> Field and Field -> Town gateways.
- Updated `scenes/town-hub.md`, `scenes/field.md`, and `index.md` with the gateway transition behavior note.
- Validation: `204 tests, 204 passed, 0 failed`; MCP main-scene play reports no errors.

## [2026-05-08] init | Wiki initialized

- Created `SCHEMA.md` with proposed schema
- Created `index.md` (empty catalog)
- Created `raw-sources/index.md` (empty registry)

## [2026-05-08] ingest | Game Design Session 1

- Registered `raw-sources/conversations/2026-05-08-game-design-sess1.md`
- Compiled `game-design/game-design.md`
- Updated `index.md`
- Updated `raw-sources/index.md`

## [2026-05-08] ingest | Architecture Decision

- Compiled `architecture/architecture.md` — MVC + SOLID pattern
- Compiled `architecture/spec-driven-dev.md` — Spec-driven development workflow
- Compiled `architecture/test-runner.md` — JSON spec runner
- Updated `index.md`

## [2026-05-08] ingest | Test Runner

- Registered `scripts/managers/test_runner.gd`
- Registered `resources/specs/test_spec.json`
- Compiled `architecture/test-runner.md`
- Updated `index.md`

## [2026-05-10] ingest | QuestManager + TDD enforcement

- Created `architecture/quest-manager.md` — Quest catalog, multi-quest tracking, HP-based affordability
- Updated `architecture/spec-driven-dev.md` — Added TDD enforcement rules
- Updated `index.md` — Added QuestManager page
- Updated `docs/STATUS.md` — QuestManager docs, TDD rules, commit history

## [2026-05-10] update | Minitest-style Test Runner

- Moved test assertions to `tests/test_helper.gd`
- Moved the CI entrypoint to `tests/test_runner.gd` attached to `tests/test_runner.tscn`
- Split playable demo behavior into `scripts/controllers/demo_controller.gd`
- Updated test runner architecture docs

## [2026-05-11] style | Center main menu layout, font sizing, button spacing

- CenterContainer → VBoxContainer with alignment=CENTER, buttons via SHRINK_CENTER size flags
- Buttons: custom_minimum_size Vector2(200, 40)
- Title: 36px font via `add_theme_font_size_override`
- VBoxContainer separation: 16px via `add_theme_constant_override`
- All 64 tests pass

## [2026-05-11] feat | Town Hub + Player Character

- Created `scenes/town_scene.tscn` — town hub with 1280×720 background, player, stats UI
- Fleshed out `scenes/player.tscn` — Sprite2D with player.png LPC atlas (13×21), CircleShape2D (radius 20)
- Attached `player_movement.gd` to player sprite — click-to-move, 8-directional animation
- Created `scripts/controllers/town_scene_controller.gd` — stats display, quest count updates
- Updated `main_menu_controller.gd` — transitions to town_scene.tscn
- Fixed `player_movement.gd` — `get_node_or_null()` for destination marker

## [2026-05-11] feat | Click-to-move for player

- Added `_unhandled_input` handler in `player_movement.gd` for left-click movement
- Screen position converted to world position via `get_global_mouse_position()`
- Added `DestinationMarker` sprite to town scene — shows during movement, hides when idle
- Added `can_move` flag for toggling movement (set by scene controller)

## [2026-05-11] refactor | Codebase review: all issues fixed

- Created `scripts/models/game_balance.gd` — shared constants (QUEST_HP_COST, animation timings)
- Extracted `_deduct_hp()` private method in `player_stats.gd` — `take_quest()` and `complete_quest()` now call it
- Removed default param `current_hp = 100` from `quest_manager.take_quest()` — callers must pass HP explicitly
- Updated `quest_manager_test.gd` — all `take_quest()` calls now pass explicit HP
- Added walking frame advance to `AnimationController.tick()` — `_tick_walking()` advances `walk_frame` each frame
- Updated `animation_controller_test.gd` — walking tick test renamed + expects frame advance
- Moved `player_movement.gd` from `scripts/controllers/` → `scripts/views/` — proper MVC placement
- Integrated `AnimationController` into `PlayerMovement` — removed duplicated LPC constants, delegates frames to model
- Fixed `town_scene_controller.gd` parse error (`const _` → `const _PMovement`)
- Added `_player_stats` + `_quest_manager` instance vars to `TownSceneController` — no more create+free per update
- Added `class_name DemoController` to `demo_controller.gd`
- Updated scene references in `player.tscn` and `test_runner_scene.tscn` for moved script
- Deleted orphan `tests/specs/test_spec.gd.uid`
- Added `PlayerMovement._dir_from_vector()` static utility with spec coverage (10 tests)
- Fixed zero-vector edge case in `_dir_from_vector` (was returning "up" instead of "down")
- Fixed equal-magnitude edge case (was vertical-preferring, now horizontal-preferring per spec)
- Updated docs: STATUS.md, AGENTS.md, quest-manager.md, test-runner.md — all test counts current
- All 74 tests pass

## [2026-05-11] create | Wiki pages for AnimationController and PlayerMovement

- Created `architecture/animation-controller.md`
- Created `architecture/player-movement.md`

## [2026-05-11] fix | PlayerMovement physics-based movement, export marker

- Switched `_process` → `_physics_process` — velocity + `move_and_slide()` via parent CharacterBody2D
- Replaced hardcoded `get_node_or_null` paths with `@export var marker_path: NodePath`
- Snap threshold (5.0) instead of raw distance-per-frame check
- Removed unused `_marker_paths` array
- Updated `architecture/player-movement.md` with new API and physics details
- All 74 tests pass

## [2026-05-11] fix | TDD review fixes: NPC quest null, scene wiring, GameBalance specs

- RED: added `tests/specs/scene_smoke_test.gd`; confirmed failing player/demo scene wiring.
- Added `tests/specs/game_balance_test.gd` coverage for `GameBalance`.
- Fixed `NpcState.current_quest` to clear to `null`.
- Fixed `test_runner_scene.tscn` to use `scripts/views/character_movement.gd`.
- Split `player.tscn` from NPC controller/proximity; root is `Player` with CharacterMovement sprite.
- Tightened `NpcController` and `DemoController` CharacterMovement typing.
- Cleaned QuestManager spec wording for HP-at-cost behavior.
- Created `architecture/game-balance.md`; updated NPC, movement, quest, test-runner wiki pages and index.
- All 98 tests pass.

## [2026-05-11] fix | NPC interaction facing, idle animation, and collision stop

- Created `plans/npc-interaction-animation-fix.md` with TDD acceptance criteria.
- RED: added idle-frame specs, CharacterMovement facing/static specs, NPC controller facing specs, and NPC scene static/marker smoke spec.
- Implemented idle frame cycling in `AnimationController` while preserving direction.
- Added `CharacterMovement.set_facing()` and collision-stop behavior so player animation returns to idle when blocked by solid NPCs.
- Marked NPC sprites static and markerless in `scenes/npc.tscn`.
- Updated `NpcController` to consume click input and face actual player/global position for click/proximity interactions.
- Updated wiki pages for animation, NPC system, and movement.
- Subagents were attempted but child pi provider auth failed (`No API key found for azure-openai-responses`).
- All 105 tests pass.

## [2026-05-11] fix | Visible NPC interaction and proximity range

- RED: added specs for `interacted(npc)` signal payload, NPC collision/talk radii, and town UI conversation feedback.
- Changed `NpcController.interacted` to emit the NPC instance.
- Connected town NPC interaction signals to `TownSceneController._on_npc_interacted()`.
- Interaction now updates `QuestLabel` to `Talking to: <NPC>` so QA has visible feedback.
- Set NPC solid collision radius to 20px and talk/proximity radius to 60px.
- Hardened `CharacterMovement.set_facing()` to initialize animation/frame layout before `_ready` if needed.
- All 108 tests pass.

## [2026-05-11] feat | Complete NPC dialog and quest UI

- Attempted planner/scout subagents for NPC system completion; both failed due child pi provider auth (`No API key found for azure-openai-responses`).
- RED: added `tests/specs/town_scene_dialog_test.gd` and NPC metadata coverage.
- Added NPC metadata exports: display name, role, dialog text, quest fields.
- Added `DialogPanel` UI to `town_scene.tscn` with name/body labels and Accept/Complete/Close buttons.
- `TownSceneController` now connects NPC interactions to dialog UI and wires QuestGiver accept/complete to `QuestManager` + `PlayerStats`.
- Vendor/Guard show dialog without quest controls.
- Updated `plans/npc-system.md`, `plans/npc-interaction-animation-fix.md`, and NPC wiki docs.
- All 115 tests pass.

## [2026-05-11] feat | RO-style NPC approach interaction

- RED: added specs for CharacterMovement stop/facing/move lock, NpcController talk range/talk point/name label, and TownSceneController pending approach/modal dialog flow.
- Added `CharacterMovement.stop_moving()` and `face_target()` for dialog control.
- Added NPC talk helpers: `talk_radius`, `solid_radius`, `talk_stop_buffer`, `is_player_in_talk_range()`, and `talk_point_for()`.
- Added overhead `NameLabel` to `scenes/npc.tscn`; `NpcController._ready()` syncs it from `display_name`.
- Changed town interaction to RO-style: far click moves player toward NPC, pending dialog opens inside talk range, near click opens immediately.
- Dialog now stops movement, disables click-to-move while open, faces player/NPC toward each other, and restores movement on close.
- Updated `plans/ro-style-npc-interaction.md`, `architecture/npc-system.md`, `architecture/player-movement.md`, and `scenes/town-hub.md`.
- All 128 tests pass.

## [2026-05-11] fix | Quest HP cost moves from accept to complete

- RED: updated PlayerStats, QuestManager, and TownScene dialog specs to assert accepting a quest costs no HP.
- Changed `PlayerStats.take_quest()` to no-op and kept `complete_quest()` as 40 Max HP cost.
- Changed `QuestManager.take_quest()` to ignore HP affordability; it fails only when no quest is available.
- Updated QuestGiver UI flow: accept keeps HP at 100; complete changes HP 100 → 60 and removes active quest.
- Updated game-design, quest-manager, NPC, and plan docs.
- Manual QA passed in `scenes/town_scene.tscn`: far/near NPC interaction, modal movement lock, free accept, 40 HP completion cost, Vendor/Guard dialogs, and name labels.
- All 126 tests pass.

## [2026-05-11] refactor | Extract TownDialogView from TownSceneController

- Deleted `reviews/solid-1.md` per request.
- RED: added TownScene dialog specs for `TownDialogView` scene wiring and `show_dialog()` presentation API.
- Created `scripts/views/town_dialog_view.gd` for dialog labels, panel visibility, button visibility, and button request signals.
- Attached `TownDialogView` to `scenes/town_scene.tscn` `UI/DialogPanel`.
- Refactored `TownSceneController` to delegate dialog presentation while keeping quest orchestration and movement lock behavior.
- Updated `scenes/town-hub.md`, `architecture/npc-system.md`, and `index.md`.
- All 128 tests pass.

## [2026-05-11] feat | Life tracking foundation and TODO completion

- RED: added specs for LifeTracker, SaveManager, NpcDefinition, ProgressionModel, settings/audio/scene transitions, and town daily task UI.
- Created `scripts/models/life_tracker.gd` for tasks, habits, daily completions, streaks, XP, and serialization.
- Created `scripts/models/progression_model.gd` for task completion rewards, linked quest completion, HP spend, and facility unlock rules.
- Created `scripts/models/npc_definition.gd` plus resource examples in `resources/npc_definitions/` for quest giver, vendor, and facility NPC roles.
- Created `scripts/managers/save_manager.gd` and `scripts/managers/audio_manager.gd`.
- Created `scripts/models/settings_model.gd` and `scripts/controllers/scene_transition_controller.gd`.
- Added daily task and settings UI to `scenes/town_scene.tscn`; `TownSceneController` now seeds tasks, completes tasks, updates XP, and plays SFX request.
- Updated `QuestManager` and `PlayerStats` serialization/progression APIs.
- Disabled GDAI MCP autoload/editor plugin in `project.godot` to remove headless `gdaimcp` capture error.
- Added `README.md`, `assets/task_complete.svg`, CI output checking, and updated `todo.md`.
- Created wiki pages: `architecture/player-stats.md`, `architecture/life-tracker.md`, `architecture/progression-model.md`, `architecture/npc-definition.md`, `architecture/settings-model.md`, `architecture/persistence-audio-settings.md`.
- Updated `scenes/town-hub.md`, plan docs, and index.
- All 152 tests pass.

## [2026-05-11] docs | QA pass and commit preparation

- Updated `docs/STATUS.md` with current MVP state, QA result, implemented feature list, and remaining production work.
- Updated `todo.md` to distinguish complete, MVP/stub, and open items.
- Manual QA marked pass for main menu, town movement, NPC dialog, quest accept/complete, daily task XP, and settings panel.
- Known cleanup warnings remain documented as non-blocking MVP issues.

## [2026-05-11] fix | Guard GDAI MCP runtime in headless tests

- RED: added `tests/specs/gdai_mcp_runtime_guard_test.gd` for headless skip, non-headless allow, and autoload path.
- Created `scripts/managers/gdai_mcp_runtime_guard.gd` wrapper around `GDAIRuntimeServer` startup.
- Re-enabled GDAI MCP plugin/autoload in `project.godot`, pointing autoload to the guard.
- Headless tests no longer emit `ERROR: Capture not registered: 'gdaimcp'` while editor MCP remains enabled.
- Created `architecture/gdai-mcp-runtime-guard.md`; updated index, todo, and status docs.
- All 155 tests pass.

## [2026-05-11] fix | Remove Godot cleanup leaks

- Fixed owned model cleanup in `CharacterMovement` (`AnimationController`) via `NOTIFICATION_PREDELETE`.
- Fixed owned model cleanup in `CameraController` (`CameraModel`) via `NOTIFICATION_PREDELETE`.
- Fixed owned model cleanup in `TownSceneController` (`PlayerStats`, `QuestManager`, `LifeTracker`, `ProgressionModel`, `SettingsModel`) via `NOTIFICATION_PREDELETE`.
- Tightened CI output check to fail on any Godot `ERROR:` or `WARNING:` after cleanup warnings were removed.
- Updated `todo.md`, `docs/STATUS.md`, `architecture/player-movement.md`, and `scenes/town-hub.md`.
- Full verbose suite: `155 tests, 155 passed, 0 failed`, no leak/resource warnings.

## [2026-05-11] refactor | Remove legacy demo scene/controller

- RED: changed `tests/specs/scene_smoke_test.gd` to assert `test_runner_scene.tscn` and `demo_controller.gd` stay removed; confirmed failure while files still existed.
- Deleted `scenes/test_runner_scene.tscn`, `scripts/controllers/demo_controller.gd`, and orphan `scripts/controllers/demo_controller.gd.uid`.
- Updated current docs/wiki references to remove DemoController as active architecture.
- Updated `docs/STATUS.md` to reflect no-warning validation and legacy demo removal.

## [2026-05-11] fix | Remove test runner shadow warning

- Renamed `_find_test_methods()` local `name` variable to `method_name` to avoid shadowing `Node.name` during GDScript reload.
- Renamed `AudioManager.play_sfx(name)` parameter to `sfx_name` to avoid `Node.name` shadow warning.
- Updated `architecture/test-runner.md` successful output example to current 155-test suite.

## [2026-05-11] docs | Prototype systemic design and art direction

- Created `prototype-checklists.md` with systemic design checklist, component inventory, rules, permissions, restrictions, conditions, and primitive/SVG art direction.
- Created `prototype/components/` one-page specs for Town, Run State, Starter Area, Forest Gate, Swordsman Guild Quest, Inventory, Combat, UI, and Rebirth.
- Created `llm-wiki/game-design/prototype-systemic-design.md` and updated wiki index.

## [2026-05-11] feat | Prototype Town first slice

- RED: added `tests/specs/town_prototype_test.gd` for Town root/class naming, buildings, NPCs, dialog copy, reborn prompt, and Starter Area Portal.
- Rewrote `scenes/town_scene.tscn` as first-slice Town: Shop, Swordsman Guild, Blacksmith, Guildmaster, Shopkeeper, Smith, reborn prompt, dialog panel, and glowing portal.
- Rewrote `scripts/controllers/town_scene_controller.gd` as `class_name Town`, thin glue for worldbuilding NPC dialog and portal transition request.
- Updated `tests/specs/town_scene_dialog_test.gd` and `tests/specs/scene_smoke_test.gd` for first-slice systemic Town behavior.
- Updated `prototype/components/town.md`, removed duplicate `prototype/town.md`, and updated `scenes/town-hub.md` wiki page.
- Completed pre-Starter Town behavior: 1920×1080 viewport, RO-style camera follow, click-to-move while dialog is closed, world primitives ignore mouse so ground clicks move, dialog blocks movement, far NPC click approaches before dialog, paged NPC dialog with Next/Close, Player entering Starter Area Portal shows Yes/No prompt, No hides it, and Yes records Starter Area target path.
- Generated distinct LPC sprites for Guildmaster, Shopkeeper, and Smith using `tools/lpc-sprite-gen` and wired them into `scenes/town_scene.tscn`.
- Scaled Town NPC instances to `Vector2(2, 2)` so they match player size.
- Enlarged dialog typography for 1080p and moved NPC face portrait above the dialog box using cropped LPC spritesheet face frame.
- Reworked idle animation to use calm standing walk-row frames instead of LPC spellcast/prayer frames; Town NPCs use varied idle timing for desync.
- Hid NPC overhead name labels by default; NPC names remain in dialog.
- Validation: `173 tests, 173 passed, 0 failed`; MCP play current scene reports no errors.
- Manual QA passed: ground click movement, RO-style NPC approach, paged dialog Next/Close, dialog movement lock, camera follow, and portal Yes/No prompt.
- Created `prototype/game-systems.md` as append-only system inventory using systemic design terms: verbs, components, resources, rules, and conditions.
- Added `prototype/components/Field.md` and `prototype/field-development-decisions.md` documenting Field terminology, real combat scope, direct gateway transitions, model-first implementation order, Guard LPC sprite, and SVG/primitive monsters.

## [2026-05-11] feat | Playable Field MVP

- RED: added specs for gateway, enemy, combat, respawn, NPC placement, biome, Field scene, and direct Town → Field gateway behavior.
- Created pure models: `GatewayDefinition`, `EnemyDefinition`, `CombatSystem`, `RandomEnemyRespawnSystem`, `NpcPlacement`, and `BiomeDefinition`.
- Created `scenes/field.tscn` and `scripts/controllers/field.gd` with click movement, camera follow, direct Town gateway, blocked Forest gateway, Forest Guard dialog, Chick/Rabbit/Slime placeholders, and click-attack combat.
- Updated Town gateway from Starter Area prompt flow to direct Field transition.
- Generated `assets/npcs/forest_guard.png` with local LPC sprite generator.
- Updated prototype docs and wiki pages for new models, Field scene, and Town gateway behavior.
- Validation: `202 tests, 202 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] art | SVG enemy placeholders for Field

- RED: added `tests/specs/field_scene_test.gd` coverage requiring Chick/Rabbit/Slime SVG art resources.
- Created `assets/enemies/chick.svg`, `assets/enemies/rabbit.svg`, and `assets/enemies/slime.svg` plus import metadata.
- Replaced Field enemy `ColorRect` visuals with `TextureRect` SVG visuals while preserving mouse-filter ignore behavior.
- Updated Field prototype docs and scene wiki.
- Validation: `203 tests, 203 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] fix | Editor preview LPC sprites and test runner UID warning

- RED: added `tests/specs/scene_smoke_test.gd` coverage requiring Player/NPC scene sprites to store LPC sheet slicing and standing-down preview frame.
- Updated `scenes/player.tscn` and `scenes/npc.tscn` with `hframes = 13`, `vframes = 21`, and `frame_coords = Vector2i(1, 10)` so Field editor view no longer displays full LPC sheets tiled across the map.
- Removed stale UID from `tests/test_runner.tscn` ext_resource so headless runs do not warn and fall back to text path.
- Updated player movement wiki docs.
- Validation: `203 tests, 203 passed, 0 failed`.

## [2026-05-11] feat | Enemy art registry and Slime spritesheet integration

- Created `assets/assets-catalog.md` with enemy sprite integration tasks and current asset list.
- RED: added specs for `EnemyArtDefinition`, `EnemyView`, and Field Slime spritesheet wiring.
- Created `scripts/models/enemy_art_definition.gd` for art-only enemy metadata and Field factories.
- Created `scripts/views/enemy_view.gd` and `scenes/enemy.tscn` as reusable `Area2D` visual/click target.
- Wired Field Slime to `assets/enemies/slime_water_blue_spritesheet.png` through `EnemyView`; Chick/Rabbit remain SVG fallbacks.
- Updated Field scene wiki, architecture pages, and index.
- Validation: `210 tests, 210 passed, 0 failed`; MCP play `scenes/field.tscn` reports no errors.

## [2026-05-11] reset | Remove Field enemies for EnemySystem rebuild

- RED: updated `tests/specs/field_scene_test.gd` to require no `Enemies` node, no `CombatHud`, and no stale Field enemy attack/connect API.
- Removed all enemy placements from `scenes/field.tscn`.
- Removed enemy/combat wiring from `scripts/controllers/field.gd`.
- Removed first-pass EnemySystem implementation files/specs: `EnemyDefinition`, `RandomEnemyRespawnSystem`, `EnemyArtDefinition`, `EnemyView`, and related wiki pages.
- Kept enemy art assets in `assets/enemies/` for future rebuild.
- Updated `assets/assets-catalog.md`, Field prototype docs, wiki Field scene page, and index.

## [2026-05-11] feat | Enemy assets viewer gallery

- RED: added `tests/specs/assets_viewer_test.gd` for asset viewer scene load, recursive PNG collection, and gallery card generation.
- Created `assets/assets-viewer.tscn`.
- Created `assets/assets_viewer.gd` with `AssetsViewer.collect_asset_paths()` and `rebuild_gallery()`.
- Viewer scans `res://assets/enemies` recursively and builds a scrollable thumbnail grid for PNG assets.
- Updated `assets/assets-catalog.md`, wiki assets viewer page, index, and log.
- Validation: `198 tests, 198 passed, 0 failed`.

## [2026-05-11] feat | Focused Slime asset animation viewer

- RED: added `tests/specs/slime_asset_viewer_test.gd` for focused Slime viewer scene, animation path catalog, animated cards, playback, and 64×64 frame slicing.
- Created `assets/asset-view.tscn`.
- Created `assets/asset_view.gd` with `SlimeAssetView`, generated `SpriteFrames`, and `AnimatedSprite2D` preview cards for idle/run/hit/jump/death/ability.
- Updated `assets/assets-catalog.md`, wiki Slime asset view page, index, and log.
- Validation: `202 tests, 202 passed, 0 failed`.

## [2026-05-11] fix | Center Slime asset viewer animations

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require each animation card to reserve a `PreviewArea` and center `AnimatedSprite2D` at `Vector2(110, 80)`.
- Updated `assets/asset_view.gd` so animated sprites are children of a fixed preview area instead of direct VBox children, fixing clipped/overlapping previews.
- Reduced Slime preview scale to `Vector2(2.5, 2.5)` for cleaner card fit.
- Updated Slime asset viewer wiki docs.
- Validation: `202 tests, 202 passed, 0 failed`.

## [2026-05-12] feat | Enemy sprite metadata V1 for Spiked Slime

- RED: added `tests/specs/enemy_sprite_metadata_test.gd` for metadata schema, catalog loading, texture/dimension validation, and SpriteFrames generation.
- Updated `tests/specs/slime_asset_viewer_test.gd` so Slime viewer consumes metadata instead of hardcoded paths/frame size.
- Created `assets/enemies/Slime/slime_spiked.asset.json` with `schema_version = 1`, `enemy_id = slime_spiked`, `display_name = Spiked Slime`, `horizontal_2d` facing, flip support, frame size, scale, anchor, and animation actions.
- Created `scripts/models/enemy_sprite_catalog.gd` for JSON loading/normalization/validation.
- Created `scripts/views/enemy_sprite_frames_builder.gd` for metadata-driven `SpriteFrames` construction.
- Refactored `assets/asset_view.gd` to load `slime_spiked` through the catalog/builder.
- Added `llm-wiki/architecture/enemy-sprite-metadata.md` and updated asset viewer docs, catalog, index, and log.
- Validation: `208 tests, 208 passed, 0 failed`.

## [2026-05-12] refactor | Single-sprite Slime asset viewer controls

- RED: rewrote `tests/specs/slime_asset_viewer_test.gd` expectations so `asset-view.tscn` has one `AnimatedSprite2D`, defaults to `idle`, removes the old multi-card animation grid, and exposes one button per supported animation.
- Refactored `assets/asset_view.gd` to build one centered preview sprite with metadata-driven `SpriteFrames` containing all animations.
- Added `play_animation(animation_name)` and generated animation buttons for ability/death/hit/idle/jump/run.
- Updated Slime asset view wiki docs.
- Validation: `210 tests, 210 passed, 0 failed`.

## [2026-05-12] feat | Import Rat enemy sprite metadata

- RED: added `tests/specs/enemy_sprite_rat_test.gd` for Rat metadata schema, catalog loading, actions, texture path resolution, and validation.
- Created `assets/enemies/Rat/rat.asset.json` with V1 sprite/action metadata.
- Registered `rat` in `EnemySpriteCatalog`.
- Updated asset catalog and enemy sprite metadata wiki docs.
- Validation: `213 tests, 213 passed, 0 failed`.

## [2026-05-12] feat | Add Rat to asset-view selector

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require an `EnemySelector`, Rat metadata loading, Rat switching, and selected-enemy animation button rebuilding.
- Added `EnemySpriteCatalog.enemy_ids()` and registered selector order.
- Refactored `assets/asset_view.gd` to show an `OptionButton` for Spiked Slime/Rat and rebuild the single-sprite preview when selection changes.
- Updated Slime asset viewer wiki docs.
- Validation: `214 tests, 214 passed, 0 failed`.

## [2026-05-12] fix | Center asset-view panel layout

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require full-rect `Center/Panel/Margin/VBox` and fixed centered panel sizing.
- Updated `assets/asset_view.gd` to use a root-level full-rect `CenterContainer` + `PanelContainer`, center the VBox content, and use larger panel margins.
- Updated Slime asset view wiki docs.
- Validation: `215 tests, 215 passed, 0 failed`.

## [2026-05-12] feat | Add all enemy sprite metadata types

- RED: added `tests/specs/enemy_sprite_catalog_all_test.gd` requiring catalog entries and validation for all imported enemy types.
- Added V1 metadata for Bat, Crab, Armored Golem, Golem, Pebble, and Skull.
- Registered all enemy IDs in `EnemySpriteCatalog.enemy_ids()` for asset-view selector use.
- Updated asset catalog and enemy sprite metadata wiki docs.
- Validation: `217 tests, 217 passed, 0 failed`.

## [2026-05-12] refactor | Make asset-view nodes editor-visible

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require saved scene nodes for `EnemySelector`, `PreviewArea/AnimatedSprite2D`, and `AnimationButtons` before runtime setup.
- Rebuilt `assets/asset-view.tscn` with editor-visible `Center/Panel/Margin/VBox` hierarchy and preview sprite node.
- Refactored `assets/asset_view.gd` to populate existing scene nodes instead of creating the whole UI dynamically.
- Updated enemy asset view wiki docs.
- Validation: `218 tests, 218 passed, 0 failed`.

## [2026-05-12] refactor | Convert asset-view to editor-visible enemy gallery

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require one saved `AnimatedSprite2D` per catalog enemy with direct `.tres` resource references.
- Rebuilt `assets/asset-view.tscn` as a scrollable gallery with `SlimeSprite`, `RatSprite`, `BatSprite`, `CrabSprite`, `ArmoredGolemSprite`, `GolemSprite`, `PebbleSprite`, and `SkullSprite`.
- Refactored `assets/asset_view.gd` so animation buttons target the selected gallery sprite instead of swapping one runtime preview node.
- Updated asset catalog and enemy asset view wiki docs.
- Validation: `220 tests, 220 passed, 0 failed`.

## [2026-05-12] refine | Show one asset-view sprite at a time

- RED: updated `tests/specs/slime_asset_viewer_test.gd` to require only the selected enemy preview to be visible while hidden enemy sprite nodes remain editor-selectable.
- Updated `assets/asset_view.gd` to toggle preview container visibility from `enemy_id`.
- Reduced `assets/asset-view.tscn` back to a compact single-preview panel while preserving all per-enemy `AnimatedSprite2D` nodes and `.tres` references.
- Updated asset catalog and enemy asset view wiki docs.
- Validation: `221 tests, 221 passed, 0 failed`.

## [2026-05-12] refactor | Split AssetView and AssetGallery

- RED: updated `tests/specs/slime_asset_viewer_test.gd` for `AssetView` root naming and focused single-preview behavior.
- RED: added `tests/specs/asset_gallery_test.gd` requiring `assets-gallery.tscn` to expose all enemy sprites, direct `.tres` references, and looping idle playback.
- Renamed `SlimeAssetView` script/root semantics to `AssetView`.
- Added `assets/assets-gallery.tscn` and `assets/asset_gallery.gd` as one root Control for all looping enemy sprite previews.
- Updated asset catalog, enemy asset tools wiki, wiki index, and enemy sprite metadata docs.
- Validation: `223 tests, 223 passed, 0 failed`.

## [2026-05-12] fix | Enforce Field collision for enemies

- RED: updated `tests/specs/field_scene_test.gd` to require enemy movement through `FieldCollision` and removal of the old visible ForestBlocker bar.
- Added Field controller collision checks for enemy movement and spawn placement against generated collision shapes.
- Removed `ForestBlocker` from `scenes/field.tscn`; the Forest Guard remains at the southeast road end and blockers come from `FieldCollision`.
- Updated Field scene wiki docs.
- Validation: `250 tests, 250 passed, 0 failed`; Godot MCP main-scene play reports no errors.

## [2026-05-12] refine | Import expanded Field map

- Imported the edited `D:\godot\kenney_tiny-town\field.tmj` into `scenes/maps/field_map.tscn` and `scenes/maps/field_collision.tscn`.
- Updated Tiny Town import collision generation so only layers beginning with `C-` produce blockers.
- Updated Field scene specs for the expanded `96x68` map, larger enemy spawn zone, and southeast Forest Guard/Gateway placement.
- Validation: Field scene specs `22 tests, 22 passed, 0 failed`. Full suite has an unrelated existing `EnemySpriteMetadataTest` asset-frame failure.

## [2026-05-12] fix | Reposition Field portals on expanded map

- Moved the Town gateway, default spawn, and player start to the current north road center at `Vector2(1552, 64)` / `Vector2(1552, 160)`.
- Centered the Forest gateway and Forest Guard on the southeast road at `Vector2(2768, 2112)` / `Vector2(2768, 2000)`.
- Validation: Field scene specs `22 tests, 22 passed, 0 failed`.

## [2026-05-12] docs | Refresh Field prototype tracker

- Updated `prototype/components/Field.md` to reflect the current imported Tiny Town Field implementation, expanded `96x68` map, `C-` render/collision layer rule, Slime/Bat/Rat runtime enemies, portal coordinates, and remaining open work.
- Documentation-only change; no runtime validation required.

## [2026-05-12] feat | Add game-wide enemy spawn system

- RED: added `tests/specs/enemy_spawn_system_test.gd` for biome max-active caps, defeated-slot timers, serialization, and autoload registration.
- Added pure `EnemySpawnSystem` and game-wide `EnemySpawnManager` autoload with 60 second respawn delay support and runtime persistence.
- Updated Field to register grassland enemy slots through `EnemySpawnManager`, spawn active slots only, and mark defeated slots globally.
- Updated Field docs and enemy spawn wiki docs.
- Validation: `EnemySpawnSystem` specs `5 tests, 5 passed`; Field scene specs `23 tests, 23 passed`.

## [2026-05-12] fix | Poll Field enemy respawns while loaded

- RED: added Field scene coverage for a defeated enemy respawning after the global 60 second timer while the player remains in Field.
- Added `_tick_enemy_spawns()` to poll `EnemySpawnManager` once per second and fill eligible missing slots up to the biome cap.
- Updated Field and enemy spawn docs.
- Validation: Field scene specs `24 tests, 24 passed`; EnemySpawnSystem specs `5 tests, 5 passed`.
