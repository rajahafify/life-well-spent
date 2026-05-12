---
title: Feedback Components
type: reference
updated: 2026-05-13
sources:
  - scripts/views/hit_feedback_component.gd
  - scripts/views/damage_text_component.gd
  - scripts/managers/feedback_system.gd
  - tests/specs/damage_text_component_test.gd
  - tests/specs/feedback_system_test.gd
  - tests/specs/field_scene_test.gd
tags: [architecture, ui, combat, feedback]
---

# Feedback Components

## Overview

Combat juice is implemented through reusable feedback components instead of embedding visual and audio details in combat logic. The Field controller still decides when a hit or drop happens, but reusable scene children own hit flash, floating damage numbers, and global SFX requests.

## API

```gdscript
# HitFeedbackComponent
func ensure_ready() -> void
func play_hit(damage: int = 1) -> void

# DamageTextComponent
func ensure_ready() -> void
func show_damage(value: int, damage_color: Color = Color.WHITE) -> void

# FeedbackSystem
func reset() -> void
func play_sfx(sfx_name: String, stream: AudioStream = null, bus_name: String = "SFX") -> AudioStreamPlayer
```

## Design Decisions

- `EnemyView` emits `hit_feedback_requested(damage)` and owns `HitFeedbackComponent` plus `DamageTextComponent` children.
- `HitFeedbackComponent` listens to the parent signal, flashes the parent `CanvasItem`, plays the hit animation, and delegates text to `DamageTextComponent`.
- `DamageTextComponent` owns floating damage text with small random offsets to avoid exact overlap. Numbers use a readable 36px default font size, travel horizontally away, and follow a parabolic rise/fall path closer to RO-style combat text.
- `FeedbackSystem` is a global boundary for SFX requests and can spawn independent audio players so sounds can outlive deleted source nodes.
- Enemy damage text is white. Player damage text is red.
- Combat math remains in `CombatSystem`; feedback components do not change HP, Life, XP, drops, or enemy behavior.

## Test Coverage

- `tests/specs/damage_text_component_test.gd` covers damage text color, readable font sizing for new and existing labels, and parabolic arc movement.
- `tests/specs/field_scene_test.gd` covers enemy hit component presence, hit flash, enemy/player damage text colors, camera shake, and loot toast.
- `tests/specs/feedback_system_test.gd` covers global SFX request recording.

## Related

- [Field Scene](../scenes/field.md)
- [CombatSystem](combat-system.md)
- [Enemy Behavior System](enemy-behavior-system.md)
