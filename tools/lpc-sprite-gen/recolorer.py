"""Palette-swap recoloring using numpy — mirrors the LPC WebGL shader logic."""

import json
from pathlib import Path
from typing import Optional

import numpy as np
from PIL import Image

ASSETS_DIR = Path(__file__).parent / "lpc-assets"
PALETTE_DEFS = ASSETS_DIR / "palette_definitions"
TOLERANCE = 2  # per-channel tolerance (out of 255)


def _hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    h = hex_color.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def _load_palette(material: str, variant: str) -> Optional[list[tuple[int, int, int]]]:
    """Return list of 6 RGB tuples for the given material+variant, or None."""
    for palette_file in sorted(PALETTE_DEFS.rglob(f"{material}_*.json")):
        try:
            data = json.loads(palette_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue
        if variant in data:
            return [_hex_to_rgb(c) for c in data[variant]]
        # fuzzy match: accept if variant is a substring of any key
        for key in data:
            if variant.lower() in key.lower() or key.lower() in variant.lower():
                return [_hex_to_rgb(c) for c in data[key]]
    return None


def _get_base_palette(material: str) -> Optional[list[tuple[int, int, int]]]:
    """Return the default 'light' or 'base' palette for a material."""
    for default in ("light", "base", "beige", "brown"):
        result = _load_palette(material, default)
        if result:
            return result
    return None


def recolor(
    image: Image.Image, material: str, variant: str
) -> Image.Image:
    """Swap the base palette of `image` with the target variant palette."""
    source_palette = _get_base_palette(material)
    target_palette = _load_palette(material, variant)

    if source_palette is None or target_palette is None:
        return image  # no recolor data available, return as-is

    img = image.convert("RGBA")
    arr = np.array(img, dtype=np.int32)

    r, g, b, a = arr[..., 0], arr[..., 1], arr[..., 2], arr[..., 3]

    result = arr.copy()

    for src_rgb, tgt_rgb in zip(source_palette, target_palette):
        mask = (
            (np.abs(r - src_rgb[0]) <= TOLERANCE)
            & (np.abs(g - src_rgb[1]) <= TOLERANCE)
            & (np.abs(b - src_rgb[2]) <= TOLERANCE)
            & (a > 0)
        )
        result[mask, 0] = tgt_rgb[0]
        result[mask, 1] = tgt_rgb[1]
        result[mask, 2] = tgt_rgb[2]

    return Image.fromarray(result.astype(np.uint8), "RGBA")
