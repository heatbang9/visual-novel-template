## 미니게임 로더 싱글톤
## 동적 미니게임 로딩 및 관리를 담당
## Godot 4.5 호환, 비동기 로딩 지원
extends Node


## 미니게임 로드 완료 시그널
signal minigame_loaded(game_id: String)

## 미니게임 언로드 완료 시그널
signal minigame_unloaded(game_id: String)

## 미니게임 로드 실패 시그널
signal minigame_load_failed(game_id: String, error: String)

## 로딩 진행률 변경 시그널 (게임 ID, 진행률 0.0-1.0)
signal loading_progress(game_id: String, progress: float)

## 프리로딩 완료 시그널
signal preload_completed(game_ids: Array)

## 현재 로드된 미니게임 인스턴스들 (ID -> Node)
var _loaded_minigames: Dictionary = {}

## 로드된 씬 리소스 캐시 (ID -> PackedScene)
var _scene_cache: Dictionary = {}

## 비동기 로딩 중인 미니게임들 (ID -> 로딩 상태)
var _loading_minigames: Dictionary = {}

## 사용 가능한 미니게임 목록 (캐시)
var _available_minigames: Dictionary = {}

## LRU 캐시를 위한 접근 순서 추적
var _access_order: Array[String] = []

## 최대 캐시 크기 (메모리 관리)
const MAX_CACHE_SIZE := 10

## 자동 언로드 대기 시간 (초)
const AUTO_UNLOAD_DELAY := 300.0

## 자동 언로드 타이머
var _auto_unload_timer: Timer

## 설정 파일 경로
const CONFIG_PATH := "res://addons/minigames/minigames_config.json"

## 기본 미니게임 폴더들
const DEFAULT_GAME_FOLDERS := [
	"res://minigames/scenes",
	"res://minigames_v2/scenes",
	"res://scenes/minigames"
]


func _ready() -> void:
	# 시작 시 미니게임 목록 스캔
	scan_minigames()
	
	# 자동 언로드 타이머 설정
	_setup_auto_unload_timer()


## 자동 언로드 타이머 설정
func _setup_auto_unload_timer() -> void:
	_auto_unload_timer = Timer.new()
	_auto_unload_timer.wait_time = 60.0  # 1분마다 체크
	_auto_unload_timer.autostart = true
	_auto_unload_timer.timeout.connect(_check_auto_unload)
	add_child(_auto_unload_timer)


## 미니게임 로드 (동기)
## @param game_id: 미니게임 ID
## @return: 로드된 MinigameBase 인스턴스 또는 null
func load_minigame(game_id: String) -> MinigameBase:
	# 이미 로드된 경우 캐시된 인스턴스 반환
	if _loaded_minigames.has(game_id):
		_update_access_order(game_id)
		return _loaded_minigames[game_id]
	
	# 사용 가능한 미니게임 목록에서 찾기
	if not _available_minigames.has(game_id):
		scan_minigames()
		if not _available_minigames.has(game_id):
			var error := "미니게임을 찾을 수 없습니다: %s" % game_id
			push_error(error)
			minigame_load_failed.emit(game_id, error)
			return null
	
	var game_info: Dictionary = _available_minigames[game_id]
	var scene_path: String = game_info.get("scene_path", "")
	
	# 씬 리소스 로드 (캐시 확인)
	var scene_resource: PackedScene
	if _scene_cache.has(game_id):
		scene_resource = _scene_cache[game_id]
	else:
		scene_resource = load(scene_path)
		if scene_resource == null:
			var error := "미니게임 씬을 로드할 수 없습니다: %s" % scene_path
			push_error(error)
			minigame_load_failed.emit(game_id, error)
			return null
		_cache_scene(game_id, scene_resource)
	
	# 인스턴스 생성
	var instance := scene_resource.instantiate() as MinigameBase
	if instance == null:
		var error := "미니게임 인스턴스 생성 실패: %s" % game_id
		push_error(error)
		minigame_load_failed.emit(game_id, error)
		return null
	
	# 메타데이터 설정
	_apply_metadata(instance, game_info)
	
	# 캐시에 저장
	_loaded_minigames[game_id] = instance
	_update_access_order(game_id)
	
	minigame_loaded.emit(game_id)
	return instance


