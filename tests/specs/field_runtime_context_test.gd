# tests/specs/field_runtime_context_test.gd
# Spec: FieldRuntimeContext owns Field collaborator construction.

class_name TestFieldRuntimeContext
extends TestCase

var context


func setup() -> void:
	var script := load("res://scripts/controllers/field_runtime_context.gd") as GDScript
	assert_not_null(script, "FieldRuntimeContext script should exist")
	context = script.new()


func teardown() -> void:
	if context:
		context.dispose()
		context.free()
		context = null


func test_context_builds_required_field_collaborators() -> void:
	assert_not_null(context.behavior)
	assert_not_null(context.combat)
	assert_not_null(context.drop_system)
	assert_not_null(context.camera_controller)
	assert_not_null(context.spawn_controller)
	assert_not_null(context.combat_controller)
	assert_not_null(context.player_aging)
	assert_not_null(context.equipment_stats)


func test_dispose_releases_field_collaborator_references() -> void:
	context.dispose()
	assert_null(context.behavior)
	assert_null(context.combat)
	assert_null(context.drop_system)
	assert_null(context.camera_controller)
	assert_null(context.spawn_controller)
	assert_null(context.combat_controller)
	assert_null(context.player_aging)
	assert_null(context.equipment_stats)
