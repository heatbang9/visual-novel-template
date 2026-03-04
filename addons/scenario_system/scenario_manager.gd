extends Node

# class_name ScenarioManager

signal scenario_loaded(scenario_path: String)
signal scenario_completed(scenario_path: String)
signal choice_selected(choice_id: String, target_route: String)
signal route_changed(old_route: String, new_route: String)
signal achievement_triggered(achievement_id: String)
signal item_received(item_id: String, count: int)
signal flashback_triggered(flashback_id: String)

var current_scenario: Dictionary = {}
var current_scene_index: int = 0
var scenario_variables: Dictionary = {}
var current_route: String = "main"
var scenario_history: Array[String] = []

# 업적 데이터 캐시
var _achievement_definitions: Dictionary = {}

# 플래시백 데이터 캐시
var _flashback_definitions: Dictionary = {}

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
	
	# 업적 등록
	_register_achievements()
	
	# 인벤토리 아이템 등록
	_register_inventory_items()
	
	# 플래시백 등록
	_register_flashbacks()
	
	# 분기 통계 등록
	_register_branch_stats()
	
	if current_scenario.has("name"):
		emit_signal("scenario_loaded", scenario_path)
		return OK
	
	return Error.FAILED

# 속성 값 가져오기 (기본값 지원)
func _get_attr(parser: XMLParser, name: String, default: String = "") -> String:
	if parser.has_attribute(name):
		return parser.get_named_attribute_value(name)
	return default

