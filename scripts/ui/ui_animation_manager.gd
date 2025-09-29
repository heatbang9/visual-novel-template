extends Node

# UI 애니메이션 매니저
# UI 요소의 애니메이션 효과 관리

const DEFAULT_DURATION = 0.3
const DEFAULT_TRANSITION = Tween.TRANS_CUBIC
const DEFAULT_EASE = Tween.EASE_OUT

var active_tweens: Dictionary = {}
var accessibility_manager: Node

func _ready():
    accessibility_manager = get_node("/root/AccessibilityManager")

# 페이드 인
func fade_in(node: CanvasItem, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.modulate.a = 1.0
        return
    
    _cancel_active_tween(node)
    node.modulate.a = 0.0
    node.show()
    
    var tween = create_tween()
    tween.tween_property(node, "modulate:a", 1.0, duration)
    _store_active_tween(node, tween)

# 페이드 아웃
func fade_out(node: CanvasItem, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.modulate.a = 0.0
        node.hide()
        return
    
    _cancel_active_tween(node)
    
    var tween = create_tween()
    tween.tween_property(node, "modulate:a", 0.0, duration)
    tween.tween_callback(node.hide)
    _store_active_tween(node, tween)

# 슬라이드 인
func slide_in(node: Control, from: Vector2, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.position = Vector2.ZERO
        return
    
    _cancel_active_tween(node)
    node.position = from
    node.show()
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(node, "position", Vector2.ZERO, duration)
    _store_active_tween(node, tween)

# 슬라이드 아웃
func slide_out(node: Control, to: Vector2, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.position = to
        node.hide()
        return
    
    _cancel_active_tween(node)
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(node, "position", to, duration)
    tween.tween_callback(node.hide)
    _store_active_tween(node, tween)

# 스케일 인
func scale_in(node: Control, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.scale = Vector2.ONE
        return
    
    _cancel_active_tween(node)
    node.scale = Vector2.ZERO
    node.show()
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(node, "scale", Vector2.ONE, duration)
    _store_active_tween(node, tween)

# 스케일 아웃
func scale_out(node: Control, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.scale = Vector2.ZERO
        node.hide()
        return
    
    _cancel_active_tween(node)
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(node, "scale", Vector2.ZERO, duration)
    tween.tween_callback(node.hide)
    _store_active_tween(node, tween)

# 팝업 효과
func popup(node: Control, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.scale = Vector2.ONE
        node.modulate.a = 1.0
        return
    
    _cancel_active_tween(node)
    node.scale = Vector2(0.5, 0.5)
    node.modulate.a = 0.0
    node.show()
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.parallel().tween_property(node, "scale", Vector2.ONE, duration)
    tween.parallel().tween_property(node, "modulate:a", 1.0, duration)
    _store_active_tween(node, tween)

# 흔들림 효과
func shake(node: Control, intensity: float = 5.0, duration: float = 0.5) -> void:
    if _should_skip_animation():
        return
    
    _cancel_active_tween(node)
    var initial_position = node.position
    
    var tween = create_tween()
    for i in range(int(duration * 20)):  # 20Hz로 흔들림
        var offset = Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(node, "position", initial_position + offset, 0.05)
    tween.tween_property(node, "position", initial_position, 0.1)
    _store_active_tween(node, tween)

# 버튼 호버 효과
func button_hover(button: BaseButton) -> void:
    if _should_skip_animation():
        return
    
    _cancel_active_tween(button)
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
    _store_active_tween(button, tween)

# 버튼 일반 상태로 복귀
func button_normal(button: BaseButton) -> void:
    if _should_skip_animation():
        return
    
    _cancel_active_tween(button)
    
    var tween = create_tween()
    tween.set_trans(DEFAULT_TRANSITION)
    tween.set_ease(DEFAULT_EASE)
    tween.tween_property(button, "scale", Vector2.ONE, 0.1)
    _store_active_tween(button, tween)

# 타이핑 효과
func type_text(label: Label, text: String, duration: float = 0.5) -> void:
    if _should_skip_animation():
        label.text = text
        return
    
    _cancel_active_tween(label)
    var original_text = text
    label.text = ""
    
    var tween = create_tween()
    for i in range(text.length()):
        tween.tween_callback(func():
            label.text = original_text.substr(0, i + 1)
        ).set_delay(duration / text.length())
    _store_active_tween(label, tween)

# 색상 변경 효과
func color_transition(node: CanvasItem, to_color: Color, duration: float = DEFAULT_DURATION) -> void:
    if _should_skip_animation():
        node.modulate = to_color
        return
    
    _cancel_active_tween(node)
    
    var tween = create_tween()
    tween.tween_property(node, "modulate", to_color, duration)
    _store_active_tween(node, tween)

# 현재 활성화된 Tween 취소
func _cancel_active_tween(node: Node) -> void:
    if active_tweens.has(node):
        var tween = active_tweens[node]
        if tween and tween.is_valid():
            tween.kill()
        active_tweens.erase(node)

# 활성 Tween 저장
func _store_active_tween(node: Node, tween: Tween) -> void:
    active_tweens[node] = tween
    tween.finished.connect(func(): active_tweens.erase(node))

# 애니메이션 생략 여부 확인
func _should_skip_animation() -> bool:
    return accessibility_manager.get_setting("reduce_motion")

# 모든 애니메이션 중지
func stop_all_animations() -> void:
    for node in active_tweens:
        var tween = active_tweens[node]
        if tween and tween.is_valid():
            tween.kill()
    active_tweens.clear()