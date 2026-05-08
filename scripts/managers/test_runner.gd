## TestRunner — discovers and executes GDScript-based spec files.
## Scans tests/specs/ for test_*.gd files, loads the class, runs all
## test_* methods, and aggregates results.
class_name TestRunner
extends Object

const SPEC_DIR: String = "res://tests/specs/"


# ── Public API ────────────────────────────────────────────────────────

static func run_all() -> Dictionary:
	var results: Dictionary = {
		"total": 0,
		"passed": 0,
		"failed": 0,
		"results": []
	}

	var spec_files: Array[String] = _discover_specs()

	for file_path: String in spec_files:
		var file_results: Array = _run_spec_file(file_path)
		results["results"].append_array(file_results)

	for r: Dictionary in results["results"]:
		if r["passed"]:
			results["passed"] += 1
		else:
			results["failed"] += 1

	results["total"] = results["passed"] + results["failed"]
	return results


static func run_with_output() -> Dictionary:
	var results: Dictionary = run_all()

	for r: Dictionary in results["results"]:
		var status: String = "PASS" if r["passed"] else "FAIL"
		print("[%s] %s" % [status, r["id"]])
		for failure: Dictionary in r["failures"]:
			print("  %s" % failure["message"])

	print("\nResults: %d/%d passed" % [results["passed"], results["total"]])
	return results


# ── Discovery ─────────────────────────────────────────────────────────

static func _discover_specs() -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(SPEC_DIR)

	if not dir:
		push_error("Failed to open spec directory: %s" % SPEC_DIR)
		return files

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".gd") and (file_name.begins_with("test_") or file_name.ends_with("_test.gd")):
			files.append(SPEC_DIR + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return files


# ── Execution ─────────────────────────────────────────────────────────

static func _run_spec_file(file_path: String) -> Array:
	var results: Array = []

	var script: GDScript = load(file_path)
	var instance: Object = script.new()

	# class_setup once
	_try(instance, "class_setup")

	# find test_* methods
	var tests: Array = _find_test_methods(instance)

	for test_name: String in tests:
		var test_result: Dictionary = {
			"passed": true,
			"id": test_name,
			"title": test_name,
			"failures": []
		}

		# setup
		_try(instance, "setup")

		# test
		_try(instance, test_name)

		# Check for failures — specs track them via get_failures()
		var failures: Array = []
		if instance.has_method("get_failures"):
			failures = instance.call("get_failures") as Array
		if failures.size() > 0:
			test_result["passed"] = false
			for failure_msg: String in failures:
				test_result["failures"].append({
					"name": test_name,
					"message": failure_msg
				})

		# teardown
		_try(instance, "teardown")

		results.append(test_result)

	instance.free()
	return results


# ── Helpers ───────────────────────────────────────────────────────────

static func _try(target: Object, method: String) -> void:
	if target.has_method(method):
		target.callv(method, [])


static func _find_test_methods(instance: Object) -> Array:
	var methods: Array = []
	var method_list: Array = instance.get_method_list()

	for mi: Dictionary in method_list:
		var name: String = mi.get("name", "")
		if name.begins_with("test_") and not name.begins_with("test__"):
			methods.append(name)

	return methods