## 미니게임 비동기 로드
## @param game_id: 미니게임 ID
## @param callback: 로드 완료 시 호출할 콜백 함수 (optional)
func load_minigame_async(game_id: String, callback: Callable = Callable()) -> void:
	# 이미 로드된 경우
	if _loaded_minigames.has(game_id):
		_update_access_order(game_id)
		loading_progress.emit(game_id, 1.0)
		if callback.is_valid():
			callback.call(game_id, _loaded_minigames[game_id])
		return
	
	# 이미 로딩 중인 경우
	if _loading_minigames.has(game_id):
		return
	
	# 사용 가능한 미니게임 목록에서 찾기
	if not _available_minigames.has(game_id):
		scan_minigames()
		if not _available_minigames.has(game_id):
			var error := "미니게임을 찾을 수 없습니다: %s" % game_id
			push_error(error)
			minigame_load_failed.emit(game_id, error)
			return
	
	var game_info: Dictionary = _available_minigames[game_id]
	var scene_path: String = game_info.get("scene_path", "")
	
	# 로딩 상태 초기화
	_loading_minigames[game_id] = {
		"callback": callback,
		"scene_path": scene_path,
		"game_info": game_info
	}
	
	# ResourceLoader로 비동기 로딩 시작
	var error := ResourceLoader.load_threaded_request(scene_path)
	if error != OK:
		_loading_minigames.erase(game_id)
		push_error("비동기 로딩 시작 실패: %s" % scene_path)
		minigame_load_failed.emit(game_id, "비동기 로딩 시작 실패")
		return
	
	# 로딩 상태 폴링 시작
	_poll_loading(game_id)


## 로딩 상태 폴링
func _poll_loading(game_id: String) -> void:
	if not _loading_minigames.has(game_id):
		return
	
	var loading_info: Dictionary = _loading_minigames[game_id]
	var scene_path: String = loading_info.scene_path
	
	var status := ResourceLoader.load_threaded_get_status(scene_path)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# 진행률 업데이트 (Godot 4.5에서는 진행률을 직접 가져올 수 없으므로 추정)
			loading_progress.emit(game_id, 0.5)
			# 다음 프레임에 다시 체크
			await get_tree().process_frame
			_poll_loading(game_id)
		
		ResourceLoader.THREAD_LOAD_LOADED:
			# 로딩 완료
			var scene_resource := ResourceLoader.load_threaded_get(scene_path) as PackedScene
			_loading_minigames.erase(game_id)
			
			if scene_resource == null:
				minigame_load_failed.emit(game_id, "씬 리소스 로드 실패")
				return
			
			# 캐시에 저장
			_cache_scene(game_id, scene_resource)
			
			# 인스턴스 생성
			var instance := scene_resource.instantiate() as MinigameBase
			if instance == null:
				minigame_load_failed.emit(game_id, "인스턴스 생성 실패")
				return
			
			# 메타데이터 설정
			_apply_metadata(instance, loading_info.game_info)
			
			_loaded_minigames[game_id] = instance
			_update_access_order(game_id)
			
			loading_progress.emit(game_id, 1.0)
			minigame_loaded.emit(game_id)
			
			var callback: Callable = loading_info.callback
			if callback.is_valid():
				callback.call(game_id, instance)
		
		ResourceLoader.THREAD_LOAD_FAILED:
			_loading_minigames.erase(game_id)
			minigame_load_failed.emit(game_id, "비동기 로딩 실패")
		
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_loading_minigames.erase(game_id)
			minigame_load_failed.emit(game_id, "잘못된 리소스 경로")


## 미니게임 프리로드 (여러 개 한번에)
## @param game_ids: 미니게임 ID 배열
func preload_minigames(game_ids: Array) -> void:
	var loaded_count := 0
	var total_count := game_ids.size()
	
	for game_id in game_ids:
		if not _loaded_minigames.has(game_id) and not _loading_minigames.has(game_id):
			load_minigame_async(game_id, func(_id: String, _instance: MinigameBase) -> void:
				loaded_count += 1
				if loaded_count >= total_count:
					preload_completed.emit(game_ids)
			)
		else:
			loaded_count += 1
	
	if loaded_count >= total_count:
		preload_completed.emit(game_ids)


## 미니게임 언로드
## @param game_id: 미니게임 ID
func unload_minigame(game_id: String) -> void:
	if _loaded_minigames.has(game_id):
		var instance: Node = _loaded_minigames[game_id]
		
		# 안전하게 정리
		if is_instance_valid(instance):
			if instance.is_inside_tree():
				instance.get_parent().remove_child(instance)
			instance.queue_free()
		
		_loaded_minigames.erase(game_id)
		_access_order.erase(game_id)
		
		minigame_unloaded.emit(game_id)


