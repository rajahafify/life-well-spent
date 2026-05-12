@tool
## AssetGallery - editor-visible looping enemy SpriteFrames gallery.
class_name AssetGallery
extends Control

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const LPC_BUILDER_SCRIPT := preload("res://scripts/views/lpc_sprite_frames_builder.gd")
const VIEW_ROOT := "Center/Panel/Margin/VBox"
const CHARACTER_SPRITES := {
	"player": {"display_name": "Player", "texture_path": "res://assets/player.png"},
	"forest_guard": {"display_name": "Forest Guard", "texture_path": "res://assets/npcs/forest_guard.png"},
}
const ENEMY_SPRITE_NODES := {
	"slime_spiked": "GalleryScroll/GalleryGrid/SlimePreview/SlimeArea/SlimeSprite",
	"rat": "GalleryScroll/GalleryGrid/RatPreview/RatArea/RatSprite",
	"bat": "GalleryScroll/GalleryGrid/BatPreview/BatArea/BatSprite",
	"crab": "GalleryScroll/GalleryGrid/CrabPreview/CrabArea/CrabSprite",
	"golem_armored": "GalleryScroll/GalleryGrid/ArmoredGolemPreview/ArmoredGolemArea/ArmoredGolemSprite",
	"golem": "GalleryScroll/GalleryGrid/GolemPreview/GolemArea/GolemSprite",
	"pebble": "GalleryScroll/GalleryGrid/PebblePreview/PebbleArea/PebbleSprite",
	"skull": "GalleryScroll/GalleryGrid/SkullPreview/SkullArea/SkullSprite",
}


func _ready() -> void:
	rebuild_gallery()


func rebuild_gallery() -> void:
	var catalog = CATALOG_SCRIPT.new()
	for enemy_id in catalog.enemy_ids():
		var sprite := sprite_node_for_enemy(enemy_id)
		if sprite == null:
			continue
		sprite.centered = true
		if sprite.sprite_frames == null:
			var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
			var resource_path := str(sprite_set.get("sprite_frames_resource", ""))
			if resource_path != "" and ResourceLoader.exists(resource_path):
				sprite.sprite_frames = load(resource_path) as SpriteFrames
		if sprite.sprite_frames != null:
			_ensure_idle_loops(sprite.sprite_frames)
			if sprite.sprite_frames.has_animation("idle"):
				sprite.animation = "idle"
				sprite.play("idle")
	catalog.free()
	_rebuild_character_previews()


func sprite_node_for_character(character_id: String) -> AnimatedSprite2D:
	return get_node_or_null(VIEW_ROOT + "/GalleryScroll/GalleryGrid/%sPreview/%sArea/%sSprite" % [character_id.to_pascal_case(), character_id.to_pascal_case(), character_id.to_pascal_case()]) as AnimatedSprite2D


func _rebuild_character_previews() -> void:
	var grid := get_node_or_null(VIEW_ROOT + "/GalleryScroll/GalleryGrid") as GridContainer
	if grid == null:
		return
	var builder = LPC_BUILDER_SCRIPT.new()
	for character_id in ["player", "forest_guard"]:
		var sprite := sprite_node_for_character(character_id)
		if sprite == null:
			sprite = _add_character_preview(grid, character_id)
		var data: Dictionary = CHARACTER_SPRITES[character_id]
		sprite.sprite_frames = builder.build(str(data["texture_path"]))
		sprite.centered = true
		sprite.scale = Vector2(2, 2)
		if sprite.sprite_frames.has_animation("idle"):
			sprite.animation = "idle"
			sprite.play("idle")
	builder.free()


func _add_character_preview(grid: GridContainer, character_id: String) -> AnimatedSprite2D:
	var pascal := character_id.to_pascal_case()
	var preview := VBoxContainer.new()
	preview.name = "%sPreview" % pascal
	preview.custom_minimum_size = Vector2(160, 140)
	var label := Label.new()
	label.name = "Label"
	label.text = str((CHARACTER_SPRITES[character_id] as Dictionary).get("display_name", character_id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(label)
	var area := Control.new()
	area.name = "%sArea" % pascal
	area.custom_minimum_size = Vector2(128, 96)
	preview.add_child(area)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "%sSprite" % pascal
	sprite.position = Vector2(64, 70)
	area.add_child(sprite)
	grid.add_child(preview)
	return sprite


func sprite_node_for_enemy(enemy_id: String) -> AnimatedSprite2D:
	if not ENEMY_SPRITE_NODES.has(enemy_id):
		return null
	return get_node_or_null(VIEW_ROOT + "/" + ENEMY_SPRITE_NODES[enemy_id]) as AnimatedSprite2D


func _ensure_idle_loops(frames: SpriteFrames) -> void:
	if frames.has_animation("idle"):
		frames.set_animation_loop("idle", true)
