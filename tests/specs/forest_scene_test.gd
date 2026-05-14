# tests/specs/forest_scene_test.gd
# Spec: Forest prototype endpoint scene.

class_name TestForestScene
extends TestCase

var root: Node


func setup() -> void:
	var scene: PackedScene = load("res://scenes/forest.tscn")
	assert_not_null(scene, "Forest scene should exist")
	if scene:
		root = scene.instantiate()
		root._ready()


func teardown() -> void:
	if root:
		root.free()
		root = null


func test_forest_scene_shows_prototype_endpoint_copy() -> void:
	if root == null:
		return
	var title := root.get_node_or_null("UI/EndpointPanel/VBox/TitleLabel") as Label
	var body := root.get_node_or_null("UI/EndpointPanel/VBox/BodyLabel") as Label
	assert_not_null(title)
	assert_not_null(body)
	if title and body:
		assert_eq("Forest", title.text)
		assert_true(body.text.contains("The path is open"))


func test_forest_scene_has_return_gateway_to_field() -> void:
	if root == null:
		return
	var gateway := root.get_node_or_null("FieldGateway") as Area2D
	assert_not_null(gateway)
	if gateway:
		root._on_field_gateway_body_entered(root.get_node("Player"))
		assert_eq("res://scenes/field.tscn", root.requested_scene_path)