## 미니게임 씬 리소스만 언로드 (메모리 관리)
## @param game_id: 미니게임 ID
func unload_scene_cache(game_id: String) -> void:
	if _scene_cache.has(game_id) and not _loaded_minigames.has(game_id):
		_scene_cache.erase(game_id)


## 로드된 미니게임 인스턴스 반환
## @param game_id: 미니게임 ID
## @return: MinigameBase 인스턴스 또는 null
func get_minigame_instance(game_id: String) -> Node:
	if _loaded_minigames.has(game_id):
		_update_access_order(game_id)
		return _loaded_minigames[game_id]
	return null


## 미니게임 로드 여부 확인
## @param game_id: 미니게임 ID
## @return: 로드 여부
func is_minigame_loaded(game_id: String) -> bool:
	return _loaded_minigames.has(game_id)


## 미니게임 로딩 중 여부 확인
## @param game_id: 미니게임 ID
## @return: 로딩 중 여부
func is_minigame_loading(game_id: String) -> bool:
	return _loading_minigames.has(game_id)


## 사용 가능한 미니게임 목록 반환
## @return: 미니게임 ID 배열
func get_available_minigames() -> Array:
	return _available_minigames.keys()


## 특정 미니게임 정보 반환
## @param game_id: 미니게임 ID
## @return: 미니게임 정보 딕셔너리
func get_minigame_info(game_id: String) -> Dictionary:
	if _available_minigames.has(game_id):
		return _available_minigames[game_id]
	return {}


## 미니게임 존재 여부 확인
## @param game_id: 미니게임 ID
## @return: 존재 여부
func has_minigame(game_id: String) -> bool:
	return _available_minigames.has(game_id)


## 카테고리별 미니게임 목록 반환
## @param category: 카테고리 이름
## @return: 미니게임 ID 배열
func get_minigames_by_category(category: String) -> Array:
	var result: Array = []
	for game_id in _available_minigames:
		var info: Dictionary = _available_minigames[game_id]
		if info.get("category", "general") == category:
			result.append(game_id)
	return result


## 태그로 미니게임 검색
## @param tag: 태그 이름
## @return: 미니게임 ID 배열
func get_minigames_by_tag(tag: String) -> Array:
	var result: Array = []
	for game_id in _available_minigames:
		var info: Dictionary = _available_minigames[game_id]
		var tags: Array = info.get("tags", [])
		if tag in tags:
			result.append(game_id)
	return result


## 미니게임 폴더 스캔
func scan_minigames() -> void:
	_available_minigames.clear()
	
	# 설정 파일에서 로드 시도
	var config_loaded := _load_from_config()
	
	# 설정 파일이 없거나 비어있으면 폴더 스캔
	if not config_loaded or _available_minigames.is_empty():
		_scan_game_folders()
		_save_to_config()


## 메타데이터 적용
func _apply_metadata(instance: MinigameBase, game_info: Dictionary) -> void:
	if game_info.has("game_name_key"):
		instance.game_name_key = game_info.game_name_key
	if game_info.has("game_desc_key"):
		instance.game_desc_key = game_info.game_desc_key
	if game_info.has("time_limit"):
		instance.time_limit = game_info.time_limit
	if game_info.has("difficulty"):
		instance.difficulty = game_info.difficulty


## 씬 캐시에 저장 (LRU 관리)
func _cache_scene(game_id: String, scene: PackedScene) -> void:
	# 캐시 크기 제한 확인
	while _scene_cache.size() >= MAX_CACHE_SIZE:
		# 가장 오래된 항목 제거
		var oldest_id: String = ""
		for cached_id in _scene_cache:
			if oldest_id == "" or _access_order.find(cached_id) < _access_order.find(oldest_id):
				oldest_id = cached_id
		
		if oldest_id != "" and not _loaded_minigames.has(oldest_id):
			_scene_cache.erase(oldest_id)
	
	_scene_cache[game_id] = scene


## 접근 순서 업데이트 (LRU)
func _update_access_order(game_id: String) -> void:
	_access_order.erase(game_id)
	_access_order.append(game_id)


