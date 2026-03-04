extends SceneTree

## XML 시스템 TDD 테스트

const EnhancedXMLParserScript = preload("res://addons/scene_system/enhanced_xml_parser.gd")

var tests_passed = 0
var tests_failed = 0
var test_results = []

func _init():
	print("========================================")
	print("Visual Novel XML System TDD Test")
	print("========================================")
	
	# 테스트 실행
	test_parser_initialization()
	test_scene_parsing()
	test_character_parsing()
	test_message_parsing()
	test_choice_parsing()
	test_action_parsing()
	test_screen_effect_parsing()
	test_camera_parsing()
	test_audio_parsing()
	
	# 결과 출력
	print("\n========================================")
	print("Test Results")
	print("========================================")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("Total: %d" % (tests_passed + tests_failed))
	print("========================================")
	
	if tests_failed > 0:
		quit(1)
	else:
		quit(0)

func assert_true(condition: bool, test_name: String, message: String = "") -> bool:
	if condition:
		tests_passed += 1
		test_results.append({"name": test_name, "status": "PASS", "message": ""})
		print("[PASS] %s" % test_name)
		return true
	else:
		tests_failed += 1
		test_results.append({"name": test_name, "status": "FAIL", "message": message})
		print("[FAIL] %s - %s" % [test_name, message])
		return false

func assert_equal(actual, expected, test_name: String) -> bool:
	return assert_true(actual == expected, test_name, "Expected: %s, Got: %s" % [expected, actual])

func assert_not_null(value, test_name: String) -> bool:
	return assert_true(value != null, test_name, "Value is null")

func assert_has_key(dict: Dictionary, key: String, test_name: String) -> bool:
	return assert_true(dict.has(key), test_name, "Key '%s' not found" % key)

# ========================================
# 테스트 케이스
# ========================================

func test_parser_initialization():
	print("\n[TEST] Parser Initialization")
	var parser = EnhancedXMLParserScript.new()
	assert_not_null(parser, "Parser instance created")
	assert_not_null(parser.characters, "Characters dictionary initialized")
	assert_not_null(parser.variables, "Variables dictionary initialized")

