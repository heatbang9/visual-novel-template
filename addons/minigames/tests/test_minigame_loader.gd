## 미니게임 로더 테스트
## GUT 테스트 프레임워크 사용
extends GutTest

var loader: MinigameLoader


func before_each() -> void:
	# MinigameLoader 싱글톤이 이미 존재함
	loader = MinigameLoader


func after_each() -> void:
	loader.unload_all()


func test_scan_minigames() -> void:
	loader.scan_minigames()
	assert_gt(loader.get_available_count(), 0, "미니게임이 스캔되어야 함")


func test_load_minigame() -> void:
	# 테스트 미니게임 로드
	var instance = loader.load_minigame("test_puzzle")
	
	if instance != null:
		assert_true(loader.is_minigame_loaded("test_puzzle"), "미니게임이 로드되어야 함")
		assert_is(instance, MinigameBase, "MinigameBase 인스턴스여야 함")
	else:
		# 미니게임이 없으면 스킵
		pending("test_puzzle 미니게임이 없음")


func test_unload_minigame() -> void:
	# 로드 후 언로드
	loader.load_minigame("test_puzzle")
	loader.unload_minigame("test_puzzle")
	
	assert_false(loader.is_minigame_loaded("test_puzzle"), "미니게임이 언로드되어야 함")


func test_get_minigame_instance() -> void:
	loader.load_minigame("test_puzzle")
	var instance = loader.get_minigame_instance("test_puzzle")
	
	assert_not_null(instance, "인스턴스를 반환해야 함")


func test_preload_minigames() -> void:
	var game_ids := ["test_puzzle"]
	var completed := false
	
	loader.preload_completed.connect(func(ids):
		completed = true
	, CONNECT_ONE_SHOT)
	
	loader.preload_minigames(game_ids)
	
	# 동기적으로 처리되므로 바로 확인
	await get_tree().process_frame
	
	assert_true(loader.is_minigame_loaded("test_puzzle") or completed, "프리로드가 완료되어야 함")


func test_get_minigame_info() -> void:
	loader.scan_minigames()
	var available := loader.get_available_minigames()
	
	if available.size() > 0:
		var first_id: String = available[0]
		var info := loader.get_minigame_info(first_id)
		
		assert_true(info.has("game_id"), "game_id가 있어야 함")
		assert_true(info.has("scene_path"), "scene_path가 있어야 함")


func test_has_minigame() -> void:
	loader.scan_minigames()
	var available := loader.get_available_minigames()
	
	if available.size() > 0:
		var first_id: String = available[0]
		assert_true(loader.has_minigame(first_id), "미니게임이 존재해야 함")
	
	assert_false(loader.has_minigame("nonexistent_game"), "존재하지 않는 게임은 false")


func test_cache_management() -> void:
	# 캐시 크기 확인
	loader.unload_all()
	
	assert_eq(loader.get_cache_size(), 0, "초기 캐시는 비어있어야 함")


func test_unload_all() -> void:
	loader.load_minigame("test_puzzle")
	loader.unload_all()
	
	assert_eq(loader.get_loaded_count(), 0, "모든 미니게임이 언로드되어야 함")
