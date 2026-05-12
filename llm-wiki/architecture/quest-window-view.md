---
title: QuestWindowView
type: reference
updated: 2026-05-12
sources:
  - scripts/views/quest_window_view.gd
  - tests/specs/quest_window_view_test.gd
  - tests/specs/field_scene_test.gd
  - tests/specs/town_scene_dialog_test.gd
tags: [architecture, ui, quest]
---

# QuestWindowView

## Overview

`QuestWindowView` is a reusable top-right UI panel for the current quest objective. It is a dumb view: scenes pass in the quest title and objective text, and the view only owns labels and layout.

## API

```gdscript
func ensure_ready() -> void
func show_main_objective(quest_title: String, objective_text: String, checkpoint_text: String = "") -> void
```

## Design Decisions

- Anchored to the top-right viewport edge with right offset `-28`.
- Creates its own title and objective labels if a scene only provides the root `PanelContainer`.
- Uses autowrap for objective text so longer quest objectives stay inside the panel.
- Checkpoint text is intentionally not rendered; checkpoints are internal progression state.
- Controllers read from `QuestSystem`; the view does not.

## Test Coverage

- `tests/specs/quest_window_view_test.gd` covers label creation and display text.
- `tests/specs/field_scene_test.gd` covers Field integration and objective refresh after Forest Gateway progression.
- `tests/specs/town_scene_dialog_test.gd` covers Town integration.

## Related

- [QuestSystem](quest-system.md)
- [Field Scene](../scenes/field.md)
- [Town Scene](../scenes/town-hub.md)
