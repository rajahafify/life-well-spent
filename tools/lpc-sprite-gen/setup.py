"""One-time setup: sparse-clone LPC assets into lpc-assets/."""

import subprocess
import sys
from pathlib import Path

REPO_URL = "https://github.com/liberatedpixelcup/Universal-LPC-Spritesheet-Character-Generator.git"
ASSETS_DIR = Path(__file__).parent / "lpc-assets"
SPARSE_DIRS = ["sheet_definitions", "spritesheets", "palette_definitions"]


def run(cmd: list[str], **kwargs) -> None:
    result = subprocess.run(cmd, check=True, **kwargs)
    return result


def main() -> None:
    if ASSETS_DIR.exists() and (ASSETS_DIR / "sheet_definitions").exists():
        print("lpc-assets/ already present. Delete it to re-clone.")
        return

    print(f"Cloning (sparse) into {ASSETS_DIR} ...")
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    run(["git", "init"], cwd=ASSETS_DIR)
    run(["git", "remote", "add", "origin", REPO_URL], cwd=ASSETS_DIR)
    run(["git", "config", "core.sparseCheckout", "true"], cwd=ASSETS_DIR)

    sparse_file = ASSETS_DIR / ".git" / "info" / "sparse-checkout"
    sparse_file.write_text("\n".join(SPARSE_DIRS) + "\n")

    print("Fetching (this may take a few minutes) ...")
    run(["git", "fetch", "--depth=1", "origin", "master"], cwd=ASSETS_DIR)
    run(["git", "checkout", "master"], cwd=ASSETS_DIR)

    print("Done. Assets ready in lpc-assets/")


if __name__ == "__main__":
    main()
