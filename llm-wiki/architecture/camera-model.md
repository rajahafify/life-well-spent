---
title: Camera Model
type: reference
tags: [architecture, models, camera]
---

# Camera Model

## Overview
Pure logic for smooth camera follow. Lerp to player pos outside deadzone. Clamp bounds. Fixed zoom.

## API
```gdscript
class_name CameraModel
extends Object

var position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var lerp_speed: float = 5.0
var deadzone: Rect2 = Rect2()
var bound_left/right/top/bottom: float = 0.0
var zoom_level: float = 1.0

func update(delta: float) -> void:
  if deadzone.has_point(target_position): return
  var factor = min(1.0, lerp_speed * delta)
  position = position.lerp(target_position, factor)
  _apply_bounds()
```

## Design Decisions
- Frame-rate indep lerp factor = speed * delta cap1.
- Default no deadzone/bounds.
- No Node refs. Inject to controller.

## Test Coverage
- tests/specs/camera_model_test.gd: lerp, deadzone skip, bounds clamp.

## Related
animation-controller.md, player-movement.md
