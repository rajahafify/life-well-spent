extends Resource

@export var id: String = "test"
@export var title: String = "Test Spec"
@export var description: String = "Baseline spec — proves the spec system works."
@export var acceptance_criteria: Array[String] = ["Assert true"]
@export var model_dependencies: Array[String] = []
@export var view_dependencies: Array[String] = []
@export var priority: int = 99
@export var status: String = "pending"


func run() -> bool:
	var passed: bool = true
	for criterion: String in acceptance_criteria:
		if criterion == "Assert true":
			assert(true, "criterion failed")
		else:
			warning_cache_push("unknown criterion: %s" % criterion)
			passed = false
	return passed
