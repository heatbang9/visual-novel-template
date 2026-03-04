extends Node

## 업적 관리 싱글톤
## 시스템 전반의 업적 잠금 해제, 저장, 로드를 담당

# class_name AchievementManager

# 시그널
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)
signal achievement_progress_updated(achievement_id: String, progress: float)

# 업적 데이터
var _achievements: Dictionary = {}
var _unlocked_achievements: Dictionary = {}
var _achievement_progress: Dictionary = {}

# 저장 경로
const SAVE_PATH := "user://achievements.save"

func _ready() -> void:
	_load_achievements()

## 업적 등록
func register_achievement(id: String, data: Dictionary) -> void:
	if _achievements.has(id):
		push_warning("이미 등록된 업적입니다: " + id)
		return
	
	_achievements[id] = {
		"id": id,
		"name": data.get("name", id),
		"description": data.get("description", ""),
		"icon": data.get("icon", ""),
		"hidden": data.get("hidden", false),
		"conditions": data.get("conditions", []),
		"rewards": data.get("rewards", []),
		"unlocked": _unlocked_achievements.has(id)
	}
	
	# 진행도 초기화
	if not _achievement_progress.has(id):
		_achievement_progress[id] = 0.0

## XML 데이터로부터 업적 등록
func register_achievement_from_xml(xml_data: Dictionary) -> void:
	var id = xml_data.get("id", "")
	if id.is_empty():
		push_error("업적 ID가 없습니다")
		return
	
	register_achievement(id, xml_data)

## 업적 잠금 해제
func unlock_achievement(id: String) -> bool:
	if not _achievements.has(id):
		push_error("존재하지 않는 업적입니다: " + id)
		return false
	
	if _unlocked_achievements.has(id):
		push_warning("이미 잠금 해제된 업적입니다: " + id)
		return false
	
	var achievement = _achievements[id]
	achievement.unlocked = true
	_unlocked_achievements[id] = {
		"id": id,
		"unlocked_at": Time.get_datetime_string_from_system()
	}
	
	# 보상 처리
	_process_rewards(achievement.get("rewards", []))
	
	# 저장
	_save_achievements()
	
	# 시그널 발생
	emit_signal("achievement_unlocked", id, achievement)
	
	return true

## 조건 확인 후 자동 잠금 해제
func check_and_unlock_achievement(id: String) -> bool:
	if not _achievements.has(id):
		return false
	
	if _unlocked_achievements.has(id):
		return false
	
	var achievement = _achievements[id]
	var conditions = achievement.get("conditions", [])
	
	if _evaluate_conditions(conditions):
		return unlock_achievement(id)
	
	return false

## 모든 업적 조건 확인
func check_all_achievements(variables: Dictionary) -> Array:
	var newly_unlocked := []
	
	for id in _achievements:
		if _unlocked_achievements.has(id):
			continue
		
		var achievement = _achievements[id]
		var conditions = achievement.get("conditions", [])
		
		if _evaluate_conditions_with_variables(conditions, variables):
			if unlock_achievement(id):
				newly_unlocked.append(id)
	
	return newly_unlocked

## 조건 평가 (기본 - ScenarioManager 변수 사용)
func _evaluate_conditions(conditions: Array) -> bool:
	if conditions.is_empty():
		return true
	
	for condition in conditions:
		if not _evaluate_single_condition(condition):
			return false
	
	return true

## 조건 평가 (외부 변수 사용)
func _evaluate_conditions_with_variables(conditions: Array, variables: Dictionary) -> bool:
	if conditions.is_empty():
		return true
	
	for condition in conditions:
		if not _evaluate_single_condition_with_variables(condition, variables):
			return false
	
	return true

## 단일 조건 평가
func _evaluate_single_condition(condition: Dictionary) -> bool:
	var type = condition.get("type", "variable")
	
	match type:
		"variable":
			var variable = condition.get("variable", "")
			var operator = condition.get("operator", "==")
			var expected_value = condition.get("value", null)
			var current_value = ScenarioManager.get_variable(variable)
			
			return _compare_values(current_value, operator, expected_value)
		
		"flag":
			var flag = condition.get("flag", "")
			return ScenarioManager.get_variable(flag) == true
		
		"route_complete":
			var route = condition.get("route", "")
			return ScenarioManager.get_variable(route + "_complete") == true
	
	return false

