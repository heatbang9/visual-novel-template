extends Node

## 비주얼 노벨용 확장 XML 파서

signal scene_loaded(scene_data: Dictionary)
signal command_ready(command: String, params: Dictionary)

var current_scene: Dictionary = {}
var characters: Dictionary = {}
var variables: Dictionary = {}

## 이름으로 속성 값 가져오기 (헬퍼 함수)
func _get_attr(parser: XMLParser, name: String, default: String = "") -> String:
	for i in range(parser.get_attribute_count()):
		if parser.get_attribute_name(i) == name:
			return parser.get_attribute_value(i)
	return default

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

## 씬 파싱
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
	
	# 씬 시작 찾기
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "scene":
			scene.id = _get_attr(parser, "id", "")
			scene.name = _get_attr(parser, "name", "")
			scene.localization_key = _get_attr(parser, "localization_key", "")
			break
	
	# 씬 내용 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		
		if node_type == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			match node_name:
				"background":
					scene.backgrounds.append(_parse_background(parser))
				"character":
					var char_data = _parse_character(parser)
					scene.characters[char_data.id] = char_data
				"message":
					scene.messages.append(_parse_message(parser))
				"choice_point":
					scene.choices.append(_parse_choice_point(parser))
				"choice":
					scene.choices.append(_parse_choice(parser))
				"action":
					scene.actions.append(_parse_action(parser))
				"screen_effect", "effect":
					scene.effects.append(_parse_screen_effect(parser))
				"camera", "camera_zoom", "camera_move", "camera_shake":
					scene.camera.append(_parse_camera(parser))
				"bgm", "sfx", "voice", "play_bgm", "play_sfx", "stop_bgm":
					scene.audio.append(_parse_audio(parser))
				"wait":
					scene.actions.append({
						"type": "wait",
						"duration": float(_get_attr(parser, "duration", "1.0"))
					})
				"next":
					scene.next_scene = _get_element_text(parser)
		
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "scene":
				break
	
	return scene

## 배경 파싱
func _parse_background(parser: XMLParser) -> Dictionary:
	return {
		"type": _get_attr(parser, "type", "image"),
		"path": _get_attr(parser, "path", ""),
		"transition": _get_attr(parser, "transition", "fade"),
		"duration": float(_get_attr(parser, "duration", "1.0")),
		"scale": float(_get_attr(parser, "scale", "1.0")),
		"blur": float(_get_attr(parser, "blur", "0.0"))
	}

## 캐릭터 파싱
func _parse_character(parser: XMLParser) -> Dictionary:
	var char = {
		"id": _get_attr(parser, "id", ""),
		"name": _get_attr(parser, "name", ""),
		"position": _get_attr(parser, "position", "center"),
		"scale": float(_get_attr(parser, "scale", "1.0")),
		"opacity": float(_get_attr(parser, "opacity", "1.0")),
		"flip_h": _get_attr(parser, "flip_h", "false") == "true",
		"entry_animation": _get_attr(parser, "entry_animation", "fade_in"),
		"exit_animation": _get_attr(parser, "exit_animation", "fade_out"),
		"portraits": {},
		"voice": {}
	}
	
	# 하위 요소 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT:
			match node_name:
				"portrait":
					var emotion = _get_attr(parser, "emotion", "normal")
					char.portraits[emotion] = {
						"emotion": emotion,
						"path": _get_attr(parser, "path", ""),
						"offset_x": int(_get_attr(parser, "offset_x", "0")),
						"offset_y": int(_get_attr(parser, "offset_y", "0"))
					}
				"voice":
					char.voice = {
						"pitch": float(_get_attr(parser, "pitch", "1.0")),
						"speed": float(_get_attr(parser, "speed", "1.0")),
						"volume": float(_get_attr(parser, "volume", "1.0"))
					}
		
		elif node_type == XMLParser.NODE_ELEMENT_END and node_name == "character":
			break
	
	return char

