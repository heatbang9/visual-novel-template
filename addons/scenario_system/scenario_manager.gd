extends Node

class_name ScenarioManager

signal scenario_loaded(scenario_path: String)
signal scenario_completed(scenario_path: String)
signal choice_selected(choice_id: String, target_route: String)
signal route_changed(old_route: String, new_route: String)

var current_scenario: Dictionary = {}
var current_scene_index: int = 0
var scenario_variables: Dictionary = {}
var current_route: String = "main"
var scenario_history: Array[String] = []

# 기본 변수 초기화
func _ready() -> void:
	_initialize_default_variables()

func _initialize_default_variables() -> void:
	scenario_variables = {
		"first_meeting_complete": false,
		"lunch_time_complete": false,
		"class_time_complete": false,
		"going_home_complete": false,
		"affection_level": 0,
		"friendship_level": 0,
		"current_route": "main"
	}

# 시나리오 XML 로드
func load_scenario(scenario_path: String) -> Error:
	if not FileAccess.file_exists(scenario_path):
		push_error("Scenario file not found: " + scenario_path)
		return Error.FAILED

	var file = FileAccess.open(scenario_path, FileAccess.READ)
	if not file:
		push_error("Failed to open scenario file: " + scenario_path)
		return Error.FAILED
	
	var content = file.get_as_text()
	var parser = XMLParser.new()
	var error = parser.open_buffer(content.to_utf8_buffer())
	
	if error != OK:
		push_error("Failed to parse scenario XML: " + scenario_path)
		return error
	
	current_scenario = _parse_scenario_xml(parser)
	current_scene_index = 0
	scenario_history.append(scenario_path)
	
	if current_scenario.has("name"):
		emit_signal("scenario_loaded", scenario_path)
		return OK
	
	return Error.FAILED

# XML 파싱
func _parse_scenario_xml(parser: XMLParser) -> Dictionary:
	var scenario_data = {
		"name": "",
		"routes": {},
		"scenes": [],
		"global_variables": {}
	}
	
	var current_route_id = ""
	var current_scene = {}
	
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				match node_name:
					"scenario":
						scenario_data.name = parser.get_named_attribute_value("name")
						if parser.has_attribute("default_route"):
							current_route = parser.get_named_attribute_value("default_route")
					
					"route":
						current_route_id = parser.get_named_attribute_value("id")
						var route_name = parser.get_named_attribute_value("name")
						scenario_data.routes[current_route_id] = {
							"name": route_name,
							"scenes": []
						}
					
					"scene":
						current_scene = {
							"path": parser.get_named_attribute_value("path"),
							"conditions": [],
							"actions": [],
							"choices": []
						}
						if parser.has_attribute("id"):
							current_scene["id"] = parser.get_named_attribute_value("id")
					
					"condition":
						var condition = {
							"type": parser.get_named_attribute_value("type"),
							"variable": parser.get_named_attribute_value("variable"),
							"value": parser.get_named_attribute_value("value")
						}
						current_scene.conditions.append(condition)
					
					"set_variable":
						var action = {
							"type": "set_variable",
							"name": parser.get_named_attribute_value("name"),
							"value": _parse_value(parser.get_named_attribute_value("value"))
						}
						current_scene.actions.append(action)
					
					"choice":
						var choice = {
							"id": parser.get_named_attribute_value("id"),
							"text": parser.get_named_attribute_value("text"),
							"target_route": parser.get_named_attribute_value("target_route"),
							"requirements": [],
							"effects": []
						}
						current_scene.choices.append(choice)
					
					"requirement":
						if current_scene.choices.size() > 0:
							var req = {
								"variable": parser.get_named_attribute_value("variable"),
								"operator": parser.get_named_attribute_value("operator"),
								"value": _parse_value(parser.get_named_attribute_value("value"))
							}
							current_scene.choices[-1].requirements.append(req)
					
					"effect":
						if current_scene.choices.size() > 0:
							var effect = {
								"variable": parser.get_named_attribute_value("variable"),
								"modifier": parser.get_named_attribute_value("modifier"),
								"value": _parse_value(parser.get_named_attribute_value("value"))
							}
							current_scene.choices[-1].effects.append(effect)
			
			XMLParser.NODE_ELEMENT_END:
				var end_name = parser.get_node_name()
				if end_name == "scene":
					if current_route_id != "":
						scenario_data.routes[current_route_id].scenes.append(current_scene)
					else:
						scenario_data.scenes.append(current_scene)
					current_scene = {}
	
	return scenario_data

# 값 파싱 (문자열을 적절한 타입으로 변환)
func _parse_value(value_str: String):
	if value_str.to_lower() == "true":
		return true
	elif value_str.to_lower() == "false":
		return false
	elif value_str.is_valid_int():
		return value_str.to_int()
	elif value_str.is_valid_float():
		return value_str.to_float()
	else:
		return value_str

