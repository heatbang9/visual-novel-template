extends Node

# 고급 대화 관리 시스템
# 분기, 조건, 효과, 변수 관리를 포함한 완전한 대화 시스템

signal dialogue_started(scenario_id: String)
signal dialogue_ended(scenario_id: String)
signal message_displayed(speaker: String, text: String)
signal choice_presented(choices: Array)
signal choice_selected(choice_id: String)
signal variable_changed(variable_name: String, new_value: Variant)
signal emotion_changed(character_id: String, emotion: String)
signal route_changed(new_route: String)

# 대화 상태
var current_scenario_id: String = ""
var current_route: String = ""
var current_scene_id: String = ""
var variables: Dictionary = {}
var dialogue_history: Array = []
var visited_scenes: Array = []

# 대화 데이터
var scenario_data: Dictionary = {}
var current_dialogue_queue: Array = []
var current_message_index: int = 0

# 설정
var text_speed: float = 1.0
var auto_play: bool = false
var auto_play_delay: float = 2.0
var skip_unseen: bool = false

# 노드 참조
var character_manager: Node
var relationship_manager: Node

func _ready():
	# 싱글톤 참조
	character_manager = get_node_or_null("/root/CharacterManager")
	relationship_manager = get_node_or_null("/root/CharacterRelationshipManager")

# 시나리오 로드
func load_scenario(scenario_path: String) -> bool:
	var file = FileAccess.open(scenario_path, FileAccess.READ)
	if not file:
		push_error("시나리오 파일을 열 수 없습니다: " + scenario_path)
		return false
	
	var xml_string = file.get_as_text()
	file.close()
	
	# XML 파싱 (간단한 구현)
	scenario_data = _parse_xml_scenario(xml_string)
	
	if scenario_data.is_empty():
		push_error("시나리오 파싱 실패: " + scenario_path)
		return false
	
	current_scenario_id = scenario_data.get("id", "")
	current_route = scenario_data.get("default_route", "main")
	
	emit_signal("dialogue_started", current_scenario_id)
	return true

# 대화 시작
func start_dialogue(scene_id: String = "") -> void:
	if scenario_data.is_empty():
		push_error("시나리오가 로드되지 않았습니다")
		return
	
	if scene_id.is_empty():
		# 기본 씬 또는 현재 루트의 첫 번째 씬
		scene_id = _get_first_scene_in_route(current_route)
	
	load_scene(scene_id)

# 씬 로드
func load_scene(scene_id: String) -> void:
	if not scenario_data.has("scenes"):
		return
	
	var scene_data = scenario_data.scenes.get(scene_id)
	if not scene_data:
		push_error("씬을 찾을 수 없습니다: " + scene_id)
		return
	
	current_scene_id = scene_id
	
	# 방문 기록
	if not scene_id in visited_scenes:
		visited_scenes.append(scene_id)
	
	# 씬 시작 액션 실행
	_execute_actions(scene_data.get("on_enter", []))
	
	# 대화 큐 구성
	current_dialogue_queue = scene_data.get("dialogues", [])
	current_message_index = 0
	
	# 첫 번째 메시지 표시
	_display_next_message()

# 다음 메시지 표시
func _display_next_message() -> void:
	if current_message_index >= current_dialogue_queue.size():
		# 대화 완료, 선택지 또는 다음 씬으로
		_handle_scene_completion()
		return
	
	var message_data = current_dialogue_queue[current_message_index]
	
	# 조건 확인
	if not _check_conditions(message_data.get("conditions", [])):
		current_message_index += 1
		_display_next_message()
		return
	
	# 메시지 표시
	var speaker = message_data.get("speaker", "")
	var text = message_data.get("text", "")
	var emotion = message_data.get("emotion", "")
	
	# 텍스트 치환 (변수)
	text = _replace_variables(text)
	
	# 이력에 추가
	dialogue_history.append({
		"speaker": speaker,
		"text": text,
		"emotion": emotion,
		"timestamp": Time.get_datetime_string_from_system()
	})
	
	# 감정 변경
	if not emotion.is_empty() and character_manager:
		character_manager.get_character(speaker).change_emotion(emotion)
		emit_signal("emotion_changed", speaker, emotion)
	
	# 효과 실행
	_execute_effects(message_data.get("effects", []))
	
	emit_signal("message_displayed", speaker, text)
	current_message_index += 1