# XML 파싱
func _parse_scenario_xml(parser: XMLParser) -> Dictionary:
	var scenario_data = {
		"name": "",
		"routes": {},
		"scenes": [],
		"global_variables": {},
		"achievements": [],
		"items": [],
		"flashbacks": [],  # 플래시백 데이터 추가
		"branch_stats": {}  # 분기 통계 데이터 추가
	}
	
	var current_route_id = ""
	var current_scene = {}
	var current_achievement = {}
	
	# ============ 인벤토리 파싱 변수 ============
	var current_item = {}
	var in_on_use = false
	var current_text_content = ""
	
	# ============ 플래시백 파싱 변수 ============
	var current_flashback = {}
	var in_flashback = false
	var current_flashback_scene = {}
	var current_flashback_effect = {}
	
	# ============ 분기 통계 파싱 변수 ============
	var current_branch_stats = {}
	var current_stat = {}
	var current_branch_prediction = {}
	
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
						if in_flashback:
							# 플래시백 내부의 씬
							current_flashback_scene = {
								"id": _get_attr(parser, "id", ""),
								"path": parser.get_named_attribute_value("path")
							}
						else:
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
							"target_route": _get_attr(parser, "target_route", ""),
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
						if in_flashback:
							# 플래시백 효과
							current_flashback_effect = {
								"variable": parser.get_named_attribute_value("variable"),
								"value": _parse_value(parser.get_named_attribute_value("value"))
							}
						else:
							if current_scene.choices.size() > 0:
								var effect = {
									"variable": parser.get_named_attribute_value("variable"),
									"modifier": parser.get_named_attribute_value("modifier"),
									"value": _parse_value(parser.get_named_attribute_value("value"))
								}
								current_scene.choices[-1].effects.append(effect)
					
					# ============ 업적 태그 파싱 ============
					"achievement":
						current_achievement = {
							"id": parser.get_named_attribute_value("id"),
							"name": parser.get_named_attribute_value("name"),
							"description": _get_attr(parser, "description", ""),
							"icon": _get_attr(parser, "icon", ""),
							"hidden": _get_attr(parser, "hidden", "false").to_lower() == "true",
							"conditions": [],
							"rewards": []
						}
						if parser.has_attribute("auto_unlock"):
							current_achievement["auto_unlock"] = parser.get_named_attribute_value("auto_unlock").to_lower() == "true"
						else:
							current_achievement["auto_unlock"] = true
					
					"achievement_condition":
						if not current_achievement.is_empty():
							var cond = {
								"type": _get_attr(parser, "type", "variable"),
								"variable": _get_attr(parser, "variable", ""),
								"operator": _get_attr(parser, "operator", "=="),
								"value": _parse_value(_get_attr(parser, "value", ""))
							}
							if parser.has_attribute("flag"):
								cond["flag"] = parser.get_named_attribute_value("flag")
							if parser.has_attribute("route"):
								cond["route"] = parser.get_named_attribute_value("route")
							current_achievement.conditions.append(cond)
					
					"reward":
						if not current_achievement.is_empty():
							var reward = {
								"type": _get_attr(parser, "type", "unlock"),
								"target": _get_attr(parser, "target", ""),
								"value": null
							}
							if parser.has_attribute("value"):
								reward["value"] = _parse_value(parser.get_named_attribute_value("value"))
							current_achievement.rewards.append(reward)
					
					# 업적 트리거 (씬 내에서 업적 수동 해제)
					"trigger_achievement":
						if current_scene.has("actions"):
							var trigger_action = {
								"type": "trigger_achievement",
								"achievement_id": parser.get_named_attribute_value("id")
							}
							current_scene.actions.append(trigger_action)
					
					# ============ 인벤토리 태그 파싱 ============
					"inventory":
						current_item = {
							"id": parser.get_named_attribute_value("id"),
							"name": _get_attr(parser, "name", ""),
							"description": _get_attr(parser, "description", ""),
							"icon": "",
							"stackable": true,
							"max_count": 99,
							"consumable": true,
							"on_use": [],
							"tags": []
						}
					
					"icon":
						if not current_item.is_empty():
							# 텍스트 노드에서 읽기 위해 플래그 설정
							pass
					
					"stackable":
						if not current_item.is_empty():
							# 텍스트 노드에서 읽기
							pass
					
					"max_count":
						if not current_item.is_empty():
							# 텍스트 노드에서 읽기
							pass
					
					"consumable":
						if not current_item.is_empty():
							# 텍스트 노드에서 읽기
							pass
					
					"tag":
						if not current_item.is_empty():
							var tag_value = _get_attr(parser, "value", "")
							if not tag_value.is_empty():
								current_item.tags.append(tag_value)
					
					"on_use":
						if not current_item.is_empty():
							in_on_use = true
					
					"on_use_effect", "use_effect":
						if not current_item.is_empty() and in_on_use:
							var effect = {
								"type": _get_attr(parser, "type", "variable"),
								"variable": _get_attr(parser, "variable", ""),
								"modifier": _get_attr(parser, "modifier", "set"),
								"value": _parse_value(_get_attr(parser, "value", "0"))
							}
							# 추가 속성들
							if parser.has_attribute("id"):
								effect["id"] = parser.get_named_attribute_value("id")
							if parser.has_attribute("item_id"):
								effect["item_id"] = parser.get_named_attribute_value("item_id")
							if parser.has_attribute("count"):
								effect["count"] = parser.get_named_attribute_value("count").to_int()
							current_item.on_use.append(effect)
					
					# 씬 내 아이템 지급 액션
					"give_item":
						if current_scene.has("actions"):
							var give_action = {
								"type": "give_item",
								"item_id": parser.get_named_attribute_value("id"),
								"count": _get_attr(parser, "count", "1").to_int()
							}
							current_scene.actions.append(give_action)
					
					# 씬 내 아이템 제거 액션
					"take_item":
						if current_scene.has("actions"):
							var take_action = {
								"type": "take_item",
								"item_id": parser.get_named_attribute_value("id"),
								"count": _get_attr(parser, "count", "1").to_int()
							}
							current_scene.actions.append(take_action)
					
					# ============ 플래시백 태그 파싱 ============
					"flashback":
						current_flashback = {
							"id": parser.get_named_attribute_value("id"),
							"trigger_variable": _get_attr(parser, "trigger_variable", ""),
							"trigger_value": _parse_value(_get_attr(parser, "trigger_value", "")),
							"trigger_operator": _get_attr(parser, "trigger_operator", "=="),
							"scene": {},
							"effects": [],
							"return_to_scene": {},
							"bgm": _get_attr(parser, "bgm", ""),
							"fade_duration": _get_attr(parser, "fade_duration", "0.5").to_float(),
							"timeout": _get_attr(parser, "timeout", "300").to_float(),
							"skippable": _get_attr(parser, "skippable", "true").to_lower() == "true",
							"auto_trigger": _get_attr(parser, "auto_trigger", "false").to_lower() == "true"
						}
						in_flashback = true
					
					"return_to_scene":
						if in_flashback:
							current_flashback.return_to_scene = {
								"id": parser.get_named_attribute_value("id")
							}
					
					# 플래시백 트리거 (씬 내에서 플래시백 수동 시작)
					"trigger_flashback":
						if current_scene.has("actions"):
							var trigger_action = {
								"type": "trigger_flashback",
								"flashback_id": parser.get_named_attribute_value("id")
							}
							current_scene.actions.append(trigger_action)
			
			XMLParser.NODE_TEXT:
				var text = parser.get_node_data().strip_edges()
				if not text.is_empty():
					current_text_content = text
			
			XMLParser.NODE_ELEMENT_END:
				var end_name = parser.get_node_name()
				match end_name:
					"scene":
						if in_flashback:
							# 플래시백 내부 씬 저장
							current_flashback.scene = current_flashback_scene
							current_flashback_scene = {}
						else:
							if current_route_id != "":
								scenario_data.routes[current_route_id].scenes.append(current_scene)
							else:
								scenario_data.scenes.append(current_scene)
							current_scene = {}
					
					"achievement":
						if not current_achievement.is_empty():
							scenario_data.achievements.append(current_achievement)
							current_achievement = {}
					
					# ============ 인벤토리 태그 종료 ============
					"inventory":
						if not current_item.is_empty():
							scenario_data.items.append(current_item)
							current_item = {}
					
					"icon":
						if not current_item.is_empty() and not current_text_content.is_empty():
							current_item.icon = current_text_content
							current_text_content = ""
					
					"stackable":
						if not current_item.is_empty() and not current_text_content.is_empty():
							current_item.stackable = current_text_content.to_lower() == "true"
							current_text_content = ""
					
					"max_count":
						if not current_item.is_empty() and not current_text_content.is_empty():
							current_item.max_count = current_text_content.to_int()
							current_text_content = ""
					
					"consumable":
						if not current_item.is_empty() and not current_text_content.is_empty():
							current_item.consumable = current_text_content.to_lower() == "true"
							current_text_content = ""
					
					"on_use":
						in_on_use = false
					
					# ============ 플래시백 태그 종료 ============
					"flashback":
						if not current_flashback.is_empty():
							# scene이 설정되지 않았으면 기본값 사용
							if current_flashback.scene.is_empty() and not current_flashback_scene.is_empty():
								current_flashback.scene = current_flashback_scene
							
							scenario_data.flashbacks.append(current_flashback)
							current_flashback = {}
							current_flashback_scene = {}
							in_flashback = false
					
					"effect":
						if in_flashback:
							if not current_flashback_effect.is_empty():
								current_flashback.effects.append(current_flashback_effect)
								current_flashback_effect = {}
	
	return scenario_data

