extends Node

class_name LocalizationManager

signal language_changed(old_language: String, new_language: String)
signal translation_loaded(language: String)

@export var default_language: String = "ko"
@export var supported_languages: Array[String] = ["ko", "en", "ja", "zh"]

var current_language: String
var translations: Dictionary = {}
var character_translations: Dictionary = {}
var font_cache: Dictionary = {}

# 언어별 폰트 설정
var language_fonts: Dictionary = {
	"ko": "res://fonts/korean.ttf",
	"en": "res://fonts/english.ttf", 
	"ja": "res://fonts/japanese.ttf",
	"zh": "res://fonts/chinese.ttf"
}

# 언어별 TTS 음성 설정
var language_tts_settings: Dictionary = {
	"ko": {
		"voice_id": "ko-KR-Standard-A",
		"speed": 1.0,
		"pitch": 0.0
	},
	"en": {
		"voice_id": "en-US-Standard-A",
		"speed": 1.0,
		"pitch": 0.0
	},
	"ja": {
		"voice_id": "ja-JP-Standard-A", 
		"speed": 1.0,
		"pitch": 0.0
	},
	"zh": {
		"voice_id": "zh-CN-Standard-A",
		"speed": 1.0,
		"pitch": 0.0
	}
}

func _ready() -> void:
	current_language = default_language
	_load_translations_for_language(current_language)

# 번역 로딩
func _load_translations_for_language(language: String) -> Error:
	var base_path = "res://localization/%s/" % language
	
	# 일반 번역 로드
	var general_path = base_path + "general.json"
	var general_error = _load_translation_file(general_path, "general")
	
	# 시나리오 번역 로드
	var scenario_path = base_path + "scenarios.json"
	var scenario_error = _load_translation_file(scenario_path, "scenarios")
	
	# 캐릭터 번역 로드
	var character_path = base_path + "characters.json"
	var character_error = _load_translation_file(character_path, "characters")
	
	if general_error != OK and scenario_error != OK and character_error != OK:
		push_error("Failed to load any translations for language: " + language)
		return Error.FAILED
	
	emit_signal("translation_loaded", language)
	return OK

func _load_translation_file(file_path: String, category: String) -> Error:
	if not FileAccess.file_exists(file_path):
		push_warning("Translation file not found: " + file_path)
		return Error.FAILED
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open translation file: " + file_path)
		return Error.FAILED
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse translation file: " + file_path)
		return Error.FAILED
	
	var translation_data = json.data
	
	if not translations.has(current_language):
		translations[current_language] = {}
	
	translations[current_language][category] = translation_data
	return OK

# 언어 변경
func set_language(language: String) -> Error:
	if language == current_language:
		return OK
	
	if not supported_languages.has(language):
		push_error("Unsupported language: " + language)
		return Error.FAILED
	
	var old_language = current_language
	current_language = language
	
	var error = _load_translations_for_language(language)
	if error != OK:
		current_language = old_language
		return error
	
	emit_signal("language_changed", old_language, language)
	return OK

# 번역 가져오기
func get_text(key: String, category: String = "general", fallback: String = "") -> String:
	if not translations.has(current_language):
		return fallback if not fallback.is_empty() else key
	
	var language_data = translations[current_language]
	if not language_data.has(category):
		return fallback if not fallback.is_empty() else key
	
	var category_data = language_data[category]
	if not category_data.has(key):
		# 기본 언어에서 찾기
		if current_language != default_language:
			return _get_fallback_text(key, category, fallback)
		return fallback if not fallback.is_empty() else key
	
	return category_data[key]

func _get_fallback_text(key: String, category: String, fallback: String) -> String:
	if not translations.has(default_language):
		return fallback if not fallback.is_empty() else key
	
	var default_data = translations[default_language]
	if not default_data.has(category):
		return fallback if not fallback.is_empty() else key
	
	var category_data = default_data[category]
	if not category_data.has(key):
		return fallback if not fallback.is_empty() else key
	
	return category_data[key]

# 시나리오 번역
func get_scenario_text(scenario_id: String, scene_id: String, message_id: String) -> String:
	var key = "%s.%s.%s" % [scenario_id, scene_id, message_id]
	return get_text(key, "scenarios", key)

func get_character_text(character_id: String, key: String) -> String:
	var full_key = "%s.%s" % [character_id, key]
	return get_text(full_key, "characters", key)

# 다국어 XML 처리
func process_localized_message(message_element: Dictionary, language: String = "") -> String:
	if language.is_empty():
		language = current_language
	
	# XML에서 다국어 메시지 처리
	var localized_key = message_element.get("localization_key", "")
	if not localized_key.is_empty():
		return get_text(localized_key, "scenarios", message_element.get("text", ""))
	
	# 직접 번역 텍스트가 있는 경우
	var translations_data = message_element.get("translations", {})
	if translations_data.has(language):
		return translations_data[language]
	
	# 기본 텍스트 반환
	return message_element.get("text", "")

