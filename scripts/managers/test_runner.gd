class_name TestRunner

const SPEC_DIR: String = "res://resources/specs/"


static func run_all() -> Dictionary:
	var results: Dictionary = {
		"total": 0,
		"passed": 0,
		"failed": 0,
		"results": []
	}
	
	var specs: Array = _load_specs()
	
	for spec_data: Dictionary in specs:
		var result: Dictionary = {
			"id": spec_data.get("id", ""),
			"title": spec_data.get("title", ""),
			"passed": true,
			"failures": []
		}
		
		var criteria: Array = spec_data.get("acceptance_criteria", [])
		for criterion: String in criteria:
			var criterion_passed: bool = _evaluate_criterion(criterion)
			if not criterion_passed:
				result["passed"] = false
				result["failures"].append(criterion)
		
		if result["passed"]:
			results["passed"] += 1
		else:
			results["failed"] += 1
		
		results["results"].append(result)
	
	results["total"] = results["passed"] + results["failed"]
	
	return results


static func run_with_output() -> Dictionary:
	var results: Dictionary = run_all()
	
	for result: Dictionary in results["results"]:
		var status_str: String = "PASS" if result["passed"] else "FAIL"
		print("[Spec %s] %s: %s" % [status_str, result["id"], result["title"]])
		for failure: String in result["failures"]:
			print("  - %s" % failure)
	
	var summary: String = "Results: %d/%d passed" % [results["passed"], results["total"]]
	print(summary)
	
	return results


static func _evaluate_criterion(criterion: String) -> bool:
	match criterion:
		"Assert true":
			assert(true, "criterion failed")
			return true
		_:
			push_warning("unknown criterion: %s" % criterion)
			return false


static func _load_specs() -> Array:
	var specs: Array = []
	var dir: DirAccess = DirAccess.open(SPEC_DIR)
	
	if not dir:
		push_error("Failed to open spec directory: %s" % SPEC_DIR)
		return specs
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var file_path: String = SPEC_DIR + file_name
			var file_contents: String = FileAccess.get_file_as_string(file_path)
			var json_result: Variant = JSON.parse_string(file_contents)
			if json_result is Dictionary:
				specs.append(json_result as Dictionary)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	return specs