## 메시지 파싱
func _parse_message(parser: XMLParser) -> Dictionary:
	var msg = {
		"speaker": _get_attr(parser, "speaker", ""),
		"text": "",
		"emotion": _get_attr(parser, "emotion", "normal"),
		"localization_key": _get_attr(parser, "localization_key", ""),
		"translations": {},
		"typewriter_speed": int(_get_attr(parser, "typewriter_speed", "30")),
		"voice_file": _get_attr(parser, "voice_file", ""),
		"text_color": _get_attr(parser, "text_color", "white")
	}
	
	# 하위 요소 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_TEXT:
			msg.text = parser.get_node_data().strip_edges()
		elif node_type == XMLParser.NODE_ELEMENT and node_name == "translation":
			var lang = _get_attr(parser, "lang", "en")
			msg.translations[lang] = _get_element_text(parser)
		elif node_type == XMLParser.NODE_ELEMENT_END and node_name == "message":
			break
	
	return msg

## 선택지 파싱
func _parse_choice_point(parser: XMLParser) -> Dictionary:
	var choice = {
		"id": _get_attr(parser, "id", ""),
		"timer": float(_get_attr(parser, "timer", "0.0")),
		"choices": []
	}
	
	# 하위 choice 파싱
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
		"target": _get_attr(parser, "target", ""),
		"condition": _get_attr(parser, "condition", ""),
		"locked": _get_attr(parser, "locked", "false") == "true",
		"hidden": _get_attr(parser, "hidden", "false") == "true"
	}
	choice.text = _get_element_text(parser)
	return choice

## 액션 파싱
func _parse_action(parser: XMLParser) -> Dictionary:
	var action = {
		"type": _get_attr(parser, "type", ""),
		"target": _get_attr(parser, "target", ""),
		"duration": float(_get_attr(parser, "duration", "0.0")),
		"parameters": {}
	}
	
	# parameters 파싱
	while parser.read() == OK:
		var node_type = parser.get_node_type()
		var node_name = parser.get_node_name()
		
		if node_type == XMLParser.NODE_ELEMENT and node_name == "parameters":
			for i in range(parser.get_attribute_count()):
				action.parameters[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
		elif node_type == XMLParser.NODE_ELEMENT_END and node_name == "action":
			break
	
	return action

## 화면 효과 파싱
func _parse_screen_effect(parser: XMLParser) -> Dictionary:
	return {
		"type": _get_attr(parser, "type", "fade"),
		"duration": float(_get_attr(parser, "duration", "1.0")),
		"intensity": float(_get_attr(parser, "intensity", "1.0")),
		"color": _get_attr(parser, "color", "white")
	}

## 카메라 파싱
func _parse_camera(parser: XMLParser) -> Dictionary:
	var cam = {
		"type": "zoom",
		"duration": float(_get_attr(parser, "duration", "1.0")),
		"zoom_level": float(_get_attr(parser, "zoom_level", "1.0")),
		"intensity": float(_get_attr(parser, "intensity", "1.0")),
		"animation": _get_attr(parser, "animation", "ease_in_out")
	}
	
	var node_name = parser.get_node_name()
	match node_name:
		"camera_zoom": cam.type = "zoom"
		"camera_move": cam.type = "move"
		"camera_shake": cam.type = "shake"
		_: cam.type = _get_attr(parser, "type", "zoom")
	
	return cam

## 오디오 파싱
func _parse_audio(parser: XMLParser) -> Dictionary:
	var audio = {
		"type": "bgm",
		"path": _get_attr(parser, "path", ""),
		"volume": float(_get_attr(parser, "volume", "1.0")),
		"fade_in": _get_attr(parser, "fade_in", "false") == "true",
		"fade_out": _get_attr(parser, "fade_out", "false") == "true",
		"loop": _get_attr(parser, "loop", "true") == "true"
	}
	
	var node_name = parser.get_node_name()
	match node_name:
		"bgm", "play_bgm": audio.type = "bgm"
		"sfx", "play_sfx": audio.type = "sfx"
		"voice": audio.type = "voice"
		"stop_bgm": audio.type = "stop_bgm"
		_: audio.type = _get_attr(parser, "type", "bgm")
	
	return audio

## 유틸리티 함수들

func _get_element_text(parser: XMLParser) -> String:
	var text = ""
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_TEXT:
			text += parser.get_node_data()
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			break
	return text.strip_edges()

## 마스터 인덱스 파싱 (간소화)
func _parse_master_index(parser: XMLParser) -> Dictionary:
	var result = {
		"metadata": {},
		"scenarios": []
	}
	
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "scenario":
			result.scenarios.append({
				"id": _get_attr(parser, "id", ""),
				"path": _get_attr(parser, "path", "")
			})
	
	return result
