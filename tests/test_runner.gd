## TestRunner — Minitest-style GDScript spec runner and CI entrypoint.
## Attach this script to tests/test_runner.tscn.
extends Node

const SPEC_DIR: String = "res://tests/specs/"


func _ready() -> void:
	var results: Dictionary = run_with_output(_test_filter_from_args())
	get_tree().quit(1 if results["failed"] > 0 else 0)


# ── Public API ────────────────────────────────────────────────────────

static func run_all(filter: String = "") -> Dictionary:
	var results: Dictionary = {
		"total": 0,
		"passed": 0,
		"failed": 0,
		"results": []
	}

	var spec_files: Array[String] = _discover_specs()

	for file_path: String in spec_files:
		var file_results: Array = _run_spec_file(file_path, filter)
		results["results"].append_array(file_results)

	for r: Dictionary in results["results"]:
		if r["passed"]:
			results["passed"] += 1
		else:
			results["failed"] += 1

	results["total"] = results["passed"] + results["failed"]
	return results


static func run_with_output(filter: String = "") -> Dictionary:
	var results: Dictionary = run_all(filter)
	_print_summary(results)
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
	files.sort()
	return files


# ── Execution ─────────────────────────────────────────────────────────

static func _run_spec_file(file_path: String, filter: String = "") -> Array:
	var results: Array = []

	var script: GDScript = load(file_path)
	if not script:
		return [_load_failure(file_path, "failed to load spec script")]

	var class_instance: Object = script.new()
	_try(class_instance, "class_setup")

	var tests: Array = _find_test_methods(class_instance)
	class_instance.free()

	for test_name: String in tests:
		var test_id: String = "%s.%s" % [_class_label(file_path), test_name]
		if filter != "" and not file_path.contains(filter) and not test_id.contains(filter) and not test_name.contains(filter):
			continue
		var test_result: Dictionary = {
			"passed": true,
			"id": test_id,
			"title": test_name,
			"file": file_path,
			"class": _class_label(file_path),
			"failures": []
		}

		var instance: Object = script.new()
		if instance.has_method("_framework_before_test"):
			instance.call("_framework_before_test", file_path, test_name)

		_try(instance, "setup")
		_try(instance, test_name)

		var failures: Array = []
		if instance.has_method("get_failures"):
			failures = instance.call("get_failures") as Array
		if failures.size() > 0:
			test_result["passed"] = false
			for failure in failures:
				test_result["failures"].append(_normalize_failure(failure, file_path, test_name))

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
		var method_name: String = mi.get("name", "")
		if method_name.begins_with("test_") and not method_name.begins_with("test__"):
			methods.append(method_name)

	methods.sort()
	return methods


static func _class_label(file_path: String) -> String:
	return file_path.get_file().get_basename().to_pascal_case()


static func _load_failure(file_path: String, message: String) -> Dictionary:
	return {
		"passed": false,
		"id": "%s.load" % _class_label(file_path),
		"title": "load",
		"file": file_path,
		"class": _class_label(file_path),
		"failures": [{
			"name": "load",
			"message": message,
			"expected": "loadable script",
			"actual": file_path,
			"file": file_path,
			"test": "load",
		}]
	}


static func _normalize_failure(failure, file_path: String, test_name: String) -> Dictionary:
	if failure is Dictionary:
		return {
			"name": test_name,
			"message": failure.get("message", "assertion failed"),
			"expected": failure.get("expected", null),
			"actual": failure.get("actual", null),
			"file": failure.get("file", file_path),
			"test": failure.get("test", test_name),
		}

	return {
		"name": test_name,
		"message": str(failure),
		"expected": null,
		"actual": null,
		"file": file_path,
		"test": test_name,
	}


static func _print_summary(results: Dictionary) -> void:
	print("Running %d tests" % results["total"])
	var progress := ""
	for r: Dictionary in results["results"]:
		progress += "." if r["passed"] else "F"
	print(progress)

	if results["failed"] > 0:
		print("\nFailures:")
		var failure_index := 1
		for r: Dictionary in results["results"]:
			if r["passed"]:
				continue
			for failure: Dictionary in r["failures"]:
				print("\n%d) %s" % [failure_index, r["id"]])
				print("   %s" % failure.get("message", "assertion failed"))
				if failure.has("expected"):
					print("   Expected: %s" % _format_value(failure["expected"]))
				if failure.has("actual"):
					print("   Actual:   %s" % _format_value(failure["actual"]))
				print("   File: %s" % failure.get("file", r.get("file", "")))
				failure_index += 1

	print("\n%d tests, %d passed, %d failed" % [
		results["total"], results["passed"], results["failed"]
	])


static func _format_value(value) -> String:
	if value == null:
		return "null"
	return str(value)


static func _test_filter_from_args() -> String:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size()):
		if args[i] == "--filter" and i + 1 < args.size():
			return args[i + 1]
	return ""
