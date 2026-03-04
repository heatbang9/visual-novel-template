extends Node
class_name EnhancedXMLParser

## 비주얼 노벨용 확장 XML 파서
## 캐릭터, 화면 효과, 카메라, 텍스트, 오디오 등 모든 비주얼 노벨 기능 지원

signal scene_loaded(scene_data: Dictionary)
signal command_ready(command: String, params: Dictionary)

var current_scene: Dictionary = {}
var characters: Dictionary = {}
var variables: Dictionary = {}

func _ready():
	load_master_index()

## 마스터 인덱스 로드
func load_master_index() -> Dictionary:
	var path = "res://scenarios/scenarios_index.xml"
	if not FileAccess.file_exists(path):
		push_warning("Master index not found: " + path)
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var xml_text = file.get_as_text()
	file.close()
	
	var parser = XMLParser.new()
	var err = parser.open_buffer(xml_text.to_utf8_buffer())
	if err != OK:
		push_error("Failed to parse master index")
		return {}
	
	return _parse_master_index(parser)

## 마스터 인덱스 파싱
func _parse_master_index(parser: XMLParser) -> Dictionary:
	var result = {
		"metadata": {},
		"global_settings": {},
		"variables": {},
		"scenarios": [],
		"endings": [],
		"achievements": [],
		"cg_gallery": []
	}
	
	while parser.read() == OK:
		var node_name = parser.get_node_name()
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			match node_name:
				"metadata":
					result.metadata = _parse_metadata(parser)
				"global_settings":
					result.global_settings = _parse_global_settings(parser)
				"global_variables":
					result.variables = _parse_variables(parser)
				"scenarios":
					result.scenarios = _parse_scenarios(parser)
				"endings":
					result.endings = _parse_endings(parser)
				"achievements":
					result.achievements = _parse_achievements(parser)
				"cg_gallery":
					result.cg_gallery = _parse_cg_gallery(parser)
	
	return result

## 씬 XML 로드 및 파싱
func load_scene(xml_path: String) -> Dictionary:
	if not FileAccess.file_exists(xml_path):
		push_error("Scene file not found: " + xml_path)
		return {}
	
	var file = FileAccess.open(xml_path, FileAccess.READ)
	var xml_text = file.get_as_text()
	file.close()
	
	var parser = XMLParser.new()
	var err = parser.open_buffer(xml_text.to_utf8_buffer())
	if err != OK:
		push_error("Failed to parse scene: " + xml_path)
		return {}
	
	current_scene = _parse_scene(parser)
	emit_signal("scene_loaded", current_scene)
	return current_scene

## 씬 파싱 (모든 비주얼 노벨 기능 포함)
func _parse_scene(parser: XMLParser) -> Dictionary:
	var scene = {
		"id": "",
		"name": "",
		"localization_key": "",
		"backgrounds": [],
		"characters": {},
		"messages": [],
		"choices": [],
		"actions": [],
		"effects": [],
		"camera": [],
		"audio": [],
		"text_settings": {},
		"conditions": [],
		"minigames": [],
		"cg_events": [],
		"next_scene": ""
	}
	
	# 씬 속성 읽기
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"id": scene.id = attr_value
			"name": scene.name = attr_value
			"localization_key": scene.localization_key = attr_value
	
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		
		if node_type == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			match node_name:
				# 배경
				"background":
					scene.backgrounds.append(_parse_background(parser))
				
				# 캐릭터
				"character":
					var char_data = _parse_character(parser)
					scene.characters[char_data.id] = char_data
				
				# 메시지/대화
				"message":
					scene.messages.append(_parse_message(parser))
				
				# 선택지
				"choice_point":
					scene.choices.append(_parse_choice_point(parser))
				"choice":
					scene.choices.append(_parse_choice(parser))
				
				# 액션
				"action":
					scene.actions.append(_parse_action(parser))
				
				# 화면 효과
				"effect", "screen_effect":
					scene.effects.append(_parse_screen_effect(parser))
				
				# 카메라
				"camera", "camera_zoom", "camera_move", "camera_shake":
					scene.camera.append(_parse_camera(parser))
				
				# 오디오
				"bgm", "sfx", "voice", "play_bgm", "play_sfx", "stop_bgm":
					scene.audio.append(_parse_audio(parser))
				
				# 텍스트 설정
				"text_settings":
					scene.text_settings = _parse_text_settings(parser)
				
				# 조건
				"condition", "if":
					scene.conditions.append(_parse_condition(parser))
				
				# 미니게임/QTE
				"minigame", "qte":
					scene.minigames.append(_parse_minigame(parser))
				
				# CG 이벤트
				"cg", "cg_event":
					scene.cg_events.append(_parse_cg_event(parser))
				
				# 대기
				"wait":
					scene.actions.append({
						"type": "wait",
						"duration": float(parser.get_attribute_value("duration", "1.0"))
					})
				
				# 다음 씬
				"next":
					scene.next_scene = _get_element_text(parser)
		
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "scene":
				break
	
	return scene

