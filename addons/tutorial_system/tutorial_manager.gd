extends Node

## 튜토리얼 매니저
## 튜토리얼 시스템, 도웼 오버레이, 힌트 표시 등
class_name TutorialManager

signal tutorial_started(tutorial_id: String)
signal tutorial_step_completed(step_index: int)
signal tutorial_completed(tutorial_id: String)
signal tutorial_skipped(tutorial_id: String)
signal help_requested(topic: String)

# 튜토리얼 데이터
var tutorials: Dictionary = {}
var active_tutorial: String = ""
var current_step: int = 0
var tutorial_data_file: String = "user://tutorial_data.json"

const TUTORIAL_DATA_FILE = "user://tutorial_data.json"

# 튜토리얼 상태
var tutorial_states: Dictionary = {
	"not_started": "아, 시작 전 상 표시 안",
	"in_progress": "진행 중, 오버레이 표시",
	"paused": "일시 정지됨 버튼으로 다시 표시",
	"completed": "완료됨 닫 표시"
}

var settings: Dictionary = {
	"show_hints": true,
	"auto_progress": true,
	"progress_delay": 3.0,
	"skip_button_text": "Skip",
	"next_button_text": "Next",
	"back_button_text": "Back",
	"finish_button_text": "Finish"
}

# UI 참조
var tutorial_ui: Control = null
var hint_overlay: Control = null
var focus_highlight: Control = null

func _ready() -> void:
	_load_tutorial_data()
	_connect_signals()

# 튜토리얼 데이터 로드
func _load_tutorial_data() -> void:
	if FileAccess.file_exists(TUTORIAL_DATA_FILE):
		var file = FileAccess.open(TUTORIAL_DATA_FILE, FileAccess.READ)
	 if file:
            var json = JSON.parse_string(file.get_as_text())
            if json:
                tutorials = json

# 튜토리얼 데이터 저장
func save_tutorial_data() -> void:
    var file = FileAccess.open(TUTORIAL_DATA_FILE, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(tutorials))

# 튜토리얼 시작
func start_tutorial(tutorial_id: String) -> void:
    if not tutorials.has(tutorial_id):
        push_error("Tutorial not found: " + tutorial_id)
        return
    
    active_tutorial = tutorial_id
    current_step = 0
    tutorial_states[tutorial_id] = "not_started"
    _show_tutorial_step(tutorial_id, 0)

# 튜토리얼 단계 진행
func next_step(tutorial_id: String = "") -> void:
    if active_tutorial != tutorial_id:
        return
    
    if not tutorials.has(tutorial_id):
        return
    
    var tutorial = tutorials[tutorial_id]
    current_step += 1
    
    if current_step >= tutorial["steps"].size():
        # 튜토리얼 완료
        complete_tutorial(tutorial_id)
    else:
        # 다음 단계 표시
        tutorial_states[tutorial_id] = "in_progress"
        _show_tutorial_step(tutorial_id, current_step)

# 튜토리얼 완료
func complete_tutorial(tutorial_id: String) -> void:
    if not tutorials.has(tutorial_id):
        return
    
    var tutorial = tutorials[tutorial_id]
    tutorial["completed"] = true
    
    tutorial_states[tutorial_id] = "completed"
    _hide_tutorial_ui()
    
    emit_signal("tutorial_completed", tutorial_id)
    save_tutorial_data()

# 튜토리얼 건너뛰기
func skip_tutorial(tutorial_id: String) -> void:
    if active_tutorial == tutorial_id and tutorial_states[tutorial_id] == "in_progress":
        tutorial_states[tutorial_id] = "completed"
        _hide_tutorial_ui()
        emit_signal("tutorial_skipped", tutorial_id)
        save_tutorial_data()

# 튜토리얼 일시 정지
func pause_tutorial(tutorial_id: String) -> void:
    if active_tutorial == tutorial_id and tutorial_states[tutorial_id] == "in_progress":
        tutorial_states[tutorial_id] = "paused"
        _show_pause_overlay()

