## 미니게임 인터페이스
## 모든 미니게임이 구현해야 하는 기본 인터페이스
## Godot 4.5 호환, Node 기반
class_name MinigameInterface
extends Node

## 미니게임 완료 시그널 (성공 여부, 점수)
signal game_completed(success: bool, score: int)

## 미니게임 종료 시그널
signal game_exited

## 미니게임 일시정지 시그널
signal game_paused

## 미니게임 재개 시그널
signal game_resumed

## 점수 변경 시그널
signal score_changed(new_score: int)

## 미니게임 고유 ID
@export var game_id: String = ""

## 미니게임 표시 이름 (현지화 키)
@export var game_name_key: String = ""

## 미니게임 설명 (현지화 키)
@export var game_desc_key: String = ""

## 시간 제한 (초)
@export var time_limit: float = 60.0

## 난이도 (1-5)
@export var difficulty: int = 1

## 미니게임이 활성화되어 있는지 여부
var is_active: bool = false

## 미니게임이 일시정지 상태인지 여부
var is_paused: bool = false

## 미니게임이 완료되었는지 여부
var is_completed_flag: bool = false

## 현재 점수
var current_score: int = 0

## 미니게임 씬 경로
var scene_path: String = ""

## 미니게임 아이콘 경로
var icon_path: String = ""

## 카테고리 (예: "puzzle", "action", "strategy")
var category: String = "general"

## 태그 목록
var tags: Array[String] = []

## 의존성 목록 (다른 미니게임 ID)
var dependencies: Array[String] = []

## 게임 시작 데이터
var _start_data: Dictionary = {}

## 게임 결과 데이터
var _result_data: Dictionary = {}


## 미니게임 초기화
func initialize(config: Dictionary = {}) -> void:
	if config.has("game_id"):
		game_id = config.game_id
	if config.has("game_name_key"):
		game_name_key = config.game_name_key
	if config.has("game_desc_key"):
		game_desc_key = config.game_desc_key
	if config.has("time_limit"):
		time_limit = config.time_limit
	if config.has("difficulty"):
		difficulty = config.difficulty
	if config.has("scene_path"):
		scene_path = config.scene_path
	if config.has("icon_path"):
		icon_path = config.icon_path
	if config.has("category"):
		category = config.category
	if config.has("tags"):
		tags = config.tags
	if config.has("dependencies"):
		dependencies = config.dependencies


## 미니게임 시작 (인터페이스 메서드)
## @param data: 게임 시작 데이터
func start(data: Dictionary = {}) -> void:
	_start_data = data
	is_active = true
	is_paused = false
	is_completed_flag = false
	current_score = 0
	_result_data.clear()
	
	# 난이도 적용
	if data.has("difficulty"):
		difficulty = data.difficulty
	if data.has("time_limit"):
		time_limit = data.time_limit
	
	_on_game_start()


## 미니게임 일시정지 (인터페이스 메서드)
func pause() -> void:
	if not is_active or is_paused:
		return
	
	is_paused = true
	_on_game_pause()
	game_paused.emit()


## 미니게임 재개 (인터페이스 메서드)
func resume() -> void:
	if not is_active or not is_paused:
		return
	
	is_paused = false
	_on_game_resume()
	game_resumed.emit()


## 미니게임 종료 (인터페이스 메서드)
## @return: 게임 결과 데이터
func end() -> Dictionary:
	if not is_active:
		return _result_data
	
	is_active = false
	is_completed_flag = true
	
	# 결과 데이터 구성
	_result_data = {
		"success": current_score > 0,
		"score": current_score,
		"difficulty": difficulty,
		"game_id": game_id
	}
	
	_on_game_end(_result_data.success)
	game_completed.emit(_result_data.success, current_score)
	
	return _result_data


## 미니게임 완료 여부 반환 (인터페이스 메서드)
## @return: 완료 여부
func is_completed() -> bool:
	return is_completed_flag


## 현재 점수 반환 (인터페이스 메서드)
## @return: 점수
func get_score() -> int:
	return current_score


## 점수 업데이트
## @param new_score: 새 점수
func update_score(new_score: int) -> void:
	current_score = new_score
	score_changed.emit(current_score)


## 점수 추가
## @param points: 추가할 점수
func add_score(points: int) -> void:
	update_score(current_score + points)


## 게임 시작 시 호출 (자식 클래스에서 오버라이드)
func _on_game_start() -> void:
	pass


## 게임 일시정지 시 호출 (자식 클래스에서 오버라이드)
func _on_game_pause() -> void:
	pass


## 게임 재개 시 호출 (자식 클래스에서 오버라이드)
func _on_game_resume() -> void:
	pass


## 게임 종료 시 호출 (자식 클래스에서 오버라이드)
## @param success: 성공 여부
func _on_game_end(success: bool) -> void:
	pass


## 미니게임 데이터를 딕셔너리로 반환
func to_dictionary() -> Dictionary:
	return {
		"game_id": game_id,
		"game_name_key": game_name_key,
		"game_desc_key": game_desc_key,
		"time_limit": time_limit,
		"difficulty": difficulty,
		"scene_path": scene_path,
		"icon_path": icon_path,
		"category": category,
		"tags": tags,
		"dependencies": dependencies
	}


## 딕셔너리에서 미니게임 데이터 로드
static func from_dictionary(data: Dictionary) -> MinigameInterface:
	var interface := MinigameInterface.new()
	interface.initialize(data)
	return interface


## 의존성이 모두 충족되는지 확인
func check_dependencies(available_games: Array[String]) -> bool:
	for dep in dependencies:
		if dep not in available_games:
			return false
	return true


## 미니게임이 유효한지 확인
func is_valid() -> bool:
	return game_id != "" and scene_path != ""
