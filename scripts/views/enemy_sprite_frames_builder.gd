## EnemySpriteFramesBuilder — converts enemy sprite/action metadata into SpriteFrames.
class_name EnemySpriteFramesBuilder
extends Object


func build(sprite_set: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	var frame_size: Vector2i = sprite_set.get("frame_size", Vector2i(64, 64))
	var animations: Dictionary = sprite_set.get("animations", {})
	for animation_name in animations.keys():
		_add_animation(frames, animation_name, animations[animation_name], frame_size)
	return frames


func frame_count_for_animation(sprite_set: Dictionary, animation_name: String) -> int:
	var animations: Dictionary = sprite_set.get("animations", {})
	if not animations.has(animation_name):
		return 0
	return _frame_count_for_texture(animations[animation_name].get("texture_path", ""), sprite_set.get("frame_size", Vector2i(64, 64)))


func _add_animation(frames: SpriteFrames, animation_name: String, animation: Dictionary, frame_size: Vector2i) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, float(animation.get("fps", 8.0)))
	frames.set_animation_loop(animation_name, bool(animation.get("loop", true)))
	var texture_path := str(animation.get("texture_path", ""))
	if not ResourceLoader.exists(texture_path):
		return
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return
	var columns_count: int = max(1, texture.get_width() / frame_size.x)
	var rows_count: int = max(1, texture.get_height() / frame_size.y)
	for y in range(rows_count):
		for x in range(columns_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(x * frame_size.x, y * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame(animation_name, atlas)


func _frame_count_for_texture(texture_path: String, frame_size: Vector2i) -> int:
	if not ResourceLoader.exists(texture_path):
		return 0
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return 0
	var columns_count: int = max(1, texture.get_width() / frame_size.x)
	var rows_count: int = max(1, texture.get_height() / frame_size.y)
	return columns_count * rows_count