# 폰트 관리
func get_current_font() -> Font:
	if font_cache.has(current_language):
		return font_cache[current_language]
	
	var font_path = language_fonts.get(current_language, language_fonts[default_language])
	var font = load(font_path)
	
	if font:
		font_cache[current_language] = font
	
	return font

func apply_font_to_control(control: Control) -> void:
	var font = get_current_font()
	if font and control.has_theme_font_override("font"):
		control.add_theme_font_override("font", font)

# TTS 다국어 지원
func get_tts_settings_for_language(language: String = "") -> Dictionary:
	if language.is_empty():
		language = current_language
	
	return language_tts_settings.get(language, language_tts_settings[default_language])

# 오디오 파일 다국어 경로
func get_localized_audio_path(base_path: String, language: String = "") -> String:
	if language.is_empty():
		language = current_language
	
	# base_path: "res://audio/voice/greeting.ogg"
	# 결과: "res://audio/voice/ko/greeting.ogg"
	var path_parts = base_path.split("/")
	var filename = path_parts[-1]
	var directory = "/".join(path_parts.slice(0, -1))
	
	var localized_path = directory + "/" + language + "/" + filename
	
	# 파일이 존재하지 않으면 기본 언어 시도
	if not FileAccess.file_exists(localized_path) and language != default_language:
		localized_path = directory + "/" + default_language + "/" + filename
	
	# 기본 언어도 없으면 원본 경로 반환
	if not FileAccess.file_exists(localized_path):
		return base_path
	
	return localized_path

# 숫자/날짜 포맷팅 (언어별)
func format_number(number: int, use_separator: bool = true) -> String:
	var formatted = str(number)
	
	if not use_separator:
		return formatted
	
	match current_language:
		"ko", "ja", "zh":
			# 동아시아: 만 단위
			if number >= 10000:
				return str(number / 10000) + "만 " + str(number % 10000)
		"en":
			# 영어: 쉼표 구분
			var result = ""
			var digits = formatted.split("")
			digits.reverse()
			for i in range(digits.size()):
				if i > 0 and i % 3 == 0:
					result = "," + result
				result = digits[i] + result
			return result
	
	return formatted

# 실시간 번역 업데이트
func update_ui_translations(root_node: Node) -> void:
	_update_node_translations(root_node)

func _update_node_translations(node: Node) -> void:
	# Label 업데이트
	if node is Label:
		var label = node as Label
		var translation_key = label.get_meta("translation_key", "")
		if not translation_key.is_empty():
			label.text = get_text(translation_key, "general", label.text)
		apply_font_to_control(label)
	
	# Button 업데이트
	elif node is Button:
		var button = node as Button
		var translation_key = button.get_meta("translation_key", "")
		if not translation_key.is_empty():
			button.text = get_text(translation_key, "general", button.text)
		apply_font_to_control(button)
	
	# 자식 노드들 재귀 처리
	for child in node.get_children():
		_update_node_translations(child)

# 번역 키 자동 생성 (개발 도구)
func generate_translation_keys(text: String, category: String = "general") -> String:
	# 텍스트를 번역 키로 변환
	var key = text.to_lower()
	key = key.replace(" ", "_")
	key = key.replace(".", "_")
	key = key.replace("!", "_")
	key = key.replace("?", "_")
	
	# 특수문자 제거
	var clean_key = ""
	for c in key:
		if c.is_valid_identifier() or c == "_":
			clean_key += c
	
	return clean_key

# 번역 통계
func get_translation_coverage() -> Dictionary:
	var stats = {}
	
	for language in supported_languages:
		if not translations.has(language):
			stats[language] = {"coverage": 0.0, "total": 0, "translated": 0}
			continue
		
		var total_keys = 0
		var translated_keys = 0
		
		for category in translations[language]:
			var category_data = translations[language][category]
			total_keys += category_data.size()
			
			for key in category_data:
				var value = category_data[key]
				if not value.is_empty() and value != key:
					translated_keys += 1
		
		var coverage = float(translated_keys) / float(total_keys) if total_keys > 0 else 0.0
		stats[language] = {
			"coverage": coverage,
			"total": total_keys,
			"translated": translated_keys
		}
	
	return stats

# 현재 상태 조회
func get_current_language() -> String:
	return current_language

func get_supported_languages() -> Array[String]:
	return supported_languages

func is_language_supported(language: String) -> bool:
	return supported_languages.has(language)

# 저장/로드
func save_localization_settings() -> Dictionary:
	return {
		"current_language": current_language,
		"language_fonts": language_fonts,
		"tts_settings": language_tts_settings
	}

func load_localization_settings(settings: Dictionary) -> void:
	var saved_language = settings.get("current_language", default_language)
	if is_language_supported(saved_language):
		set_language(saved_language)
	
	var saved_fonts = settings.get("language_fonts", {})
	for lang in saved_fonts:
		language_fonts[lang] = saved_fonts[lang]
	
	var saved_tts = settings.get("tts_settings", {})
	for lang in saved_tts:
		language_tts_settings[lang] = saved_tts[lang]