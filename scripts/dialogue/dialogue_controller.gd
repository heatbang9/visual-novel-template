extends Node

# 대화 시스템 컨트롤러
# 대화 표시, 자동 진행, 이력 관리 등을 담당

signal dialogue_started
signal dialogue_completed
signal choice_made(choice_id: String)

# 대화 설정
var auto_mode: bool = false
var auto_delay: float = 2.0
var text_speed: float = 1.0
var skip_mode: bool = false

# 대화 이력
var dialogue_history: Array = []
const MAX_HISTORY: int = 100

# 현재 대화 상태
var current_message: String = ""
var current_speaker: String = ""
var is_typing: bool = false
var message_queue: Array = []

# 노드 참조
@onready var text_label = $DialogueUI/TextLabel
@onready var name_label = $DialogueUI/NameLabel
@onready var auto_play_timer = $AutoPlayTimer
@onready var text_timer = $TextTimer
@onready var history_ui = $HistoryUI

# 초기화
func _ready():
    _setup_timers()
    _connect_signals()
    _initialize_ui()

# 타이머 설정
func _setup_timers():
    auto_play_timer.wait_time = auto_delay
    auto_play_timer.one_shot = true
    text_timer.wait_time = 0.05 / text_speed
    text_timer.one_shot = false

# 시그널 연결
func _connect_signals():
    auto_play_timer.timeout.connect(_on_auto_play_timeout)
    text_timer.timeout.connect(_on_text_timer_timeout)

# UI 초기화
func _initialize_ui():
    text_label.text = ""
    name_label.text = ""
    history_ui.hide()

# 대화 시작
func start_dialogue(messages: Array) -> void:
    message_queue = messages
    emit_signal("dialogue_started")
    _show_next_message()

# 다음 메시지 표시
func _show_next_message() -> void:
    if message_queue.is_empty():
        emit_signal("dialogue_completed")
        return

    var message = message_queue.pop_front()
    current_message = message.text
    current_speaker = message.speaker
    
    # 이력에 추가
    _add_to_history({
        "speaker": current_speaker,
        "text": current_message,
        "time": Time.get_datetime_string_from_system()
    })
    
    name_label.text = current_speaker
    _start_typing()

# 타이핑 효과 시작
func _start_typing() -> void:
    is_typing = true
    text_label.visible_characters = 0
    text_label.text = current_message
    text_timer.wait_time = 0.05 / text_speed
    text_timer.start()

# 타이핑 타이머 처리
func _on_text_timer_timeout() -> void:
    if not is_typing:
        return

    text_label.visible_characters += 1
    
    if text_label.visible_characters >= current_message.length():
        _complete_typing()

# 타이핑 완료
func _complete_typing() -> void:
    is_typing = false
    text_label.visible_characters = -1  # 모든 텍스트 표시
    text_timer.stop()
    
    if auto_mode:
        auto_play_timer.start()

# 자동 재생 타이머 처리
func _on_auto_play_timeout() -> void:
    if auto_mode:
        _show_next_message()

# 메시지 즉시 표시 (타이핑 효과 스킵)
func skip_typing() -> void:
    if is_typing:
        _complete_typing()
    elif not message_queue.is_empty():
        _show_next_message()

# 자동 모드 설정
func set_auto_mode(enabled: bool) -> void:
    auto_mode = enabled
    if auto_mode and not is_typing:
        auto_play_timer.start()
    else:
        auto_play_timer.stop()

# 자동 재생 딜레이 설정
func set_auto_delay(delay: float) -> void:
    auto_delay = delay
    auto_play_timer.wait_time = delay

# 텍스트 속도 설정
func set_text_speed(speed: float) -> void:
    text_speed = clamp(speed, 0.5, 3.0)
    if is_typing:
        text_timer.wait_time = 0.05 / text_speed

# 대화 이력에 추가
func _add_to_history(entry: Dictionary) -> void:
    dialogue_history.push_back(entry)
    if dialogue_history.size() > MAX_HISTORY:
        dialogue_history.pop_front()

# 대화 이력 표시
func show_history() -> void:
    history_ui.clear()
    for entry in dialogue_history:
        history_ui.add_entry(entry.speaker, entry.text, entry.time)
    history_ui.show()

# 대화 이력 숨기기
func hide_history() -> void:
    history_ui.hide()

# 선택지 표시
func show_choices(choices: Array) -> void:
    # 선택지 UI 표시
    for choice in choices:
        var button = Button.new()
        button.text = choice.text
        button.pressed.connect(func():
            emit_signal("choice_made", choice.id)
        )
        $DialogueUI/ChoicesContainer.add_child(button)

# 선택지 클리어
func clear_choices() -> void:
    for child in $DialogueUI/ChoicesContainer.get_children():
        child.queue_free()