extends RefCounted
class_name MysteryScenarioValidator

# Mystery Novel 시나리오 검증 시스템
# TDD 방식으로 게임 로직을 실시간으로 검증

signal validation_completed(results: Dictionary)
signal validation_failed(error: String)

const MYSTERY_SCENARIO_PATH = "res://scenes/mystery_novel_scenario.xml"
const REQUIRED_SCENES = [
	"res://scenes/dialogue/mystery/prologue_discovery.xml",
	"res://scenes/dialogue/mystery/chapter1_contents.xml",
	"res://scenes/dialogue/mystery/chapter2_investigation.xml",
	"res://scenes/dialogue/mystery/chapter3_danger.xml",
	"res://scenes/dialogue/mystery/climax_revelation.xml",
	"res://scenes/dialogue/mystery/epilogue_resolution.xml"
]

var validation_results = {}
var xml_parser: XMLParser
var game_state = {}

func _init():
	xml_parser = XMLParser.new()
	reset_game_state()

# 전체 시나리오 검증 실행
func validate_complete_scenario() -> bool:
	print("=== Mystery Novel Scenario Validation Started ===")
	
	validation_results.clear()
	var all_passed = true
	
	# 1. XML 구조 검증
	var xml_valid = validate_xml_structure()
	validation_results["xml_structure"] = xml_valid
	all_passed = all_passed and xml_valid
	
	# 2. 필수 씬 파일 존재 검증
	var scenes_valid = validate_scene_files()
	validation_results["scene_files"] = scenes_valid
	all_passed = all_passed and scenes_valid
	
	# 3. 게임 변수 일관성 검증
	var variables_valid = validate_game_variables()
	validation_results["game_variables"] = variables_valid
	all_passed = all_passed and variables_valid
	
	# 4. 선택지 로직 검증
	var choices_valid = validate_choice_logic()
	validation_results["choice_logic"] = choices_valid
	all_passed = all_passed and choices_valid
	
	# 5. 시나리오 진행 흐름 검증
	var progression_valid = validate_scenario_progression()
	validation_results["scenario_progression"] = progression_valid
	all_passed = all_passed and progression_valid
	
	# 6. 엔딩 시스템 검증
	var endings_valid = validate_ending_system()
	validation_results["ending_system"] = endings_valid
	all_passed = all_passed and endings_valid
	
	print("=== Validation Results ===")
	for category in validation_results.keys():
		var status = "PASS" if validation_results[category] else "FAIL"
		print("%s: %s" % [category.to_upper(), status])
	
	if all_passed:
		print("✅ All validations PASSED!")
		validation_completed.emit(validation_results)
	else:
		print("❌ Some validations FAILED!")
		validation_failed.emit("Scenario validation failed")
	
	return all_passed

# XML 구조 검증
func validate_xml_structure() -> bool:
	print("Validating XML structure...")
	
	if not FileAccess.file_exists(MYSTERY_SCENARIO_PATH):
		print("❌ Mystery scenario XML file not found")
		return false
	
	var file = FileAccess.open(MYSTERY_SCENARIO_PATH, FileAccess.READ)
	if not file:
		print("❌ Cannot open mystery scenario file")
		return false
	
	var xml_content = file.get_as_text()
	file.close()
	
	var error = xml_parser.open_buffer(xml_content.to_utf8_buffer())
	if error != OK:
		print("❌ XML parsing failed: %s" % error)
		return false
	
	# 루트 요소 검증
	xml_parser.read()
	if xml_parser.get_node_name() != "scenario":
		print("❌ Root element is not 'scenario'")
		return false
	
	if not xml_parser.has_attribute("name") or xml_parser.get_named_attribute_value("name") != "mystery_novel":
		print("❌ Scenario name is incorrect")
		return false
	
	# 필수 섹션 존재 확인
	var has_main_route = false
	var has_global_variables = false
	
	while xml_parser.read() != ERR_FILE_EOF:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT:
			match xml_parser.get_node_name():
				"route":
					if xml_parser.get_named_attribute_value("id") == "main":
						has_main_route = true
				"global_variables":
					has_global_variables = true
	
	if not has_main_route:
		print("❌ Main route not found")
		return false
	
	if not has_global_variables:
		print("❌ Global variables section not found")
		return false
	
	print("✅ XML structure validation passed")
	return true

# 씬 파일 존재 검증
func validate_scene_files() -> bool:
	print("Validating scene files...")
	
	var missing_scenes = []
	for scene_path in REQUIRED_SCENES:
		if not FileAccess.file_exists(scene_path):
			missing_scenes.append(scene_path)
	
	if missing_scenes.size() > 0:
		print("❌ Missing scene files:")
		for scene in missing_scenes:
			print("  - %s" % scene)
		return false
	
	# 씬 파일 XML 구조 검증
	for scene_path in REQUIRED_SCENES:
		if not validate_scene_xml(scene_path):
			return false
	
	print("✅ Scene files validation passed")
	return true

