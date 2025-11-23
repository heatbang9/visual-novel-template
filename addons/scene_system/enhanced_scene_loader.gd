extends Node

class_name EnhancedSceneLoader

signal scene_action_started(action_type: String, action_data: Dictionary)
signal scene_action_completed(action_type: String, action_data: Dictionary)
signal scene_fully_loaded(scene_name: String)

@export var visual_director: VisualDirector
@export var audio_manager: AudioManager
@export var localization_manager: LocalizationManager

var current_scene_data: Dictionary = {}
var current_message_index: int = 0
var scene_actions: Array = []
var character_nodes: Dictionary = {}
var background_node: Sprite2D
var camera_node: Camera2D

func _ready() -> void:
	if not visual_director:
		visual_director = VisualDirector.new()
		add_child(visual_director)
	
	if not audio_manager:
		audio_manager = AudioManager.new()
		add_child(audio_manager)
	
	if not localization_manager:
		localization_manager = LocalizationManager.new()
		add_child(localization_manager)

# 확장된 XML 씬 로딩
func load_enhanced_scene(xml_path: String) -> Error:
	if not FileAccess.file_exists(xml_path):
		push_error("Scene file not found: " + xml_path)
		return Error.FAILED

	var file = FileAccess.open(xml_path, FileAccess.READ)
	if not file:
		push_error("Failed to open scene file: " + xml_path)
		return Error.FAILED
	
	var content = file.get_as_text()
	var parser = XMLParser.new()
	var error = parser.open_buffer(content.to_utf8_buffer())
	
	if error != OK:
		push_error("Failed to parse enhanced scene XML: " + xml_path)
		return error
	
	current_scene_data = _parse_enhanced_scene_xml(parser)
	current_message_index = 0
	scene_actions.clear()
	
	if current_scene_data.has("name"):
		await _execute_scene_setup()
		emit_signal("scene_fully_loaded", current_scene_data.name)
		return OK
	
	return Error.FAILED

