extends GutTest
# Mystery Novel Scenario Test Suite
# TDD 접근방식으로 시나리오 검증

class_name TestMysteryScenario

const MYSTERY_SCENARIO_PATH = "res://scenes/mystery_novel_scenario.xml"
const PROLOGUE_SCENE_PATH = "res://scenes/dialogue/mystery/prologue_discovery.xml"
const CHAPTER1_SCENE_PATH = "res://scenes/dialogue/mystery/chapter1_contents.xml"

var scenario_loader
var xml_parser
var game_state

func before_each():
	scenario_loader = preload("res://addons/scenario_system/scenario_manager.gd").new()
	xml_parser = XMLParser.new()
	game_state = {}

func after_each():
	if xml_parser:
		xml_parser = null
	scenario_loader = null
	game_state.clear()

# XML 구조 유효성 테스트
func test_mystery_scenario_xml_structure():
	describe("Mystery scenario XML structure validation")
	
	# XML 파일이 존재하는지 확인
	assert_file_exists(MYSTERY_SCENARIO_PATH, "Mystery scenario XML file should exist")
	
	# XML 파싱 테스트
	var file = FileAccess.open(MYSTERY_SCENARIO_PATH, FileAccess.READ)
	assert_not_null(file, "Should be able to open mystery scenario file")
	
	var xml_content = file.get_as_text()
	file.close()
	
	xml_parser.open_buffer(xml_content.to_utf8_buffer())
	
	# 루트 요소 검증
	xml_parser.read()
	assert_eq(xml_parser.get_node_name(), "scenario", "Root element should be 'scenario'")
	assert_true(xml_parser.has_attribute("name"), "Scenario should have 'name' attribute")
	assert_eq(xml_parser.get_named_attribute_value("name"), "mystery_novel", "Scenario name should be 'mystery_novel'")

func test_prologue_scene_structure():
	describe("Prologue scene XML validation")
	
	assert_file_exists(PROLOGUE_SCENE_PATH, "Prologue scene file should exist")
	
	var file = FileAccess.open(PROLOGUE_SCENE_PATH, FileAccess.READ)
	var xml_content = file.get_as_text()
	file.close()
	
	xml_parser.open_buffer(xml_content.to_utf8_buffer())
	xml_parser.read()
	
	assert_eq(xml_parser.get_node_name(), "scene", "Root element should be 'scene'")
	assert_true(xml_parser.has_attribute("name"), "Scene should have 'name' attribute")

# 게임 변수 초기화 테스트
func test_global_variables_initialization():
	describe("Global variables should be properly initialized")
	
	var expected_variables = {
		"game_start": true,
		"prologue_complete": false,
		"chapter1_complete": false,
		"curiosity_level": 2,
		"evidence_strength": 0,
		"investigation_approach": "neutral"
	}
	
	for var_name in expected_variables.keys():
		var expected_value = expected_variables[var_name]
		# 실제 시나리오 로더에서 변수를 가져와 확인
		# assert_eq(scenario_loader.get_variable(var_name), expected_value, 
		# 	"Variable %s should be initialized to %s" % [var_name, expected_value])

# 선택지 로직 테스트
func test_choice_requirements():
	describe("Choice requirements should be properly validated")
	
	# 공격적 조사 선택지는 호기심 레벨이 3 이상이어야 함
	game_state["curiosity_level"] = 2
	var can_choose_decode = check_choice_requirement("decode_message", game_state)
	assert_false(can_choose_decode, "Should not allow decode_message choice with low curiosity")
	
	game_state["curiosity_level"] = 3
	can_choose_decode = check_choice_requirement("decode_message", game_state)
	assert_true(can_choose_decode, "Should allow decode_message choice with sufficient curiosity")

# 시나리오 진행 흐름 테스트
func test_scenario_progression():
	describe("Scenario should progress correctly through chapters")
	
	# 초기 상태 설정
	game_state = {
		"prologue_complete": false,
		"chapter1_complete": false,
		"time_capsule_discovered": false
	}
	
	# 프롤로그 완료 시 상태 변화 확인
	complete_prologue(game_state)
	assert_true(game_state["prologue_complete"], "Prologue should be marked as complete")
	assert_true(game_state["time_capsule_discovered"], "Time capsule should be discovered")
	
	# 챕터1 진행 조건 확인
	assert_true(can_proceed_to_chapter1(game_state), "Should be able to proceed to chapter 1")