# 업적 등록
func _register_achievements() -> void:
	if not current_scenario.has("achievements"):
		return
	
	for achievement_data in current_scenario.achievements:
		var id = achievement_data.get("id", "")
		if not id.is_empty():
			_achievement_definitions[id] = achievement_data
			AchievementManager.register_achievement(id, achievement_data)

# ============ 인벤토리 아이템 등록 ============
# XML에서 파싱한 아이템 정의 등록
func _register_inventory_items() -> void:
	if not current_scenario.has("items"):
		return
	
	for item_data in current_scenario.items:
		var id = item_data.get("id", "")
		if not id.is_empty():
			InventoryManager.register_item_definition(id, item_data)

# ============ 플래시백 등록 ============
# XML에서 파싱한 플래시백 정의 등록
func _register_flashbacks() -> void:
	if not current_scenario.has("flashbacks"):
		return
	
	for flashback_data in current_scenario.flashbacks:
		var id = flashback_data.get("id", "")
		if not id.is_empty():
			_flashback_definitions[id] = flashback_data
			FlashbackManager.register_flashback_definition(id, flashback_data)

# ============ 분기 통계 등록 ============
# XML에서 파싱한 분기 통계 정의 등록
func _register_branch_stats() -> void:
	if not current_scenario.has("branch_stats"):
		return
	
	var branch_stats_data = current_scenario.branch_stats
	var stats_id = branch_stats_data.get("id", "")
	if not stats_id.is_empty():
		BranchStatsManager.register_branch_stats_definition(stats_id, branch_stats_data)

