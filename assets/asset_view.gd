@tool
## SlimeAssetView — focused single-sprite viewer for Spiked Slime animations.
class_name SlimeAssetView
extends Control

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const BUILDER_SCRIPT := preload("res://scripts/views/enemy_sprite_frames_builder.gd")

@export var enemy_id: String = "slime_spiked"
@export var preview_area_size: Vector2 = Vector2(360, 240)
@export var preview_scale: Vector2 = Vector2(3, 3)

var _sprite_set: Dictionary = {}
var _sprite: AnimatedSprite2D


func _ready() -> void:
	rebuild_view()


func load_sprite_set() -> Dictionary:
	var catalog = CATALOG_SCRIPT.new()
	var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
	catalog.free()
	return sprite_set


func rebuild_view() -> void:
	_clear_children()
	_sprite_set = load_sprite_set()

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
	title.text = "%s Asset View" % str(_sprite_set.get("display_name", enemy_id)).to_upper()
	title.add_theme_font_size_override("font_size", 34)
	vbox.add_child(title)

	var summary := Label.new()
	summary.name = "Summary"
	summary.text = "Single preview from metadata: %s" % enemy_id
	summary.add_theme_font_size_override("font_size", 18)
	vbox.add_child(summary)

	var preview_area := Control.new()
	preview_area.name = "PreviewArea"
	preview_area.custom_minimum_size = preview_area_size
	vbox.add_child(preview_area)

	_sprite = AnimatedSprite2D.new()
	_sprite.name = "AnimatedSprite2D"
	_sprite.centered = true
	_sprite.position = preview_area_size * 0.5
	_sprite.scale = preview_scale
	var builder = BUILDER_SCRIPT.new()
	_sprite.sprite_frames = builder.build(_sprite_set)
	builder.free()
	preview_area.add_child(_sprite)

	var buttons := HBoxContainer.new()
	buttons.name = "AnimationButtons"
	buttons.add_theme_constant_override("separation", 8)
	vbox.add_child(buttons)

	var animations: Dictionary = _sprite_set.get("animations", {})
	var animation_names := animations.keys()
	animation_names.sort()
	for animation_name in animation_names:
		buttons.add_child(_build_animation_button(animation_name))

	play_animation("idle" if animations.has("idle") else (animation_names[0] if animation_names.size() > 0 else ""))


func play_animation(animation_name: String) -> void:
	if _sprite == null:
		_sprite = get_node_or_null("Scroll/Margin/VBox/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D
	if _sprite == null or _sprite.sprite_frames == null or animation_name == "":
		return
	if not _sprite.sprite_frames.has_animation(animation_name):
		return
	_sprite.animation = animation_name
	_sprite.play(animation_name)


func frame_count_for_animation(animation_name: String) -> int:
	var sprite_set := load_sprite_set()
	var builder = BUILDER_SCRIPT.new()
	var count: int = builder.frame_count_for_animation(sprite_set, animation_name)
	builder.free()
	return count


func _build_animation_button(animation_name: String) -> Button:
	var button := Button.new()
	button.name = "%sButton" % animation_name.capitalize()
	button.text = animation_name.to_upper()
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(play_animation.bind(animation_name))
	return button


func _clear_children() -> void:
	_sprite = null
	for child in get_children():
		remove_child(child)
		child.free()