# 확장된 XML 파싱
func _parse_enhanced_scene_xml(parser: XMLParser) -> Dictionary:
	var scene_data = {
		"name": "",
		"background": {},
		"characters": {},
		"actions": [],
		"messages": [],
		"camera": {},
		"audio": {},
		"effects": [],
		"localization": {}
	}
	
	var current_character_id = ""
	var current_message = {}
	var current_action = {}
	
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				
				match node_name:
					"scene":
						scene_data.name = parser.get_named_attribute_value("name")
						if parser.has_attribute("localization_key"):
							scene_data.localization["title_key"] = parser.get_named_attribute_value("localization_key")
					
					# 배경 설정
					"background":
						scene_data.background = {
							"type": parser.get_named_attribute_value("type"),
							"path": parser.get_named_attribute_value("path"),
							"transition": parser.get_named_attribute_value_safe("transition", "instant"),
							"duration": parser.get_named_attribute_value_safe("duration", "1.0").to_float(),
							"parallax": parser.get_named_attribute_value_safe("parallax", "false") == "true",
							"scale": parser.get_named_attribute_value_safe("scale", "1.0").to_float()
						}
					
					# 캐릭터 정의
					"character":
						var char_data = {
							"id": parser.get_named_attribute_value("id"),
							"name": parser.get_named_attribute_value("name"),
							"default_position": parser.get_named_attribute_value_safe("default_position", "center"),
							"entry_animation": parser.get_named_attribute_value_safe("entry_animation", "fade_in"),
							"exit_animation": parser.get_named_attribute_value_safe("exit_animation", "fade_out"),
							"scale": parser.get_named_attribute_value_safe("scale", "1.0").to_float(),
							"flip_h": parser.get_named_attribute_value_safe("flip_h", "false") == "true",
							"portraits": {},
							"voice_settings": {}
						}
						current_character_id = char_data.id
						scene_data.characters[char_data.id] = char_data
					
					# 캐릭터 초상화
					"portrait":
						var emotion = parser.get_named_attribute_value_safe("emotion", "normal")
						var portrait_data = {
							"path": parser.get_named_attribute_value("path"),
							"offset_x": parser.get_named_attribute_value_safe("offset_x", "0").to_float(),
							"offset_y": parser.get_named_attribute_value_safe("offset_y", "0").to_float(),
							"scale": parser.get_named_attribute_value_safe("scale", "1.0").to_float()
						}
						if current_character_id != "":
							scene_data.characters[current_character_id].portraits[emotion] = portrait_data
					
					# 음성 설정
					"voice":
						if current_character_id != "":
							scene_data.characters[current_character_id].voice_settings = {
								"voice_file": parser.get_named_attribute_value_safe("file", ""),
								"pitch": parser.get_named_attribute_value_safe("pitch", "1.0").to_float(),
								"speed": parser.get_named_attribute_value_safe("speed", "1.0").to_float(),
								"volume": parser.get_named_attribute_value_safe("volume", "1.0").to_float()
							}
					
					# 메시지
					"message":
						current_message = {
							"type": "message",
							"speaker": parser.get_named_attribute_value_safe("speaker", "narrator"),
							"emotion": parser.get_named_attribute_value_safe("emotion", "normal"),
							"voice_file": parser.get_named_attribute_value_safe("voice_file", ""),
							"auto_voice": parser.get_named_attribute_value_safe("auto_voice", "false") == "true",
							"typewriter_speed": parser.get_named_attribute_value_safe("typewriter_speed", "30").to_float(),
							"localization_key": parser.get_named_attribute_value_safe("localization_key", ""),
							"text": "",
							"translations": {}
						}
					
					# 다국어 번역
					"translation":
						var lang = parser.get_named_attribute_value("lang")
						if parser.read() == OK and parser.get_node_type() == XMLParser.NODE_TEXT:
							var text = parser.get_node_data().strip_edges()
							current_message.translations[lang] = text
					
					# 액션 (캐릭터 이동, 효과 등)
					"action":
						current_action = {
							"type": parser.get_named_attribute_value("type"),
							"target": parser.get_named_attribute_value_safe("target", ""),
							"duration": parser.get_named_attribute_value_safe("duration", "1.0").to_float(),
							"wait": parser.get_named_attribute_value_safe("wait", "true") == "true",
							"parameters": {}
						}
						
						# 액션별 파라미터 파싱
						match current_action.type:
							"character_enter":
								current_action.parameters = {
									"animation": parser.get_named_attribute_value_safe("animation", "slide_left"),
									"position": parser.get_named_attribute_value_safe("position", "center")
								}
							"character_exit":
								current_action.parameters = {
									"animation": parser.get_named_attribute_value_safe("animation", "slide_left")
								}
							"character_move":
								current_action.parameters = {
									"to_position": parser.get_named_attribute_value_safe("to_position", "center"),
									"animation": parser.get_named_attribute_value_safe("animation", "linear")
								}
							"change_emotion":
								current_action.parameters = {
									"emotion": parser.get_named_attribute_value_safe("emotion", "normal"),
									"transition": parser.get_named_attribute_value_safe("transition", "instant")
								}
							"camera_move":
								current_action.parameters = {
									"to_position": parser.get_named_attribute_value_safe("to_position", "0,0"),
									"animation": parser.get_named_attribute_value_safe("animation", "ease_in_out")
								}
							"camera_zoom":
								current_action.parameters = {
									"zoom_level": parser.get_named_attribute_value_safe("zoom_level", "1.0").to_float(),
									"animation": parser.get_named_attribute_value_safe("animation", "ease_in_out")
								}
							"screen_effect":
								current_action.parameters = {
									"effect": parser.get_named_attribute_value_safe("effect", "fade_black"),
									"intensity": parser.get_named_attribute_value_safe("intensity", "1.0").to_float()
								}
							"play_sfx":
								current_action.parameters = {
									"audio_path": parser.get_named_attribute_value_safe("audio_path", ""),
									"volume": parser.get_named_attribute_value_safe("volume", "1.0").to_float(),
									"pitch": parser.get_named_attribute_value_safe("pitch", "1.0").to_float()
								}
							"play_bgm":
								current_action.parameters = {
									"audio_path": parser.get_named_attribute_value_safe("audio_path", ""),
									"fade_in": parser.get_named_attribute_value_safe("fade_in", "true") == "true",
									"loop": parser.get_named_attribute_value_safe("loop", "true") == "true"
								}
					
					# 대기
					"wait":
						current_action = {
							"type": "wait",
							"duration": parser.get_named_attribute_value_safe("duration", "1.0").to_float(),
							"wait": true,
							"parameters": {}
						}
					
					# 선택지 포인트
					"choice_point":
						current_message = {
							"type": "choice_point",
							"id": parser.get_named_attribute_value_safe("id", "default_choice")
						}
			
			XMLParser.NODE_TEXT:
				if current_message.has("text"):
					current_message.text = parser.get_node_data().strip_edges()
			
			XMLParser.NODE_ELEMENT_END:
				var end_name = parser.get_node_name()
				match end_name:
					"message":
						if current_message.size() > 0:
							scene_data.messages.append(current_message)
							current_message = {}
					"action":
						if current_action.size() > 0:
							scene_data.actions.append(current_action)
							current_action = {}
					"character":
						current_character_id = ""
	
	return scene_data