# 선택지 처리
func _handle_scene_completion() -> void:
	var scene_data = scenario_data.scenes.get(current_scene_id, {})
	
	# 선택지가 있는 경우
	if scene_data.has("choices"):
		var available_choices = _filter_choices_by_conditions(scene_data.choices)
		emit_signal("choice_presented", available_choices)
	else:
		# 자동 진행
		_advance_to_next_scene()

# 선택지 선택
func select_choice(choice_id: String) -> void:
	emit_signal("choice_selected", choice_id)
	
	var scene_data = scenario_data.scenes.get(current_scene_id, {})
	var choices = scene_data.get("choices", [])
	
	var selected_choice = null
	for choice in choices:
		if choice.id == choice_id:
			selected_choice = choice
			break
	
	if not selected_choice:
		push_error("선택지를 찾을 수 없습니다: " + choice_id)
		return
	
	# 효과 실행
	_execute_effects(selected_choice.get("effects", []))
	
	# 다음 씬 또는 루트로 이동
	if selected_choice.has("next_scene"):
		load_scene(selected_choice.next_scene)
	elif selected_choice.has("next_route"):
		change_route(selected_choice.next_route)
	else:
		_advance_to_next_scene()

# 루트 변경
func change_route(new_route: String) -> void:
	current_route = new_route
	emit_signal("route_changed", new_route)
	
	# 새 루트의 첫 번째 씬으로 이동
	var first_scene = _get_first_scene_in_route(new_route)
	if not first_scene.is_empty():
		load_scene(first_scene)

# 다음 씬으로 진행
func _advance_to_next_scene() -> void:
	var scene_data = scenario_data.scenes.get(current_scene_id, {})
	
	# 종료 액션 실행
	_execute_actions(scene_data.get("on_exit", []))
	
	# 다음 씬 확인
	if scene_data.has("next_scene"):
		load_scene(scene_data.next_scene)
	elif scene_data.has("next_route"):
		change_route(scene_data.next_route)
	else:
		# 시나리오 완료
		end_dialogue()

# 대화 종료
func end_dialogue() -> void:
	emit_signal("dialogue_ended", current_scenario_id)
	
	# 상태 저장
	save_dialogue_state()

# 변수 관리
func set_variable(name: String, value: Variant) -> void:
	variables[name] = value
	emit_signal("variable_changed", name, value)

func get_variable(name: String, default: Variant = null) -> Variant:
	return variables.get(name, default)

func modify_variable(name: String, operation: String, value: Variant) -> void:
	var current = get_variable(name, 0)
	
	match operation:
		"add", "+":
			current += value
		"subtract", "-":
			current -= value
		"multiply", "*":
			current *= value
		"divide", "/":
			if value != 0:
				current /= value
		"set", "=":
			current = value
	
	set_variable(name, current)

# 조건 확인
func _check_conditions(conditions: Array) -> bool:
	for condition in conditions:
		if not _evaluate_condition(condition):
			return false
	return true

func _evaluate_condition(condition: Dictionary) -> bool:
	var type = condition.get("type", "variable")
	
	match type:
		"variable":
			return _check_variable_condition(condition)
		"relationship":
			return _check_relationship_condition(condition)
		"flag":
			return _check_flag_condition(condition)
		"visited":
			return _check_visited_condition(condition)
	
	return true

func _check_variable_condition(condition: Dictionary) -> bool:
	var var_name = condition.get("variable", "")
	var operator = condition.get("operator", "==")
	var value = condition.get("value")
	var current = get_variable(var_name)
	
	return _compare_values(current, operator, value)

func _check_relationship_condition(condition: Dictionary) -> bool:
	if not relationship_manager:
		return true
	
	var char1 = condition.get("character1", "")
	var char2 = condition.get("character2", "")
	var rel_type = condition.get("relationship_type", "affection")
	var operator = condition.get("operator", ">=")
	var value = condition.get("value", 0)
	
	return relationship_manager.check_relationship_requirement(char1, char2, rel_type, operator, value)

func _check_flag_condition(condition: Dictionary) -> bool:
	var flag_name = condition.get("flag", "")
	return get_variable(flag_name, false) == true

func _check_visited_condition(condition: Dictionary) -> bool:
	var scene_id = condition.get("scene", "")
	return scene_id in visited_scenes

# 효과 실행
func _execute_effects(effects: Array) -> void:
	for effect in effects:
		_execute_effect(effect)

