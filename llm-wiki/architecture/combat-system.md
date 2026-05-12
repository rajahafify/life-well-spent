---
title: Combat System
type: reference
updated: 2026-05-12
tags: [architecture, models, combat]
---

# Combat System

## Overview

`CombatSystem` is pure Field combat logic. It changes enemy HP and player current Life. Life is the combat health resource; quests/progression reduce Max Life and therefore make later combat harder.

## API

```gdscript
func player_attack_enemy(player_stats: Dictionary, enemy_state: Dictionary) -> Dictionary
func enemy_attack_player(enemy_state: Dictionary, player_state: Dictionary) -> Dictionary
```

Results include damage, next state, defeat flags, and XP reward hook when enemy HP reaches zero. Player state uses `life` and `max_life`; current `life` must not exceed `max_life`.

## Design Decisions

Damage is `max(1, attack - defense)`. Defeated HP clamps to zero. Enemy attacks reduce current Life; quest/progression costs reduce Max Life outside combat. Healing may restore current Life only up to Max Life.

## Test Coverage

- `tests/specs/combat_system_test.gd` should cover player damage, enemy defeat XP, enemy counter damage to current Life, defeat at Life 0, and clamping current Life to Max Life.

## Related

- `llm-wiki/architecture/enemy-definition.md`
- `llm-wiki/scenes/field.md`