# 개별 씬 XML 검증
func validate_scene_xml(scene_path: String) -> bool:
	var file = FileAccess.open(scene_path, FileAccess.READ)
	if not file:
		print("❌ Cannot open scene file: %s" % scene_path)
		return false
	
	var xml_content = file.get_as_text()
	file.close()
	
	var error = xml_parser.open_buffer(xml_content.to_utf8_buffer())
	if error != OK:
		print("❌ Scene XML parsing failed: %s" % scene_path)
		return false
	
	xml_parser.read()
	if xml_parser.get_node_name() != "scene":
		print("❌ Scene root element incorrect: %s" % scene_path)
		return false
	
	return true

# 게임 변수 검증
func validate_game_variables() -> bool:
	print("Validating game variables...")
	
	reset_game_state()
	
	# 필수 변수들이 올바르게 초기화되는지 확인
	var required_vars = {
		"game_start": true,
		"prologue_complete": false,
		"curiosity_level": 2,
		"evidence_strength": 0,
		"investigation_approach": "neutral"
	}
	
	for var_name in required_vars.keys():
		if not game_state.has(var_name):
			print("❌ Missing required variable: %s" % var_name)
			return false
		
		if game_state[var_name] != required_vars[var_name]:
			print("❌ Variable %s has incorrect initial value: %s (expected %s)" % 
				[var_name, game_state[var_name], required_vars[var_name]])
			return false
	
	print("✅ Game variables validation passed")
	return true

# 선택지 로직 검증
func validate_choice_logic() -> bool:
	print("Validating choice logic...")
	
	# 호기심 레벨 요구사항 테스트
	game_state["curiosity_level"] = 2
	if can_make_choice("decode_message"):
		print("❌ decode_message choice should require curiosity_level >= 3")
		return false
	
	game_state["curiosity_level"] = 3
	if not can_make_choice("decode_message"):
		print("❌ decode_message choice should be available with curiosity_level >= 3")
		return false
	
	# 연구 스킬 요구사항 테스트
	game_state["research_skill"] = 1
	if can_make_choice("search_archives"):
		print("❌ search_archives choice should require research_skill >= 2")
		return false
	
	game_state["research_skill"] = 2
	if not can_make_choice("search_archives"):
		print("❌ search_archives choice should be available with research_skill >= 2")
		return false
	
	print("✅ Choice logic validation passed")
	return true

# 시나리오 진행 흐름 검증
func validate_scenario_progression() -> bool:
	print("Validating scenario progression...")
	
	reset_game_state()
	
	# 초기에는 프롤로그만 진행 가능해야 함
	if not can_proceed_to_scene("prologue_discovery"):
		print("❌ Should be able to proceed to prologue initially")
		return false
	
	if can_proceed_to_scene("chapter1_contents"):
		print("❌ Should not be able to proceed to chapter1 initially")
		return false
	
	# 프롤로그 완료 후 챕터1 진행 가능
	complete_scene("prologue_discovery")
	if not can_proceed_to_scene("chapter1_contents"):
		print("❌ Should be able to proceed to chapter1 after prologue")
		return false
	
	# 충분한 단서 없이는 챕터2 진행 불가
	if can_proceed_to_scene("chapter2_investigation"):
		print("❌ Should not proceed to chapter2 without enough clues")
		return false
	
	# 단서 수집 후 챕터2 진행 가능
	game_state["total_clues"] = 3
	complete_scene("chapter1_contents")
	if not can_proceed_to_scene("chapter2_investigation"):
		print("❌ Should be able to proceed to chapter2 with enough clues")
		return false
	
	print("✅ Scenario progression validation passed")
	return true

# 엔딩 시스템 검증
func validate_ending_system() -> bool:
	print("Validating ending system...")
	
	# 완전한 진실 엔딩 조건
	game_state = {
		"evidence_strength": 10,
		"courage_level": 5,
		"climax_complete": true
	}
	
	var ending = determine_ending()
	if ending != "full_truth":
		print("❌ Should trigger full_truth ending with max evidence and courage")
		return false
	
	# 부분적 진실 엔딩 조건
	game_state["evidence_strength"] = 5
	game_state["courage_level"] = 3
	ending = determine_ending()
	if ending != "partial_truth":
		print("❌ Should trigger partial_truth ending with moderate stats")
		return false
	
	# 일반 엔딩 조건
	game_state["evidence_strength"] = 2
	game_state["courage_level"] = 1
	ending = determine_ending()
	if ending != "normal":
		print("❌ Should trigger normal ending with low stats")
		return false
	
	print("✅ Ending system validation passed")
	return true

