extends Node

# 테마 매니저
# 커스텀 테마 로드, 적용 및 관리

signal theme_changed(theme_name: String)

const THEMES_DIR = "res://themes/"
const USER_THEMES_DIR = "user://themes/"
const DEFAULT_THEME = "default"

var current_theme: String = DEFAULT_THEME
var themes: Dictionary = {}
var theme_data: Dictionary = {}

# 초기화
func _ready():
    _load_built_in_themes()
    _load_user_themes()
    _apply_theme(current_theme)

# 내장 테마 로드
func _load_built_in_themes():
    # 기본 테마 정의
    var default_theme = {
        "name": "default",
        "display_name": "기본",
        "colors": {
            "background": Color(0.1, 0.1, 0.1, 1),
            "text": Color(1, 1, 1, 1),
            "accent": Color(0.3, 0.5, 0.8, 1),
            "dialog_box": Color(0, 0, 0, 0.8),
            "button_normal": Color(0.2, 0.2, 0.2, 1),
            "button_hover": Color(0.3, 0.3, 0.3, 1),
            "button_pressed": Color(0.15, 0.15, 0.15, 1)
        },
        "fonts": {
            "regular": "res://fonts/NotoSansKR-Regular.ttf",
            "bold": "res://fonts/NotoSansKR-Bold.ttf"
        },
        "font_sizes": {
            "small": 14,
            "normal": 16,
            "large": 20,
            "title": 32
        },
        "dialog": {
            "name_color": Color(1, 0.9, 0.5, 1),
            "text_color": Color(1, 1, 1, 1),
            "choice_color": Color(0.7, 0.9, 1, 1),
            "choice_hover_color": Color(0.8, 1, 1, 1)
        },
        "effects": {
            "transition_time": 0.3,
            "button_hover_scale": 1.1,
            "text_shadow": true,
            "dialog_box_blur": true
        }
    }
    
    var dark_theme = {
        "name": "dark",
        "display_name": "다크 모드",
        "colors": {
            "background": Color(0, 0, 0, 1),
            "text": Color(0.9, 0.9, 0.9, 1),
            "accent": Color(0.4, 0.6, 0.9, 1),
            "dialog_box": Color(0.1, 0.1, 0.1, 0.9),
            "button_normal": Color(0.15, 0.15, 0.15, 1),
            "button_hover": Color(0.25, 0.25, 0.25, 1),
            "button_pressed": Color(0.1, 0.1, 0.1, 1)
        },
        "fonts": default_theme.fonts,
        "font_sizes": default_theme.font_sizes,
        "dialog": {
            "name_color": Color(0.7, 0.8, 1, 1),
            "text_color": Color(0.9, 0.9, 0.9, 1),
            "choice_color": Color(0.6, 0.8, 1, 1),
            "choice_hover_color": Color(0.7, 0.9, 1, 1)
        },
        "effects": default_theme.effects
    }
    
    var light_theme = {
        "name": "light",
        "display_name": "라이트 모드",
        "colors": {
            "background": Color(0.95, 0.95, 0.95, 1),
            "text": Color(0.1, 0.1, 0.1, 1),
            "accent": Color(0.2, 0.4, 0.8, 1),
            "dialog_box": Color(1, 1, 1, 0.9),
            "button_normal": Color(0.85, 0.85, 0.85, 1),
            "button_hover": Color(0.9, 0.9, 0.9, 1),
            "button_pressed": Color(0.8, 0.8, 0.8, 1)
        },
        "fonts": default_theme.fonts,
        "font_sizes": default_theme.font_sizes,
        "dialog": {
            "name_color": Color(0.2, 0.4, 0.8, 1),
            "text_color": Color(0.1, 0.1, 0.1, 1),
            "choice_color": Color(0.2, 0.4, 0.8, 1),
            "choice_hover_color": Color(0.3, 0.5, 0.9, 1)
        },
        "effects": default_theme.effects
    }
    
    # 테마 등록
    themes[default_theme.name] = default_theme
    themes[dark_theme.name] = dark_theme
    themes[light_theme.name] = light_theme

