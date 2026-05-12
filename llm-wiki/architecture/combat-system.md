---
title: Combat System
type: reference
updated: 2026-05-13
tags: [architecture, models, combat]
---

# Combat System

## Overview

`CombatSystem` is pure Field combat logic. It changes enemy HP and player current Life. Life is the combat health resource; quests/progression reduce Max Life and therefore make later combat harder.

The current Field controller feeds `CombatSystem` with prototype readability tuning: player attack is 40 and Field enemy HP is 10x larger. Player Life and enemy attack damage to Player remain unchanged.

## API

```gdscript
func player_attack_enemy(player_stats: Dictionary, enemy_state: Dictionary) -> Dictionary
func enemy_attack_player(enemy_state: Dictionary, player_state: Dictionary) -> Dictionary
```

Results include damage, next state, defeat flags, and XP reward hook when enemy HP reaches zero. Player state uses `life` and `max_life`; current `life` must not exceed `max_life`.

## Design Decisions

Damage is `max(1, attack - defense)`. Defeated HP clamps to zero. Enemy attacks reduce current Life; quest/progression costs reduce Max Life outside combat. Healing may restore current Life only up to Max Life.

The 10x Field tuning lives in enemy definitions and the Field controller, not inside the pure damage formula.

## Test Coverage

- `tests/specs/combat_system_test.gd` covers player damage, enemy defeat XP, enemy counter damage to current Life, player defense with minimum 1 damage, defeat at Life 0, and clamping current Life to Max Life.

## Related

- `llm-wiki/architecture/enemy-definition.md`
- `llm-wiki/scenes/field.md`
