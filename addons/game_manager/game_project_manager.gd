extends Node

class_name GameProjectManager

signal game_selected(game_id: String)
signal game_loaded(game_data: Dictionary)
signal games_list_updated()

@export var games_config_path: String = "res://games/games_config.json"
@export var enabled_games_only: bool = false

var available_games: Dictionary = {}
var current_game: Dictionary = {}
var deployment_config: Dictionary = {}

func _ready() -> void:
	load_games_configuration()

# 게임 설정 로딩
func load_games_configuration() -> Error:
	if not FileAccess.file_exists(games_config_path):
		push_error("Games configuration not found: " + games_config_path)
		_create_default_config()
		return Error.FAILED
	
	var file = FileAccess.open(games_config_path, FileAccess.READ)
	if not file:
		push_error("Failed to open games config: " + games_config_path)
		return Error.FAILED
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse games config JSON")
		return Error.FAILED
	
	var config_data = json.data
	available_games = config_data.get("games", {})
	deployment_config = config_data.get("deployment", {})
	
	# 배포 모드에서는 활성화된 게임만 로딩
	if enabled_games_only:
		_filter_enabled_games()
	
	emit_signal("games_list_updated")
	return OK

# 기본 설정 생성
func _create_default_config() -> void:
	var default_config = {
		"games": {
			"school_romance": {
				"id": "school_romance",
				"title": "학교 생활 로맨스",
				"title_en": "School Life Romance",
				"title_ja": "学校生活ロマンス",
				"description": "고등학교에서 펼쳐지는 달콤한 청춘 로맨스",
				"description_en": "Sweet youth romance unfolding in high school",
				"description_ja": "高校で繰り広げられる甘い青春ロマンス",
				"version": "1.0.0",
				"author": "Visual Novel Studio",
				"thumbnail": "res://games/school_romance/thumbnail.png",
				"banner": "res://games/school_romance/banner.png",
				"scenario_path": "res://games/school_romance/scenarios/",
				"main_scenario": "main_story.xml",
				"estimated_playtime": 60,
				"genre": ["romance", "school", "comedy"],
				"rating": "Teen",
				"enabled": true,
				"featured": true,
				"release_date": "2024-11-23",
				"last_updated": "2024-11-23"
			},
			"mystery_detective": {
				"id": "mystery_detective",
				"title": "미스터리 탐정",
				"title_en": "Mystery Detective",
				"title_ja": "ミステリー探偵",
				"description": "도시에서 벌어지는 미스터리한 사건들을 해결하는 탐정 이야기",
				"description_en": "Detective story solving mysterious cases in the city",
				"description_ja": "都市で起こる謎めいた事件を解決する探偵の物語",
				"version": "1.0.0",
				"author": "Visual Novel Studio",
				"thumbnail": "res://games/mystery_detective/thumbnail.png",
				"banner": "res://games/mystery_detective/banner.png",
				"scenario_path": "res://games/mystery_detective/scenarios/",
				"main_scenario": "main_story.xml",
				"estimated_playtime": 75,
				"genre": ["mystery", "detective", "thriller"],
				"rating": "Teen",
				"enabled": true,
				"featured": true,
				"release_date": "2024-11-23",
				"last_updated": "2024-11-23"
			},
			"space_adventure": {
				"id": "space_adventure",
				"title": "스페이스 어드벤처",
				"title_en": "Space Adventure",
				"title_ja": "スペースアドベンチャー",
				"description": "먼 미래, 우주를 탐험하며 벌어지는 모험 이야기",
				"description_en": "Adventure story exploring space in the distant future",
				"description_ja": "遠い未来、宇宙を探検して繰り広げられる冒険の物語",
				"version": "1.0.0",
				"author": "Visual Novel Studio",
				"thumbnail": "res://games/space_adventure/thumbnail.png",
				"banner": "res://games/space_adventure/banner.png",
				"scenario_path": "res://games/space_adventure/scenarios/",
				"main_scenario": "main_story.xml",
				"estimated_playtime": 90,
				"genre": ["sci-fi", "adventure", "space"],
				"rating": "Teen",
				"enabled": true,
				"featured": false,
				"release_date": "2024-11-23",
				"last_updated": "2024-11-23"
			}
		},
		"deployment": {
			"build_mode": "development",
			"enabled_games": ["school_romance", "mystery_detective", "space_adventure"],
			"featured_games": ["school_romance", "mystery_detective"],
			"show_development_games": true,
			"auto_update_check": true
		}
	}
	
	var file = FileAccess.open(games_config_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(default_config, "\t"))
		file.close()

