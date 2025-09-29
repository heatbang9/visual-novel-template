extends Node

# 다국어 매니저
# 번역 리소스 관리 및 다국어 지원

signal language_changed(new_language: String)

const TRANSLATIONS_DIR = "res://translations/"
const DEFAULT_LANGUAGE = "ko"

var current_language: String = DEFAULT_LANGUAGE
var translations: Dictionary = {}
var available_languages: Dictionary = {
    "ko": "한국어",
    "en": "English",
    "ja": "日本語",
    "zh": "中文"
}

# 초기화
func _ready():
    _load_translations()
    _set_language(DEFAULT_LANGUAGE)

# 번역 파일 로드
func _load_translations():
    translations = {
        "ko": {},
        "en": {},
        "ja": {},
        "zh": {}
    }
    
    # 각 언어별 번역 파일 로드
    for lang in available_languages.keys():
        var file_path = TRANSLATIONS_DIR + lang + ".json"
        if FileAccess.file_exists(file_path):
            var file = FileAccess.open(file_path, FileAccess.READ)
            if file:
                var content = file.get_as_text()
                var json = JSON.parse_string(content)
                if json:
                    translations[lang] = json
                else:
                    push_error("번역 파일 파싱 오류: " + file_path)

# 언어 설정
func _set_language(language: String) -> void:
    if not available_languages.has(language):
        push_error("지원하지 않는 언어: " + language)
        return
    
    if not translations.has(language):
        push_error("번역 데이터가 없습니다: " + language)
        return
    
    current_language = language
    TranslationServer.set_locale(language)
    emit_signal("language_changed", language)

# 텍스트 번역
func tr(key: String, params: Dictionary = {}) -> String:
    if not translations.has(current_language):
        return key
    
    var translation = translations[current_language]
    if not translation.has(key):
        # 기본 언어에서 찾아보기
        if translations.has(DEFAULT_LANGUAGE) and translations[DEFAULT_LANGUAGE].has(key):
            translation = translations[DEFAULT_LANGUAGE]
        else:
            return key
    
    var text = translation[key]
    
    # 파라미터 치환
    for param_key in params:
        text = text.replace("{" + param_key + "}", str(params[param_key]))
    
    return text

# 현재 언어 가져오기
func get_current_language() -> String:
    return current_language

# 현재 언어 이름 가져오기
func get_current_language_name() -> String:
    return available_languages[current_language]

# 지원 언어 목록 가져오기
func get_available_languages() -> Dictionary:
    return available_languages

# 언어 변경
func change_language(language: String) -> void:
    _set_language(language)

# 번역 추가
func add_translation(language: String, key: String, text: String) -> void:
    if not translations.has(language):
        translations[language] = {}
    
    translations[language][key] = text
    _save_translations(language)

# 번역 저장
func _save_translations(language: String) -> void:
    var file = FileAccess.open(TRANSLATIONS_DIR + language + ".json", FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(translations[language]))
    else:
        push_error("번역 파일을 저장할 수 없습니다: " + language)

# 대화 텍스트 번역
func translate_dialogue(text: String) -> String:
    var dialogue_key = "dialogue." + text.sha256_text()
    return tr(dialogue_key, {"original": text})