func _execute_effect(effect: Dictionary) -> void:
	var type = effect.get("type", "variable")
	
	match type:
		"variable":
			_execute_variable_effect(effect)
		"relationship":
			_execute_relationship_effect(effect)
		"flag":
			_execute_flag_effect(effect)
		"emotion":
			_execute_emotion_effect(effect)
		"route":
			_execute_route_effect(effect)

func _execute_variable_effect(effect: Dictionary) -> void:
	var var_name = effect.get("variable", "")
	var operation = effect.get("operation", "set")
	var value = effect.get("value")
	
	modify_variable(var_name, operation, value)

func _execute_relationship_effect(effect: Dictionary) -> void:
	if not relationship_manager:
		return
	
	var char1 = effect.get("character1", "")
	var char2 = effect.get("character2", "")
	var rel_type = effect.get("relationship_type", "affection")
	var operation = effect.get("operation", "add")
	var value = effect.get("value", 0)
	
	if operation == "set":
		relationship_manager.set_relationship(char1, char2, rel_type, value)
	else:
		relationship_manager.modify_relationship(char1, char2, rel_type, value)

func _execute_flag_effect(effect: Dictionary) -> void:
	var flag_name = effect.get("flag", "")
	var value = effect.get("value", true)
	set_variable(flag_name, value)

func _execute_emotion_effect(effect: Dictionary) -> void:
	var character_id = effect.get("character", "")
	var emotion = effect.get("emotion", "")
	
	if character_manager and not emotion.is_empty():
		var character = character_manager.get_character(character_id)
		if character:
			character.change_emotion(emotion)
			emit_signal("emotion_changed", character_id, emotion)

func _execute_route_effect(effect: Dictionary) -> void:
	var new_route = effect.get("route", "")
	if not new_route.is_empty():
		change_route(new_route)

# 액션 실행
func _execute_actions(actions: Array) -> void:
	for action in actions:
		_execute_effect(action)

# 유틸리티 함수들
func _compare_values(left: Variant, operator: String, right: Variant) -> bool:
	match operator:
		"==", "=":
			return left == right
		"!=":
			return left != right
		">":
			return left > right
		">=":
			return left >= right
		"<":
			return left < right
		"<=":
			return left <= right
		"contains":
			return str(right) in str(left)
		"starts_with":
			return str(left).begins_with(str(right))
		"ends_with":
			return str(left).ends_with(str(right))
	
	return false

func _replace_variables(text: String) -> String:
	# {variable_name} 형식의 변수 치환
	var regex = RegEx.new()
	regex.compile("\\{([^}]+)\\}")
	
	var result = regex.search(text)
	while result:
		var var_name = result.get_string(1)
		var var_value = str(get_variable(var_name, ""))
		text = text.replace("{" + var_name + "}", var_value)
		result = regex.search(text)
	
	return text

func _filter_choices_by_conditions(choices: Array) -> Array:
	var filtered = []
	for choice in choices:
		if _check_conditions(choice.get("conditions", [])):
			filtered.append(choice)
	return filtered

func _get_first_scene_in_route(route_id: String) -> String:
	if not scenario_data.has("routes"):
		return ""
	
	var route = scenario_data.routes.get(route_id, {})
	if route.has("scenes") and route.scenes.size() > 0:
		return route.scenes[0]
	
	return ""

func _parse_xml_scenario(xml_string: String) -> Dictionary:
	# 간단한 XML 파싱 (실제로는 XMLParser 사용 권장)
	# 이것은 플레이스홀더 구현
	var parser = XMLParser.new()
	var error = parser.open_buffer(xml_string.to_utf8_buffer())
	
	if error != OK:
		return {}
	
	# 실제 구현에서는 XMLParser를 사용하여 전체 파싱
	# 여기서는 기본 구조만 반환
	return {
		"id": "scenario",
		"default_route": "main",
		"scenes": {},
		"routes": {}
	}

# 저장/로드
func save_dialogue_state() -> Dictionary:
	return {
		"scenario_id": current_scenario_id,
		"route": current_route,
		"scene_id": current_scene_id,
		"variables": variables.duplicate(),
		"history": dialogue_history.duplicate(),
		"visited": visited_scenes.duplicate()
	}

func load_dialogue_state(state: Dictionary) -> void:
	current_scenario_id = state.get("scenario_id", "")
	current_route = state.get("route", "main")
	current_scene_id = state.get("scene_id", "")
	variables = state.get("variables", {})
	dialogue_history = state.get("history", [])
	visited_scenes = state.get("visited", [])
