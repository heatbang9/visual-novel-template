## 미니게임 베이스 클래스
## 모든 미니게임이 상속받아야 하는 기본 클래스
## Godot 4.5 호환
extends Control
class_name MinigameBase

## 게임 완료 시그널 (성공 여부, 점수)
signal game_completed(success: bool, score: int)

## 게임 종료 시그널
signal game_exited

## 게임 일시정지 시그널
signal game_paused

## 게임 재개 시그널
signal game_resumed

## 점수 변경 시그널
signal score_changed(new_score: int)

## 게임 이름 (현지화 키)
@export var game_name_key: String = ""

## 게임 설명 (현지화 키)
@export var game_desc_key: String = ""

## 시간 제한 (초)
@export var time_limit: float = 60.0

## 난이도 (1-5)
@export var difficulty: int = 1

## 게임 타이머
var game_timer: Timer

## 게임 활성화 여부
var is_game_active: bool = false

## 게임 일시정지 여부
var is_paused: bool = false

## 게임 완료 여부
var is_completed_flag: bool = false

## 현재 점수
var current_score: int = 0

## 랜덤 시드
var random_seed_value: int

## 게임 시작 데이터
var _start_data: Dictionary = {}

## 게임 결과 데이터
var _result_data: Dictionary = {}

## UI 레이어
@onready var ui_layer = $UILayer

## 게임 레이어
@onready var game_layer = $GameLayer


func _ready() -> void:
	# 전역 LocalizationManager 싱글톤 사용
	if LocalizationManager != null:
		LocalizationManager.language_changed.connect(_on_language_changed)
	
	random_seed_value = randi()
	seed(random_seed_value)
	
	setup_ui()
	setup_game_timer()
	setup_game()


## UI 설정
func setup_ui() -> void:
	# UILayer와 GameLayer가 없으면 생성
	if not has_node("UILayer"):
		var ui := Control.new()
		ui.name = "UILayer"
		ui.anchors_preset = Control.PRESET_FULL_RECT
		add_child(ui)
	
	if not has_node("GameLayer"):
		var game := Control.new()
		game.name = "GameLayer"
		game.anchors_preset = Control.PRESET_FULL_RECT
		add_child(game)
	
	# 뒤로 가기 버튼
	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = _get_localized_text("back_button", "뒤로 가기")
	back_button.position = Vector2(10, 10)
	back_button.size = Vector2(100, 40)
	back_button.pressed.connect(_on_back_pressed)
	$UILayer.add_child(back_button)
	
	# 타이머 라벨
	var timer_label := Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(get_viewport().size.x - 150, 10)
	timer_label.size = Vector2(140, 40)
	timer_label.text = "%s: %.1f" % [_get_localized_text("time", "시간"), time_limit]
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UILayer.add_child(timer_label)
	
	# 점수 라벨
	var score_label := Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(get_viewport().size.x - 150, 60)
	score_label.size = Vector2(140, 40)
	score_label.text = "%s: 0" % _get_localized_text("score", "점수")
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UILayer.add_child(score_label)


## 게임 타이머 설정
func setup_game_timer() -> void:
	game_timer = Timer.new()
	game_timer.wait_time = time_limit
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_game_timeout)
	add_child(game_timer)


## 게임 설정 (자식 클래스에서 오버라이드)
func setup_game() -> void:
	pass


## 미니게임 시작 (인터페이스 메서드)
## @param data: 게임 시작 데이터
func start(data: Dictionary = {}) -> void:
	_start_data = data
	is_game_active = true
	is_paused = false
	is_completed_flag = false
	current_score = 0
	_result_data.clear()
	
	# 난이도 적용
	if data.has("difficulty"):
		difficulty = data.difficulty
	if data.has("time_limit"):
		time_limit = data.time_limit
		game_timer.wait_time = time_limit
	
	game_timer.start()
	on_game_start()


## 미니게임 일시정지 (인터페이스 메서드)
func pause() -> void:
	if not is_game_active or is_paused:
		return
	
	is_paused = true
	game_timer.paused = true
	on_game_pause()
	game_paused.emit()