# 다음 씬 가져오기
func get_next_scene() -> Dictionary:
	var scenes = _get_current_route_scenes()
	
	if current_scene_index >= scenes.size():
		emit_signal("scenario_completed", current_scenario.get("name", ""))
		return {}
	
	var scene = scenes[current_scene_index]
	
	# 조건 확인
	if not _check_scene_conditions(scene):
		current_scene_index += 1
		return get_next_scene()  # 재귀적으로 다음 씬 확인
	
	return scene

# 현재 루트의 씬들 가져오기
func _get_current_route_scenes() -> Array:
	if current_scenario.routes.has(current_route):
		return current_scenario.routes[current_route].scenes
	else:
		return current_scenario.get("scenes", [])

# 씬 조건 확인
func _check_scene_conditions(scene: Dictionary) -> bool:
	if not scene.has("conditions"):
		return true
	
	for condition in scene.conditions:
		if not _evaluate_condition(condition):
			return false
	
	return true

# 조건 평가
func _evaluate_condition(condition: Dictionary) -> bool:
	var variable = condition.get("variable", "")
	var expected_value = _parse_value(condition.get("value", ""))
	var condition_type = condition.get("type", "variable")
	
	match condition_type:
		"variable":
			var current_value = scenario_variables.get(variable, null)
			return current_value == expected_value
		"requirement":
			var current_value = scenario_variables.get(variable, null)
			return current_value == expected_value
		_:
			return true

# 씬 진행
func advance_scene() -> void:
	var scene = get_next_scene()
	if scene.has("actions"):
		_execute_scene_actions(scene.actions)
	current_scene_index += 1

# 씬 액션 실행
func _execute_scene_actions(actions: Array) -> void:
	for action in actions:
		match action.get("type", ""):
			"set_variable":
				var name = action.get("name", "")
				var value = action.get("value", null)
				scenario_variables[name] = value

# 선택지 선택
func make_choice(choice_id: String) -> void:
	var scene = get_next_scene()
	if not scene.has("choices"):
		return
	
	for choice in scene.choices:
		if choice.get("id", "") == choice_id:
			# 요구사항 확인
			if not _check_choice_requirements(choice):
				push_warning("Choice requirements not met: " + choice_id)
				return
			
			# 효과 적용
			_apply_choice_effects(choice)
			
			# 루트 변경
			var target_route = choice.get("target_route", "")
			if target_route != "":
				_change_route(target_route)
			
			emit_signal("choice_selected", choice_id, target_route)
			advance_scene()
			return

# 선택지 요구사항 확인
func _check_choice_requirements(choice: Dictionary) -> bool:
	if not choice.has("requirements"):
		return true
	
	for req in choice.requirements:
		var variable = req.get("variable", "")
		var operator = req.get("operator", "==")
		var expected_value = req.get("value", null)
		var current_value = scenario_variables.get(variable, null)
		
		match operator:
			"==":
				if current_value != expected_value:
					return false
			">=":
				if current_value < expected_value:
					return false
			"<=":
				if current_value > expected_value:
					return false
			">":
				if current_value <= expected_value:
					return false
			"<":
				if current_value >= expected_value:
					return false
	
	return true

# 선택지 효과 적용
func _apply_choice_effects(choice: Dictionary) -> void:
	if not choice.has("effects"):
		return
	
	for effect in choice.effects:
		var variable = effect.get("variable", "")
		var modifier = effect.get("modifier", "set")
		var value = effect.get("value", 0)
		var current_value = scenario_variables.get(variable, 0)
		
		match modifier:
			"set":
				scenario_variables[variable] = value
			"add":
				scenario_variables[variable] = current_value + value
			"subtract":
				scenario_variables[variable] = current_value - value
			"multiply":
				scenario_variables[variable] = current_value * value

# 루트 변경
func _change_route(new_route: String) -> void:
	if new_route != current_route:
		var old_route = current_route
		current_route = new_route
		current_scene_index = 0  # 새 루트의 시작으로
		scenario_variables["current_route"] = new_route
		emit_signal("route_changed", old_route, new_route)

# 게터 함수들
func get_variable(name: String):
	return scenario_variables.get(name, null)

func set_variable(name: String, value) -> void:
	scenario_variables[name] = value

func get_current_route() -> String:
	return current_route

func get_scenario_name() -> String:
	return current_scenario.get("name", "")

func get_available_choices() -> Array:
	var scene = get_next_scene()
	if scene.has("choices"):
		var available = []
		for choice in scene.choices:
			if _check_choice_requirements(choice):
				available.append(choice)
		return available
	return []

# 저장/로드 기능
func save_state() -> Dictionary:
	return {
		"current_scenario": current_scenario,
		"current_scene_index": current_scene_index,
		"scenario_variables": scenario_variables,
		"current_route": current_route,
		"scenario_history": scenario_history
	}

func load_state(state: Dictionary) -> void:
	current_scenario = state.get("current_scenario", {})
	current_scene_index = state.get("current_scene_index", 0)
	scenario_variables = state.get("scenario_variables", {})
	current_route = state.get("current_route", "main")
	scenario_history = state.get("scenario_history", [])