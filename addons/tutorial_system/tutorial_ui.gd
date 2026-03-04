extends Control

## 튜토리얼 UI
## 단계별 안내, 도움말, 진행 표시

signal tutorial_next_requested
signal tutorial_back_requested
signal tutorial_skip_requested
signal tutorial_finished

signal tutorial_paused

@onready var title_label: Label = $MainContainer/Header/TitleLabel
@onready var step_label: Label = $MainContainer/Header/StepLabel
@onready var skip_button: Button = $MainContainer/Header/SkipButton
@onready var message_label: Label = $MainContainer/Content/MessageLabel
@onready var image_rect: TextureRect = $MainContainer/Content/ImageRect
@onready var back_button: Button = $MainContainer/Footer/BackButton
@onready var next_button: Button = $MainContainer/Footer/NextButton
@onready var finish_button: Button = $MainContainer/Footer/FinishButton
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var pause_label: Label = $PauseOverlay/PauseContainer/PauseLabel
@onready var resume_button: Button = $PauseOverlay/PauseContainer/ResumeButton
@onready var quit_button: Button = $PauseOverlay/PauseContainer/QuitButton

var current_tutorial_id: String = ""
var current_step_index: int = 0

func _ready() -> void:
	_connect_signals()
	_localize_ui()
	hide()

func _connect_signals() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	back_button.pressed.connect(_on_back_pressed)
	next_button.pressed.connect(_on_next_pressed)
	finish_button.pressed.connect(_on_finish_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _localize_ui() -> void:
	title_label.text = LocalizationManager.get_text("tutorial_title", "Tutorial")
	skip_button.text = LocalizationManager.get_text("skip", "Skip")
	back_button.text = LocalizationManager.get_text("back", "Back")
	next_button.text = LocalizationManager.get_text("next", "Next")
	finish_button.text = LocalizationManager.get_text("finish", "Finish")
	pause_label.text = LocalizationManager.get_text("tutorial_paused", "Tutorial Paused")
	resume_button.text = LocalizationManager.get_text("resume", "Resume")
	quit_button.text = LocalizationManager.get_text("quit_tutorial", "Quit Tutorial")

	message_label.text = LocalizationManager.get_text("tutorial_welcome", "Welcome! Let's get started.")

# 단계 업데이트
func update_step(step_data: Dictionary) -> void:
	if step_data.is_empty():
		return
	
	# 메시지 업데이트
	if step_data.has("message"):
		message_label.text = step_data["message"]
	
	# 이미지 업데이트
	if step_data.has("image"):
		var texture = load(step_data["image"])
		if texture:
			image_rect.texture = texture
			image_rect.visible = true
		else:
			image_rect.visible = false
	else:
		image_rect.visible = false
	
	# 단계 인덱스 업데이트
	if step_data.has("step_index"):
		current_step_index = step_data["step_index"]
		_update_step_label()
	
	# 버튼 가시성 조정
	if step_data.has("is_last_step") and step_data["is_last_step"]:
		next_button.visible = false
		finish_button.visible = true
	else:
		next_button.visible = true
		finish_button.visible = false
	
	back_button.visible = current_step_index > 0

# 단계 라벨 업데이트
func _update_step_label() -> void:
	var tutorial_data = TutorialManager.get_tutorial_data(current_tutorial_id)
	if not tutorial_data.is_empty():
		var total_steps = tutorial_data["steps"].size()
		step_label.text = "Step %d/%d" % [current_step_index + 1, total_steps]

# 건너뛰기
func _on_skip_pressed() -> void:
	TutorialManager.skip_tutorial(current_tutorial_id)
	hide()

# 다음
func _on_next_pressed() -> void:
	emit_signal("tutorial_next_requested")
	TutorialManager.next_step(current_tutorial_id)

# 이전
func _on_back_pressed() -> void:
	emit_signal("tutorial_back_requested")
	TutorialManager.previous_step(current_tutorial_id)

# 완료
func _on_finish_pressed() -> void:
	TutorialManager.complete_tutorial(current_tutorial_id)
	hide()

# 이어서 누르기 표시
func show_pause() -> void:
	pause_overlay.visible = true

# 이어서 누르기 숨기기
func hide_pause() -> void:
	pause_overlay.visible = false

# 도움말 표시
func show_help(topic: String) -> void:
	# 도움말 오버레이 또는 툴팁 표시
	print("Help requested: ", topic)

	# TODO: Implement help overlay or tooltip

# 계속
func _on_resume_pressed() -> void:
	TutorialManager.resume_tutorial(current_tutorial_id)
	hide_pause()

# 종료
func _on_quit_pressed() -> void:
	TutorialManager.skip_tutorial(current_tutorial_id)
	hide()

# 열기
func open(tutorial_id: String) -> void:
	current_tutorial_id = tutorial_id
	visible = true

# 닫기
func close() -> void:
	visible = false
