extends Node2D

@onready var _results_label: Label = $UI/ResultsLabel


func _ready() -> void:
	var results: Dictionary = TestRunner.run_with_output()
	_results_label.text = _format_results(results)
	_results_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_results_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_results_label.add_theme_font_size_override("font_size", 32)


func _format_results(results: Dictionary) -> String:
	var text: String = "Test Results\n\n"
	text += "%d/%d passed\n\n" % [
		results["passed"],
		results["total"]
	]

	for result: Dictionary in results["results"]:
		var status: String = "PASS" if result["passed"] else "FAIL"
		text += "[%s] %s\n" % [status, result["id"]]
		for failure: Dictionary in result["failures"]:
			text += "  ❌ %s\n" % failure["message"]

	return text


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit(0)
