extends Control

# 대화 이력 UI
# 지난 대화 내용을 스크롤 가능한 목록으로 표시

@onready var scroll_container = $ScrollContainer
@onready var history_container = $ScrollContainer/HistoryContainer
@onready var close_button = $CloseButton

func _ready():
    close_button.pressed.connect(hide)
    scroll_container.scroll_vertical = 0

# 이력 항목 추가
func add_entry(speaker: String, text: String, timestamp: String) -> void:
    var entry = create_history_entry(speaker, text, timestamp)
    history_container.add_child(entry)
    
    # 자동 스크롤
    await get_tree().process_frame
    scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

# 이력 항목 생성
func create_history_entry(speaker: String, text: String, timestamp: String) -> Control:
    var entry = Control.new()
    entry.custom_minimum_size.y = 100
    
    # 타임스탬프 라벨
    var time_label = Label.new()
    time_label.text = timestamp
    time_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
    time_label.position = Vector2(10, 5)
    entry.add_child(time_label)
    
    # 화자 이름 라벨
    var name_label = Label.new()
    name_label.text = speaker
    name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
    name_label.position = Vector2(10, 25)
    entry.add_child(name_label)
    
    # 대화 텍스트 라벨
    var text_label = Label.new()
    text_label.text = text
    text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    text_label.position = Vector2(20, 45)
    text_label.size = Vector2(760, 0)  # 너비 설정
    entry.add_child(text_label)
    
    # 구분선
    var separator = HSeparator.new()
    separator.position = Vector2(0, 90)
    separator.size = Vector2(800, 2)
    entry.add_child(separator)
    
    return entry

# 모든 이력 삭제
func clear() -> void:
    for child in history_container.get_children():
        child.queue_free()
    scroll_container.scroll_vertical = 0