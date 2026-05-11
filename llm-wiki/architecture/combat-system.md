---
title: Combat System
type: reference
updated: 2026-05-11
tags: [architecture, models, combat]
---

# Combat System

## Overview

`CombatSystem` is pure Field combat logic. It changes enemy HP and player Combat HP only; player Life is preserved.

## API

```gdscript
func player_attack_enemy(player_stats: Dictionary, enemy_state: Dictionary) -> Dictionary
func enemy_attack_player(enemy_state: Dictionary, player_state: Dictionary) -> Dictionary
```

Results include damage, next state, defeat flags, and XP reward hook when enemy HP reaches zero.

## Design Decisions

Damage is `max(1, attack - defense)`. Defeated HP clamps to zero. Field combat never spends or damages Life.

## Test Coverage

- `tests/specs/combat_system_test.gd` covers player damage, enemy defeat XP, enemy counter damage, combat-down, and Life preservation.

## Related

- `llm-wiki/architecture/enemy-definition.md`
- `llm-wiki/scenes/field.md`