# 튜토리얼 재개
func resume_tutorial(tutorial_id: String) -> void:
    if active_tutorial == tutorial_id and tutorial_states[tutorial_id] == "paused":
        tutorial_states[tutorial_id] = "in_progress"
        _show_tutorial_step(tutorial_id, current_step)

# 튜토리얼 이전 단계로
func previous_step(tutorial_id: String) -> void:
    if active_tutorial == tutorial_id and tutorial_states[tutorial_id] == "in_progress":
        if current_step > 0:
            current_step -= 1
            _show_tutorial_step(tutorial_id, current_step)

# 튜토리얼 데이터 가져오기
func get_tutorial_data(tutorial_id: String) -> Dictionary:
    if tutorials.has(tutorial_id):
        return tutorials[tutorial_id]
    return {}

# 튜토리얼 완료 여부
func is_tutorial_completed(tutorial_id: String) -> bool:
    if tutorials.has(tutorial_id):
        return tutorials[tutorial_id]["completed"]
    return false

# 활성 튜토리얼 가져오기
func get_active_tutorial() -> String:
    return active_tutorial

# 튜토리얼 진행률 (0.0 ~ 1.0)
func get_tutorial_progress(tutorial_id: String) -> float:
    if not tutorials.has(tutorial_id):
        return 0.0
    
    var tutorial = tutorials[tutorial_id]
    if tutorial["completed"]:
        return 1.0
    
    return float(current_step) / float(tutorial["steps"].size())

# 특정 단계 데이터 가져오기
func get_step_data(tutorial_id: String, step_index: int) -> Dictionary:
    if tutorials.has(tutorial_id):
        var tutorial = tutorials[tutorial_id]
        if step_index >= 0 and step_index < tutorial["steps"].size():
            return tutorial["steps"][step_index]
    return {}

# 튜토리얼 UI 표시
func _show_tutorial_ui() -> void:
    if tutorial_ui:
        tutorial_ui.queue_free()
    
    # UI 생성 및 표시
    tutorial_ui = _create_tutorial_ui_instance()
    add_child(tutorial_ui)
    tutorial_ui.show()

# 튜토리얼 단계 표시
func _show_tutorial_step(tutorial_id: String, step_index: int) -> void:
    if not tutorial_ui:
        return
    
    var step_data = get_step_data(tutorial_id, step_index)
    if step_data.is_empty():
        return
    
    # 단계 UI 업데이트
    tutorial_ui.update_step(step_data)

# 일시 정지 오버레이 표시
func _show_pause_overlay() -> void:
    if tutorial_ui:
        tutorial_ui.show_pause()

# 튜토리얼 UI 숨기
func _hide_tutorial_ui() -> void:
    if tutorial_ui:
        tutorial_ui.hide()
        tutorial_ui.queue_free()
        tutorial_ui = null

# 튜토리얼 UI 인스턴스 생성
func _create_tutorial_ui_instance() -> Control:
    var ui_scene = preload("res://addons/tutorial_system/tutorial_ui.tscn")
    return ui_scene.instantiate()

# 신규 튜토리얼 등록
func register_tutorial(tutorial_id: String, tutorial_data: Dictionary) -> void:
    tutorials[tutorial_id] = {
        "title": tutorial_data.get("title", ""),
        "description": tutorial_data.get("description", ""),
        "steps": tutorial_data.get("steps", []),
        "trigger": tutorial_data.get("trigger", "manual"),
        "required": tutorial_data.get("required", false),
        "completed": false
    }
    save_tutorial_data()

# 도움말 표시
func show_help(topic: String) -> void:
    emit_signal("help_requested", topic)
    
    if tutorial_ui:
        tutorial_ui.show_help(topic)

# 설정 업데이트
func update_settings(new_settings: Dictionary) -> void:
    for key in new_settings:
        settings[key] = new_settings[key]