## 자동 언로드 체크
func _check_auto_unload() -> void:
	# 현재 사용되지 않는 미니게임 언로드
	# 실제 구현에서는 마지막 사용 시간을 추적해야 함
	pass


## 설정 파일에서 미니게임 목록 로드
func _load_from_config() -> bool:
	if not FileAccess.file_exists(CONFIG_PATH):
		return false
	
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return false
	
	var json_text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("설정 파일 파싱 실패: %s" % json.get_error_message())
		return false
	
	var data: Dictionary = json.data
	if not data.has("minigames"):
		return false
	
	var minigames_data: Array = data.minigames
	for game_data in minigames_data:
		if game_data is Dictionary:
			var g_id: String = game_data.get("game_id", "")
			if g_id != "":
				_available_minigames[g_id] = game_data
	
	return true


## 설정 파일에 미니게임 목록 저장
func _save_to_config() -> void:
	var minigames_array: Array = []
	for game_id in _available_minigames:
		minigames_array.append(_available_minigames[game_id])
	
	var data := {
		"version": "1.0",
		"minigames": minigames_array
	}
	
	var json_text := JSON.stringify(data, "  ")
	
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		push_error("설정 파일 저장 실패")
		return
	
	file.store_string(json_text)
	file.close()


## 미니게임 폴더 스캔
func _scan_game_folders() -> void:
	for folder_path in DEFAULT_GAME_FOLDERS:
		_scan_folder(folder_path)


## 개별 폴더 스캔
func _scan_folder(folder_path: String) -> void:
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var game_id := file_name.replace("_game.tscn", "").replace(".tscn", "")
			var scene_path := folder_path.path_join(file_name)
			
			var game_info := {
				"game_id": game_id,
				"game_name_key": "minigame_%s_name" % game_id,
				"game_desc_key": "minigame_%s_desc" % game_id,
				"scene_path": scene_path,
				"time_limit": 60.0,
				"difficulty": 1,
				"category": _guess_category(game_id),
				"tags": [],
				"dependencies": []
			}
			
			_available_minigames[game_id] = game_info
		
		file_name = dir.get_next()
	
	dir.list_dir_end()


## 게임 ID로부터 카테고리 추측
func _guess_category(game_id: String) -> String:
	var action_games := ["shooting", "racing", "rhythm", "reaction", "fishing", "balance", "wave_survivor", "chain_reaction"]
	var puzzle_games := ["puzzle", "rotate_puzzle", "connect", "color_match", "pattern", "math", "maze", "memory", "pattern_breaker", "puzzle_maker", "tetris_variant", "color_flow"]
	var strategy_games := ["tower", "tower_defense", "card_battle", "dungeon_crawler", "grid_control", "sequence_master", "line_defender", "time_manager"]
	var adventure_games := ["log_adventure", "route_finder", "dungeon_crawler"]
	var casual_games := ["cleaning", "cooking", "plant", "find_object", "word_guess", "stack_management", "particle_collector", "node_connector", "spell_caster", "matrix_hacker"]
	
	game_id = game_id.to_lower()
	
	if game_id in action_games:
		return "action"
	elif game_id in puzzle_games:
		return "puzzle"
	elif game_id in strategy_games:
		return "strategy"
	elif game_id in adventure_games:
		return "adventure"
	elif game_id in casual_games:
		return "casual"
	
	return "general"


## 로드된 미니게임 수 반환
func get_loaded_count() -> int:
	return _loaded_minigames.size()


## 사용 가능한 미니게임 수 반환
func get_available_count() -> int:
	return _available_minigames.size()


## 모든 로드된 미니게임 언로드
func unload_all() -> void:
	var game_ids := _loaded_minigames.keys()
	for game_id in game_ids:
		unload_minigame(game_id)
	_scene_cache.clear()


## 로딩 진행률 반환 (비동기 로딩 중인 경우)
## @param game_id: 미니게임 ID
## @return: 진행률 0.0-1.0, 로딩 중이 아니면 -1.0
func get_loading_progress(game_id: String) -> float:
	if _loaded_minigames.has(game_id):
		return 1.0
	if not _loading_minigames.has(game_id):
		return -1.0
	return 0.5  # Godot 4.5에서는 정확한 진행률을 가져올 수 없음


## 메모리 사용량 추정 반환
## @return: 캐시된 씬 수
func get_cache_size() -> int:
	return _scene_cache.size()
