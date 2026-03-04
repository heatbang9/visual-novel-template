extends Control

## 갤러리 UI
## CG, 배경화면, 캐릭터 스프라이트 갤러리 표시

signal gallery_closed

@onready var title_label: Label = $MainContainer/Header/Title
@onready var progress_label: Label = $MainContainer/Header/ProgressLabel
@onready var close_button: Button = $MainContainer/Header/CloseButton
@onready var category_tabs: TabContainer = $MainContainer/CategoryTabs
@onready var cg_grid: GridContainer = $MainContainer/CategoryTabs/CGImagesTab/CGGrid
@onready var bg_grid: GridContainer = $MainContainer/CategoryTabs/BackgroundsTab/BGGrid
@onready var char_grid: GridContainer = $MainContainer/CategoryTabs/CharactersTab/CharGrid
@onready var cg_viewer: Control = $CGViewer
@onready var image_display: TextureRect = $CGViewer/ImageDisplay
@onready var title_label_viewer: Label = $CGViewer/ImageInfo/TitleLabel
@onready var desc_label: Label = $CGViewer/ImageInfo/DescLabel
@onready var view_count_label: Label = $CGViewer/ImageInfo/ViewCountLabel
@onready var close_viewer_button: Button = $CGViewer/CloseViewerButton

var current_category: String = ""
var current_cg_id: String = ""

func _ready() -> void:
	_connect_signals()
	_localize_ui()
	refresh_gallery()

func _connect_signals() -> void:
	close_button.pressed.connect(_on_close_pressed)
	close_viewer_button.pressed.connect(_on_close_viewer_pressed)
	
	# 탭 변경 시그널
	category_tabs.tab_changed.connect(_on_tab_changed)

func _localize_ui() -> void:
	title_label.text = LocalizationManager.get_text("gallery_title", "CG Gallery")
	close_button.text = LocalizationManager.get_text("close", "Close")
	close_viewer_button.text = LocalizationManager.get_text("close", "Close")

# 갤러리 새로고침
func refresh_gallery() -> void:
	_clear_grids()
	_load_cg_images()
	_load_backgrounds()
	_load_characters()
	_update_progress()

# 그리드 클리어
func _clear_grids() -> void:
	for child in cg_grid.get_children():
		child.queue_free()
	
	for child in bg_grid.get_children():
		child.queue_free()
	
	for child in char_grid.get_children():
		child.queue_free()

# CG 이미지 로드
func _load_cg_images() -> void:
	var categories = GalleryManager.get_all_categories()
	
	for category_id in categories.keys():
		var category = categories[category_id]
		var category_frame = _create_category_frame(category["name"])
		cg_grid.add_child(category_frame)
		
		for cg_id in category["images"].keys():
			var cg_data = category["images"][cg_id]
			var cg_button = _create_cg_button(cg_data, category_id, cg_id)
			cg_grid.add_child(cg_button)

# 배경화면 로드
func _load_backgrounds() -> void:
	var backgrounds = GalleryManager.gallery_data["backgrounds"]
	
	for bg_id in backgrounds.keys():
		var bg_data = backgrounds[bg_id]
		var bg_button = _create_bg_button(bg_data, bg_id)
		bg_grid.add_child(bg_button)

# 캐릭터 로드
func _load_characters() -> void:
	var characters = GalleryManager.gallery_data["character_sprites"]
	
	for char_id in characters.keys():
		var char_data = characters[char_id]
		for sprite_name in char_data["sprites"].keys():
			var sprite_data = char_data["sprites"][sprite_name]
			var sprite_button = _create_sprite_button(sprite_data, char_id, sprite_name)
			char_grid.add_child(sprite_button)