## 미니게임 재개 (인터페이스 메서드)
func resume() -> void:
	if not is_game_active or not is_paused:
		return
	
	is_paused = false
	game_timer.paused = false
	on_game_resume()
	game_resumed.emit()


## 미니게임 종료 (인터페이스 메서드)
## @return: 게임 결과 데이터
func end() -> Dictionary:
	if not is_game_active:
		return _result_data
	
	is_game_active = false
	is_completed_flag = true
	game_timer.stop()
	
	# 결과 데이터 구성
	_result_data = {
		"success": current_score > 0,
		"score": current_score,
		"time_remaining": game_timer.time_left if game_timer else 0.0,
		"difficulty": difficulty,
		"game_id": game_name_key
	}
	
	on_game_end(_result_data.success)
	game_completed.emit(_result_data.success, current_score)
	
	return _result_data


## 게임 완료 여부 반환 (인터페이스 메서드)
## @return: 완료 여부
func is_completed() -> bool:
	return is_completed_flag


## 현재 점수 반환 (인터페이스 메서드)
## @return: 점수
func get_score() -> int:
	return current_score


## 게임 시작 시 호출 (자식 클래스에서 오버라이드)
func on_game_start() -> void:
	pass


## 게임 일시정지 시 호출 (자식 클래스에서 오버라이드)
func on_game_pause() -> void:
	pass


## 게임 재개 시 호출 (자식 클래스에서 오버라이드)
func on_game_resume() -> void:
	pass


## 게임 종료 시 호출 (자식 클래스에서 오버라이드)
## @param success: 성공 여부
func on_game_end(success: bool) -> void:
	pass


## 점수 업데이트
## @param new_score: 새 점수
func update_score(new_score: int) -> void:
	current_score = new_score
	var score_label = $UILayer.get_node_or_null("ScoreLabel")
	if score_label:
		score_label.text = "%s: %d" % [_get_localized_text("score", "점수"), current_score]
	score_changed.emit(current_score)


## 점수 추가
## @param points: 추가할 점수
func add_score(points: int) -> void:
	update_score(current_score + points)


func _process(_delta: float) -> void:
	if is_game_active and not is_paused and game_timer:
		var timer_label = $UILayer.get_node_or_null("TimerLabel")
		if timer_label:
			timer_label.text = "%s: %.1f" % [_get_localized_text("time", "시간"), game_timer.time_left]


func _on_language_changed(_new_language: String) -> void:
	update_ui_text()


## UI 텍스트 업데이트
func update_ui_text() -> void:
	var back_button = $UILayer.get_node_or_null("BackButton")
	if back_button:
		back_button.text = _get_localized_text("back_button", "뒤로 가기")
	
	var timer_label = $UILayer.get_node_or_null("TimerLabel")
	if timer_label and game_timer:
		timer_label.text = "%s: %.1f" % [_get_localized_text("time", "시간"), game_timer.time_left]
	
	var score_label = $UILayer.get_node_or_null("ScoreLabel")
	if score_label:
		score_label.text = "%s: %d" % [_get_localized_text("score", "점수"), current_score]


## 현지화된 텍스트 가져오기
func _get_localized_text(key: String, default: String) -> String:
	if LocalizationManager != null:
		return LocalizationManager.get_text(key, default)
	return default


## 랜덤 정수 생성
func get_random_int(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)


## 랜덤 실수 생성
func get_random_float(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)


## 배열에서 랜덤 선택
func get_random_choice(choices: Array) -> Variant:
	if choices.is_empty():
		return null
	return choices[randi() % choices.size()]


## 게임 타임아웃
func _on_game_timeout() -> void:
	end()


## 뒤로 가기 버튼 클릭
func _on_back_pressed() -> void:
	end()
	game_exited.emit()


## 게임 데이터 반환 (저장용)
func get_game_data() -> Dictionary:
	return {
		"score": current_score,
		"time_remaining": game_timer.time_left if game_timer else 0.0,
		"difficulty": difficulty,
		"is_completed": is_completed_flag
	}


## 게임 데이터 로드
func load_game_data(data: Dictionary) -> void:
	if data.has("score"):
		current_score = data.score
	if data.has("difficulty"):
		difficulty = data.difficulty