# 씬 셋업 실행
func _execute_scene_setup() -> void:
	# 배경 설정
	if current_scene_data.has("background") and current_scene_data.background.size() > 0:
		await _setup_background(current_scene_data.background)
	
	# 캐릭터 설정
	for character_id in current_scene_data.characters:
		await _setup_character(character_id, current_scene_data.characters[character_id])
	
	# 초기 액션 실행 (씬 시작 전 실행되는 액션들)
	for action in current_scene_data.actions:
		if action.get("timing", "start") == "start":
			await _execute_action(action)

# 배경 설정
func _setup_background(bg_data: Dictionary) -> void:
	if not background_node:
		background_node = Sprite2D.new()
		background_node.name = "Background"
		add_child(background_node)
	
	var texture_path = bg_data.get("path", "")
	if not texture_path.is_empty():
		# 다국어 지원 배경
		if localization_manager:
			texture_path = localization_manager.get_localized_audio_path(texture_path)
		
		var texture = load(texture_path)
		if texture:
			var transition_type = bg_data.get("transition", "instant")
			var duration = bg_data.get("duration", 1.0)
			
			if visual_director:
				await visual_director.change_background(background_node, texture, transition_type, duration)
			else:
				background_node.texture = texture
			
			# 배경 스케일 적용
			var scale_value = bg_data.get("scale", 1.0)
			background_node.scale = Vector2(scale_value, scale_value)

# 캐릭터 설정
func _setup_character(character_id: String, char_data: Dictionary) -> void:
	var char_node = Node2D.new()
	char_node.name = character_id
	
	# 기본 설정
	var default_pos = _resolve_position(char_data.get("default_position", "center"))
	char_node.position = default_pos
	
	var scale_value = char_data.get("scale", 1.0)
	char_node.scale = Vector2(scale_value, scale_value)
	
	var flip_h = char_data.get("flip_h", false)
	if flip_h:
		char_node.scale.x *= -1
	
	# 초상화 스프라이트 추가
	var sprite = Sprite2D.new()
	sprite.name = "Portrait"
	char_node.add_child(sprite)
	
	# 기본 감정 설정
	var portraits = char_data.get("portraits", {})
	if portraits.size() > 0:
		var first_emotion = portraits.keys()[0]
		var portrait_data = portraits[first_emotion]
		var texture_path = portrait_data.get("path", "")
		
		if localization_manager:
			texture_path = localization_manager.get_localized_audio_path(texture_path)
		
		var texture = load(texture_path)
		if texture:
			sprite.texture = texture
		
		# 포트레이트 오프셋 적용
		sprite.offset.x = portrait_data.get("offset_x", 0.0)
		sprite.offset.y = portrait_data.get("offset_y", 0.0)
	
	add_child(char_node)
	character_nodes[character_id] = char_node
	
	# 등장 애니메이션 (필요한 경우)
	var entry_animation = char_data.get("entry_animation", "")
	if not entry_animation.is_empty() and entry_animation != "instant":
		char_node.visible = false
		if visual_director:
			await visual_director.character_enter(char_node, entry_animation)

# 다음 메시지 가져오기 (확장된 기능)
func get_next_enhanced_message() -> Dictionary:
	if current_message_index >= current_scene_data.messages.size():
		return {}
	
	var message = current_scene_data.messages[current_message_index]
	current_message_index += 1
	
	# 다국어 텍스트 적용
	if localization_manager and message.has("localization_key"):
		var localized_text = localization_manager.get_text(message.localization_key, "scenarios", message.get("text", ""))
		message.text = localized_text
	elif message.has("translations") and localization_manager:
		var current_lang = localization_manager.get_current_language()
		if message.translations.has(current_lang):
			message.text = message.translations[current_lang]
	
	return message

