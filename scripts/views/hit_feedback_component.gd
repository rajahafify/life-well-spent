## HitFeedbackComponent - reusable hit flash and hit animation trigger.
class_name HitFeedbackComponent
extends Node

@export var flash_color: Color = Color(1.0, 0.45, 0.35, 1.0)
@export var flash_duration: float = 0.16
@export var hit_animation: String = "hit"
@export var damage_color: Color = Color.WHITE

var _target: CanvasItem
var _sprite: AnimatedSprite2D
var _damage_text
var _timer: float = 0.0
var _base_modulate: Color = Color(1, 1, 1, 1)


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	var parent := get_parent()
	if _target == null and parent is CanvasItem:
		_target = parent as CanvasItem
	if _sprite == null and parent:
		_sprite = parent.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if _damage_text == null and parent:
		_damage_text = parent.get_node_or_null("DamageTextComponent")
	if parent and parent.has_signal("hit_feedback_requested") and not parent.hit_feedback_requested.is_connected(play_hit):
		parent.hit_feedback_requested.connect(play_hit)


func play_hit(damage: int = 1) -> void:
	ensure_ready()
	if _sprite and _sprite.sprite_frames and _sprite.sprite_frames.has_animation(hit_animation):
		_sprite.stop()
		_sprite.play(hit_animation)
	if _damage_text and _damage_text.has_method("show_damage"):
		_damage_text.show_damage(damage, damage_color)
	if _target:
		_base_modulate = Color(1, 1, 1, 1)
		_target.modulate = flash_color
		_timer = flash_duration


func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0 and _target:
		_target.modulate = _base_modulate
