---
title: Forest Scene
type: reference
updated: 2026-05-13
tags: [scenes, forest, prototype]
sources: [scenes/forest.tscn, scripts/controllers/forest.gd, tests/specs/forest_scene_test.gd]
---

# Forest Scene

## Overview

`scenes/forest.tscn` is the current Forest endpoint after Swordsman Guild certification. It proves the certified Field gateway can enter a new scene while deeper Forest combat remains future work.

## Scene Structure

```text
Forest (Node2D, Forest)
- Ground
- Path
- Player
- FieldGateway
- Camera2D
- UI (shared_hud.tscn)
  - EndpointPanel
```

## Behavior

- Field transitions here after `swordsman_certification`.
- The endpoint panel explains that the path is open and more Forest content comes next.
- The FieldGateway returns to `res://scenes/field.tscn`.
- The shared HUD shows `Explore the World / Enter the Forest.`.

## Test Coverage

- `tests/specs/forest_scene_test.gd` covers scene load, endpoint copy, and return gateway transition.

## Related

- [Field Scene](field.md)
- [Quest System](../architecture/quest-system.md)
