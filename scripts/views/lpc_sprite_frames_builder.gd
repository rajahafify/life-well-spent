## LPCSpriteFramesBuilder — builds preview SpriteFrames from a 13x21 Universal LPC sheet.
class_name LPCSpriteFramesBuilder
extends Object

const FRAME_SIZE := Vector2i(64, 64)
const DOWN_ROWS := {
	"spellcast": 2,
	"thrust": 6,
	"walk": 10,
	"slash": 14,
	"shoot": 18,
	"hurt": 20,
}
const FRAME_COUNTS := {
	"spellcast": 7,
	"thrust": 8,
	"walk": 9,
	"slash": 6,
	"shoot": 13,
	"hurt": 6,
}


func build(texture_path: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	if not ResourceLoader.exists(texture_path):
		return frames
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return frames
	_add_idle(frames, texture)
	for animation_name in ["walk", "slash", "thrust", "shoot", "spellcast", "hurt"]:
		_add_row_animation(frames, texture, animation_name)
	return frames


func _add_idle(frames: SpriteFrames, texture: Texture2D) -> void:
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 2.0)
	frames.set_animation_loop("idle", true)
	var row: int = DOWN_ROWS["walk"]
	for column in [1, 2]:
		frames.add_frame("idle", _atlas(texture, column, row))


func _add_row_animation(frames: SpriteFrames, texture: Texture2D, animation_name: String) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 8.0)
	frames.set_animation_loop(animation_name, animation_name == "walk")
	var row: int = DOWN_ROWS[animation_name]
	var count: int = FRAME_COUNTS[animation_name]
	for column in range(count):
		frames.add_frame(animation_name, _atlas(texture, column, row))


func _atlas(texture: Texture2D, column: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(column * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return atlas