# 실시간 게임 상태 검증 (플레이 중 호출)
func validate_current_state(current_state: Dictionary) -> Dictionary:
	var issues = []
	
	# 변수 범위 검증
	for stat_name in ["curiosity_level", "courage_level", "evidence_strength"]:
		if current_state.has(stat_name):
			var value = current_state[stat_name]
			if value < 0:
				issues.append("Stat %s cannot be negative: %d" % [stat_name, value])
			elif value > 20:
				issues.append("Stat %s seems unusually high: %d" % [stat_name, value])
	
	# 논리적 일관성 검증
	if current_state.get("prologue_complete", false) and not current_state.get("time_capsule_discovered", false):
		issues.append("Prologue complete but time capsule not discovered")
	
	if current_state.get("evidence_strength", 0) > 0 and current_state.get("total_clues", 0) == 0:
		issues.append("Evidence strength > 0 but no clues collected")
	
	return {
		"valid": issues.size() == 0,
		"issues": issues
	}

# 헬퍼 함수들
func reset_game_state():
	game_state = {
		"game_start": true,
		"prologue_complete": false,
		"chapter1_complete": false,
		"chapter2_complete": false,
		"chapter3_complete": false,
		"climax_complete": false,
		"curiosity_level": 2,
		"evidence_strength": 0,
		"total_clues": 0,
		"research_skill": 1,
		"investigation_approach": "neutral"
	}

func can_make_choice(choice_id: String) -> bool:
	match choice_id:
		"decode_message":
			return game_state.get("curiosity_level", 0) >= 3
		"search_archives":
			return game_state.get("research_skill", 0) >= 2
		"confront_board":
			return game_state.get("evidence_strength", 0) >= 5 and game_state.get("courage_level", 0) >= 4
		_:
			return true

func can_proceed_to_scene(scene_id: String) -> bool:
	match scene_id:
		"prologue_discovery":
			return game_state.get("game_start", false)
		"chapter1_contents":
			return game_state.get("prologue_complete", false)
		"chapter2_investigation":
			return game_state.get("chapter1_complete", false) and game_state.get("total_clues", 0) >= 3
		"chapter3_danger":
			return game_state.get("chapter2_complete", false) and game_state.get("investigation_progress", 0) >= 5
		"climax_revelation":
			return game_state.get("chapter3_complete", false) and game_state.get("evidence_strength", 0) >= 7
		_:
			return false

func complete_scene(scene_id: String):
	match scene_id:
		"prologue_discovery":
			game_state["prologue_complete"] = true
			game_state["time_capsule_discovered"] = true
		"chapter1_contents":
			game_state["chapter1_complete"] = true
			game_state["contents_examined"] = true
		"chapter2_investigation":
			game_state["chapter2_complete"] = true
		"chapter3_danger":
			game_state["chapter3_complete"] = true

func determine_ending() -> String:
	var evidence = game_state.get("evidence_strength", 0)
	var courage = game_state.get("courage_level", 0)
	var climax_done = game_state.get("climax_complete", false)
	
	if not climax_done:
		return "incomplete"
	
	if evidence >= 10 and courage >= 5:
		return "full_truth"
	elif evidence >= 7:
		return "partial_truth"
	else:
		return "normal"

# 외부에서 호출 가능한 빠른 검증
func quick_validate() -> bool:
	var xml_ok = FileAccess.file_exists(MYSTERY_SCENARIO_PATH)
	var scenes_ok = true
	
	for scene in REQUIRED_SCENES:
		if not FileAccess.file_exists(scene):
			scenes_ok = false
			break
	
	return xml_ok and scenes_ok

# 검증 결과 리포트 생성
func generate_validation_report() -> String:
	var report = "=== Mystery Novel Validation Report ===\n"
	report += "Generated at: %s\n\n" % Time.get_datetime_string_from_system()
	
	for category in validation_results.keys():
		var status = "✅ PASS" if validation_results[category] else "❌ FAIL"
		report += "%s: %s\n" % [category.replace("_", " ").to_upper(), status]
	
	report += "\nRecommendations:\n"
	if not validation_results.get("xml_structure", true):
		report += "- Fix XML structure errors\n"
	if not validation_results.get("scene_files", true):
		report += "- Create missing scene files\n"
	if not validation_results.get("choice_logic", true):
		report += "- Review choice requirement logic\n"
	
	return report