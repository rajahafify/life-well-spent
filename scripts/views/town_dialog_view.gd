## TownDialogView — owns town dialog UI presentation.
## View layer: no quest/business decisions, only labels, visibility, and button signals.
class_name TownDialogView
extends PanelContainer

signal accept_quest_requested
signal complete_quest_requested
signal close_requested

var _name_label: Label
var _body_label: Label
var _accept_quest_button: Button
var _complete_quest_button: Button
var _close_dialog_button: Button


func _ready() -> void:
	ensure_ready()


func ensure_ready() -> void:
	if _name_label == null:
		_name_label = get_node_or_null("VBox/NameLabel") as Label
	if _body_label == null:
		_body_label = get_node_or_null("VBox/BodyLabel") as Label
	if _accept_quest_button == null:
		_accept_quest_button = get_node_or_null("VBox/Buttons/AcceptQuestButton") as Button
	if _complete_quest_button == null:
		_complete_quest_button = get_node_or_null("VBox/Buttons/CompleteQuestButton") as Button
	if _close_dialog_button == null:
		_close_dialog_button = get_node_or_null("VBox/Buttons/CloseButton") as Button
	_connect_buttons()


func show_dialog(display_name: String, body_text: String, can_offer_quest: bool, has_active_quest: bool) -> void:
	ensure_ready()
	visible = true
	if _name_label:
		_name_label.text = display_name
	if _body_label:
		_body_label.text = body_text
	configure_buttons(can_offer_quest, has_active_quest)


func configure_buttons(can_offer_quest: bool, has_active_quest: bool) -> void:
	ensure_ready()
	if _accept_quest_button:
		_accept_quest_button.visible = can_offer_quest
	if _complete_quest_button:
		_complete_quest_button.visible = has_active_quest
	if _close_dialog_button:
		_close_dialog_button.visible = true


func set_body(text: String) -> void:
	ensure_ready()
	if _body_label:
		_body_label.text = text


func hide_dialog() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _connect_buttons() -> void:
	if _accept_quest_button and not _accept_quest_button.pressed.is_connected(_on_accept_quest_pressed):
		_accept_quest_button.pressed.connect(_on_accept_quest_pressed)
	if _complete_quest_button and not _complete_quest_button.pressed.is_connected(_on_complete_quest_pressed):
		_complete_quest_button.pressed.connect(_on_complete_quest_pressed)
	if _close_dialog_button and not _close_dialog_button.pressed.is_connected(_on_close_dialog_pressed):
		_close_dialog_button.pressed.connect(_on_close_dialog_pressed)


func _on_accept_quest_pressed() -> void:
	accept_quest_requested.emit()


func _on_complete_quest_pressed() -> void:
	complete_quest_requested.emit()


func _on_close_dialog_pressed() -> void:
	close_requested.emit()
