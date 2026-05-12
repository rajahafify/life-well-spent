## DamageTextComponent - reusable floating damage number view.
class_name DamageTextComponent
extends Node2D

@export var label_name: String = "HitLabel"
@export var visible_duration: float = 0.55
@export var horizontal_distance: float = 34.0
@export var upward_distance: float = 16.0
@export var arc_height: float = 26.0
@export var jitter_range: Vector2 = Vector2(10.0, 4.0)
@export var font_size: int = 36
@export var randomize_side: bool = true
@export var arc_side: float = 1.0

var _label: Label
var _timer: float = 0.0
var _base_position: Vector2 = Vector2.ZERO
var _start_position: Vector2 = Vector2.ZERO
var _resolved_arc_side: float = 1.0


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	if _label == null:
		var parent_node := get_parent()
		_label = parent_node.get_node_or_null(label_name) as Label if parent_node else null
		if _label == null:
			_label = Label.new()
			_label.name = label_name
			_label.position = Vector2(-12, -108)
			_label.visible = false
			if parent_node:
				parent_node.add_child(_label)
			else:
				add_child(_label)
	if _label:
		_label.add_theme_font_size_override("font_size", font_size)
	_base_position = _label.position


func show_damage(value: int, damage_color: Color = Color.WHITE) -> void:
	ensure_ready()
	_resolved_arc_side = (-1.0 if randf() < 0.5 else 1.0) if randomize_side else (-1.0 if arc_side < 0.0 else 1.0)
	var jitter := Vector2(
		randf_range(-jitter_range.x, jitter_range.x),
		randf_range(-jitter_range.y, jitter_range.y)
	)
	_start_position = _base_position + jitter
	_label.text = str(value)
	_label.add_theme_color_override("font_color", damage_color)
	_label.position = _start_position
	_label.visible = true
	_timer = visible_duration


func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	if _label:
		var progress: float = 1.0 - maxf(_timer, 0.0) / visible_duration
		var arc_y: float = -upward_distance * progress - arc_height * 4.0 * progress * (1.0 - progress)
		_label.position = _start_position + Vector2(horizontal_distance * _resolved_arc_side * progress, arc_y)
	if _timer <= 0.0 and _label:
		_label.visible = false