## 배경 파싱
func _parse_background(parser: XMLParser) -> Dictionary:
	var bg = {
		"type": "image",
		"path": "",
		"transition": "fade",
		"duration": 1.0,
		"scale": 1.0,
		"offset": Vector2.ZERO,
		"blur": 0.0,
		"color": Color.WHITE
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": bg.type = attr_value
			"path": bg.path = attr_value
			"transition": bg.transition = attr_value
			"duration": bg.duration = float(attr_value)
			"scale": bg.scale = float(attr_value)
			"blur": bg.blur = float(attr_value)
			"color": bg.color = Color(attr_value)
	
	return bg

## 캐릭터 파싱 (확장)
func _parse_character(parser: XMLParser) -> Dictionary:
	var char = {
		"id": "",
		"name": "",
		"position": "center",
		"emotion": "normal",
		"portraits": {},
		"voice": {},
		"animation": {},
		"scale": 1.0,
		"flip_h": false,
		"opacity": 1.0,
		"offset": Vector2.ZERO,
		"entry_animation": "fade_in",
		"exit_animation": "fade_out",
		"lip_sync": true,
		"eye_blink": true,
		"shake": false
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"id": char.id = attr_value
			"name": char.name = attr_value
			"default_position", "position": char.position = attr_value
			"scale": char.scale = float(attr_value)
			"flip_h": char.flip_h = attr_value == "true"
			"opacity": char.opacity = float(attr_value)
			"entry_animation": char.entry_animation = attr_value
			"exit_animation": char.exit_animation = attr_value
			"lip_sync": char.lip_sync = attr_value == "true"
			"eye_blink": char.eye_blink = attr_value == "true"
	
	# 하위 요소 파싱 (portrait, voice, animation)
	var depth = 0
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT:
			match node_name:
				"portrait":
					var portrait = _parse_portrait(parser)
					char.portraits[portrait.emotion] = portrait
				"voice":
					char.voice = _parse_voice_settings(parser)
				"animation":
					char.animation = _parse_animation_settings(parser)
		
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if node_name == "character":
				break
	
	return char

## 초상화 파싱
func _parse_portrait(parser: XMLParser) -> Dictionary:
	var portrait = {
		"emotion": "normal",
		"path": "",
		"offset_x": 0,
		"offset_y": 0,
		"scale": 1.0
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"emotion": portrait.emotion = attr_value
			"path": portrait.path = attr_value
			"offset_x": portrait.offset_x = int(attr_value)
			"offset_y": portrait.offset_y = int(attr_value)
			"scale": portrait.scale = float(attr_value)
	
	return portrait

## 메시지 파싱 (확장)
func _parse_message(parser: XMLParser) -> Dictionary:
	var msg = {
		"speaker": "",
		"text": "",
		"emotion": "normal",
		"localization_key": "",
		"translations": {},
		"typewriter_speed": 30,
		"voice_file": "",
		"auto_voice": false,
		"text_color": Color.WHITE,
		"text_size": 16,
		"text_position": "bottom",
		"bold": false,
		"italic": false,
		"ruby": "",
		"effects": [],
		"wait_for_input": true
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"speaker": msg.speaker = attr_value
			"emotion": msg.emotion = attr_value
			"localization_key": msg.localization_key = attr_value
			"typewriter_speed": msg.typewriter_speed = int(attr_value)
			"voice_file": msg.voice_file = attr_value
			"auto_voice": msg.auto_voice = attr_value == "true"
			"text_color": msg.text_color = Color(attr_value)
			"text_size": msg.text_size = int(attr_value)
			"text_position": msg.text_position = attr_value
			"bold": msg.bold = attr_value == "true"
			"italic": msg.italic = attr_value == "true"
			"wait_for_input": msg.wait_for_input = attr_value != "false"
	
	# 하위 요소 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_TEXT:
			msg.text = parser.get_node_data().strip_edges()
		elif node_type == XMLParser.NODE_ELEMENT:
			match node_name:
				"translation":
					var lang = parser.get_attribute_value("lang", "en")
					msg.translations[lang] = _get_element_text(parser)
				"ruby":
					msg.ruby = _get_element_text(parser)
				"effect":
					msg.effects.append(_parse_text_effect(parser))
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if node_name == "message":
				break
	
	return msg

## 텍스트 효과 파싱
func _parse_text_effect(parser: XMLParser) -> Dictionary:
	var effect = {
		"type": "shake",
		"start": 0,
		"end": 0,
		"intensity": 1.0
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": effect.type = attr_value
			"start": effect.start = int(attr_value)
			"end": effect.end = int(attr_value)
			"intensity": effect.intensity = float(attr_value)
	
	return effect

## 화면 효과 파싱
func _parse_screen_effect(parser: XMLParser) -> Dictionary:
	var effect = {
		"type": "fade",
		"duration": 1.0,
		"wait": false,
		"color": Color.WHITE,
		"intensity": 1.0,
		"direction": Vector2.ZERO
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": effect.type = attr_value
			"effect": effect.type = attr_value
			"duration": effect.duration = float(attr_value)
			"wait": effect.wait = attr_value == "true"
			"color": effect.color = Color(attr_value)
			"intensity": effect.intensity = float(attr_value)
			"direction": effect.direction = _parse_vector2(attr_value)
	
	return effect

## 카메라 파싱
func _parse_camera(parser: XMLParser) -> Dictionary:
	var cam = {
		"type": "zoom",
		"target": "main",
		"duration": 1.0,
		"wait": false,
		"zoom_level": 1.0,
		"position": Vector2(640, 360),
		"rotation": 0.0,
		"intensity": 1.0,
		"animation": "ease_in_out"
	}
	
	var node_name = parser.get_node_name()
	match node_name:
		"camera_zoom": cam.type = "zoom"
		"camera_move": cam.type = "move"
		"camera_shake": cam.type = "shake"
		"camera_rotate": cam.type = "rotate"
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": cam.type = attr_value
			"target": cam.target = attr_value
			"duration": cam.duration = float(attr_value)
			"wait": cam.wait = attr_value == "true"
			"zoom_level": cam.zoom_level = float(attr_value)
			"to_position", "position": cam.position = _parse_vector2(attr_value)
			"rotation": cam.rotation = float(attr_value)
			"intensity": cam.intensity = float(attr_value)
			"animation": cam.animation = attr_value
	
	return cam

## 오디오 파싱
func _parse_audio(parser: XMLParser) -> Dictionary:
	var audio = {
		"type": "bgm",
		"path": "",
		"volume": 1.0,
		"pitch": 1.0,
		"loop": true,
		"fade_in": false,
		"fade_out": false,
		"fade_duration": 1.0,
		"wait": false,
		"position_3d": Vector3.ZERO
	}
	
	var node_name = parser.get_node_name()
	match node_name:
		"bgm", "play_bgm": audio.type = "bgm"
		"sfx", "play_sfx": audio.type = "sfx"
		"voice": audio.type = "voice"
		"stop_bgm": audio.type = "stop_bgm"
		"ambient": audio.type = "ambient"
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": audio.type = attr_value
			"path", "audio_path": audio.path = attr_value
			"volume": audio.volume = float(attr_value)
			"pitch": audio.pitch = float(attr_value)
			"loop": audio.loop = attr_value == "true"
			"fade_in": audio.fade_in = attr_value == "true"
			"fade_out": audio.fade_out = attr_value == "true"
			"fade_duration": audio.fade_duration = float(attr_value)
			"wait": audio.wait = attr_value == "true"
			"position_3d": audio.position_3d = _parse_vector3(attr_value)
	
	return audio

## 선택지 파싱
func _parse_choice_point(parser: XMLParser) -> Dictionary:
	var choice = {
		"id": "",
		"choices": [],
		"timer": 0.0,
		"default_index": 0,
		"position": "bottom"
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"id": choice.id = attr_value
			"timer": choice.timer = float(attr_value)
			"default_index": choice.default_index = int(attr_value)
			"position": choice.position = attr_value
	
	# 하위 choice 요소 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT and node_name == "choice":
			choice.choices.append(_parse_single_choice(parser))
		elif node_type == XMLParser.NODE_ELEMENT_END and node_name == "choice_point":
			break
	
	return choice

func _parse_choice(parser: XMLParser) -> Dictionary:
	return _parse_single_choice(parser)

func _parse_single_choice(parser: XMLParser) -> Dictionary:
	var choice = {
		"text": "",
		"target": "",
		"localization_key": "",
		"icon": "",
		"condition": {},
		"locked": false,
		"hidden": false,
		"effects": []
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"target": choice.target = attr_value
			"localization_key": choice.localization_key = attr_value
			"icon": choice.icon = attr_value
			"locked": choice.locked = attr_value == "true"
			"hidden": choice.hidden = attr_value == "true"
	
	choice.text = _get_element_text(parser)
	return choice

## 액션 파싱
func _parse_action(parser: XMLParser) -> Dictionary:
	var action = {
		"type": "",
		"target": "",
		"duration": 0.0,
		"wait": false,
		"condition": "",
		"parameters": {}
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": action.type = attr_value
			"target": action.target = attr_value
			"duration": action.duration = float(attr_value)
			"wait": action.wait = attr_value == "true"
			"condition": action.condition = attr_value
	
	# parameters 하위 요소 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT and node_name == "parameters":
			action.parameters = _parse_parameters(parser)
		elif node_type == XMLParser.NODE_ELEMENT_END and node_name == "action":
			break
	
	return action

## 파라미터 파싱
func _parse_parameters(parser: XMLParser) -> Dictionary:
	var params = {}
	
	for i in range(parser.get_attribute_count()):
		params[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
	
	return params

## 미니게임/QTE 파싱
func _parse_minigame(parser: XMLParser) -> Dictionary:
	var mg = {
		"type": "qte",
		"id": "",
		"trigger": "",
		"timeout": 5.0,
		"success_target": "",
		"fail_target": "",
		"parameters": {}
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": mg.type = attr_value
			"id": mg.id = attr_value
			"trigger": mg.trigger = attr_value
			"timeout": mg.timeout = float(attr_value)
			"success_target": mg.success_target = attr_value
			"fail_target": mg.fail_target = attr_value
	
	# parameters 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT and node_name == "parameters":
			mg.parameters = _parse_parameters(parser)
		elif node_type == XMLParser.NODE_ELEMENT_END and (node_name == "minigame" or node_name == "qte"):
			break
	
	return mg

## CG 이벤트 파싱
func _parse_cg_event(parser: XMLParser) -> Dictionary:
	var cg = {
		"id": "",
		"path": "",
		"type": "fullscreen",
		"duration": 0.0,
		"pan": Vector2.ZERO,
		"zoom": 1.0,
		"filter": "",
		"wait_for_input": true
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"id": cg.id = attr_value
			"path": cg.path = attr_value
			"type": cg.type = attr_value
			"duration": cg.duration = float(attr_value)
			"pan": cg.pan = _parse_vector2(attr_value)
			"zoom": cg.zoom = float(attr_value)
			"filter": cg.filter = attr_value
			"wait_for_input": cg.wait_for_input = attr_value != "false"
	
	return cg

## 조건 파싱
func _parse_condition(parser: XMLParser) -> Dictionary:
	var cond = {
		"type": "variable",
		"variable": "",
		"operator": "==",
		"value": "",
		"then": [],
		"else": []
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"type": cond.type = attr_value
			"variable", "name": cond.variable = attr_value
			"operator": cond.operator = attr_value
			"value": cond.value = attr_value
	
	return cond

## 텍스트 설정 파싱
func _parse_text_settings(parser: XMLParser) -> Dictionary:
	var settings = {
		"speed": 30,
		"auto_delay": 3.0,
		"font": "",
		"size": 16,
		"color": Color.WHITE,
		"position": "bottom",
		"box_style": "default"
	}
	
	for i in range(parser.get_attribute_count()):
		var attr_name = parser.get_attribute_name(i)
		var attr_value = parser.get_attribute_value(i)
		match attr_name:
			"speed": settings.speed = int(attr_value)
			"auto_delay": settings.auto_delay = float(attr_value)
			"font": settings.font = attr_value
			"size": settings.size = int(attr_value)
			"color": settings.color = Color(attr_value)
			"position": settings.position = attr_value
			"box_style": settings.box_style = attr_value
	
	return settings

## 유틸리티 함수들

func _get_element_text(parser: XMLParser) -> String:
	var text = ""
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_TEXT:
			text += parser.get_node_data()
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			break
	return text.strip_edges()

func _parse_vector2(value: String) -> Vector2:
	var parts = value.split(",")
	if parts.size() >= 2:
		return Vector2(float(parts[0]), float(parts[1]))
	return Vector2.ZERO

func _parse_vector3(value: String) -> Vector3:
	var parts = value.split(",")
	if parts.size() >= 3:
		return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	return Vector3.ZERO

# 나머지 파싱 함수들 (메타데이터, 시나리오 등)
func _parse_metadata(parser: XMLParser) -> Dictionary:
	var meta = {}
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var name = parser.get_node_name()
			var lang = parser.get_attribute_value("lang", "")
			var text = _get_element_text(parser)
			if lang != "":
				if not meta.has(name):
					meta[name] = {}
				meta[name][lang] = text
			else:
				meta[name] = text
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "metadata":
			break
	return meta

func _parse_global_settings(parser: XMLParser) -> Dictionary:
	var settings = {}
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var name = parser.get_node_name()
			settings[name] = {}
			for i in range(parser.get_attribute_count()):
				settings[name][parser.get_attribute_name(i)] = parser.get_attribute_value(i)
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "global_settings":
			break
	return settings

func _parse_variables(parser: XMLParser) -> Dictionary:
	var vars = {}
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "variable":
			var name = parser.get_attribute_value("name", "")
			var type = parser.get_attribute_value("type", "string")
			var default = parser.get_attribute_value("default", "")
			if name != "":
				vars[name] = {"type": type, "default": default}
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "global_variables":
			break
	return vars

func _parse_scenarios(parser: XMLParser) -> Array:
	var scenarios = []
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "scenario":
			scenarios.append(_parse_scenario_entry(parser))
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "scenarios":
			break
	return scenarios

func _parse_scenario_entry(parser: XMLParser) -> Dictionary:
	var scenario = {
		"id": parser.get_attribute_value("id", ""),
		"path": parser.get_attribute_value("path", ""),
		"type": parser.get_attribute_value("type", "main"),
		"order": int(parser.get_attribute_value("order", "0"))
	}
	return scenario

func _parse_endings(parser: XMLParser) -> Array:
	var endings = []
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "ending":
			endings.append({
				"id": parser.get_attribute_value("id", ""),
				"name": parser.get_attribute_value("name", "")
			})
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "endings":
			break
	return endings

func _parse_achievements(parser: XMLParser) -> Array:
	var achievements = []
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "achievement":
			achievements.append({
				"id": parser.get_attribute_value("id", ""),
				"name": parser.get_attribute_value("name", ""),
				"description": parser.get_attribute_value("description", "")
			})
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "achievements":
			break
	return achievements

func _parse_cg_gallery(parser: XMLParser) -> Array:
	var gallery = []
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "cg":
			gallery.append({
				"id": parser.get_attribute_value("id", ""),
				"path": parser.get_attribute_value("path", "")
			})
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "cg_gallery":
			break
	return gallery

func _parse_voice_settings(parser: XMLParser) -> Dictionary:
	return {
		"pitch": float(parser.get_attribute_value("pitch", "1.0")),
		"speed": float(parser.get_attribute_value("speed", "1.0")),
		"volume": float(parser.get_attribute_value("volume", "1.0"))
	}

func _parse_animation_settings(parser: XMLParser) -> Dictionary:
	return {
		"lip_sync": parser.get_attribute_value("lip_sync", "true") == "true",
		"eye_blink": parser.get_attribute_value("eye_blink", "true") == "true",
		"breath": parser.get_attribute_value("breath", "true") == "true"
	}
