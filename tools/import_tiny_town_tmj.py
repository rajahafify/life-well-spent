#!/usr/bin/env python3
"""Import a layered Tiny Town TMJ as a native Godot visual scene.

The generated scene is visual-only. Gameplay nodes such as Player, NPCs,
gateways, spawn points, and collision remain owned by town_scene.tscn.
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path


DEFAULT_TMJ = Path(r"D:\godot\kenney_tiny-town\town_layout_build_32.tmj")
DEFAULT_TILESET = Path(r"D:\godot\kenney_tiny-town\Tilemap\tilemap_packed_2x.png")
DEFAULT_PROJECT = Path(__file__).resolve().parents[1]
MAP_SCENE_REL = Path("scenes/maps/town_map.tscn")
COLLISION_SCENE_REL = Path("scenes/maps/town_collision.tscn")
TILESET_REL = Path("assets/tiny_town/tilemap_packed_2x.png")
TOWN_SCENE_REL = Path("scenes/town_scene.tscn")
LAYER_NAMES = ["Ground", "Paths", "Fences", "Houses", "Castle", "Trees", "Bushes", "Props"]
SOLID_LAYER_NAMES = ["Fences", "Houses", "Castle", "Trees", "Bushes", "Props"]


def res_path(path: Path) -> str:
	return "res://" + path.as_posix()


def tscn_string(value: str) -> str:
	return json.dumps(value)


def load_tmj(path: Path) -> dict:
	with path.open("r", encoding="utf-8") as handle:
		return json.load(handle)


def copy_tileset(source: Path, project_root: Path) -> Path:
	target = project_root / TILESET_REL
	target.parent.mkdir(parents=True, exist_ok=True)
	shutil.copy2(source, target)
	return target


def tile_region(gid: int, columns: int, tile_width: int, tile_height: int) -> tuple[int, int, int, int]:
	tile_id = gid - 1
	atlas_x = tile_id % columns
	atlas_y = tile_id // columns
	return atlas_x * tile_width, atlas_y * tile_height, tile_width, tile_height


def generate_map_scene(tmj: dict, output_path: Path) -> None:
	tile_width = int(tmj["tilewidth"])
	tile_height = int(tmj["tileheight"])
	tilesets = tmj.get("tilesets", [])
	if len(tilesets) != 1:
		raise ValueError("Expected one Tiny Town tileset")
	columns = int(tilesets[0]["columns"])
	first_gid = int(tilesets[0].get("firstgid", 1))
	if first_gid != 1:
		raise ValueError("Expected Tiny Town firstgid to be 1")

	lines: list[str] = [
		"[gd_scene load_steps=2 format=3]",
		"",
		f"[ext_resource type=\"Texture2D\" path={tscn_string(res_path(TILESET_REL))} id=\"1_tiles\"]",
		"",
		"[node name=\"TownMap\" type=\"Node2D\"]",
	]

	for layer in tmj.get("layers", []):
		name = layer.get("name", "")
		if layer.get("type") != "tilelayer" or name not in LAYER_NAMES:
			continue
		width = int(layer["width"])
		data = layer["data"]
		lines.extend(["", f"[node name={tscn_string(name)} type=\"Node2D\" parent=\".\"]"])
		for index, gid in enumerate(data):
			gid = int(gid)
			if gid <= 0:
				continue
			map_x = index % width
			map_y = index // width
			region_x, region_y, region_w, region_h = tile_region(gid, columns, tile_width, tile_height)
			node_name = f"{name}_Tile_{map_x}_{map_y}"
			lines.extend(
				[
					"",
					f"[node name={tscn_string(node_name)} type=\"Sprite2D\" parent={tscn_string(name)}]",
					"texture = ExtResource(\"1_tiles\")",
					"centered = false",
					"region_enabled = true",
					f"region_rect = Rect2({region_x}, {region_y}, {region_w}, {region_h})",
					f"position = Vector2({map_x * tile_width}, {map_y * tile_height})",
				]
			)

	output_path.parent.mkdir(parents=True, exist_ok=True)
	output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def solid_tile_mask(tmj: dict) -> set[tuple[int, int]]:
	solid: set[tuple[int, int]] = set()
	for layer in tmj.get("layers", []):
		if layer.get("type") != "tilelayer" or layer.get("name", "") not in SOLID_LAYER_NAMES:
			continue
		width = int(layer["width"])
		for index, gid in enumerate(layer["data"]):
			if int(gid) > 0:
				solid.add((index % width, index // width))
	return solid


def merge_tiles_to_rects(solid: set[tuple[int, int]], width: int, height: int) -> list[tuple[int, int, int, int]]:
	remaining = set(solid)
	rects: list[tuple[int, int, int, int]] = []
	for y in range(height):
		for x in range(width):
			if (x, y) not in remaining:
				continue
			rect_width = 1
			while (x + rect_width, y) in remaining:
				rect_width += 1
			rect_height = 1
			while True:
				next_y = y + rect_height
				if any((x + dx, next_y) not in remaining for dx in range(rect_width)):
					break
				rect_height += 1
			for dy in range(rect_height):
				for dx in range(rect_width):
					remaining.remove((x + dx, y + dy))
			rects.append((x, y, rect_width, rect_height))
	return rects


def generate_collision_scene(tmj: dict, output_path: Path) -> None:
	tile_width = int(tmj["tilewidth"])
	tile_height = int(tmj["tileheight"])
	width = int(tmj["width"])
	height = int(tmj["height"])
	rects = merge_tiles_to_rects(solid_tile_mask(tmj), width, height)

	lines: list[str] = [
		f"[gd_scene load_steps={len(rects) + 1} format=3]",
		"",
	]

	for index, (x, y, rect_width, rect_height) in enumerate(rects, 1):
		size_x = rect_width * tile_width
		size_y = rect_height * tile_height
		shape_id = f"RectangleShape2D_{index}"
		lines.extend(
			[
				f"[sub_resource type=\"RectangleShape2D\" id=\"{shape_id}\"]",
				f"size = Vector2({size_x:g}, {size_y:g})",
				"",
			]
		)

	lines.append("[node name=\"TownCollision\" type=\"Node2D\"]")

	for index, (x, y, rect_width, rect_height) in enumerate(rects, 1):
		size_x = rect_width * tile_width
		size_y = rect_height * tile_height
		pos_x = x * tile_width + size_x / 2.0
		pos_y = y * tile_height + size_y / 2.0
		shape_id = f"RectangleShape2D_{index}"
		lines.extend(
			[
				"",
				f"[node name=\"Blocker_{index}\" type=\"StaticBody2D\" parent=\".\"]",
				f"position = Vector2({pos_x:g}, {pos_y:g})",
				"",
				f"[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"Blocker_{index}\"]",
				f"shape = SubResource(\"{shape_id}\")",
			]
		)

	output_path.parent.mkdir(parents=True, exist_ok=True)
	output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def next_ext_resource_id(scene_text: str, suffix: str) -> str:
	index = 1
	while f'id="{index}_{suffix}"' in scene_text:
		index += 1
	return f"{index}_{suffix}"


def update_town_scene(project_root: Path, position: str, scale: str) -> None:
	town_scene_path = project_root / TOWN_SCENE_REL
	scene_text = town_scene_path.read_text(encoding="utf-8")
	map_res = res_path(MAP_SCENE_REL)
	collision_res = res_path(COLLISION_SCENE_REL)

	def add_ext_resource(text: str, resource_path: str, suffix: str) -> tuple[str, str]:
		if resource_path in text:
			start = text.find(f"path={tscn_string(resource_path)}")
			line_start = text.rfind("[ext_resource", 0, start)
			line_end = text.find("\n", start)
			line = text[line_start:line_end]
			id_start = line.find("id=\"") + 4
			id_end = line.find("\"", id_start)
			return text, line[id_start:id_end]
		ext_id = next_ext_resource_id(text, suffix)
		ext_line = f"[ext_resource type=\"PackedScene\" path={tscn_string(resource_path)} id=\"{ext_id}\"]\n"
		last_ext = text.rfind("[ext_resource")
		if last_ext == -1:
			raise ValueError("Could not find ext_resource section in town_scene.tscn")
		insert_after = text.find("\n", last_ext) + 1
		return text[:insert_after] + ext_line + text[insert_after:], ext_id

	scene_text, map_ext_id = add_ext_resource(scene_text, map_res, "town_map")
	scene_text, collision_ext_id = add_ext_resource(scene_text, collision_res, "town_collision")

	insert_at = scene_text.find("[node name=\"SpawnPoints\" type=\"Node2D\" parent=\".\"]")
	if insert_at == -1:
		raise ValueError("Could not find SpawnPoints insertion point in town_scene.tscn")

	node_blocks: list[str] = []
	if "[node name=\"TownMap\"" not in scene_text:
		node_blocks.append(
			f"[node name=\"TownMap\" parent=\".\" instance=ExtResource(\"{map_ext_id}\")]\n"
			f"position = Vector2({position})\n"
			f"scale = Vector2({scale})\n"
		)
	if "[node name=\"TownCollision\"" not in scene_text:
		node_blocks.append(
			f"[node name=\"TownCollision\" parent=\".\" instance=ExtResource(\"{collision_ext_id}\")]\n"
			f"position = Vector2({position})\n"
			f"scale = Vector2({scale})\n"
		)
	if node_blocks:
		scene_text = scene_text[:insert_at] + "\n" + "\n".join(node_blocks) + "\n" + scene_text[insert_at:]
	town_scene_path.write_text(scene_text, encoding="utf-8")


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(description="Import Tiny Town TMJ into this Godot project.")
	parser.add_argument("--tmj", type=Path, default=DEFAULT_TMJ)
	parser.add_argument("--tileset", type=Path, default=DEFAULT_TILESET)
	parser.add_argument("--project-root", type=Path, default=DEFAULT_PROJECT)
	parser.add_argument("--update-town-scene", action="store_true")
	parser.add_argument("--position", default="64, -180")
	parser.add_argument("--scale", default="2, 2")
	return parser.parse_args()


def main() -> None:
	args = parse_args()
	project_root = args.project_root.resolve()
	tmj = load_tmj(args.tmj)
	copy_tileset(args.tileset, project_root)
	generate_map_scene(tmj, project_root / MAP_SCENE_REL)
	generate_collision_scene(tmj, project_root / COLLISION_SCENE_REL)
	if args.update_town_scene:
		update_town_scene(project_root, args.position, args.scale)
	print(f"Generated {project_root / MAP_SCENE_REL}")
	print(f"Generated {project_root / COLLISION_SCENE_REL}")
	print(f"Copied {project_root / TILESET_REL}")
	if args.update_town_scene:
		print(f"Updated {project_root / TOWN_SCENE_REL}")


if __name__ == "__main__":
	main()
