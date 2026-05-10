# Camera Controller Implementation Plan

**Status:** Draft — awaiting approval before any code or spec written.

**Goal:** Add a 2D camera that smoothly follows the player character in the town hub (and future scenes). Camera stays centered on player with optional deadzone, limits, and zoom.

## Why
- Current town scene has no Camera2D — view is static 1280×720.
- Player can move off-screen; no way to explore larger maps.
- Future: larger world maps, smooth follow, zoom on events.

## Requirements (Acceptance Criteria)
1. Camera follows player position every physics frame (smooth lerp or spring).
2. Camera2D node is `current = true` so it renders the viewport.
3. Optional deadzone (player moves inside rectangle before camera pans).
4. Optional camera limits (left/right/top/bottom) to prevent showing out-of-bounds.
5. Zoom level controllable (default 1.0, can zoom out for overview).
6. Works in town_scene.tscn; reusable for other 2D scenes.
7. No performance hit — uses `_physics_process` or `RemoteTransform2D`.
8. All public behavior covered by executable spec (RED first).

## Architecture Decision
**Option A (Recommended):** Camera2D as direct child of Player CharacterBody2D in player.tscn.
- Pros: automatic follow (no script needed for basic), position inherits from body.
- Cons: limits/deadzone/zoom require script anyway; less flexible for cutscenes.

**Option B (Chosen):** Dedicated `CameraController` script (extends Camera2D) attached to a standalone Camera2D node in the scene.
- Controller in `scripts/controllers/camera_controller.gd`.
- Exposes `@export` for target (Player), lerp_speed, deadzone, limits, zoom.
- In `_physics_process`: lerp position toward target position.
- Keeps camera decoupled from player scene (easier to swap targets or disable).
- Follows MVC: CameraController is thin glue (controller layer).

**Why B?**
- SOLID: camera logic isolated.
- Reusable across scenes without modifying player.tscn.
- Future: cutscene targets, shake, room transitions.
- Matches existing pattern (TownSceneController, MainMenuController).

## Files to Create / Modify
- `plans/camera-controller.md` — this plan (current).
- `scripts/controllers/camera_controller.gd` — new controller script (after spec approved).
- `tests/specs/camera_controller_test.gd` — new executable spec (RED first).
- `scenes/town_scene.tscn` — add Camera2D child to TownScene root + attach script.
- `llm-wiki/architecture/camera-controller.md` — new wiki page (after GREEN).
- Update `docs/STATUS.md` — add to Current State + TODO.
- Update `llm-wiki/log.md` + `llm-wiki/index.md`.

## TDD Workflow (Non-Negotiable)
1. **RED** — Write failing spec `tests/specs/camera_controller_test.gd` first.
   - `test_follows_player_position`
   - `test_lerp_speed_affects_follow`
   - `test_deadzone_keeps_camera_still_inside_zone`
   - `test_limits_clamp_camera_position`
   - `test_zoom_level_applied`
   - `test_no_target_does_nothing`
2. **GREEN** — Minimal implementation in `camera_controller.gd` to pass spec.
3. **REFACTOR** — Clean code, add edge cases, ensure 74+ tests still pass.
4. Only then edit scenes and update wiki.

## Spec Outline (tests/specs/camera_controller_test.gd)
```gdscript
class_name TestCameraController
extends TestCase

var camera: CameraController
var mock_player: CharacterBody2D

func setup():
    mock_player = CharacterBody2D.new()
    camera = CameraController.new()
    camera.target = mock_player
    # ...

func test_follows_player_position():
    mock_player.position = Vector2(300, 200)
    camera._physics_process(0.016)
    assert_eq(300, camera.position.x)  # or within lerp tolerance

func test_deadzone():
    # move player inside deadzone rect → camera should not move
    ...

# ... more behaviors
```

## Implementation Steps (Post-Approval)
1. Create `scripts/controllers/camera_controller.gd` skeleton (extends Camera2D).
2. Add exports: `target: NodePath`, `lerp_speed: float = 5.0`, `deadzone_rect: Rect2`, `limit_left/right/top/bottom: int`, `zoom_level: float = 1.0`.
3. In `_ready()`: make current, resolve target NodePath to node.
4. In `_physics_process(delta)`: if target, compute desired pos, lerp, apply limits, set zoom.
5. Write + run spec until GREEN.
6. Add Camera2D to `town_scene.tscn` (position 0,0 or offset).
7. Attach script, set target = ^"Player", configure limits/deadzone.
8. Test in editor + headless run.
9. Update wiki + STATUS + log.
10. Commit with message referencing the spec file.

## Design Details
- **Follow algorithm:** `position = position.lerp(target.position, lerp_speed * delta)` (frame-rate independent).
- **Deadzone:** if player pos inside camera-relative deadzone rect, skip lerp.
- **Limits:** `clamp(desired_x, limit_left, limit_right)` etc. before assign.
- **Zoom:** `zoom = Vector2(zoom_level, zoom_level)`.
- **Performance:** no every-frame node lookup; cache target in _ready.
- **Edge cases:** target freed, no target set, scene reload, multiple cameras (only one current).

## Related
- `TownSceneController` — will not own camera (single responsibility).
- Future: `CameraShake` addon or tween for impact.
- `Player` (CharacterBody2D) — the follow target.

**Approval checklist:**
- [ ] Acceptance criteria clear and testable.
- [ ] Architecture choice justified.
- [ ] TDD steps defined.
- [ ] No code written yet.

Once approved: start with RED spec.