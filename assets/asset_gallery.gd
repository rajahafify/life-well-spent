@tool
## AssetGallery - editor-visible looping enemy SpriteFrames gallery.
class_name AssetGallery
extends Control

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const VIEW_ROOT := "Center/Panel/Margin/VBox"
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


func sprite_node_for_enemy(enemy_id: String) -> AnimatedSprite2D:
	if not ENEMY_SPRITE_NODES.has(enemy_id):
		return null
	return get_node_or_null(VIEW_ROOT + "/" + ENEMY_SPRITE_NODES[enemy_id]) as AnimatedSprite2D


func _ensure_idle_loops(frames: SpriteFrames) -> void:
	if frames.has_animation("idle"):
		frames.set_animation_loop("idle", true)
