## TownDialogView — owns town dialog UI presentation.
## View layer: no quest/business decisions, only labels, visibility, pages, and button signals.
class_name TownDialogView
extends PanelContainer

signal accept_quest_requested
signal complete_quest_requested
signal close_requested

var _name_label: Label
var _body_label: Label
var _accept_quest_button: Button
var _complete_quest_button: Button
var _next_button: Button
var _close_dialog_button: Button
var _pages: Array[String] = []
var _page_index: int = 0


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
	if _next_button == null:
		_next_button = get_node_or_null("VBox/Buttons/NextButton") as Button
	if _close_dialog_button == null:
		_close_dialog_button = get_node_or_null("VBox/Buttons/CloseButton") as Button
	_connect_buttons()


func show_dialog(display_name: String, body_text: String, can_offer_quest: bool, has_active_quest: bool) -> void:
	show_dialog_pages(display_name, _split_pages(body_text), can_offer_quest, has_active_quest)


func show_dialog_pages(display_name: String, pages: Array[String], can_offer_quest: bool, has_active_quest: bool) -> void:
	ensure_ready()
	visible = true
	_pages = pages.duplicate()
	if _pages.is_empty():
		_pages.append("")
	_page_index = 0
	if _name_label:
		_name_label.text = display_name
	_update_page()
	configure_buttons(can_offer_quest, has_active_quest)


func next_page() -> void:
	ensure_ready()
	if _page_index < _pages.size() - 1:
		_page_index += 1
		_update_page()
		_update_next_button()


func configure_buttons(can_offer_quest: bool, has_active_quest: bool) -> void:
	ensure_ready()
	if _accept_quest_button:
		_accept_quest_button.visible = can_offer_quest
	if _complete_quest_button:
		_complete_quest_button.visible = has_active_quest
	_update_next_button()
	if _close_dialog_button:
		_close_dialog_button.visible = true


func set_body(text: String) -> void:
	ensure_ready()
	_pages = _split_pages(text)
	_page_index = 0
	_update_page()
	_update_next_button()


func hide_dialog() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _split_pages(body_text: String) -> Array[String]:
	var pages: Array[String] = []
	for page in body_text.split("\n\n"):
		var clean := str(page).strip_edges()
		if clean != "":
			pages.append(clean)
	return pages


func _update_page() -> void:
	if _body_label:
		_body_label.text = _pages[_page_index] if _page_index < _pages.size() else ""


func _update_next_button() -> void:
	if _next_button:
		_next_button.visible = _page_index < _pages.size() - 1


func _connect_buttons() -> void:
	if _accept_quest_button and not _accept_quest_button.pressed.is_connected(_on_accept_quest_pressed):
		_accept_quest_button.pressed.connect(_on_accept_quest_pressed)
	if _complete_quest_button and not _complete_quest_button.pressed.is_connected(_on_complete_quest_pressed):
		_complete_quest_button.pressed.connect(_on_complete_quest_pressed)
	if _next_button and not _next_button.pressed.is_connected(next_page):
		_next_button.pressed.connect(next_page)
	if _close_dialog_button and not _close_dialog_button.pressed.is_connected(_on_close_dialog_pressed):
		_close_dialog_button.pressed.connect(_on_close_dialog_pressed)


func _on_accept_quest_pressed() -> void:
	accept_quest_requested.emit()


func _on_complete_quest_pressed() -> void:
	complete_quest_requested.emit()


func _on_close_dialog_pressed() -> void:
	close_requested.emit()