# 액션 실행
func _execute_action(action: Dictionary) -> void:
	var action_type = action.get("type", "")
	var target = action.get("target", "")
	var duration = action.get("duration", 1.0)
	var parameters = action.get("parameters", {})
	var should_wait = action.get("wait", true)
	
	emit_signal("scene_action_started", action_type, action)
	
	match action_type:
		"character_enter":
			if character_nodes.has(target):
				var char_node = character_nodes[target]
				var animation = parameters.get("animation", "slide_left")
				var position_name = parameters.get("position", "center")
				
				char_node.position = _resolve_position(position_name)
				if visual_director:
					if should_wait:
						await visual_director.character_enter(char_node, animation, duration)
					else:
						visual_director.character_enter(char_node, animation, duration)
		
		"character_exit":
			if character_nodes.has(target):
				var char_node = character_nodes[target]
				var animation = parameters.get("animation", "slide_left")
				if visual_director:
					if should_wait:
						await visual_director.character_exit(char_node, animation, duration)
					else:
						visual_director.character_exit(char_node, animation, duration)
		
		"character_move":
			if character_nodes.has(target):
				var char_node = character_nodes[target]
				var to_position = _resolve_position(parameters.get("to_position", "center"))
				var animation = parameters.get("animation", "linear")
				if visual_director:
					if should_wait:
						await visual_director.character_move(char_node, to_position, animation, duration)
					else:
						visual_director.character_move(char_node, to_position, animation, duration)
		
		"change_emotion":
			if character_nodes.has(target):
				await _change_character_emotion(target, parameters.get("emotion", "normal"))
		
		"camera_zoom":
			if visual_director and camera_node:
				var zoom_level = Vector2(parameters.get("zoom_level", 1.0), parameters.get("zoom_level", 1.0))
				if should_wait:
					await visual_director.camera_zoom(zoom_level, duration)
				else:
					visual_director.camera_zoom(zoom_level, duration)
		
		"screen_effect":
			if visual_director:
				var effect = parameters.get("effect", "fade_black")
				if should_wait:
					await visual_director.screen_transition(effect, duration)
				else:
					visual_director.screen_transition(effect, duration)
		
		"play_sfx":
			if audio_manager:
				var audio_path = parameters.get("audio_path", "")
				var volume = parameters.get("volume", 1.0)
				var pitch = parameters.get("pitch", 1.0)
				
				if localization_manager:
					audio_path = localization_manager.get_localized_audio_path(audio_path)
				
				audio_manager.play_sfx(audio_path, pitch, volume)
		
		"play_bgm":
			if audio_manager:
				var audio_path = parameters.get("audio_path", "")
				var fade_in = parameters.get("fade_in", true)
				
				if localization_manager:
					audio_path = localization_manager.get_localized_audio_path(audio_path)
				
				if should_wait:
					await audio_manager.play_bgm(audio_path, fade_in, duration)
				else:
					audio_manager.play_bgm(audio_path, fade_in, duration)
		
		"wait":
			await get_tree().create_timer(duration).timeout
	
	emit_signal("scene_action_completed", action_type, action)

# 캐릭터 감정 변경
func _change_character_emotion(character_id: String, emotion: String) -> void:
	if not character_nodes.has(character_id):
		return
	
	var char_node = character_nodes[character_id]
	var sprite = char_node.get_node_or_null("Portrait")
	if not sprite:
		return
	
	var char_data = current_scene_data.characters.get(character_id, {})
	var portraits = char_data.get("portraits", {})
	
	if portraits.has(emotion):
		var portrait_data = portraits[emotion]
		var texture_path = portrait_data.get("path", "")
		
		if localization_manager:
			texture_path = localization_manager.get_localized_audio_path(texture_path)
		
		var texture = load(texture_path)
		if texture:
			sprite.texture = texture

# 위치 해석
func _resolve_position(position_name: String) -> Vector2:
	var positions = {
		"far_left": Vector2(160, 600),
		"left": Vector2(320, 600),
		"center": Vector2(640, 600),
		"right": Vector2(960, 600),
		"far_right": Vector2(1120, 600)
	}
	
	if positions.has(position_name):
		return positions[position_name]
	
	# 좌표 형식 (x,y) 파싱
	if "," in position_name:
		var coords = position_name.split(",")
		if coords.size() == 2:
			return Vector2(coords[0].to_float(), coords[1].to_float())
	
	return positions["center"]

# 설정
func set_camera_node(camera: Camera2D) -> void:
	camera_node = camera
	if visual_director:
		visual_director.set_camera_controller(camera)

func set_background_node(bg_node: Sprite2D) -> void:
	background_node = bg_node

# 정리
func clear_scene() -> void:
	for char_id in character_nodes:
		var char_node = character_nodes[char_id]
		if is_instance_valid(char_node):
			char_node.queue_free()
	
	character_nodes.clear()
	current_scene_data.clear()
	current_message_index = 0
	scene_actions.clear()