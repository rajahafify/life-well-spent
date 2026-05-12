## EnemySpriteCatalog — loads RO-ish enemy sprite/action metadata.
class_name EnemySpriteCatalog
extends Object

const ENEMY_METADATA := {
	"slime_spiked": "res://assets/enemies/Slime/slime_spiked.asset.json",
}


func load_enemy(enemy_id: String) -> Dictionary:
	if not ENEMY_METADATA.has(enemy_id):
		return {}
	return load_from_json(ENEMY_METADATA[enemy_id])


func load_from_json(json_path: String) -> Dictionary:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return {}
	return _normalize_sprite_set(parsed, json_path.get_base_dir())


func validate_sprite_set(sprite_set: Dictionary) -> Array:
	var errors: Array = []
	if sprite_set.is_empty():
		return ["sprite set is empty"]
	if int(sprite_set.get("schema_version", 0)) != 1:
		errors.append("schema_version must be 1")
	if str(sprite_set.get("enemy_id", "")) == "":
		errors.append("enemy_id is required")
	var frame_size: Vector2i = sprite_set.get("frame_size", Vector2i.ZERO)
	if frame_size.x <= 0 or frame_size.y <= 0:
		errors.append("frame_size must be positive")
	var animations: Dictionary = sprite_set.get("animations", {})
	for required in ["idle", "run", "hit", "death"]:
		if not animations.has(required):
			errors.append("missing animation: %s" % required)
	for animation_name in animations.keys():
		var animation: Dictionary = animations[animation_name]
		var texture_path := str(animation.get("texture_path", ""))
		if not ResourceLoader.exists(texture_path):
			errors.append("missing texture: %s" % texture_path)
			continue
		var texture := load(texture_path) as Texture2D
		if texture == null:
			errors.append("texture failed to load: %s" % texture_path)
			continue
		if texture.get_width() % frame_size.x != 0:
			errors.append("%s width not divisible by frame width" % animation_name)
		if texture.get_height() % frame_size.y != 0:
			errors.append("%s height not divisible by frame height" % animation_name)
	return errors


func _normalize_sprite_set(raw: Dictionary, base_dir: String) -> Dictionary:
	var frame_array: Array = raw.get("frame_size", [64, 64])
	var preview_scale_array: Array = raw.get("preview_scale", [1.0, 1.0])
	var world_scale_array: Array = raw.get("world_scale", [1.0, 1.0])
	var ground_anchor_array: Array = raw.get("ground_anchor", [32, 56])
	var animations := {}
	var raw_animations: Dictionary = raw.get("animations", {})
	for animation_name in raw_animations.keys():
		var anim: Dictionary = raw_animations[animation_name]
		var texture_file := str(anim.get("texture", ""))
		var texture_path := texture_file if texture_file.begins_with("res://") else base_dir.path_join(texture_file)
		animations[animation_name] = {
			"name": animation_name,
			"texture_path": texture_path,
			"fps": float(anim.get("fps", 8.0)),
			"loop": bool(anim.get("loop", true)),
			"offset": _vector2_from_array(anim.get("offset", [0, 0])),
		}
	return {
		"schema_version": int(raw.get("schema_version", 0)),
		"enemy_id": str(raw.get("enemy_id", "")),
		"display_name": str(raw.get("display_name", "")),
		"directions": str(raw.get("directions", "horizontal_2d")),
		"supports_flip": bool(raw.get("supports_flip", true)),
		"frame_size": Vector2i(int(frame_array[0]), int(frame_array[1])),
		"preview_scale": _vector2_from_array(preview_scale_array),
		"world_scale": _vector2_from_array(world_scale_array),
		"ground_anchor": _vector2_from_array(ground_anchor_array),
		"animations": animations,
	}


func _vector2_from_array(value: Array) -> Vector2:
	if value.size() < 2:
		return Vector2.ZERO
	return Vector2(float(value[0]), float(value[1]))
