extends Control

class_name GameSelectorMenu

signal game_selected(game_id: String)
signal settings_requested()
signal admin_panel_requested()

@export var game_manager: GameProjectManager
@export var localization_manager: LocalizationManager

# UI 노드들
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var featured_games_container: HBoxContainer = $VBoxContainer/FeaturedSection/FeaturedGamesContainer
@onready var all_games_grid: GridContainer = $VBoxContainer/ScrollContainer/AllGamesGrid
@onready var search_bar: LineEdit = $VBoxContainer/SearchSection/SearchBar
@onready var genre_filter: OptionButton = $VBoxContainer/SearchSection/GenreFilter
@onready var settings_button: Button = $VBoxContainer/BottomSection/SettingsButton
@onready var admin_button: Button = $VBoxContainer/BottomSection/AdminButton
@onready var version_label: Label = $VBoxContainer/BottomSection/VersionLabel

# 게임 카드 씬
@export var game_card_scene: PackedScene = preload("res://scenes/ui/game_card.tscn")
@export var featured_card_scene: PackedScene = preload("res://scenes/ui/featured_game_card.tscn")

var current_games: Array = []
var current_language: String = "ko"

func _ready() -> void:
	_setup_ui()
	_setup_signals()
	_load_games()
	_setup_admin_mode()

func _setup_ui() -> void:
	# UI 기본 설정
	if title_label:
		title_label.text = "Visual Novel Collection"
	
	if version_label:
		version_label.text = "v" + ProjectSettings.get_setting("application/config/version", "1.0.0")
	
	# 검색바 설정
	if search_bar:
		search_bar.placeholder_text = "게임 검색..."
		search_bar.clear_button_enabled = true
	
	# 장르 필터 설정
	_setup_genre_filter()

func _setup_signals() -> void:
	if game_manager:
		game_manager.games_list_updated.connect(_on_games_list_updated)
		game_manager.game_loaded.connect(_on_game_loaded)
	
	if search_bar:
		search_bar.text_changed.connect(_on_search_text_changed)
	
	if genre_filter:
		genre_filter.item_selected.connect(_on_genre_filter_changed)
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	
	if admin_button:
		admin_button.pressed.connect(_on_admin_button_pressed)

func _setup_genre_filter() -> void:
	if not genre_filter:
		return
	
	genre_filter.clear()
	genre_filter.add_item("모든 장르", -1)
	
	var genres = ["romance", "mystery", "sci-fi", "adventure", "comedy", "drama", "thriller", "fantasy"]
	for i in range(genres.size()):
		genre_filter.add_item(genres[i], i)

func _setup_admin_mode() -> void:
	if not admin_button:
		return
	
	# 개발 모드에서만 관리자 버튼 표시
	if game_manager and game_manager.is_development_mode():
		admin_button.visible = true
	else:
		admin_button.visible = false

func _load_games() -> void:
	if not game_manager:
		push_error("GameProjectManager not found")
		return
	
	current_games = []
	var games_dict = game_manager.get_available_games()
	
	for game_id in games_dict:
		current_games.append(games_dict[game_id])
	
	_update_game_display()

func _update_game_display() -> void:
	_display_featured_games()
	_display_all_games()

func _display_featured_games() -> void:
	if not featured_games_container:
		return
	
	# 기존 카드들 정리
	for child in featured_games_container.get_children():
		child.queue_free()
	
	var featured_games = game_manager.get_featured_games()
	
	for game_data in featured_games:
		var card = _create_featured_game_card(game_data)
		if card:
			featured_games_container.add_child(card)

func _display_all_games() -> void:
	if not all_games_grid:
		return
	
	# 기존 카드들 정리
	for child in all_games_grid.get_children():
		child.queue_free()
	
	# 필터링된 게임들 표시
	var filtered_games = _get_filtered_games()
	
	for game_data in filtered_games:
		var card = _create_game_card(game_data)
		if card:
			all_games_grid.add_child(card)

func _create_featured_game_card(game_data: Dictionary) -> Control:
	var card: Control
	
	if featured_card_scene:
		card = featured_card_scene.instantiate()
	else:
		card = _create_default_featured_card()
	
	_setup_game_card(card, game_data, true)
	return card

func _create_game_card(game_data: Dictionary) -> Control:
	var card: Control
	
	if game_card_scene:
		card = game_card_scene.instantiate()
	else:
		card = _create_default_game_card()
	
	_setup_game_card(card, game_data, false)
	return card

func _create_default_featured_card() -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(300, 200)
	
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	
	# 배너 이미지
	var banner = TextureRect.new()
	banner.name = "BannerTexture"
	banner.custom_minimum_size = Vector2(300, 120)
	banner.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	vbox.add_child(banner)
	
	# 제목
	var title = Label.new()
	title.name = "TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	# 설명
	var desc = Label.new()
	desc.name = "DescriptionLabel"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.y = 40
	vbox.add_child(desc)
	
	# 플레이 버튼
	var button = Button.new()
	button.name = "PlayButton"
	button.text = "플레이"
	vbox.add_child(button)
	
	return card

func _create_default_game_card() -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(200, 280)
	
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	
	# 썸네일 이미지
	var thumbnail = TextureRect.new()
	thumbnail.name = "ThumbnailTexture"
	thumbnail.custom_minimum_size = Vector2(200, 150)
	thumbnail.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	vbox.add_child(thumbnail)
	
	# 제목
	var title = Label.new()
	title.name = "TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)
	
	# 장르
	var genre = Label.new()
	genre.name = "GenreLabel"
	genre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	genre.add_theme_font_size_override("font_size", 10)
	vbox.add_child(genre)
	
	# 플레이타임
	var playtime = Label.new()
	playtime.name = "PlaytimeLabel"
	playtime.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	playtime.add_theme_font_size_override("font_size", 10)
	vbox.add_child(playtime)
	
	# 플레이 버튼
	var button = Button.new()
	button.name = "PlayButton"
	button.text = "플레이"
	vbox.add_child(button)
	
	return card