# 사용자 테마 로드
func _load_user_themes():
    if not DirAccess.dir_exists_absolute(USER_THEMES_DIR):
        DirAccess.make_dir_recursive_absolute(USER_THEMES_DIR)
        return
    
    var dir = DirAccess.open(USER_THEMES_DIR)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                var theme = _load_theme_from_file(USER_THEMES_DIR + file_name)
                if theme != null:
                    themes[theme.name] = theme
            file_name = dir.get_next()

# 테마 파일 로드
func _load_theme_from_file(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    
    var file = FileAccess.open(path, FileAccess.READ)
    if not file:
        push_error("테마 파일을 읽을 수 없습니다: " + path)
        return {}
    
    var json = JSON.parse_string(file.get_as_text())
    if not json:
        push_error("잘못된 테마 파일 형식: " + path)
        return {}
    
    return json

# 테마 적용
func _apply_theme(theme_name: String) -> void:
    if not themes.has(theme_name):
        push_error("존재하지 않는 테마: " + theme_name)
        return
    
    var theme = themes[theme_name]
    current_theme = theme_name
    
    # 테마 리소스 생성
    var theme_resource = Theme.new()
    
    # 폰트 설정
    var normal_font = load(theme.fonts.regular)
    theme_resource.default_font = normal_font
    theme_resource.default_font_size = theme.font_sizes.normal
    
    # 색상 설정
    theme_resource.set_color("font_color", "Label", theme.colors.text)
    theme_resource.set_color("font_focus_color", "Label", theme.colors.accent)
    
    # 버튼 스타일
    var button_style = StyleBoxFlat.new()
    button_style.bg_color = theme.colors.button_normal
    button_style.corner_radius_top_left = 5
    button_style.corner_radius_top_right = 5
    button_style.corner_radius_bottom_left = 5
    button_style.corner_radius_bottom_right = 5
    theme_resource.set_stylebox("normal", "Button", button_style)
    
    var button_hover = button_style.duplicate()
    button_hover.bg_color = theme.colors.button_hover
    theme_resource.set_stylebox("hover", "Button", button_hover)
    
    var button_pressed = button_style.duplicate()
    button_pressed.bg_color = theme.colors.button_pressed
    theme_resource.set_stylebox("pressed", "Button", button_pressed)
    
    # 테마 적용
    get_tree().root.theme = theme_resource
    
    # 시그널 발신
    emit_signal("theme_changed", theme_name)

# 테마 가져오기
func get_theme(name: String) -> Dictionary:
    return themes.get(name, {})

# 현재 테마 가져오기
func get_current_theme() -> Dictionary:
    return themes.get(current_theme, {})

# 테마 목록 가져오기
func get_theme_list() -> Array:
    var theme_list = []
    for theme_name in themes:
        theme_list.append({
            "name": theme_name,
            "display_name": themes[theme_name].display_name
        })
    return theme_list

# 테마 변경
func change_theme(theme_name: String) -> void:
    _apply_theme(theme_name)

# 사용자 테마 저장
func save_user_theme(theme: Dictionary) -> void:
    if not theme.has("name"):
        push_error("테마 이름이 필요합니다.")
        return
    
    var file = FileAccess.open(USER_THEMES_DIR + theme.name + ".json", FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(theme))
        themes[theme.name] = theme
    else:
        push_error("테마를 저장할 수 없습니다.")

# 사용자 테마 삭제
func delete_user_theme(theme_name: String) -> void:
    if theme_name == DEFAULT_THEME:
        push_error("기본 테마는 삭제할 수 없습니다.")
        return
    
    var theme_path = USER_THEMES_DIR + theme_name + ".json"
    if FileAccess.file_exists(theme_path):
        DirAccess.remove_absolute(theme_path)
    
    themes.erase(theme_name)
    if current_theme == theme_name:
        change_theme(DEFAULT_THEME)