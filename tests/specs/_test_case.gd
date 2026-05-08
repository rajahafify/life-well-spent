## TestCase — base class for all spec files.
## Subclass, override setup()/teardown()/class_setup() as needed,
## then write test_* methods using check() / check_eq() / check_neq().
class_name TestCase
extends Object

var _failures: Array[String] = []


# ── Lifecycle hooks ───────────────────────────────────────────────────
## Override these in your spec. All default to no-op.

func class_setup() -> void:
	pass


func setup() -> void:
	pass


func teardown() -> void:
	pass


# ── Failure tracking ──────────────────────────────────────────────────

func get_failures() -> Array[String]:
	return _failures.duplicate()


# ── Assertions ────────────────────────────────────────────────────────

func check(condition: bool, msg: String) -> bool:
	if not condition:
		_failures.append(msg)
		return false
	return true


func check_eq(got, expected, msg: String = "") -> bool:
	if not (got == expected):
		var desc: String = msg if msg else "expected %s == %s" % [got, expected]
		_failures.append("%s (got %s, expected %s)" % [desc, got, expected])
		return false
	return true


func check_neq(got, unexpected, msg: String = "") -> bool:
	if got == unexpected:
		var desc: String = msg if msg else "expected %s != %s" % [got, unexpected]
		_failures.append("%s (got %s)" % [desc, got])
		return false
	return true
