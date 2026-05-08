"""
Composite LPC spritesheet layers into a single RGBA image.

Three sprite directory structures exist in the repo:
  A) {prefix}/walk.png               (body, legs, shoes, beard, most hair)
  B) {prefix}/fg/walk.png            (hair with fg/bg layers)
  C) {prefix}/walk/variant.png       (shadow, some weapons)
  D) {prefix}/attack_slash/file.png  (weapons — custom animation names)
"""

import json
from pathlib import Path
from typing import Any, Optional

from PIL import Image

from recolorer import recolor

ASSETS_DIR = Path(__file__).parent / "lpc-assets"
SHEET_DEFS = ASSETS_DIR / "sheet_definitions"
SPRITESHEETS = ASSETS_DIR / "spritesheets"

CANVAS_W = 832

LPC_ANIMATIONS = ["spellcast", "thrust", "walk", "slash", "shoot", "hurt"]

# Weapon custom animation → LPC animation name mapping
WEAPON_ANIM_MAP = {
    "slash": "attack_slash",
    "thrust": "attack_thrust",
}


def _find_def(layer_id: str) -> Optional[dict[str, Any]]:
    for json_file in SHEET_DEFS.rglob(f"{layer_id}.json"):
        if json_file.name.startswith("meta_"):
            continue
        try:
            return json.loads(json_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            pass
    return None


def _find_anim_png(sprite_dir: Path, anim: str) -> Optional[Path]:
    """Find the PNG for a given animation in a sprite directory (handles all structures)."""

    # Structure A: {dir}/{anim}.png
    p = sprite_dir / f"{anim}.png"
    if p.exists():
        return p

    # Structure B: {dir}/fg/{anim}.png  (hair fg layer)
    p = sprite_dir / "fg" / f"{anim}.png"
    if p.exists():
        return p

    # Structure C: {dir}/{anim}/{variant}.png
    anim_subdir = sprite_dir / anim
    if anim_subdir.is_dir():
        pngs = [f for f in anim_subdir.glob("*.png")]
        if pngs:
            return pngs[0]

    # Structure D: weapon custom names (slash → attack_slash, thrust → attack_thrust)
    if anim in WEAPON_ANIM_MAP:
        alt_subdir = sprite_dir / WEAPON_ANIM_MAP[anim]
        if alt_subdir.is_dir():
            pngs = [f for f in alt_subdir.glob("*.png") if "behind" not in f.name]
            if pngs:
                return pngs[0]

    return None


def _pad(img: Image.Image, target_h: Optional[int] = None) -> Image.Image:
    w = CANVAS_W
    h = target_h if target_h else img.height
    if img.size == (w, h):
        return img
    padded = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    padded.paste(img.convert("RGBA"), (0, 0))
    return padded


def composite(
    body_type: str,
    selections: dict[str, dict[str, Any]],
    catalog: dict[str, list[dict[str, Any]]],
) -> Image.Image:
    # Resolve selections → (zPos, label, sprite_dir, material, palette_variant)
    layers: list[tuple[int, str, Path, Optional[str], Optional[str]]] = []

    for category, sel in selections.items():
        layer_id = sel["id"]
        definition = _find_def(layer_id)
        if definition is None:
            print(f"  [warn] no definition for {category}/{layer_id}")
            continue

        layer_info = definition.get("layer_1", {})
        z_pos = layer_info.get("zPos", 50)
        path_prefix = layer_info.get(body_type) or layer_info.get("male")
        if not path_prefix:
            print(f"  [warn] no path for body_type='{body_type}' in {category}/{layer_id}")
            continue

        sprite_dir = SPRITESHEETS / path_prefix.strip("/")
        if not sprite_dir.exists():
            print(f"  [warn] sprite dir missing: {sprite_dir.relative_to(ASSETS_DIR)}")
            continue

        material = (definition.get("recolors") or {}).get("material")
        palette_variant = sel.get("palette_variant")
        layers.append((z_pos, f"{category}/{layer_id}", sprite_dir, material, palette_variant))

    layers.sort(key=lambda x: x[0])

    for z, label, sdir, _, _ in layers:
        print(f"  [z={z:3d}] {label}")

    # Composite per animation strip then stack vertically
    strips: list[Image.Image] = []

    for anim in LPC_ANIMATIONS:
        strip: Optional[Image.Image] = None

        for z_pos, label, sprite_dir, material, palette_variant in layers:
            anim_png = _find_anim_png(sprite_dir, anim)
            if anim_png is None:
                continue

            try:
                layer_img = Image.open(anim_png).convert("RGBA")
            except OSError:
                continue

            if material and palette_variant:
                layer_img = recolor(layer_img, material, palette_variant)

            if strip is None:
                strip = _pad(layer_img)
            else:
                layer_img = _pad(layer_img, strip.height)
                strip = Image.alpha_composite(strip, layer_img)

        if strip is not None:
            strips.append(strip)

    if not strips:
        return Image.new("RGBA", (CANVAS_W, 256), (0, 0, 0, 0))

    total_h = sum(s.height for s in strips)
    canvas = Image.new("RGBA", (CANVAS_W, total_h), (0, 0, 0, 0))
    y = 0
    for strip in strips:
        canvas.paste(strip, (0, y))
        y += strip.height

    return canvas
