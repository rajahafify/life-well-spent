---
title: NpcDefinition
type: reference
tags: [architecture, resources, npc]
sources: [scripts/models/npc_definition.gd, tests/specs/npc_definition_test.gd, resources/npc_definitions]
---

# NpcDefinition

## Overview
Resource-backed data model for NPC role variants: quest giver, vendor, and facility.

## API
```gdscript
NpcDefinition.quest_giver(name, quest, cost, description, task_id = "")
NpcDefinition.vendor(name, dialog)
NpcDefinition.facility(name, id, title)
```

## Design Decisions
- NPC role data lives in resources so scene instances can stay reusable.
- `NpcController` applies a definition before wiring labels and interaction state.
- `life_task_id` links quest NPCs to real-life task completion.

## Test Coverage
- `tests/specs/npc_definition_test.gd`: role factories and controller application.

## Related
- [NPC System](npc-system.md)
- [Town Hub](../scenes/town-hub.md)
