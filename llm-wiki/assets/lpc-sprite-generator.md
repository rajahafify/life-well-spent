---
title: LPC Sprite Generator
type: reference
updated: 2026-05-09
tags: [assets, tech]
---

# LPC Sprite Generator

## What it is

A local Python tool that composites [Universal LPC Spritesheet](https://github.com/liberatedpixelcup/Universal-LPC-Spritesheet-Character-Generator) assets into character spritesheets from a structured config. Used as an asset pipeline tool — not at runtime.

The AI agent picks layers from the catalog and calls the script directly. No web UI, no second AI call.

## Location

```
tools/lpc-sprite-gen/
  generate.py            — entry point (catalog + make commands)
  setup.py               — one-time asset clone
  catalog.py             — parses sheet_definitions/ into a layer menu
  compositor.py          — stacks PNGs by zPos per animation strip
  recolorer.py           — numpy palette swap (mirrors LPC WebGL shader)
  exporter.py            — saves PNG output
  spritegen.workflow.md  — full usage guide
  lpc-assets/            — cloned LPC repo (gitignored, ~500MB)
  output/                — generated PNGs (gitignored)
```

## Output format

832×variable px RGBA PNG in standard LPC universal format:

| Row block | Animation | Directions | Frames |
|-----------|-----------|------------|--------|
| 0–3 | spellcast | 4 | 7 |
| 4–7 | thrust | 4 | 8 |
| 8–11 | walk | 4 | 9 |
| 12–15 | slash | 4 | 6 |
| 16–19 | shoot | 4 | 13 |
| 20 | hurt | 1 | 6 |

Compatible with the Godot [LPCAnimatedSprite2D](https://github.com/alextrevisan/LPCAnimatedSprite2D) plugin (Asset Library #2212), which auto-generates `AnimationPlayer` tracks from this format.

## Asset source

- **Repo:** [LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator](https://github.com/liberatedpixelcup/Universal-LPC-Spritesheet-Character-Generator)
- **License:** Art is CC0 / CC-BY-SA / CC-BY / OGA-BY / GPL depending on asset. Attribution required for non-CC0. See `CREDITS.csv` in the LPC repo.
- **Generator tool itself:** GPL-3.0

## Layer categories (key ones)

| Category | Examples |
|----------|---------|
| `body` | human, skeleton, zombie |
| `head` | human, orc, goblin, lizard, minotaur, vampire, wolf |
| `hair` | 90+ styles (wavy, braids, afro, bob, pixie, ponytail…) |
| `beard` / `mustache` | trimmed, full, handlebar, walrus |
| `armour` | leather, plate, legion |
| `clothes` | tunics, robes, shirts, formal |
| `legs` | pants, skirts, hose, armour |
| `shoes` | boots, sandals, armour |
| `weapon` | swords, axes, staves, bows, daggers, wands |
| `shield` | heater, round, kite, spartan |
| `hat` | helmets, wizard, tricorne, hood, crown |
| `cape` | solid, tattered |
| `wings` | feathered, bat, pixie, lunar |
| `ears` | elven, dragon, cat, wolf |

Full catalog: `python generate.py catalog`

## Genre coverage

| Genre | Support |
|-------|---------|
| Fantasy | Excellent |
| Medieval / Historical | Excellent (LPC's sweet spot) |
| Modern | Partial (casual clothes, no guns) |
| Sci-Fi | Minimal (jetpack only) |

## Usage

See [spritegen.workflow.md](../../tools/lpc-sprite-gen/spritegen.workflow.md) and [AGENTS.md](../../AGENTS.md#sprite-generation) for full instructions.
