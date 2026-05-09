## TestCase — Minitest-style base class for all spec files.
## Subclass, override setup()/teardown()/class_setup() as needed,
## then write test_* methods using assert_* helpers.
class_name TestCase
extends Object

var _failures: Array[Dictionary] = []
var _current_file: String = ""
var _current_test: String = ""


# ── Lifecycle hooks ───────────────────────────────────────────────────
## Override these in your spec. All default to no-op.

func class_setup() -> void:
	pass


func setup() -> void:
	pass


func teardown() -> void:
	pass


# ── Framework hooks ───────────────────────────────────────────────────
## Called by TestRunner. Specs should not override these.

func _framework_before_test(file_path: String, test_name: String) -> void:
	_current_file = file_path
	_current_test = test_name
	_failures.clear()


# ── Failure tracking ──────────────────────────────────────────────────

func get_failures() -> Array[Dictionary]:
	return _failures.duplicate()


func fail(message: String = "failed") -> bool:
	_record_failure(message)
	return false


func _record_failure(message: String, expected = null, actual = null) -> void:
	_failures.append({
		"message": message,
		"expected": expected,
		"actual": actual,
		"file": _current_file,
		"test": _current_test,
	})


# ── Assertions ────────────────────────────────────────────────────────

func assert_true(condition: bool, message: String = "") -> bool:
	if not condition:
		_record_failure(message if message else "expected value to be true", true, condition)
		return false
	return true


func assert_false(condition: bool, message: String = "") -> bool:
	if condition:
		_record_failure(message if message else "expected value to be false", false, condition)
		return false
	return true


func assert_eq(expected, actual, message: String = "") -> bool:
	if not (actual == expected):
		var desc: String = message if message else "expected values to be equal"
		_record_failure(desc, expected, actual)
		return false
	return true


func assert_neq(unexpected, actual, message: String = "") -> bool:
	if actual == unexpected:
		var desc: String = message if message else "expected values to differ"
		_record_failure(desc, "not %s" % [unexpected], actual)
		return false
	return true


func assert_in(expected_item, collection, message: String = "") -> bool:
	if not (expected_item in collection):
		var desc: String = message if message else "expected collection to include item"
		_record_failure(desc, expected_item, collection)
		return false
	return true


func assert_has(collection: Dictionary, key, message: String = "") -> bool:
	if not collection.has(key):
		var desc: String = message if message else "expected dictionary to include key"
		_record_failure(desc, key, collection)
		return false
	return true


func assert_null(actual, message: String = "") -> bool:
	if actual != null:
		var desc: String = message if message else "expected value to be null"
		_record_failure(desc, null, actual)
		return false
	return true


func assert_not_null(actual, message: String = "") -> bool:
	if actual == null:
		var desc: String = message if message else "expected value not to be null"
		_record_failure(desc, "not null", actual)
		return false
	return true


# ── Backward-compatible aliases ───────────────────────────────────────
## Existing specs used check_* helpers. Keep these while specs migrate.

func check(condition: bool, msg: String) -> bool:
	return assert_true(condition, msg)


func check_eq(got, expected, msg: String = "") -> bool:
	return assert_eq(expected, got, msg)


func check_neq(got, unexpected, msg: String = "") -> bool:
	return assert_neq(unexpected, got, msg)
