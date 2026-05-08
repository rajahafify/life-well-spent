"""Parse sheet_definitions/ into a structured catalog for LLM consumption."""

import json
from pathlib import Path
from typing import Any

ASSETS_DIR = Path(__file__).parent / "lpc-assets"
SHEET_DEFS = ASSETS_DIR / "sheet_definitions"


def _load_definitions() -> dict[str, list[dict[str, Any]]]:
    catalog: dict[str, list[dict[str, Any]]] = {}

    for json_file in sorted(SHEET_DEFS.rglob("*.json")):
        if json_file.name.startswith("meta_"):
            continue

        try:
            data = json.loads(json_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue

        type_name = data.get("type_name") or json_file.parent.parent.name
        if not type_name:
            continue

        layer = data.get("layer_1") or {}
        entry = {
            "id": json_file.stem,
            "name": data.get("name", json_file.stem),
            "zPos": layer.get("zPos", 0),
            "body_types": [k for k in layer if k != "zPos"],
            "recolor_material": (data.get("recolors") or {}).get("material"),
            "path_prefix": next(
                (v for k, v in layer.items() if k not in ("zPos",)), None
            ),
            "credits": data.get("credits", []),
        }
        catalog.setdefault(type_name, []).append(entry)

    return catalog


def load_catalog() -> dict[str, list[dict[str, Any]]]:
    return _load_definitions()


def catalog_summary(catalog: dict[str, list[dict[str, Any]]]) -> str:
    """Compact text representation for the LLM system prompt."""
    lines = ["Available LPC sprite layers (category: [id, ...]):\n"]
    for category, options in sorted(catalog.items()):
        ids = [o["id"] for o in options]
        lines.append(f"  {category}: {ids}")
    return "\n".join(lines)
