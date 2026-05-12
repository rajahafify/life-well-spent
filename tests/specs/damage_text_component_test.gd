# tests/specs/damage_text_component_test.gd
# Spec: DamageTextComponent - RO-style floating number presentation.

class_name TestDamageTextComponent
extends TestCase

const COMPONENT_SCRIPT := "res://scripts/views/damage_text_component.gd"

var owner_node: Node2D
var component


func setup() -> void:
	owner_node = Node2D.new()
	var script := load(COMPONENT_SCRIPT) as GDScript
	component = Node2D.new()
	component.name = "DamageTextComponent"
	component.set_script(script)
	owner_node.add_child(component)
	component.randomize_side = false
	component.arc_side = 1.0
	component.jitter_range = Vector2.ZERO
	component.visible_duration = 1.0
	component.horizontal_distance = 36.0
	component.upward_distance = 18.0
	component.arc_height = 24.0
	component.ensure_ready()


func teardown() -> void:
	if owner_node:
		owner_node.free()
		owner_node = null
	component = null


func test_show_damage_uses_given_color() -> void:
	component.show_damage(7, Color.WHITE)
	var label := owner_node.get_node("HitLabel") as Label
	assert_true(label.visible)
	assert_eq("7", label.text)
	assert_eq(Color.WHITE, label.get_theme_color("font_color"))
	assert_true(int(label.get_theme_font_size("font_size")) >= 36, "damage numbers should be large enough to read during combat")


func test_damage_number_animates_on_parabolic_arc_away() -> void:
	component.show_damage(7, Color.WHITE)
	var label := owner_node.get_node("HitLabel") as Label
	var start_position := label.position
	component._process(0.5)
	var middle_position := label.position
	component._process(0.5)
	var end_position := label.position
	assert_true(middle_position.x > start_position.x, "damage number should travel horizontally away")
	assert_true(middle_position.y < start_position.y, "damage number should rise during the arc")
	assert_true(middle_position.y < end_position.y, "parabolic arc should descend after the apex")
	assert_false(label.visible)


func test_existing_damage_label_gets_large_font_size() -> void:
	teardown()
	owner_node = Node2D.new()
	var existing_label := Label.new()
	existing_label.name = "HitLabel"
	existing_label.add_theme_font_size_override("font_size", 24)
	owner_node.add_child(existing_label)
	var script := load(COMPONENT_SCRIPT) as GDScript
	component = Node2D.new()
	component.name = "DamageTextComponent"
	component.set_script(script)
	owner_node.add_child(component)
	component.ensure_ready()
	assert_true(int(existing_label.get_theme_font_size("font_size")) >= 36, "component should resize labels that already exist")