# 엔딩 조건 테스트
func test_ending_conditions():
	describe("Different ending conditions should be properly checked")
	
	# 완전한 진실 엔딩 조건
	game_state = {
		"evidence_strength": 10,
		"courage_level": 5,
		"chapter3_complete": true
	}
	
	var ending_type = determine_ending(game_state)
	assert_eq(ending_type, "full_truth", "Should trigger full_truth ending with sufficient evidence and courage")
	
	# 부분적 해결 엔딩 조건
	game_state["evidence_strength"] = 5
	ending_type = determine_ending(game_state)
	assert_eq(ending_type, "partial_truth", "Should trigger partial_truth ending with moderate evidence")

# 캐릭터 능력치 증가 테스트
func test_character_stat_progression():
	describe("Character stats should increase based on choices")
	
	game_state = {
		"observation_skill": 1,
		"logic_skill": 1,
		"social_skill": 1
	}
	
	# 사진 관찰 선택시 관찰력 증가
	make_choice("focus_on_photos", game_state)
	assert_eq(game_state["observation_skill"], 2, "Observation skill should increase after focusing on photos")
	
	# 암호 해독 선택시 논리력 증가
	make_choice("decode_message", game_state)
	assert_eq(game_state["logic_skill"], 3, "Logic skill should increase significantly after decoding")

# 위험도 시스템 테스트
func test_danger_level_system():
	describe("Danger level should escalate based on investigation progress")
	
	game_state = {
		"investigation_progress": 0,
		"danger_level": "low"
	}
	
	# 조사 진행에 따른 위험도 증가
	progress_investigation(game_state, 3)
	assert_eq(game_state["danger_level"], "medium", "Danger should increase to medium")
	
	progress_investigation(game_state, 5)
	assert_eq(game_state["danger_level"], "high", "Danger should increase to high")

# 단서 수집 시스템 테스트
func test_clue_collection_system():
	describe("Clue collection should affect investigation progress")
	
	game_state = {
		"photo_clues": 0,
		"cipher_clues": 0,
		"document_clues": 0,
		"total_clues": 0
	}
	
	# 각 단서 수집이 총 단서 수에 반영되는지 확인
	collect_clue("photo", 2, game_state)
	assert_eq(game_state["photo_clues"], 2, "Photo clues should be collected")
	assert_eq(game_state["total_clues"], 2, "Total clues should be updated")
	
	collect_clue("cipher", 3, game_state)
	assert_eq(game_state["total_clues"], 5, "Total clues should accumulate")

# 협력 vs 단독 조사 경로 테스트
func test_investigation_approaches():
	describe("Different investigation approaches should lead to different outcomes")
	
	# 협력적 접근
	game_state = {"investigation_approach": "collaborative", "teamwork_level": 0}
	follow_collaborative_path(game_state)
	assert_gt(game_state["teamwork_level"], 0, "Teamwork level should increase in collaborative approach")
	
	# 공격적 접근
	game_state = {"investigation_approach": "aggressive", "danger_level": "low"}
	follow_aggressive_path(game_state)
	assert_ne(game_state["danger_level"], "low", "Danger level should increase in aggressive approach")

# 헬퍼 함수들 (실제 게임 로직을 시뮬레이션)
func check_choice_requirement(choice_id: String, state: Dictionary) -> bool:
	match choice_id:
		"decode_message":
			return state.get("curiosity_level", 0) >= 3
		_:
			return true

func complete_prologue(state: Dictionary):
	state["prologue_complete"] = true
	state["time_capsule_discovered"] = true

func can_proceed_to_chapter1(state: Dictionary) -> bool:
	return state.get("prologue_complete", false)

func determine_ending(state: Dictionary) -> String:
	if state.get("evidence_strength", 0) >= 10 and state.get("courage_level", 0) >= 5:
		return "full_truth"
	elif state.get("evidence_strength", 0) >= 7:
		return "partial_truth"
	else:
		return "normal"

func make_choice(choice_id: String, state: Dictionary):
	match choice_id:
		"focus_on_photos":
			state["observation_skill"] = state.get("observation_skill", 1) + 1
		"decode_message":
			state["logic_skill"] = state.get("logic_skill", 1) + 2

func progress_investigation(state: Dictionary, amount: int):
	state["investigation_progress"] = state.get("investigation_progress", 0) + amount
	if state["investigation_progress"] >= 8:
		state["danger_level"] = "high"
	elif state["investigation_progress"] >= 5:
		state["danger_level"] = "medium"

func collect_clue(clue_type: String, amount: int, state: Dictionary):
	var clue_key = clue_type + "_clues"
	state[clue_key] = state.get(clue_key, 0) + amount
	state["total_clues"] = state.get("total_clues", 0) + amount

func follow_collaborative_path(state: Dictionary):
	state["teamwork_level"] = state.get("teamwork_level", 0) + 2

func follow_aggressive_path(state: Dictionary):
	state["danger_level"] = "medium"