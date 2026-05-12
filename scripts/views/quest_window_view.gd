## QuestWindowView - dumb UI for current quest objective display.
class_name QuestWindowView
extends PanelContainer

var _title_label: Label
var _objective_label: Label


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	_setup_layout()
	_title_label = get_node_or_null("VBox/TitleLabel") as Label
	_objective_label = get_node_or_null("VBox/ObjectiveLabel") as Label


func show_main_objective(quest_title: String, objective_text: String, checkpoint_text: String = "") -> void:
	ensure_ready()
	if _title_label:
		_title_label.text = "Quest"
	if _objective_label:
		_objective_label.text = "%s\n%s" % [quest_title, objective_text]


func _setup_layout() -> void:
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0
	offset_left = -430.0
	offset_top = 24.0
	offset_right = -28.0
	offset_bottom = 150.0
	if get_node_or_null("VBox") == null:
		var vbox := VBoxContainer.new()
		vbox.name = "VBox"
		add_child(vbox)
	if get_node_or_null("VBox/TitleLabel") == null:
		var title := Label.new()
		title.name = "TitleLabel"
		title.text = "Quest"
		title.add_theme_font_size_override("font_size", 22)
		get_node("VBox").add_child(title)
	if get_node_or_null("VBox/ObjectiveLabel") == null:
		var objective := Label.new()
		objective.name = "ObjectiveLabel"
		objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		objective.add_theme_font_size_override("font_size", 24)
		get_node("VBox").add_child(objective)