# 활성화된 게임만 필터링
func _filter_enabled_games() -> void:
	var enabled_games = deployment_config.get("enabled_games", [])
	var filtered_games = {}
	
	for game_id in available_games:
		var game_data = available_games[game_id]
		if game_data.get("enabled", false) and enabled_games.has(game_id):
			filtered_games[game_id] = game_data
	
	available_games = filtered_games

# 게임 목록 가져오기
func get_available_games() -> Dictionary:
	return available_games

func get_featured_games() -> Array:
	var featured = []
	for game_id in available_games:
		var game_data = available_games[game_id]
		if game_data.get("featured", false):
			featured.append(game_data)
	
	# 출시일 순으로 정렬
	featured.sort_custom(func(a, b): return a.get("release_date", "") > b.get("release_date", ""))
	return featured

func get_games_by_genre(genre: String) -> Array:
	var filtered = []
	for game_id in available_games:
		var game_data = available_games[game_id]
		var genres = game_data.get("genre", [])
		if genres.has(genre):
			filtered.append(game_data)
	return filtered

# 게임 선택 및 로딩
func select_game(game_id: String) -> Error:
	if not available_games.has(game_id):
		push_error("Game not found: " + game_id)
		return Error.FAILED
	
	current_game = available_games[game_id]
	
	# 게임 리소스 경로 설정
	var scenario_path = current_game.get("scenario_path", "")
	var main_scenario = current_game.get("main_scenario", "main_story.xml")
	
	if not scenario_path.is_empty():
		# 게임별 리소스 경로 전역 설정
		_setup_game_resources(game_id, scenario_path)
	
	emit_signal("game_selected", game_id)
	emit_signal("game_loaded", current_game)
	return OK

# 게임별 리소스 설정
func _setup_game_resources(game_id: String, scenario_path: String) -> void:
	# 게임별 경로를 ProjectSettings에 저장
	ProjectSettings.set_setting("current_game/id", game_id)
	ProjectSettings.set_setting("current_game/scenario_path", scenario_path)
	ProjectSettings.set_setting("current_game/asset_path", "res://games/" + game_id + "/")
	
	# 다국어 설정 업데이트
	var localization_path = "res://games/" + game_id + "/localization/"
	ProjectSettings.set_setting("current_game/localization_path", localization_path)

# 현재 게임 정보
func get_current_game() -> Dictionary:
	return current_game

func get_current_game_id() -> String:
	return current_game.get("id", "")

func get_current_scenario_path() -> String:
	var scenario_path = current_game.get("scenario_path", "")
	var main_scenario = current_game.get("main_scenario", "main_story.xml")
	return scenario_path + main_scenario

# 다국어 지원
func get_game_title(game_id: String, language: String = "ko") -> String:
	if not available_games.has(game_id):
		return game_id
	
	var game_data = available_games[game_id]
	match language:
		"en":
			return game_data.get("title_en", game_data.get("title", game_id))
		"ja":
			return game_data.get("title_ja", game_data.get("title", game_id))
		_:
			return game_data.get("title", game_id)

