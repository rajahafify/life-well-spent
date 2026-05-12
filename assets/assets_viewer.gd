@tool
## AssetsViewer — runtime/editor gallery for enemy asset PNG strips.
class_name AssetsViewer
extends Control

const ASSET_ROOT := "res://assets/enemies"
const ASSET_ROOTS := ["res://assets/enemies", "res://assets/npcs", "res://assets/player.png"]
const SUPPORTED_EXTENSIONS := ["png"]

@export var columns: int = 4
@export var thumbnail_size: Vector2 = Vector2(160, 120)


func _ready() -> void:
	rebuild_gallery()


func collect_asset_paths() -> Array:
	var paths: Array = []
	for root_path in ASSET_ROOTS:
		_collect_asset_paths(root_path, paths)
	paths.sort()
	return paths


func rebuild_gallery() -> void:
	_clear_children()

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 0.0
	scroll.offset_top = 0.0
	scroll.offset_right = 0.0
	scroll.offset_bottom = 0.0
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.name = "Title"
	title.text = "Asset Gallery"
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)

	var paths := collect_asset_paths()
	var summary := Label.new()
	summary.name = "Summary"
	summary.text = "%d PNG assets under enemies, NPCs, and player" % paths.size()
	summary.add_theme_font_size_override("font_size", 18)
	vbox.add_child(summary)

	var grid := GridContainer.new()
	grid.name = "GalleryGrid"
	grid.columns = max(1, columns)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for i in range(paths.size()):
		grid.add_child(_build_card(paths[i], i))


func _build_card(asset_path: String, index: int) -> Control:
	var card := VBoxContainer.new()
	card.name = "Card_%03d" % index
	card.set_meta("asset_path", asset_path)
	card.custom_minimum_size = Vector2(190, 170)
	card.add_theme_constant_override("separation", 4)

	var texture_rect := TextureRect.new()
	texture_rect.name = "Thumbnail"
	texture_rect.custom_minimum_size = thumbnail_size
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(asset_path):
		texture_rect.texture = load(asset_path)
	card.add_child(texture_rect)

	var label := Label.new()
	label.name = "PathLabel"
	label.text = asset_path.replace(ASSET_ROOT + "/", "")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(180, 42)
	label.add_theme_font_size_override("font_size", 12)
	card.add_child(label)
	return card


func _collect_asset_paths(dir_path: String, paths: Array) -> void:
	if ResourceLoader.exists(dir_path) and dir_path.get_extension().to_lower() in SUPPORTED_EXTENSIONS:
		paths.append(dir_path)
		return
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var child_path := dir_path.path_join(entry)
			if dir.current_is_dir():
				_collect_asset_paths(child_path, paths)
			else:
				var extension := entry.get_extension().to_lower()
				if extension in SUPPORTED_EXTENSIONS:
					paths.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
