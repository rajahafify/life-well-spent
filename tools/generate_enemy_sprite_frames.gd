@tool
extends SceneTree

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const BUILDER_SCRIPT := preload("res://scripts/views/enemy_sprite_frames_builder.gd")

func _init() -> void:
	var catalog = CATALOG_SCRIPT.new()
	var builder = BUILDER_SCRIPT.new()
	for enemy_id in catalog.enemy_ids():
		var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
		var output_path := str(sprite_set.get("sprite_frames_resource", ""))
		if output_path == "":
			push_error("Missing sprite_frames_resource for %s" % enemy_id)
			continue
		var build_set := sprite_set.duplicate(true)
		build_set.erase("sprite_frames_resource")
		var frames: SpriteFrames = builder.build(build_set)
		var error := ResourceSaver.save(frames, output_path)
		if error != OK:
			push_error("Failed to save %s: %s" % [output_path, error])
		else:
			print("saved %s" % output_path)
	builder.free()
	catalog.free()
	quit()
