"""
LPC sprite compositor. Claude calls this directly with explicit layer selections.

Usage:
    # List available options per category
    python generate.py catalog

    # Generate a sprite from a JSON config
    python generate.py make '{"body_type": "female", "selections": {"hair": {"id": "bob", "palette_variant": "auburn"}, "torso": {"id": "dress_white"}}}' --out output/warrior.png
"""

import argparse
import json
import sys
from pathlib import Path

from catalog import catalog_summary, load_catalog
from compositor import composite
from exporter import export

OUTPUT_DIR = Path(__file__).parent / "output"


def cmd_catalog(_args) -> None:
    catalog = load_catalog()
    print(catalog_summary(catalog))


def cmd_make(args) -> None:
    try:
        config = json.loads(args.config)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON config: {e}")
        sys.exit(1)

    body_type = config.get("body_type", "male")
    selections = config.get("selections", {})

    if not selections:
        print("No selections provided.")
        sys.exit(1)

    catalog = load_catalog()

    print(f"Body type : {body_type}")
    print(f"Selections: {json.dumps(selections, indent=2)}\n")
    print("Compositing ...")

    image = composite(body_type, selections, catalog)

    out_path = Path(args.out) if args.out else OUTPUT_DIR / f"{body_type}_sprite.png"
    export(image, out_path)


def main() -> None:
    assets_dir = Path(__file__).parent / "lpc-assets"
    if not (assets_dir / "sheet_definitions").exists():
        print("Assets not found. Run: python setup.py")
        sys.exit(1)

    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd")

    sub.add_parser("catalog", help="List available layer options")

    p_make = sub.add_parser("make", help="Generate a sprite")
    p_make.add_argument("config", help='JSON config: {"body_type": ..., "selections": {...}}')
    p_make.add_argument("--out", default=None, help="Output PNG path")

    args = parser.parse_args()

    if args.cmd == "catalog":
        cmd_catalog(args)
    elif args.cmd == "make":
        cmd_make(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
