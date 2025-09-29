extends Node

# 접근성 매니저
# 접근성 설정 및 기능 관리

signal settings_changed(setting_name: String, value: Variant)

# 접근성 설정
var settings: Dictionary = {
    # 고대비 모드
    "high_contrast": false,
    # 텍스트 크기 스케일
    "text_scale": 1.0,
    # 자동 진행 시간
    "auto_advance_time": 2.0,
    # 클릭 영역 확대
    "enlarged_clickable": false,
    # 화면 흔들림 효과 비활성화
    "reduce_motion": false,
    # 소리 설명
    "sound_descriptions": false,
    # 스크린 리더 지원
    "screen_reader": false,
    # 키보드 내비게이션
    "keyboard_navigation": true,
    # 색맹 모드
    "color_blind_mode": "none",  # none, protanopia, deuteranopia, tritanopia
    # 자막 설정
    "subtitles": {
        "enabled": true,
        "size": 1.0,
        "background": true,
        "high_contrast": false
    }
}

const SETTINGS_FILE = "user://accessibility_settings.json"

# 초기화
func _ready():
    _load_settings()
    _apply_settings()

# 설정 로드
func _load_settings():
    if FileAccess.file_exists(SETTINGS_FILE):
        var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            var json = JSON.parse_string(content)
            if json:
                # 기존 설정과 병합
                for key in json:
                    if settings.has(key):
                        settings[key] = json[key]

# 설정 저장
func _save_settings():
    var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(settings))
    else:
        push_error("접근성 설정을 저장할 수 없습니다.")

# 설정 변경
func set_setting(name: String, value: Variant) -> void:
    if not settings.has(name):
        push_error("존재하지 않는 접근성 설정: " + name)
        return
    
    settings[name] = value
    _apply_setting(name, value)
    _save_settings()
    emit_signal("settings_changed", name, value)

# 설정 가져오기
func get_setting(name: String) -> Variant:
    return settings.get(name)

# 모든 설정 적용
func _apply_settings():
    for setting_name in settings:
        _apply_setting(setting_name, settings[setting_name])

# 개별 설정 적용
func _apply_setting(name: String, value: Variant):
    match name:
        "high_contrast":
            _apply_high_contrast(value)
        "text_scale":
            _apply_text_scale(value)
        "enlarged_clickable":
            _apply_enlarged_clickable(value)
        "reduce_motion":
            _apply_reduce_motion(value)
        "color_blind_mode":
            _apply_color_blind_mode(value)
        "subtitles":
            _apply_subtitle_settings(value)

# 고대비 모드 적용
func _apply_high_contrast(enabled: bool):
    if enabled:
        # 고대비 테마 적용
        var theme = ThemeManager.get_theme("high_contrast")
        if theme:
            ThemeManager.change_theme("high_contrast")
    else:
        # 기본 테마로 복귀
        ThemeManager.change_theme("default")

# 텍스트 크기 조정
func _apply_text_scale(scale: float):
    var base_size = 16  # 기본 폰트 크기
    get_tree().root.theme.default_font_size = base_size * scale

# 클릭 영역 확대
func _apply_enlarged_clickable(enabled: bool):
    for button in get_tree().get_nodes_in_group("clickable"):
        if button is BaseButton:
            var extra_padding = 10 if enabled else 0
            button.custom_minimum_size += Vector2(extra_padding * 2, extra_padding * 2)

# 움직임 감소
func _apply_reduce_motion(enabled: bool):
    # 애니메이션 속도 조정
    var speed_scale = 0.5 if enabled else 1.0
    for anim_player in get_tree().get_nodes_in_group("animations"):
        if anim_player is AnimationPlayer:
            anim_player.speed_scale = speed_scale

# 색맹 모드 적용
func _apply_color_blind_mode(mode: String):
    var shader: Shader = null
    
    match mode:
        "protanopia":
            shader = load("res://shaders/protanopia.gdshader")
        "deuteranopia":
            shader = load("res://shaders/deuteranopia.gdshader")
        "tritanopia":
            shader = load("res://shaders/tritanopia.gdshader")
    
    # 화면 전체에 셰이더 적용
    var canvas_layer = get_node_or_null("/root/ColorBlindLayer")
    if shader:
        if not canvas_layer:
            canvas_layer = CanvasLayer.new()
            canvas_layer.name = "ColorBlindLayer"
            get_tree().root.add_child(canvas_layer)
        
        var color_rect = ColorRect.new()
        color_rect.material = ShaderMaterial.new()
        color_rect.material.shader = shader
        color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        
        canvas_layer.add_child(color_rect)
    elif canvas_layer:
        canvas_layer.queue_free()

# 자막 설정 적용
func _apply_subtitle_settings(settings: Dictionary):
    for subtitle in get_tree().get_nodes_in_group("subtitles"):
        if subtitle is Label:
            # 크기 조정
            subtitle.add_theme_font_size_override("font_size", 
                int(16 * settings.size))  # 기본 크기 16
            
            # 배경 설정
            if settings.background:
                var panel = subtitle.get_parent()
                if panel is PanelContainer:
                    panel.show()
            
            # 고대비
            if settings.high_contrast:
                subtitle.add_theme_color_override("font_color", Color.WHITE)
                if subtitle.get_parent() is PanelContainer:
                    subtitle.get_parent().modulate = Color.BLACK
            else:
                subtitle.remove_theme_color_override("font_color")
                if subtitle.get_parent() is PanelContainer:
                    subtitle.get_parent().modulate = Color(0, 0, 0, 0.8)

# 스크린 리더 지원
func speak_text(text: String) -> void:
    if settings.screen_reader:
        OS.execute("espeak", ["-v", "ko", text])  # 시스템의 TTS 엔진 사용

# 키보드 포커스 처리
func setup_keyboard_navigation():
    if settings.keyboard_navigation:
        # 포커스 그룹 설정
        var focus_groups = get_tree().get_nodes_in_group("focus_group")
        for i in range(focus_groups.size()):
            var group = focus_groups[i]
            if group is Control:
                # 다음/이전 포커스 설정
                var next_group = focus_groups[(i + 1) % focus_groups.size()]
                var prev_group = focus_groups[(i - 1 + focus_groups.size()) % focus_groups.size()]
                
                group.focus_neighbor_bottom = next_group.get_path()
                group.focus_neighbor_top = prev_group.get_path()
                group.focus_mode = Control.FOCUS_ALL