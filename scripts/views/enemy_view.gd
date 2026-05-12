## EnemyView — displays one enemy instance and emits click intent.
class_name EnemyView
extends Area2D

signal clicked(instance_id: String)
signal hit_feedback_requested(damage: int)

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const BUILDER_SCRIPT := preload("res://scripts/views/enemy_sprite_frames_builder.gd")
const HIT_FEEDBACK_SCRIPT := preload("res://scripts/views/hit_feedback_component.gd")
const DAMAGE_TEXT_SCRIPT := preload("res://scripts/views/damage_text_component.gd")
const WORLD_SPRITE_SCALE := Vector2(4, 4)
const CLICK_COLLISION_RADIUS := 76.0

@export var enemy_id: String = "slime_spiked"
@export var instance_id: String = ""

var _sprite: AnimatedSprite2D
var _hp_bar: ProgressBar
var _shape: CollisionShape2D
var _damage_text
var _hit_feedback
var _loaded_enemy_id: String = ""


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	if _sprite == null:
		_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
		if _sprite == null:
			_sprite = AnimatedSprite2D.new()
			_sprite.name = "AnimatedSprite2D"
			add_child(_sprite)
	_remove_legacy_hp_label()
	if _hp_bar == null:
		_hp_bar = get_node_or_null("HpBar") as ProgressBar
		if _hp_bar == null:
			_hp_bar = ProgressBar.new()
			_hp_bar.name = "HpBar"
			add_child(_hp_bar)
		_configure_hp_bar()
	if _shape == null:
		_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
		if _shape == null:
			_shape = CollisionShape2D.new()
			_shape.name = "CollisionShape2D"
			add_child(_shape)
	if _shape.shape == null:
		var circle := CircleShape2D.new()
		circle.radius = CLICK_COLLISION_RADIUS
		_shape.shape = circle
	if _damage_text == null:
		_damage_text = get_node_or_null("DamageTextComponent")
		if _damage_text == null:
			_damage_text = Node2D.new()
			_damage_text.name = "DamageTextComponent"
			_damage_text.set_script(DAMAGE_TEXT_SCRIPT)
			add_child(_damage_text)
		if _damage_text.has_method("ensure_ready"):
			_damage_text.ensure_ready()
	if _hit_feedback == null:
		_hit_feedback = get_node_or_null("HitFeedbackComponent")
		if _hit_feedback == null:
			_hit_feedback = Node.new()
			_hit_feedback.name = "HitFeedbackComponent"
			_hit_feedback.set_script(HIT_FEEDBACK_SCRIPT)
			add_child(_hit_feedback)
		if _hit_feedback.has_method("ensure_ready"):
			_hit_feedback.ensure_ready()
	_load_sprite_frames()
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)


func configure(instance_id_value: String, enemy_id_value: String) -> void:
	instance_id = instance_id_value
	enemy_id = enemy_id_value
	ensure_ready()


func update_from_state(state) -> void:
	ensure_ready()
	global_position = state.position
	_hp_bar.max_value = float(max(1, state.max_hp))
	_hp_bar.value = float(clampi(state.hp, 0, state.max_hp))
	_hp_bar.visible = state.hp < state.max_hp
	_hp_bar.tooltip_text = "%s: %d/%d" % [state.display_name, state.hp, state.max_hp]
	var animation_name := _animation_for_state(state.behavior_state)
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation(animation_name):
		if _sprite.animation != animation_name:
			_sprite.play(animation_name)
	if state.behavior_state == "die":
		_shape.disabled = true


func set_summary_text(text: String) -> void:
	ensure_ready()
	_hp_bar.tooltip_text = text


func play_hit_feedback(damage: int = 1) -> void:
	ensure_ready()
	hit_feedback_requested.emit(damage)


func play_attack_feedback() -> void:
	ensure_ready()
	if not _play_animation_once("ability"):
		_play_animation_once("hit")


func _play_animation_once(animation_name: String) -> bool:
	if _sprite.sprite_frames == null or not _sprite.sprite_frames.has_animation(animation_name):
		return false
	_sprite.stop()
	_sprite.play(animation_name)
	return true


func _animation_for_state(state_name: String) -> String:
	match state_name:
		"wander", "chase":
			return "run"
		"die":
			return "death"
		"attack":
			return "hit"
		_:
			return "idle"


func _load_sprite_frames() -> void:
	if _sprite.sprite_frames != null and _loaded_enemy_id == enemy_id:
		return
	var catalog = CATALOG_SCRIPT.new()
	var sprite_set: Dictionary = catalog.load_enemy(enemy_id)
	catalog.free()
	var builder = BUILDER_SCRIPT.new()
	_sprite.sprite_frames = builder.build(sprite_set)
	builder.free()
	_sprite.centered = true
	_sprite.scale = WORLD_SPRITE_SCALE
	_loaded_enemy_id = enemy_id
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation("idle"):
		_sprite.play("idle")


func _remove_legacy_hp_label() -> void:
	var legacy_label := get_node_or_null("HpLabel")
	if legacy_label:
		remove_child(legacy_label)
		legacy_label.free()


func _configure_hp_bar() -> void:
	_hp_bar.position = Vector2(-56, 90)
	_hp_bar.size = Vector2(112, 5)
	_hp_bar.scale = Vector2(1.0, 0.18)
	_hp_bar.min_value = 0.0
	_hp_bar.max_value = maxf(1.0, _hp_bar.max_value)
	_hp_bar.value = clampf(_hp_bar.value, _hp_bar.min_value, _hp_bar.max_value)
	_hp_bar.visible = false
	_hp_bar.show_percentage = false
	_hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.10, 0.05, 0.05, 0.88)
	background.border_color = Color(0.02, 0.02, 0.02, 0.95)
	background.set_border_width_all(1)
	background.set_corner_radius_all(2)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.25, 0.86, 0.30, 1.0)
	fill.set_corner_radius_all(2)
	_hp_bar.add_theme_stylebox_override("background", background)
	_hp_bar.add_theme_stylebox_override("fill", fill)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(instance_id)
