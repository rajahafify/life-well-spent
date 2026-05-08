# LPC Sprite Generator — Workflow

A tool for AI-assisted generation of LPC-format character spritesheets.
The AI picks layers and calls the script directly — no web UI needed.

## Setup (one-time)

```bash
cd tools/lpc-sprite-gen
pip install -r requirements.txt
python setup.py        # sparse-clones ~500MB of LPC assets into lpc-assets/
```

## How to Use (as an AI agent)

### 1. Browse the catalog

```bash
python generate.py catalog
```

Returns every available layer ID grouped by category. Read this before picking selections.

### 2. Generate a sprite

```bash
python generate.py make '<json>' --out output/<name>.png
```

The JSON config shape:
```json
{
  "body_type": "male",
  "selections": {
    "<category>": { "id": "<layer_id>", "palette_variant": "<color>" }
  }
}
```

- `body_type`: `male` | `female` | `muscular` | `teen` | `child` | `pregnant`
- `selections`: one entry per category you want included. Omit categories you don't need.
- `palette_variant`: optional. A color name (e.g. `"auburn"`, `"brown"`, `"blonde"`) for recolorable layers (hair, skin, clothing). Only applies to layers that have a `recolors.material` in their definition.

### Example

```bash
python generate.py make '{"body_type": "female", "selections": {"shadow": {"id": "shadow"}, "body": {"id": "body"}, "head": {"id": "heads_human_female"}, "hair": {"id": "hair_long", "palette_variant": "blonde"}, "clothes": {"id": "torso_clothes_robe"}, "legs": {"id": "legs_skirts_plain"}, "shoes": {"id": "feet_boots_basic"}, "weapon": {"id": "weapon_magic_wand"}}}' --out output/mage.png
```

## Output

- PNG at the specified path — 832px wide, LPC universal format (spellcast / thrust / walk / slash / shoot / hurt rows)
- Ready to import into Godot with the [LPCAnimatedSprite2D](https://github.com/alextrevisan/LPCAnimatedSprite2D) plugin

## Recommended Selections for Common Archetypes

| Archetype | body_type | key categories |
|-----------|-----------|----------------|
| Warrior | male/muscular | body, head, armour, legs, shoes, weapon (sword), shield |
| Mage | female | body, head, clothes (robe), legs, shoes, weapon (staff/wand), hat (wizard) |
| Rogue | teen | body, head, clothes, legs, shoes, weapon (dagger), cape |
| Orc | male | body, head (orc), armour, weapon (axe/mace) |
| Child NPC | child | body, head (human_child), clothes, legs, shoes |

## Notes

- Always include `shadow` and `body` in every character
- `head` defaults to human if omitted — include it explicitly for fantasy races
- Weapons are composited as a separate layer; they appear floating in the sheet — this is correct LPC format
- `output/` and `lpc-assets/` are gitignored — generated sprites live outside version control