# 카테고리 프레임 생성
func _create_category_frame(category_name: String) -> Control:
	var label = Label.new()
	label.text = category_name
	label.add_theme_font_size_override("font_size", 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var separator = HSeparator.new()
	
	var container = VBoxContainer.new()
	container.add_child(label)
	container.add_child(separator)
	
	return container

# CG 버튼 생성
func _create_cg_button(cg_data: Dictionary, category_id: String, cg_id: String) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 150)
	
	if cg_data["unlocked"]:
		# 언락된 경우 썸네일 표시
		var texture = load(cg_data["thumbnail_path"])
		if texture:
			button.icon = texture
			button.expand_icon = true
		button.tooltip_text = cg_data["title"]
		button.pressed.connect(_on_cg_button_pressed.bind(category_id, cg_id))
	else:
		# 언락되지 않은 경우 잠금 아이콘
		button.text = "🔒"
		button.disabled = true
	
	return button

# 배경화면 버튼 생성
func _create_bg_button(bg_data: Dictionary, bg_id: String) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 150)
	
	if bg_data["unlocked"]:
		var texture = load(bg_data["image_path"])
		if texture:
			button.icon = texture
			button.expand_icon = true
		button.tooltip_text = bg_data["name"]
		button.pressed.connect(_on_bg_button_pressed.bind(bg_id))
	else:
		button.text = "🔒"
		button.disabled = true
	
	return button

# 캐릭터 스프라이트 버튼 생성
func _create_sprite_button(sprite_data: Dictionary, char_id: String, sprite_name: String) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 150)
	
	if sprite_data["unlocked"]:
		var texture = load(sprite_data["image_path"])
		if texture:
			button.icon = texture
			button.expand_icon = true
		button.tooltip_text = sprite_name
		button.pressed.connect(_on_sprite_button_pressed.bind(char_id, sprite_name))
	else:
		button.text = "🔒"
		button.disabled = true
	
	return button

# 진행률 업데이트
func _update_progress() -> void:
	var unlocked = GalleryManager.get_unlocked_count()
	var total = GalleryManager.get_total_count()
	progress_label.text = "Unlocked: %d/%d (%.1f%%)" % [unlocked, total, GalleryManager.get_progress() * 100]

# CG 버튼 클릭
func _on_cg_button_pressed(category_id: String, cg_id: String) -> void:
	current_category = category_id
	current_cg_id = cg_id
	
	var cg_data = GalleryManager.view_cg(category_id, cg_id)
	if not cg_data.is_empty():
		_show_cg_viewer(cg_data)
		_update_progress()

# 배경화면 버튼 클릭
func _on_bg_button_pressed(bg_id: String) -> void:
	var bg_data = GalleryManager.gallery_data["backgrounds"][bg_id]
	if bg_data:
		_show_image_viewer(bg_data["name"], "", bg_data["image_path"])

# 캐릭터 스프라이트 버튼 클릭
func _on_sprite_button_pressed(char_id: String, sprite_name: String) -> void:
	var sprite_data = GalleryManager.gallery_data["character_sprites"][char_id]["sprites"][sprite_name]
	if sprite_data:
		_show_image_viewer(sprite_name, "", sprite_data["image_path"])

# CG 뷰어 표시
func _show_cg_viewer(cg_data: Dictionary) -> void:
	title_label_viewer.text = cg_data["title"]
	desc_label.text = cg_data["description"]
	view_count_label.text = "Viewed: %d times" % cg_data["view_count"]
	
	var texture = load(cg_data["image_path"])
	if texture:
		image_display.texture = texture
	
	cg_viewer.visible = true

# 이미지 뷰어 표시 (배경, 캐릭터용)
func _show_image_viewer(title: String, description: String, image_path: String) -> void:
	title_label_viewer.text = title
	desc_label.text = description
	view_count_label.text = ""
	
	var texture = load(image_path)
	if texture:
		image_display.texture = texture
	
	cg_viewer.visible = true

# 닫기 버튼
func _on_close_pressed() -> void:
	emit_signal("gallery_closed")
	hide()

# 뷰어 닫기
func _on_close_viewer_pressed() -> void:
	cg_viewer.visible = false

# 탭 변경
func _on_tab_changed(tab_index: int) -> void:
	_update_progress()

# 열기
func open() -> void:
	refresh_gallery()
	visible = true

# 닫기
func close() -> void:
	cg_viewer.visible = false
	visible = false
