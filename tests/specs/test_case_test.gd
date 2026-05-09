# tests/specs/test_case_test.gd
# Spec: TestCase framework helpers and failure isolation hooks

class_name TestTestCase
extends TestCase

var subject: TestCase


func setup() -> void:
	subject = TestCase.new()
	subject._framework_before_test("res://tests/specs/test_case_test.gd", "inner_test")


func test_assert_eq_records_expected_and_actual() -> void:
	subject.assert_eq("expected", "actual", "values should match")

	var failures := subject.get_failures()
	assert_eq(1, failures.size())
	assert_eq("values should match", failures[0]["message"])
	assert_eq("expected", failures[0]["expected"])
	assert_eq("actual", failures[0]["actual"])


func test_assert_true_passes_without_failure() -> void:
	subject.assert_true(true)

	assert_eq(0, subject.get_failures().size())


func test_framework_before_test_clears_previous_failures() -> void:
	subject.fail("old failure")
	assert_eq(1, subject.get_failures().size())

	subject._framework_before_test("res://tests/specs/test_case_test.gd", "next_test")

	assert_eq(0, subject.get_failures().size())


func test_check_eq_alias_keeps_got_expected_order() -> void:
	subject.check_eq("actual", "expected", "legacy alias")

	var failures := subject.get_failures()
	assert_eq("expected", failures[0]["expected"])
	assert_eq("actual", failures[0]["actual"])
