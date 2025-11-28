extends GutTest

# Episode 통합 테스트 클래스
# 전체 에피소드 플로우를 자동으로 검증

var scenario_manager: Node
var dialogue_scene_loader: Node

func before_each():
	# 테스트 환경 설정
	scenario_manager = load("res://scripts/scenario_manager.gd").new()
	add_child(scenario_manager)
	
	# 더미 dialogue_scene_loader 생성 (실제 UI 없이 테스트)
	dialogue_scene_loader = Node.new()
	dialogue_scene_loader.set_script(load("res://addons/scene_system/dialogue_scene_loader.gd"))
	add_child(dialogue_scene_loader)
	
	scenario_manager.configure(dialogue_scene_loader, null)

func after_each():
	if scenario_manager:
		scenario_manager.queue_free()
	if dialogue_scene_loader:
		dialogue_scene_loader.queue_free()

func test_episode02_xml_loading():
	"""Episode 2 XML 파일 로딩 테스트"""
	
	# XML 파일 존재 확인
	var xml_file = "res://mystery_novel/projects/junho_detective_series/scenarios/episode02/cafe_mystery_scenario.xml"
	assert_file_exists(xml_file, "Episode 2 XML 파일이 존재해야 함")
	
	# XML 구조 유효성 확인
	var file = FileAccess.open(xml_file, FileAccess.READ)
	assert_not_null(file, "XML 파일을 열 수 있어야 함")
	
	var content = file.get_as_text()
	file.close()
	
	# 필수 XML 요소들 확인
	assert_true("scenario" in content, "scenario 태그가 있어야 함")
	assert_true("route" in content, "route 태그가 있어야 함")
	assert_true("global_variables" in content, "global_variables 태그가 있어야 함")
	assert_true("choice" in content, "choice 태그가 있어야 함")

func test_scene_xml_loading():
	"""Scene XML 파일들 로딩 테스트"""
	
	var scene_files = [
		"res://mystery_novel/projects/junho_detective_series/scenes/dialogue/episode02/cafe_discovery.xml",
		"res://mystery_novel/projects/junho_detective_series/scenes/dialogue/episode02/meet_park_youngsu.xml"
	]
	
	for scene_file in scene_files:
		assert_file_exists(scene_file, scene_file + " 파일이 존재해야 함")
		
		# XML 파싱 테스트
		var file = FileAccess.open(scene_file, FileAccess.READ)
		assert_not_null(file, scene_file + " 파일을 열 수 있어야 함")
		
		var content = file.get_as_text()
		file.close()
		
		var parser = XMLParser.new()
		var error = parser.open_buffer(content.to_utf8_buffer())
		assert_eq(error, OK, scene_file + " XML 구조가 유효해야 함")

func test_variable_system():
	"""시나리오 변수 시스템 테스트"""
	
	# 기본 변수 확인
	var expected_variables = [
		"episode01_complete",
		"episode02_started", 
		"curiosity_level",
		"observation_skill",
		"logic_skill",
		"social_skill"
	]
	
	# XML에서 변수 정의 확인
	var xml_file = "res://mystery_novel/projects/junho_detective_series/scenarios/episode02/cafe_mystery_scenario.xml"
	var file = FileAccess.open(xml_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	for variable in expected_variables:
		assert_true(variable in content, "변수 '" + variable + "'가 정의되어야 함")

func test_character_definitions():
	"""캐릭터 정의 테스트"""
	
	var expected_characters = ["junho", "park_youngsu", "kang_minho", "soyeon"]
	
	# 캐릭터 파일 존재 확인
	for character in expected_characters:
		var char_path = "res://mystery_novel/projects/junho_detective_series/characters/"
		assert_file_exists(char_path + "protagonist.md" if character == "junho" else char_path + "extended_characters.md", 
						 "캐릭터 '" + character + "' 정의 파일이 있어야 함")

func test_resource_structure():
	"""리소스 구조 테스트"""
	
	var resource_paths = [
		"res://mystery_novel/projects/junho_detective_series/resources/characters/",
		"res://mystery_novel/projects/junho_detective_series/resources/backgrounds/", 
		"res://mystery_novel/projects/junho_detective_series/resources/audio/bgm/",
		"res://mystery_novel/projects/junho_detective_series/resources/audio/sfx/"
	]
	
	for path in resource_paths:
		assert_true(DirAccess.dir_exists_absolute(path), "리소스 폴더 '" + path + "'가 존재해야 함")

func test_minigame_availability():
	"""미니게임 가용성 테스트"""
	
	var minigame_manager = load("res://minigames/scripts/minigame_manager.gd").new()
	add_child(minigame_manager)
	
	var available_games = minigame_manager.get_available_games()
	
	# 최소 40개 미니게임이 등록되어야 함
	assert_ge(available_games.size(), 40, "최소 40개 미니게임이 있어야 함")
	
	# 핵심 미니게임들 확인
	var core_games = ["reaction", "color_match", "puzzle", "memory", "math"]
	for game in core_games:
		assert_true(minigame_manager.is_game_available(game), "핵심 미니게임 '" + game + "'이 사용 가능해야 함")
	
	minigame_manager.queue_free()

func test_docs_consistency():
	"""문서 일관성 테스트"""
	
	var docs_files = [
		"res://mystery_novel/projects/junho_detective_series/docs/project_structure.md",
		"res://mystery_novel/projects/junho_detective_series/docs/series_overview.md",
		"res://docs/IMPROVEMENT_PLAN.md"
	]
	
	for doc_file in docs_files:
		assert_file_exists(doc_file, "문서 파일 '" + doc_file + "'이 존재해야 함")
		
		var file = FileAccess.open(doc_file, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		assert_gt(content.length(), 100, "문서 '" + doc_file + "'에 실질적인 내용이 있어야 함")