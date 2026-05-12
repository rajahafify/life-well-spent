## EnemyView — displays one enemy instance and emits click intent.
class_name EnemyView
extends Area2D

signal clicked(instance_id: String)

const CATALOG_SCRIPT := preload("res://scripts/models/enemy_sprite_catalog.gd")
const BUILDER_SCRIPT := preload("res://scripts/views/enemy_sprite_frames_builder.gd")

@export var enemy_id: String = "slime_spiked"
@export var instance_id: String = ""

var _sprite: AnimatedSprite2D
var _hp_label: Label
var _shape: CollisionShape2D
var _hit_label: Label
var _loaded_enemy_id: String = ""
var _hit_label_timer: float = 0.0


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	if _sprite == null:
		_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
		if _sprite == null:
			_sprite = AnimatedSprite2D.new()
			_sprite.name = "AnimatedSprite2D"
			add_child(_sprite)
	if _hp_label == null:
		_hp_label = get_node_or_null("HpLabel") as Label
		if _hp_label == null:
			_hp_label = Label.new()
			_hp_label.name = "HpLabel"
			_hp_label.position = Vector2(-48, -74)
			_hp_label.add_theme_font_size_override("font_size", 18)
			add_child(_hp_label)
	if _shape == null:
		_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
		if _shape == null:
			_shape = CollisionShape2D.new()
			_shape.name = "CollisionShape2D"
			add_child(_shape)
	if _shape.shape == null:
		var circle := CircleShape2D.new()
		circle.radius = 42.0
		_shape.shape = circle
	if _hit_label == null:
		_hit_label = get_node_or_null("HitLabel") as Label
		if _hit_label == null:
			_hit_label = Label.new()
			_hit_label.name = "HitLabel"
			_hit_label.position = Vector2(-12, -108)
			_hit_label.add_theme_font_size_override("font_size", 24)
			_hit_label.visible = false
			add_child(_hit_label)
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
	_hp_label.text = "%s: %d/%d" % [state.display_name, state.hp, state.max_hp]
	var animation_name := _animation_for_state(state.behavior_state)
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation(animation_name):
		if _sprite.animation != animation_name:
			_sprite.play(animation_name)
	if state.behavior_state == "die":
		_shape.disabled = true


func _process(delta: float) -> void:
	if _hit_label_timer <= 0.0:
		return
	_hit_label_timer -= delta
	if _hit_label_timer <= 0.0 and _hit_label:
		_hit_label.visible = false


func set_summary_text(text: String) -> void:
	ensure_ready()
	_hp_label.text = text


func play_hit_feedback(damage: int = 1) -> void:
	ensure_ready()
	_play_animation_once("hit")
	_show_hit_text(str(damage))


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


func _show_hit_text(text: String) -> void:
	if _hit_label:
		_hit_label.text = text
		_hit_label.visible = true
		_hit_label_timer = 0.55


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
	_sprite.scale = Vector2(2, 2)
	_loaded_enemy_id = enemy_id
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation("idle"):
		_sprite.play("idle")


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(instance_id)
