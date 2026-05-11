@tool
## SlimeAssetView — focused animated viewer for one enemy type: Slime.
class_name SlimeAssetView
extends Control

const SLIME_ROOT := "res://assets/enemies/Slime"

@export var frame_size: Vector2i = Vector2i(64, 64)
@export var preview_scale: Vector2 = Vector2(2.5, 2.5)
@export var preview_area_size: Vector2 = Vector2(220, 160)
@export var columns: int = 3
@export var fps: float = 8.0


func _ready() -> void:
	rebuild_view()


func slime_animation_paths() -> Dictionary:
	return {
		"idle": SLIME_ROOT + "/Slime_Spiked_Idle.png",
		"run": SLIME_ROOT + "/Slime_Spiked_Run.png",
		"hit": SLIME_ROOT + "/Slime_Spiked_Hit.png",
		"jump": SLIME_ROOT + "/Slime_Spiked_Jump.png",
		"death": SLIME_ROOT + "/Slime_Spiked_Death.png",
		"ability": SLIME_ROOT + "/Slime_Spiked_Ability.png",
	}


func rebuild_view() -> void:
	_clear_children()

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.name = "Title"
	title.text = "SLIME Asset View"
	title.add_theme_font_size_override("font_size", 34)
	vbox.add_child(title)

	var summary := Label.new()
	summary.name = "Summary"
	summary.text = "Animated previews from 64x64 Slime strips"
	summary.add_theme_font_size_override("font_size", 18)
	vbox.add_child(summary)

	var grid := GridContainer.new()
	grid.name = "AnimationGrid"
	grid.columns = max(1, columns)
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	vbox.add_child(grid)

	var paths := slime_animation_paths()
	for animation_name in ["idle", "run", "hit", "jump", "death", "ability"]:
		grid.add_child(_build_animation_card(animation_name, paths[animation_name]))


func frame_count_for_strip(texture_path: String) -> int:
	if not ResourceLoader.exists(texture_path):
		return 0
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return 0
	var columns_count: int = max(1, texture.get_width() / frame_size.x)
	var rows_count: int = max(1, texture.get_height() / frame_size.y)
	return columns_count * rows_count


func _build_animation_card(animation_name: String, texture_path: String) -> Control:
	var card := VBoxContainer.new()
	card.name = "%sCard" % animation_name.capitalize()
	card.set_meta("animation", animation_name)
	card.set_meta("asset_path", texture_path)
	card.custom_minimum_size = Vector2(220, 210)
	card.add_theme_constant_override("separation", 6)

	var label := Label.new()
	label.name = "NameLabel"
	label.text = animation_name.to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	card.add_child(label)

	var preview_area := Control.new()
	preview_area.name = "PreviewArea"
	preview_area.custom_minimum_size = preview_area_size
	card.add_child(preview_area)

	var sprite := AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.centered = true
	sprite.position = preview_area_size * 0.5
	sprite.scale = preview_scale
	sprite.sprite_frames = _sprite_frames_for_strip(animation_name, texture_path)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.animation = animation_name
		sprite.play(animation_name)
	preview_area.add_child(sprite)

	var path_label := Label.new()
	path_label.name = "PathLabel"
	path_label.text = texture_path.replace(SLIME_ROOT + "/", "")
	path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	path_label.add_theme_font_size_override("font_size", 12)
	card.add_child(path_label)

	return card


func _sprite_frames_for_strip(animation_name: String, texture_path: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, animation_name != "death")

	if not ResourceLoader.exists(texture_path):
		return frames
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return frames

	var columns_count: int = max(1, texture.get_width() / frame_size.x)
	var rows_count: int = max(1, texture.get_height() / frame_size.y)
	for y in range(rows_count):
		for x in range(columns_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(x * frame_size.x, y * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame(animation_name, atlas)
	return frames


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
