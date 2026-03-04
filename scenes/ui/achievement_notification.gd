extends CanvasLayer

## 업적 알림 UI
## 업적 달성 시 화면에 팝업을 표시

class_name AchievementNotification

# 노드 참조
@onready var panel: PanelContainer = $PanelContainer
@onready var icon: TextureRect = $PanelContainer/HBoxContainer/Icon
@onready var title_label: Label = $PanelContainer/HBoxContainer/VBoxContainer/Title
@onready var description_label: Label = $PanelContainer/HBoxContainer/VBoxContainer/Description
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 설정
@export var display_duration: float = 3.0
@export var slide_in_duration: float = 0.5
@export var slide_out_duration: float = 0.5

# 알림 큐
var _notification_queue: Array[Dictionary] = []
var _is_displaying: bool = false

# 기본 아이콘 (없을 때 사용)
var default_icon: Texture2D

func _ready() -> void:
	# 기본 설정
	visible = false
	panel.modulate.a = 0
	
	# 시그널 연결
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
	
	# 시작 위치 설정 (화면 오른쪽 밖)
	_reset_position()

func _reset_position() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	panel.position.x = screen_size.x + 100
	panel.position.y = 50

## 업적 잠금 해제 시 호출
func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	_notification_queue.append({
		"id": achievement_id,
		"data": achievement_data
	})
	
	if not _is_displaying:
		_show_next_notification()

## 다음 알림 표시
func _show_next_notification() -> void:
	if _notification_queue.is_empty():
		_is_displaying = false
		return
	
	_is_displaying = true
	var notification = _notification_queue.pop_front()
	_display_notification(notification.data)

## 알림 표시
func _display_notification(data: Dictionary) -> void:
	# 텍스트 설정
	title_label.text = "🏆 업적 달성!"
	description_label.text = data.get("name", "") + "\n" + data.get("description", "")
	
	# 아이콘 설정
	var icon_path = data.get("icon", "")
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	else:
		# 기본 아이콘 또는 숨김 처리
		if default_icon:
			icon.texture = default_icon
		else:
			icon.visible = false
	
	# 사운드 재생
	_play_achievement_sound()
	
	# 애니메이션
	_animate_slide_in()

## 슬라이드 인 애니메이션
func _animate_slide_in() -> void:
	visible = true
	var screen_size = get_viewport().get_visible_rect().size
	var target_x = screen_size.x - panel.size.x - 20
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# 페이드 인 + 슬라이드
	tween.parallel().tween_property(panel, "modulate:a", 1.0, slide_in_duration)
	tween.parallel().tween_property(panel, "position:x", target_x, slide_in_duration)
	
	# 완료 후 대기
	tween.tween_callback(_on_slide_in_complete).set_delay(display_duration)

## 슬라이드 아웃 애니메이션
func _animate_slide_out() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	
	# 페이드 아웃 + 슬라이드
	tween.parallel().tween_property(panel, "modulate:a", 0.0, slide_out_duration)
	tween.parallel().tween_property(panel, "position:x", screen_size.x + 100, slide_out_duration)
	
	tween.tween_callback(_on_slide_out_complete)

func _on_slide_in_complete() -> void:
	_animate_slide_out()

func _on_slide_out_complete() -> void:
	visible = false
	_reset_position()
	_show_next_notification()

## 사운드 재생
func _play_achievement_sound() -> void:
	# AudioManager가 있다면 사용
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("achievement_unlock")
	else:
		# 기본 사운드
		var sound_path = "res://assets/sounds/achievement.ogg"
		if ResourceLoader.exists(sound_path):
			var audio_player = AudioStreamPlayer.new()
			audio_player.stream = load(sound_path)
			add_child(audio_player)
			audio_player.play()
			audio_player.finished.connect(audio_player.queue_free)

## 수동으로 알림 테스트 (개발용)
func test_notification() -> void:
	_display_notification({
		"name": "테스트 업적",
		"description": "이것은 테스트 알림입니다",
		"icon": ""
	})

## 알림 큐 비우기
func clear_queue() -> void:
	_notification_queue.clear()
