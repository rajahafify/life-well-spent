---
title: Gateway Definition
type: reference
updated: 2026-05-11
tags: [architecture, models, prototype]
---

# Gateway Definition

## Overview

`GatewayDefinition` is pure gateway data/rules for map transfer and locked routes. Field prototype uses direct open gateways for Town ↔ Field and a locked Field → Forest route.

## API

```gdscript
var gateway_id: String
var source_map: String
var target_map: String
var target_scene_path: String
var target_spawn_id: String
var is_locked: bool
var unlock_conditions: Dictionary
var blocked_dialog_id: String

func can_transfer(state: Dictionary = {}) -> bool
func transfer_target(state: Dictionary = {}) -> Dictionary
static func town_to_field()
static func field_to_town()
static func field_to_forest_locked()
```

## Design Decisions

Open gateways transfer immediately. Locked gateways return no transfer target and expose blocker dialog data.

## Test Coverage

- `tests/specs/gateway_system_test.gd` covers open transfer targets, locked blocking, and unlock conditions.

## Related

- `prototype/game-systems.md`
- `llm-wiki/scenes/field.md`