# 값 파싱 (문자열을 적절한 타입으로 변환)
func _parse_value(value_str):
	if value_str == null:
		return null
	var str_val = str(value_str)
	if str_val.to_lower() == "true":
		return true
	elif str_val.to_lower() == "false":
		return false
	elif str_val.is_valid_int():
		return str_val.to_int()
	elif str_val.is_valid_float():
		return str_val.to_float()
	else:
		return str_val

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
		"has_item":
			return InventoryManager.has_item(variable)
		_:
			return true

# 씬 진행
func advance_scene() -> void:
	var scene = get_next_scene()
	if scene.has("actions"):
		_execute_scene_actions(scene.actions)
	
	# 업적 조건 확인
	_check_achievements()
	
	# 자동 트리거 플래시백 확인
	_check_auto_flashbacks()
	
	current_scene_index += 1

# 업적 조건 확인
func _check_achievements() -> void:
	var newly_unlocked = AchievementManager.check_all_achievements(scenario_variables)
	for achievement_id in newly_unlocked:
		emit_signal("achievement_triggered", achievement_id)

# 자동 트리거 플래시백 확인
func _check_auto_flashbacks() -> void:
	var triggered = await FlashbackManager.check_auto_trigger_flashbacks()
	for flashback_id in triggered:
		emit_signal("flashback_triggered", flashback_id)

# 씬 액션 실행
func _execute_scene_actions(actions: Array) -> void:
	# 플래시백 중에는 선택지 비활성화
	if FlashbackManager.is_in_flashback():
		# 플래시백 중에는 set_variable만 허용 (다른 액션은 무시)
		for action in actions:
			match action.get("type", ""):
				"set_variable":
					var name = action.get("name", "")
					var value = action.get("value", null)
					scenario_variables[name] = value
		return
	
	for action in actions:
		match action.get("type", ""):
			"set_variable":
				var name = action.get("name", "")
				var value = action.get("value", null)
				scenario_variables[name] = value
			
			"trigger_achievement":
				# 수동 업적 트리거
				var achievement_id = action.get("achievement_id", "")
				if not achievement_id.is_empty():
					AchievementManager.unlock_achievement(achievement_id)
					emit_signal("achievement_triggered", achievement_id)
			
			"give_item":
				# 아이템 지급
				var item_id = action.get("item_id", "")
				var count = action.get("count", 1)
				if not item_id.is_empty():
					InventoryManager.add_item(item_id, count)
					emit_signal("item_received", item_id, count)
			
			"take_item":
				# 아이템 제거
				var item_id = action.get("item_id", "")
				var count = action.get("count", 1)
				if not item_id.is_empty():
					InventoryManager.remove_item(item_id, count)
			
			"trigger_flashback":
				# 플래시백 수동 트리거
				var flashback_id = action.get("flashback_id", "")
				if not flashback_id.is_empty():
					await FlashbackManager.start_flashback(flashback_id)
					emit_signal("flashback_triggered", flashback_id)

# 선택지 선택
func make_choice(choice_id: String) -> void:
	# 플래시백 중에는 선택지 비활성화
	if FlashbackManager.is_in_flashback():
		push_warning("플래시백 중에는 선택지를 선택할 수 없습니다")
		return
	
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
			"has_item":
				if not InventoryManager.has_item(variable):
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
	# 변수 변경 시 업적 조건 확인
	_check_achievements()

func get_current_route() -> String:
	return current_route

func get_scenario_name() -> String:
	return current_scenario.get("name", "")

func get_available_choices() -> Array:
	# 플래시백 중에는 선택지 비활성화
	if FlashbackManager.is_in_flashback():
		return []
	
	var scene = get_next_scene()
	if scene.has("choices"):
		var available = []
		for choice in scene.choices:
			if _check_choice_requirements(choice):
				available.append(choice)
		return available
	return []

