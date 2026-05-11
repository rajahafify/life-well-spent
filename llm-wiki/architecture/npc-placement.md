---
title: NPC Placement
type: reference
updated: 2026-05-11
tags: [architecture, models, npc]
---

# NPC Placement

## Overview

`NpcPlacement` stores stable NPC map placement data. Field MVP uses it for Forest Guard.

## API

```gdscript
var character_id: String
var map_id: String
var position: Vector2
var dialog_id: String
var sprite_id: String
var blocks_gateway_id: String

func matches_map(candidate_map_id: String) -> bool
static func forest_guard()
```

## Design Decisions

Forest Guard placement links NPC identity to the locked `field_to_forest_locked` gateway.

## Test Coverage

- `tests/specs/npc_placement_test.gd` covers Forest Guard placement fields and map matching.

## Related

- `llm-wiki/architecture/npc-system.md`
- `llm-wiki/scenes/field.md`