func _setup_game_card(card: Control, game_data: Dictionary, is_featured: bool) -> void:
	var game_id = game_data.get("id", "")
	
	# 제목 설정
	var title_label = card.get_node_or_null("TitleLabel")
	if title_label:
		title_label.text = game_manager.get_game_title(game_id, current_language)
	
	# 이미지 설정
	if is_featured:
		var banner_texture = card.get_node_or_null("BannerTexture")
		if banner_texture:
			_load_game_image(banner_texture, game_data.get("banner", ""))
	else:
		var thumbnail_texture = card.get_node_or_null("ThumbnailTexture")
		if thumbnail_texture:
			_load_game_image(thumbnail_texture, game_data.get("thumbnail", ""))
	
	# 설명 설정 (featured 카드만)
	if is_featured:
		var desc_label = card.get_node_or_null("DescriptionLabel")
		if desc_label:
			desc_label.text = game_manager.get_game_description(game_id, current_language)
	
	# 장르 설정 (일반 카드만)
	if not is_featured:
		var genre_label = card.get_node_or_null("GenreLabel")
		if genre_label:
			var genres = game_data.get("genre", [])
			if genres.size() > 0:
				genre_label.text = genres[0].capitalize()
		
		# 플레이타임 설정
		var playtime_label = card.get_node_or_null("PlaytimeLabel")
		if playtime_label:
			var minutes = game_data.get("estimated_playtime", 0)
			playtime_label.text = "%d분" % minutes
	
	# 플레이 버튼 설정
	var play_button = card.get_node_or_null("PlayButton")
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed.bind(game_id))
	
	# 카드 메타데이터 설정
	card.set_meta("game_id", game_id)
	card.set_meta("game_data", game_data)

func _load_game_image(texture_rect: TextureRect, image_path: String) -> void:
	if image_path.is_empty():
		return
	
	if FileAccess.file_exists(image_path):
		var texture = load(image_path)
		if texture:
			texture_rect.texture = texture
	else:
		# 기본 이미지 로딩
		var default_texture = load("res://icon.png")
		if default_texture:
			texture_rect.texture = default_texture

func _get_filtered_games() -> Array:
	var filtered = current_games.duplicate()
	
	# 검색어 필터링
	var search_text = search_bar.text.strip_edges().to_lower() if search_bar else ""
	if not search_text.is_empty():
		filtered = filtered.filter(func(game): 
			var title = game_manager.get_game_title(game.get("id", ""), current_language).to_lower()
			var desc = game_manager.get_game_description(game.get("id", ""), current_language).to_lower()
			return title.contains(search_text) or desc.contains(search_text)
		)
	
	# 장르 필터링
	if genre_filter and genre_filter.selected > 0:
		var selected_genre = genre_filter.get_item_text(genre_filter.selected)
		filtered = filtered.filter(func(game):
			var genres = game.get("genre", [])
			return genres.has(selected_genre)
		)
	
	return filtered

# 시그널 핸들러들
func _on_games_list_updated() -> void:
	_load_games()

func _on_game_loaded(game_data: Dictionary) -> void:
	# 게임 로딩 완료 후 씬 전환
	get_tree().change_scene_to_file("res://project/MainScene.tscn")

func _on_play_button_pressed(game_id: String) -> void:
	if game_manager:
		var error = game_manager.select_game(game_id)
		if error == OK:
			emit_signal("game_selected", game_id)

func _on_search_text_changed(new_text: String) -> void:
	_display_all_games()

func _on_genre_filter_changed(index: int) -> void:
	_display_all_games()

func _on_settings_button_pressed() -> void:
	emit_signal("settings_requested")

func _on_admin_button_pressed() -> void:
	emit_signal("admin_panel_requested")

# 다국어 지원
func set_language(language: String) -> void:
	current_language = language
	_update_ui_text()
	_update_game_display()

func _update_ui_text() -> void:
	if localization_manager:
		if title_label:
			title_label.text = localization_manager.get_text("ui.main_menu.title", "general", "Visual Novel Collection")
		
		if search_bar:
			search_bar.placeholder_text = localization_manager.get_text("ui.main_menu.search_placeholder", "general", "게임 검색...")
		
		if settings_button:
			settings_button.text = localization_manager.get_text("ui.main_menu.settings", "general", "설정")
		
		if admin_button:
			admin_button.text = localization_manager.get_text("ui.main_menu.admin", "general", "관리자")

# 키보드 입력 처리
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F12:
				if game_manager and game_manager.is_development_mode():
					_on_admin_button_pressed()
			KEY_ESCAPE:
				get_tree().quit()

# 관리자 기능
func refresh_games_list() -> void:
	if game_manager:
		game_manager.load_games_configuration()

func show_game_statistics() -> void:
	if game_manager:
		var stats = game_manager.get_games_statistics()
		print("=== 게임 통계 ===")
		print("총 게임 수: ", stats.total_games)
		print("활성 게임 수: ", stats.enabled_games)
		print("추천 게임 수: ", stats.featured_games)
		print("총 플레이타임: ", stats.total_playtime, "분")
		print("장르별 분포: ", stats.genres)
		print("등급별 분포: ", stats.ratings)