# 업적 관련 함수
func get_achievement_definitions() -> Dictionary:
	return _achievement_definitions

func trigger_achievement(achievement_id: String) -> bool:
	return AchievementManager.unlock_achievement(achievement_id)

# 인벤토리 관련 함수
func give_item(item_id: String, count: int = 1) -> bool:
	var result = InventoryManager.add_item(item_id, count)
	if result:
		emit_signal("item_received", item_id, count)
	return result

func take_item(item_id: String, count: int = 1) -> bool:
	return InventoryManager.remove_item(item_id, count)

func use_inventory_item(item_id: String) -> bool:
	return InventoryManager.use_item(item_id)

func has_inventory_item(item_id: String) -> bool:
	return InventoryManager.has_item(item_id)

func get_inventory_item_count(item_id: String) -> int:
	return InventoryManager.get_item_count(item_id)

func get_all_inventory_items() -> Array:
	return InventoryManager.get_all_items()

# 플래시백 관련 함수
func get_flashback_definitions() -> Dictionary:
	return _flashback_definitions

func trigger_flashback(flashback_id: String) -> bool:
	await FlashbackManager.start_flashback(flashback_id)
	return true

func _trigger_flashback_internal(flashback_id: String) -> bool:
	return await FlashbackManager.start_flashback(flashback_id)

func end_current_flashback() -> bool:
	await FlashbackManager.end_flashback()
	return true

func _end_current_flashback_internal() -> bool:
	return await FlashbackManager.end_flashback()

func is_in_flashback() -> bool:
	return FlashbackManager.is_in_flashback()

func get_flashback_depth() -> int:
	return FlashbackManager.get_flashback_depth()

func has_seen_flashback(flashback_id: String) -> bool:
	return FlashbackManager.has_seen_flashback(flashback_id)

func preload_flashback(flashback_id: String) -> bool:
	return FlashbackManager.preload_flashback(flashback_id)

# 저장/로드 기능
func save_state() -> Dictionary:
	return {
		"current_scenario": current_scenario,
		"current_scene_index": current_scene_index,
		"scenario_variables": scenario_variables,
		"current_route": current_route,
		"scenario_history": scenario_history,
		"flashback_state": FlashbackManager.save_state(),
		"branch_stats_state": BranchStatsManager.save_state()
	}

func load_state(state: Dictionary) -> void:
	current_scenario = state.get("current_scenario", {})
	current_scene_index = state.get("current_scene_index", 0)
	scenario_variables = state.get("scenario_variables", {})
	current_route = state.get("current_route", "main")
	scenario_history = state.get("scenario_history", [])
	
	# 플래시백 상태 복원
	if state.has("flashback_state"):
		FlashbackManager.load_state(state.flashback_state)
	
	# 분기 통계 상태 복원
	if state.has("branch_stats_state"):
		BranchStatsManager.load_state(state.branch_stats_state)
# ============ 분기 통계 관련 함수 ============
## 분기 통계 분석
func analyze_branch_stats() -> Dictionary:
	return BranchStatsManager.analyze_branch_stats()

## 엔딩 예측
func predict_ending() -> String:
	return BranchStatsManager.predict_ending()

## 루트 대안 가져오기
func get_route_alternatives() -> Array:
	return BranchStatsManager.get_route_alternatives()

## 통계 업데이트
func update_branch_stat(variable: String, value: Variant) -> void:
	BranchStatsManager.update_stats(variable, value)

## 통계 요약 가져오기
func get_branch_stat_summary() -> String:
	return BranchStatsManager.get_stat_summary()

## 분기 통계 리셋
func reset_branch_stats() -> void:
	BranchStatsManager.reset_stats()

## 현재 예측된 루트
func get_predicted_route() -> String:
	return BranchStatsManager.get_predicted_route()

## 예측 신뢰도
func get_prediction_confidence() -> float:
	return BranchStatsManager.get_prediction_confidence()

## 분기 통계 디버그 모드 설정
func set_branch_stats_debug_mode(enabled: bool) -> void:
	BranchStatsManager.set_debug_mode(enabled)
