## GDAIMCPRuntimeGuard — keeps editor MCP enabled while skipping runtime in headless tests.
class_name GDAIMCPRuntimeGuard
extends Node


func _enter_tree() -> void:
	if should_skip_runtime(DisplayServer.get_name()):
		return
	_start_runtime_server()


func should_skip_runtime(display_name: String) -> bool:
	return display_name == "headless"


func _start_runtime_server() -> void:
	const RUNTIME_SERVER := "GDAIRuntimeServer"
	if ClassDB.class_exists(RUNTIME_SERVER) and ClassDB.can_instantiate(RUNTIME_SERVER):
		var runtime_server: Object = ClassDB.instantiate(RUNTIME_SERVER)
		if runtime_server is Node:
			add_child(runtime_server as Node)
