---
title: Architecture — MVC + SOLID
type: decision
updated: 2026-05-08
sources:
  - AGENTS.md
tags: [architecture]
---

# Architecture — MVC + SOLID

## Decision
Use a Rails-style MVC pattern with SOLID principles. Godot's scene tree is the View; logic is split into pure Models and thin Controllers.

## Structure

```
scripts/
├── controllers/   # Thin glue — input → model calls → view updates
├── models/        # Pure business logic — no Node refs, no Godot APIs
├── views/         # Dumb UI — reads model state, no business logic
└── managers/      # Cross-cutting systems (Save, Audio, Input)
```

## SOLID Rules

| Principle | Rule |
|-----------|------|
| **SRP** | One responsibility per script. Model doesn't draw. View doesn't calculate. |
| **OCP** | Use `Resource` subtypes for quests, enemies, items. |
| **LSP** | Subclasses must not break contracts. |
| **ISP** | Small interfaces — split if a class only needs one piece. |
| **DIP** | Depend on abstractions. `CombatSystem` takes `IDamageProvider`, not `Player`. |

## Example: Quest Flow

```
[Scene] QuestGiver (Node)
  └── QuestUI.gd (View)    → reads QuestModel.state
  └── QuestController.gd   → accepts() → QuestModel.accept_quest()
                              → QuestModel.complete_quest() → emits "quest_completed"
  └── QuestModel.gd (Model) → deducts MaxHP, updates state, emits signal
```

## Rationale
- Keeps models testable outside Godot.
- Views stay dumb and composable.
- Controllers are thin, making bugs easy to trace.
- Resources replace enums for quests/enemies — open for extension without touching callers.