## 단일 조건 평가 (외부 변수 사용)
func _evaluate_single_condition_with_variables(condition: Dictionary, variables: Dictionary) -> bool:
	var type = condition.get("type", "variable")
	
	match type:
		"variable":
			var variable = condition.get("variable", "")
			var operator = condition.get("operator", "==")
			var expected_value = condition.get("value", null)
			var current_value = variables.get(variable, null)
			
			return _compare_values(current_value, operator, expected_value)
		
		"flag":
			var flag = condition.get("flag", "")
			return variables.get(flag, false) == true
		
		"route_complete":
			var route = condition.get("route", "")
			return variables.get(route + "_complete", false) == true
	
	return false

## 값 비교
func _compare_values(current, operator: String, expected) -> bool:
	match operator:
		"==", "=":
			return current == expected
		"!=":
			return current != expected
		">=":
			return current >= expected
		"<=":
			return current <= expected
		">":
			return current > expected
		"<":
			return current < expected
		"contains":
			return str(current).contains(str(expected))
		"starts_with":
			return str(current).begins_with(str(expected))
		"ends_with":
			return str(current).ends_with(str(expected))
	
	return false

## 보상 처리
func _process_rewards(rewards: Array) -> void:
	for reward in rewards:
		var type = reward.get("type", "")
		var target = reward.get("target", "")
		var value = reward.get("value", null)
		
		match type:
			"unlock":
				# 콘텐츠 잠금 해제 (예: 비밀 엔딩)
				ScenarioManager.set_variable(target + "_unlocked", true)
				push_warning("콘텐츠 잠금 해제: " + target)
			
			"variable":
				# 변수 설정
				ScenarioManager.set_variable(target, value)
			
			"item":
				# 아이템 지급 (아이템 시스템 연동 필요)
				push_warning("아이템 지급: " + target)
			
			"achievement":
				# 연관 업적 잠금 해제
				unlock_achievement(target)

## 업적 진행도 설정
func set_achievement_progress(id: String, progress: float) -> void:
	if not _achievements.has(id):
		return
	
	_achievement_progress[id] = clamp(progress, 0.0, 1.0)
	emit_signal("achievement_progress_updated", id, progress)
	
	# 진행도가 100%면 자동 잠금 해제
	if progress >= 1.0:
		unlock_achievement(id)

## 업적 진행도 가져오기
func get_achievement_progress(id: String) -> float:
	return _achievement_progress.get(id, 0.0)

## 업적 정보 가져오기
func get_achievement(id: String) -> Dictionary:
	if not _achievements.has(id):
		return {}
	
	var achievement = _achievements[id].duplicate()
	achievement["progress"] = _achievement_progress.get(id, 0.0)
	return achievement

## 모든 업적 가져오기
func get_all_achievements() -> Array:
	var result := []
	for id in _achievements:
		result.append(get_achievement(id))
	return result

## 잠금 해제된 업적 목록
func get_unlocked_achievements() -> Array:
	var result := []
	for id in _unlocked_achievements:
		result.append(get_achievement(id))
	return result

## 숨겨진 업적 확인
func is_achievement_hidden(id: String) -> bool:
	if not _achievements.has(id):
		return false
	return _achievements[id].get("hidden", false)

## 업적 잠금 해제 여부
func is_achievement_unlocked(id: String) -> bool:
	return _unlocked_achievements.has(id)

## 전체 진행도 (0.0 ~ 1.0)
func get_total_progress() -> float:
	if _achievements.is_empty():
		return 0.0
	
	var unlocked_count = _unlocked_achievements.size()
	var total_count = _achievements.size()
	
	return float(unlocked_count) / float(total_count)

## 업적 초기화 (개발용)
func reset_achievements() -> void:
	_unlocked_achievements.clear()
	_achievement_progress.clear()
	
	for id in _achievements:
		_achievements[id].unlocked = false
		_achievement_progress[id] = 0.0
	
	_save_achievements()

## 저장
func _save_achievements() -> void:
	var save_data := {
		"unlocked": _unlocked_achievements,
		"progress": _achievement_progress,
		"version": 1
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

## 로드
func _load_achievements() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if typeof(save_data) == TYPE_DICTIONARY:
			_unlocked_achievements = save_data.get("unlocked", {})
			_achievement_progress = save_data.get("progress", {})