func get_game_description(game_id: String, language: String = "ko") -> String:
	if not available_games.has(game_id):
		return ""
	
	var game_data = available_games[game_id]
	match language:
		"en":
			return game_data.get("description_en", game_data.get("description", ""))
		"ja":
			return game_data.get("description_ja", game_data.get("description", ""))
		_:
			return game_data.get("description", "")

# 게임 상태 관리
func is_game_available(game_id: String) -> bool:
	return available_games.has(game_id) and available_games[game_id].get("enabled", false)

func get_game_playtime(game_id: String) -> int:
	if not available_games.has(game_id):
		return 0
	return available_games[game_id].get("estimated_playtime", 0)

func get_game_rating(game_id: String) -> String:
	if not available_games.has(game_id):
		return "Unknown"
	return available_games[game_id].get("rating", "Unknown")

# 배포 설정
func set_deployment_mode(mode: String) -> void:
	deployment_config["build_mode"] = mode
	if mode == "production":
		enabled_games_only = true
		_filter_enabled_games()

func is_development_mode() -> bool:
	return deployment_config.get("build_mode", "development") == "development"

func get_enabled_games_for_build() -> Array:
	return deployment_config.get("enabled_games", [])

# 게임 설정 저장
func save_games_configuration() -> Error:
	var config_data = {
		"games": available_games,
		"deployment": deployment_config
	}
	
	var file = FileAccess.open(games_config_path, FileAccess.WRITE)
	if not file:
		return Error.FAILED
	
	file.store_string(JSON.stringify(config_data, "\t"))
	file.close()
	return OK

# 관리자 기능
func enable_game(game_id: String, enabled: bool = true) -> void:
	if available_games.has(game_id):
		available_games[game_id]["enabled"] = enabled
		save_games_configuration()

func set_game_featured(game_id: String, featured: bool = true) -> void:
	if available_games.has(game_id):
		available_games[game_id]["featured"] = featured
		save_games_configuration()

func add_new_game(game_data: Dictionary) -> Error:
	var game_id = game_data.get("id", "")
	if game_id.is_empty():
		push_error("Game ID cannot be empty")
		return Error.FAILED
	
	available_games[game_id] = game_data
	save_games_configuration()
	emit_signal("games_list_updated")
	return OK

func remove_game(game_id: String) -> Error:
	if not available_games.has(game_id):
		return Error.FAILED
	
	available_games.erase(game_id)
	save_games_configuration()
	emit_signal("games_list_updated")
	return OK

# 검색 기능
func search_games(query: String, language: String = "ko") -> Array:
	var results = []
	var lower_query = query.to_lower()
	
	for game_id in available_games:
		var game_data = available_games[game_id]
		var title = get_game_title(game_id, language).to_lower()
		var description = get_game_description(game_id, language).to_lower()
		var genres = game_data.get("genre", [])
		
		if title.contains(lower_query) or description.contains(lower_query):
			results.append(game_data)
			continue
		
		for genre in genres:
			if genre.to_lower().contains(lower_query):
				results.append(game_data)
				break
	
	return results

# 통계 정보
func get_games_statistics() -> Dictionary:
	var stats = {
		"total_games": available_games.size(),
		"enabled_games": 0,
		"featured_games": 0,
		"total_playtime": 0,
		"genres": {},
		"ratings": {}
	}
	
	for game_id in available_games:
		var game_data = available_games[game_id]
		
		if game_data.get("enabled", false):
			stats.enabled_games += 1
		
		if game_data.get("featured", false):
			stats.featured_games += 1
		
		stats.total_playtime += game_data.get("estimated_playtime", 0)
		
		# 장르 통계
		var genres = game_data.get("genre", [])
		for genre in genres:
			if not stats.genres.has(genre):
				stats.genres[genre] = 0
			stats.genres[genre] += 1
		
		# 등급 통계
		var rating = game_data.get("rating", "Unknown")
		if not stats.ratings.has(rating):
			stats.ratings[rating] = 0
		stats.ratings[rating] += 1
	
	return stats