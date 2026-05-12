@tool
## AssetView - focused single-enemy asset preview.
class_name AssetView
extends Control

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const BUILDER_SCRIPT := preload("res://scripts/views/enemy_sprite_frames_builder.gd")
const LPC_BUILDER_SCRIPT := preload("res://scripts/views/lpc_sprite_frames_builder.gd")
const VIEW_ROOT := "Center/Panel/Margin/VBox"
const CHARACTER_SPRITES := {
	"player": {
		"enemy_id": "player",
		"display_name": "Player",
		"texture_path": "res://assets/player.png",
		"animations": {"idle": {}, "walk": {}, "slash": {}, "thrust": {}, "shoot": {}, "spellcast": {}, "hurt": {}},
	},
	"forest_guard": {
		"enemy_id": "forest_guard",
		"display_name": "Forest Guard",
		"texture_path": "res://assets/npcs/forest_guard.png",
		"animations": {"idle": {}, "walk": {}, "slash": {}, "thrust": {}, "shoot": {}, "spellcast": {}, "hurt": {}},
	},
}

@export var enemy_id: String = "slime_spiked":
	set(value):
		enemy_id = value
		if is_inside_tree():
			rebuild_view()

var _sprite_set: Dictionary = {}


func _ready() -> void:
	rebuild_view()


func load_sprite_set() -> Dictionary:
	if CHARACTER_SPRITES.has(enemy_id):
		return (CHARACTER_SPRITES[enemy_id] as Dictionary).duplicate(true)
	var catalog = CATALOG_SCRIPT.new()
	var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
	catalog.free()
	return sprite_set


func rebuild_view() -> void:
	_sprite_set = load_sprite_set()
	_sync_static_layout()
	_populate_enemy_selector()
	_build_sprite_frames()
	_rebuild_animation_buttons()

	var animations: Dictionary = _sprite_set.get("animations", {})
	var animation_names := animations.keys()
	animation_names.sort()
	play_animation("idle" if animations.has("idle") else (animation_names[0] if animation_names.size() > 0 else ""))


func select_enemy(selected_enemy_id: String) -> void:
	enemy_id = selected_enemy_id
	rebuild_view()


func play_animation(animation_name: String) -> void:
	var sprite := _sprite_node()
	if sprite == null or sprite.sprite_frames == null or animation_name == "":
		return
	if not sprite.sprite_frames.has_animation(animation_name):
		return
	sprite.animation = animation_name
	sprite.play(animation_name)


func frame_count_for_animation(animation_name: String) -> int:
	var sprite_set := load_sprite_set()
	var builder = BUILDER_SCRIPT.new()
	var count: int = builder.frame_count_for_animation(sprite_set, animation_name)
	builder.free()
	return count


func _sync_static_layout() -> void:
	var title := get_node_or_null(VIEW_ROOT + "/Title") as Label
	if title:
		title.text = "%s Asset View" % str(_sprite_set.get("display_name", enemy_id)).to_upper()

	var summary := get_node_or_null(VIEW_ROOT + "/Summary") as Label
	if summary:
		summary.text = "Single preview from metadata: %s" % enemy_id


func _populate_enemy_selector() -> void:
	var selector := _selector_node()
	if selector == null:
		return
	if selector.item_selected.is_connected(_on_enemy_selected):
		selector.item_selected.disconnect(_on_enemy_selected)
	selector.clear()
	var catalog = CATALOG_SCRIPT.new()
	for id in catalog.enemy_ids():
		var sprite_set: Dictionary = catalog.load_enemy(id)
		selector.add_item(str(sprite_set.get("display_name", id)))
		selector.set_item_metadata(selector.item_count - 1, id)
		if id == enemy_id:
			selector.select(selector.item_count - 1)
	catalog.free()
	for id in ["player", "forest_guard"]:
		var sprite_set: Dictionary = CHARACTER_SPRITES[id]
		selector.add_item(str(sprite_set.get("display_name", id)))
		selector.set_item_metadata(selector.item_count - 1, id)
		if id == enemy_id:
			selector.select(selector.item_count - 1)
	selector.item_selected.connect(_on_enemy_selected)


func _build_sprite_frames() -> void:
	var sprite := _sprite_node()
	if sprite == null:
		return
	if CHARACTER_SPRITES.has(enemy_id):
		var lpc_builder = LPC_BUILDER_SCRIPT.new()
		sprite.sprite_frames = lpc_builder.build(str(_sprite_set.get("texture_path", "")))
		lpc_builder.free()
		return
	var builder = BUILDER_SCRIPT.new()
	sprite.sprite_frames = builder.build(_sprite_set)
	builder.free()


func _rebuild_animation_buttons() -> void:
	var buttons := _buttons_node()
	if buttons == null:
		return
	for child in buttons.get_children():
		buttons.remove_child(child)
		child.free()
	var animations: Dictionary = _sprite_set.get("animations", {})
	var animation_names := animations.keys()
	animation_names.sort()
	for animation_name in animation_names:
		buttons.add_child(_build_animation_button(animation_name))


func _on_enemy_selected(index: int) -> void:
	var selector := _selector_node()
	if selector == null:
		return
	select_enemy(str(selector.get_item_metadata(index)))


func _build_animation_button(animation_name: String) -> Button:
	var button := Button.new()
	button.name = "%sButton" % animation_name.capitalize()
	button.text = animation_name.to_upper()
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(play_animation.bind(animation_name))
	return button


func _sprite_node() -> AnimatedSprite2D:
	return get_node_or_null(VIEW_ROOT + "/PreviewArea/AnimatedSprite2D") as AnimatedSprite2D


func _selector_node() -> OptionButton:
	return get_node_or_null(VIEW_ROOT + "/EnemySelector") as OptionButton


func _buttons_node() -> HBoxContainer:
	return get_node_or_null(VIEW_ROOT + "/AnimationButtons") as HBoxContainer