func test_scene_parsing():
	print("\n[TEST] Scene Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	# 테스트용 XML 생성
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="test_scene" name="Test Scene" localization_key="test.scene">
	<message speaker="narrator">Hello World</message>
</scene>
"""
	
	var file = FileAccess.open("user://test_scene.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_scene.xml")
	
	assert_not_null(result, "Scene parsed successfully")
	if result != null and result.size() > 0:
		assert_equal(result.id, "test_scene", "Scene ID parsed")
		assert_equal(result.name, "Test Scene", "Scene name parsed")
		assert_equal(result.localization_key, "test.scene", "Localization key parsed")

func test_character_parsing():
	print("\n[TEST] Character Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="char_test">
	<character id="yuki" name="Yuki" position="right" scale="0.9">
		<portrait emotion="normal" path="res://yuki_normal.png"/>
		<portrait emotion="happy" path="res://yuki_happy.png"/>
	</character>
</scene>
"""
	
	var file = FileAccess.open("user://test_char.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_char.xml")
	
	assert_not_null(result, "Character scene parsed")
	if result != null and result.has("characters"):
		assert_has_key(result.characters, "yuki", "Character yuki found")
		if result.characters.has("yuki"):
			assert_equal(result.characters.yuki.name, "Yuki", "Character name correct")
			assert_equal(result.characters.yuki.position, "right", "Character position correct")
			assert_equal(result.characters.yuki.scale, 0.9, "Character scale correct")
			assert_has_key(result.characters.yuki.portraits, "normal", "Normal portrait found")
			assert_has_key(result.characters.yuki.portraits, "happy", "Happy portrait found")

func test_message_parsing():
	print("\n[TEST] Message Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="msg_test">
	<message speaker="narrator" typewriter_speed="25">Test message</message>
	<message speaker="yuki" emotion="happy" voice_file="res://voice.ogg">
		Hello!
		<translation lang="en">Hello!</translation>
		<translation lang="ja">こんにちは！</translation>
	</message>
</scene>
"""
	
	var file = FileAccess.open("user://test_msg.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_msg.xml")
	
	assert_not_null(result, "Message scene parsed")
	if result != null and result.has("messages"):
		assert_equal(result.messages.size(), 2, "Two messages parsed")
		
		var msg1 = result.messages[0]
		assert_equal(msg1.speaker, "narrator", "Message 1 speaker correct")
		assert_equal(msg1.typewriter_speed, 25, "Message 1 speed correct")
		assert_equal(msg1.text, "Test message", "Message 1 text correct")
		
		var msg2 = result.messages[1]
		assert_equal(msg2.speaker, "yuki", "Message 2 speaker correct")
		assert_equal(msg2.emotion, "happy", "Message 2 emotion correct")
		assert_has_key(msg2.translations, "en", "English translation found")
		assert_has_key(msg2.translations, "ja", "Japanese translation found")

func test_choice_parsing():
	print("\n[TEST] Choice Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="choice_test">
	<choice_point id="main_choice" timer="10.0">
		<choice target="scene_a">Choice A</choice>
		<choice target="scene_b" condition="affection>=5">Choice B</choice>
		<choice target="scene_c" locked="true">???</choice>
	</choice_point>
</scene>
"""
	
	var file = FileAccess.open("user://test_choice.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_choice.xml")
	
	assert_not_null(result, "Choice scene parsed")
	if result != null and result.has("choices"):
		assert_equal(result.choices.size(), 1, "One choice point parsed")
		
		var cp = result.choices[0]
		assert_equal(cp.id, "main_choice", "Choice point ID correct")
		assert_equal(cp.timer, 10.0, "Choice timer correct")
		assert_equal(cp.choices.size(), 3, "Three choices parsed")
		
		assert_equal(cp.choices[0].target, "scene_a", "Choice A target correct")
		assert_equal(cp.choices[1].condition, "affection>=5", "Choice B condition parsed")
		assert_equal(cp.choices[2].locked, true, "Choice C locked correctly")

func test_action_parsing():
	print("\n[TEST] Action Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="action_test">
	<action type="character_enter" target="yuki" duration="1.0">
		<parameters animation="slide_right" position="right"/>
	</action>
	<action type="change_emotion" target="yuki">
		<parameters emotion="happy" transition="fade"/>
	</action>
	<wait duration="2.0"/>
</scene>
"""
	
	var file = FileAccess.open("user://test_action.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_action.xml")
	
	assert_not_null(result, "Action scene parsed")
	if result != null and result.has("actions"):
		assert_equal(result.actions.size(), 3, "Three actions parsed")
		
		var action1 = result.actions[0]
		assert_equal(action1.type, "character_enter", "Action 1 type correct")
		assert_equal(action1.target, "yuki", "Action 1 target correct")
		assert_has_key(action1.parameters, "animation", "Animation parameter found")
		
		var action2 = result.actions[1]
		assert_equal(action2.type, "change_emotion", "Action 2 type correct")
		
		var action3 = result.actions[2]
		assert_equal(action3.type, "wait", "Wait action correct")
		assert_equal(action3.duration, 2.0, "Wait duration correct")

func test_screen_effect_parsing():
	print("\n[TEST] Screen Effect Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="effect_test">
	<screen_effect type="flash" duration="0.3" color="white"/>
	<screen_effect type="shake" intensity="3.0" duration="0.5"/>
	<screen_effect type="blur" intensity="0.5"/>
	<screen_effect type="vignette" intensity="0.3"/>
</scene>
"""
	
	var file = FileAccess.open("user://test_effect.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_effect.xml")
	
	assert_not_null(result, "Effect scene parsed")
	if result != null and result.has("effects"):
		assert_equal(result.effects.size(), 4, "Four effects parsed")
		
		assert_equal(result.effects[0].type, "flash", "Flash effect type correct")
		assert_equal(result.effects[0].duration, 0.3, "Flash duration correct")
		
		assert_equal(result.effects[1].type, "shake", "Shake effect type correct")
		assert_equal(result.effects[1].intensity, 3.0, "Shake intensity correct")
		
		assert_equal(result.effects[2].type, "blur", "Blur effect type correct")
		assert_equal(result.effects[3].type, "vignette", "Vignette effect type correct")

func test_camera_parsing():
	print("\n[TEST] Camera Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="camera_test">
	<camera_zoom zoom_level="1.5" duration="1.0" animation="ease_in_out"/>
	<camera_move position="640,300" duration="1.5"/>
	<camera_shake intensity="5.0" duration="0.5"/>
</scene>
"""
	
	var file = FileAccess.open("user://test_camera.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_camera.xml")
	
	assert_not_null(result, "Camera scene parsed")
	if result != null and result.has("camera"):
		assert_equal(result.camera.size(), 3, "Three camera commands parsed")
		
		assert_equal(result.camera[0].type, "zoom", "Camera zoom type correct")
		assert_equal(result.camera[0].zoom_level, 1.5, "Zoom level correct")
		assert_equal(result.camera[0].animation, "ease_in_out", "Animation correct")
		
		assert_equal(result.camera[1].type, "move", "Camera move type correct")
		assert_equal(result.camera[2].type, "shake", "Camera shake type correct")

func test_audio_parsing():
	print("\n[TEST] Audio Parsing")
	var parser = EnhancedXMLParserScript.new()
	
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<scene id="audio_test">
	<bgm path="res://bgm.ogg" fade_in="true" loop="true" volume="0.7"/>
	<sfx path="res://sfx.ogg" volume="0.8"/>
	<voice path="res://voice.ogg"/>
	<stop_bgm fade_out="true" fade_duration="2.0"/>
</scene>
"""
	
	var file = FileAccess.open("user://test_audio.xml", FileAccess.WRITE)
	file.store_string(xml_content)
	file.close()
	
	var result = parser.load_scene("user://test_audio.xml")
	
	assert_not_null(result, "Audio scene parsed")
	if result != null and result.has("audio"):
		assert_equal(result.audio.size(), 4, "Four audio commands parsed")
		
		assert_equal(result.audio[0].type, "bgm", "BGM type correct")
		assert_equal(result.audio[0].fade_in, true, "BGM fade_in correct")
		assert_equal(result.audio[0].loop, true, "BGM loop correct")
		assert_equal(result.audio[0].volume, 0.7, "BGM volume correct")
		
		assert_equal(result.audio[1].type, "sfx", "SFX type correct")
		assert_equal(result.audio[2].type, "voice", "Voice type correct")
		assert_equal(result.audio[3].type, "stop_bgm", "Stop BGM type correct")
