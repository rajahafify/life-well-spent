"""Save the composited sprite."""

from pathlib import Path

from PIL import Image


def export(image: Image.Image, out_path: str | Path) -> None:
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    image.save(out, format="PNG")
    print(f"Saved -> {out}")
