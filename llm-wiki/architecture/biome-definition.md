---
title: Biome Definition
type: reference
updated: 2026-05-12
tags: [architecture, models, biome]
---

# Biome Definition

## Overview

`BiomeDefinition` defines map visual palette, enemy pool, props, and ambience tags.

## API

```gdscript
var biome_type: String
var palette: Dictionary
var enemy_pool: Array
var prop_pool: Array
var music_id: String
var ambient_tags: Array

func allows_enemy(enemy_id: String) -> bool
static func field_grassland()
```

## Design Decisions

Field is `grassland`: bright grass, dirt paths, Slime/Bat/Rat enemy pool (`slime_spiked`, `bat`, `rat`), rocks/bushes/grass props.

## Test Coverage

- `tests/specs/biome_system_test.gd` covers Field palette, enemy pool, prop pool, and enemy filtering.

## Related

- `prototype/game-systems.md`
- `llm-wiki/scenes/field.md`
