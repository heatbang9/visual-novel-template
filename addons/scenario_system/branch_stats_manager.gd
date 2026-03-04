extends Node

# class_name BranchStatsManager

## 분기 통계 관리자
## 플레이어의 선택에 따른 분기 통계 추적 및 엔딩 예측 시스템

signal stats_updated(stat_id: String, new_value: Variant)
signal route_prediction_changed(predicted_route: String, confidence: float)
signal route_alternative_discovered(alternative_route: String, requirements: Dictionary)

## 싱글톤 인스턴스
static var _instance: Node = null

## 분기 통계 데이터
var _branch_stats: Dictionary = {}

## 통계 정의 (XML에서 로드)
var _stat_definitions: Dictionary = {}

## 분기 예측 정의
var _branch_predictions: Dictionary = {}

## 추적 중인 변수 목록
var _tracked_variables: Array[String] = []

## 현재 예측된 루트
var _predicted_route: String = ""
var _prediction_confidence: float = 0.0

## 캐시
var _analysis_cache: Dictionary = {}
var _cache_valid: bool = false

## 설정
const MAX_TRACKED_STATS: int = 10
var _debug_mode: bool = false

## 루트 변경 추적
var _route_history: Array[Dictionary] = []
var _track_route_changes: bool = false

func _ready() -> void:
	_instance = self
	_initialize_default_stats()

## 싱글톤 접근
static func get_instance() -> Node:
	return _instance

## 기본 통계 초기화
func _initialize_default_stats() -> void:
	_branch_stats = {
		"hero_reputation": 0,
		"villain_reputation": 0,
		"neutral_reputation": 0,
		"total_choices_made": 0,
		"good_choices": 0,
		"bad_choices": 0,
		"neutral_choices": 0
	}
	_analysis_cache.clear()
	_cache_valid = false

## ========== 통계 정의 등록 ==========

## 분기 통계 정의 등록 (XML에서 호출)
func register_branch_stats_definition(stats_id: String, definition: Dictionary) -> void:
	if _stat_definitions.size() >= MAX_TRACKED_STATS:
		push_warning("분기 통계 최대 개수 초과 (최대 %d개)".format([MAX_TRACKED_STATS]))
		return
	
	_stat_definitions[stats_id] = definition
	
	# track_route_changes 설정
	if definition.get("track_route_changes", false):
		_track_route_changes = true
	
	# stat 정의 등록
	if definition.has("stats"):
		for stat_def in definition.stats:
			var variable = stat_def.get("variable", "")
			if not variable.is_empty() and variable not in _tracked_variables:
				_tracked_variables.append(variable)
				# 기본값으로 초기화
				if not _branch_stats.has(variable):
					_branch_stats[variable] = 0
	
	# branch_prediction 정의 등록
	if definition.has("predictions"):
		for pred_def in definition.predictions:
			var based_on = pred_def.get("based_on", "")
			var route = pred_def.get("route", "")
			if not based_on.is_empty() and not route.is_empty():
				if not _branch_predictions.has(based_on):
					_branch_predictions[based_on] = []
				_branch_predictions[based_on].append(pred_def)
	
	_invalidate_cache()
	
	if _debug_mode:
		print("[BranchStatsManager] 통계 정의 등록: %s" % stats_id)

## ========== 통계 업데이트 ==========

## 통계 업데이트
func update_stats(variable: String, value: Variant) -> void:
	if variable not in _tracked_variables and _tracked_variables.size() >= MAX_TRACKED_STATS:
		push_warning("추적 변수 최대 개수 초과: %s" % variable)
		return
	
	# 변수가 추적 목록에 없으면 추가
	if variable not in _tracked_variables:
		_tracked_variables.append(variable)
	
	var old_value = _branch_stats.get(variable, 0)
	_branch_stats[variable] = value
	
	# 캐시 무효화
	_invalidate_cache()
	
	# 시그널 발생
	emit_signal("stats_updated", variable, value)
	
	# 예측 업데이트
	_update_route_prediction()
	
	if _debug_mode:
		print("[BranchStatsManager] 통계 업데이트: %s = %s (이전: %s)" % [variable, str(value), str(old_value)])

## 통계 증가
func increment_stat(variable: String, amount: Variant = 1) -> void:
	var current = _branch_stats.get(variable, 0)
	var new_value: Variant
	
	if current is int or current is float:
		new_value = current + amount
	elif current is bool:
		new_value = amount
	else:
		new_value = amount
	
	update_stats(variable, new_value)

## 통계 감소
func decrement_stat(variable: String, amount: Variant = 1) -> void:
	increment_stat(variable, -amount)

## 선택 기록 (자동 통계 업데이트)
func record_choice(choice_type: String, effects: Dictionary = {}) -> void:
	# 총 선택 수 증가
	increment_stat("total_choices_made", 1)
	
	# 선택 유형별 카운트
	match choice_type:
		"good", "hero":
			increment_stat("good_choices", 1)
			increment_stat("hero_reputation", 1)
		"bad", "villain":
			increment_stat("bad_choices", 1)
			increment_stat("villain_reputation", 1)
		"neutral":
			increment_stat("neutral_choices", 1)
			increment_stat("neutral_reputation", 1)
	
	# 추가 효과 적용
	for variable in effects:
		update_stats(variable, effects[variable])

## ========== 분기 분석 ==========

## 분기 통계 분석 (캐시 사용)
func analyze_branch_stats() -> Dictionary:
	if _cache_valid and not _analysis_cache.is_empty():
		return _analysis_cache
	
	var analysis: Dictionary = {
		"active_stats": {},
		"dominant_stat": "",
		"dominant_value": 0,
		"prediction": "",
		"confidence": 0.0,
		"route_progress": {},
		"alternatives": []
	}
	
	# 활성 통계 수집
	for variable in _tracked_variables:
		if _branch_stats.has(variable):
			var value = _branch_stats[variable]
			analysis.active_stats[variable] = value
			
			# 최대값 찾기
			if value > analysis.dominant_value:
				analysis.dominant_value = value
				analysis.dominant_stat = variable
	
	# 루트 예측
	var prediction_result = _calculate_route_prediction()
	analysis.prediction = prediction_result.route
	analysis.confidence = prediction_result.confidence
	
	# 루트 진행 상황
	analysis.route_progress = _calculate_route_progress()
	
	# 대안 루트
	analysis.alternatives = get_route_alternatives()
	
	# 캐시 저장
	_analysis_cache = analysis
	_cache_valid = true
	
	return analysis

## 엔딩 예측
func predict_ending(stats: Dictionary = {}) -> String:
	if stats.is_empty():
		stats = _branch_stats
	
	# 예측 정의가 있으면 사용
	if not _branch_predictions.is_empty():
		var best_prediction = ""
		var best_score = -1
		
		for based_on in _branch_predictions:
			var predictions = _branch_predictions[based_on]
			var current_value = stats.get(based_on, 0)
			
			for pred in predictions:
				var threshold = pred.get("threshold", 50)
				var operator = pred.get("operator", ">")
				var route = pred.get("route", "")
				
				var matches = false
				match operator:
					">":
						matches = current_value > threshold
					">=":
						matches = current_value >= threshold
					"<":
						matches = current_value < threshold
					"<=":
						matches = current_value <= threshold
					"==":
						matches = current_value == threshold
				
				if matches and current_value > best_score:
					best_prediction = route
					best_score = current_value
		
		if not best_prediction.is_empty():
			return best_prediction
	
	# 기본 예측 로직
	var max_stat = ""
	var max_value = 0
	
	for variable in stats:
		var value = stats.get(variable, 0)
		if value is int or value is float:
			if value > max_value:
				max_value = value
				max_stat = variable
	
	# 통계 이름을 기반으로 루트 이름 유추
	if max_stat.contains("hero") or max_stat.contains("good"):
		return "hero_ending"
	elif max_stat.contains("villain") or max_stat.contains("bad"):
		return "villain_ending"
	elif max_stat.contains("neutral"):
		return "neutral_ending"
	
	return "unknown_ending"

## 루트 대안 목록 가져오기
func get_route_alternatives() -> Array:
	var alternatives: Array = []
	
	# 모든 예측 정의에서 가능한 루트 수집
	for based_on in _branch_predictions:
		for pred in _branch_predictions[based_on]:
			var route = pred.get("route", "")
			if not route.is_empty() and route not in alternatives:
				var requirement = {
					"route": route,
					"based_on": based_on,
					"threshold": pred.get("threshold", 50),
					"operator": pred.get("operator", ">"),
					"current_value": _branch_stats.get(based_on, 0),
					"achievable": _is_requirement_achievable(pred)
				}
				alternatives.append(requirement)
	
	return alternatives

## 요구사항 달성 가능 여부
func _is_requirement_achievable(pred: Dictionary) -> bool:
	var threshold = pred.get("threshold", 50)
	var operator = pred.get("operator", ">")
	var current_value = _branch_stats.get(pred.get("based_on", ""), 0)
	
	# 현재 값이 이미 충족되었거나, 미래에 달성 가능한지 확인
	match operator:
		">", ">=":
			return current_value <= threshold  # 아직 달성하지 않았지만 가능
		"<", "<=":
			return true  # 항상 가능 (선택을 통해 감소 가능)
		"==":
			return true  # 항상 가능
	
	return true

## ========== 루트 변경 추적 ==========

## 루트 변경 기록
func record_route_change(old_route: String, new_route: String) -> void:
	if not _track_route_changes:
		return
	
	var change_record = {
		"timestamp": Time.get_ticks_msec(),
		"old_route": old_route,
		"new_route": new_route,
		"stats_snapshot": _branch_stats.duplicate()
	}
	
	_route_history.append(change_record)
	
	# 루트 변경 시 예측 업데이트
	_update_route_prediction()
	
	if _debug_mode:
		print("[BranchStatsManager] 루트 변경: %s -> %s" % [old_route, new_route])

## 루트 변경 이력 가져오기
func get_route_history() -> Array[Dictionary]:
	return _route_history

## ========== 통계 요약 ==========

## 통계 요약 문자열
func get_stat_summary() -> String:
	var summary_lines: Array[String] = []
	summary_lines.append("=== 분기 통계 요약 ===")
	
	# 추적 중인 변수
	for variable in _tracked_variables:
		if _branch_stats.has(variable):
			var value = _branch_stats[variable]
			var label = _get_stat_label(variable)
			summary_lines.append("%s: %s" % [label, str(value)])
	
	# 예측
	var prediction = predict_ending()
	var confidence = _prediction_confidence
	summary_lines.append("\n예상 엔딩: %s (%.1f%% 확률)" % [prediction, confidence * 100])
	
	return "\n".join(summary_lines)

## 통계 레이블 가져오기
func _get_stat_label(variable: String) -> String:
	# 정의에서 레이블 찾기
	for stats_id in _stat_definitions:
		var definition = _stat_definitions[stats_id]
		if definition.has("stats"):
			for stat_def in definition.stats:
				if stat_def.get("variable", "") == variable:
					return stat_def.get("label", variable)
	
	return variable

## ========== 내부 함수 ==========

## 캐시 무효화
func _invalidate_cache() -> void:
	_cache_valid = false
	_analysis_cache.clear()

## 루트 예측 업데이트
func _update_route_prediction() -> void:
	var prediction_result = _calculate_route_prediction()
	var old_route = _predicted_route
	
	_predicted_route = prediction_result.route
	_prediction_confidence = prediction_result.confidence
	
	if _predicted_route != old_route:
		emit_signal("route_prediction_changed", _predicted_route, _prediction_confidence)

## 루트 예측 계산
func _calculate_route_prediction() -> Dictionary:
	var result = {
		"route": "",
		"confidence": 0.0
	}
	
	# 예측 정의 사용
	if not _branch_predictions.is_empty():
		var route_scores: Dictionary = {}
		
		for based_on in _branch_predictions:
			var predictions = _branch_predictions[based_on]
			var current_value = _branch_stats.get(based_on, 0)
			
			for pred in predictions:
				var threshold = pred.get("threshold", 50)
				var route = pred.get("route", "")
				
				if not route.is_empty():
					# 점수 계산 (임계값에 얼마나 가까운지)
					var score = float(current_value) / float(threshold)
					route_scores[route] = route_scores.get(route, 0.0) + score
		
		# 최고 점수 루트 선택
		var best_route = ""
		var best_score = 0.0
		var total_score = 0.0
		
		for route in route_scores:
			var score = route_scores[route]
			total_score += score
			if score > best_score:
				best_score = score
				best_route = route
		
		result.route = best_route
		if total_score > 0:
			result.confidence = best_score / total_score
	
	# 기본 예측
	if result.route.is_empty():
		result.route = predict_ending()
		result.confidence = 0.5
	
	return result

## 루트 진행 상황 계산
func _calculate_route_progress() -> Dictionary:
	var progress: Dictionary = {}
	
	for based_on in _branch_predictions:
		for pred in _branch_predictions[based_on]:
			var route = pred.get("route", "")
			var threshold = pred.get("threshold", 50)
			var current_value = _branch_stats.get(based_on, 0)
			
			if not route.is_empty():
				var progress_percent = clamp(float(current_value) / float(threshold) * 100.0, 0.0, 100.0)
				progress[route] = {
					"current": current_value,
					"required": threshold,
					"percentage": progress_percent,
					"completed": current_value >= threshold
				}
	
	return progress

## ========== 디버그 모드 ==========

## 디버그 모드 설정
func set_debug_mode(enabled: bool) -> void:
	_debug_mode = enabled

## 디버그 정보 출력
func debug_print_stats() -> void:
	print("=== BranchStatsManager Debug ===")
	print("Tracked Variables: ", _tracked_variables)
	print("Current Stats: ", _branch_stats)
	print("Predictions: ", _branch_predictions)
	print("Current Prediction: %s (%.1f%%)" % [_predicted_route, _prediction_confidence * 100])
	print("Cache Valid: ", _cache_valid)
	print("================================")

## ========== 저장/로드 ==========

## 상태 저장
func save_state() -> Dictionary:
	return {
		"branch_stats": _branch_stats.duplicate(),
		"tracked_variables": _tracked_variables.duplicate(),
		"route_history": _route_history.duplicate(),
		"predicted_route": _predicted_route,
		"prediction_confidence": _prediction_confidence
	}

## 상태 로드
func load_state(state: Dictionary) -> void:
	_branch_stats = state.get("branch_stats", {})
	_tracked_variables.clear()
	for var_name in state.get("tracked_variables", []):
		_tracked_variables.append(var_name)
	
	_route_history.clear()
	for record in state.get("route_history", []):
		_route_history.append(record)
	
	_predicted_route = state.get("predicted_route", "")
	_prediction_confidence = state.get("prediction_confidence", 0.0)
	
	_invalidate_cache()

## ========== 리셋 ==========

## 통계 리셋
func reset_stats() -> void:
	_branch_stats.clear()
	_tracked_variables.clear()
	_stat_definitions.clear()
	_branch_predictions.clear()
	_route_history.clear()
	_predicted_route = ""
	_prediction_confidence = 0.0
	
	_initialize_default_stats()
	
	if _debug_mode:
		print("[BranchStatsManager] 통계 리셋 완료")

## 특정 통계만 리셋
func reset_stat(variable: String) -> void:
	if _branch_stats.has(variable):
		_branch_stats[variable] = 0
		_invalidate_cache()

## ========== 게터 ==========

## 통계 값 가져오기
func get_stat(variable: String) -> Variant:
	return _branch_stats.get(variable, 0)

## 모든 통계 가져오기
func get_all_stats() -> Dictionary:
	return _branch_stats.duplicate()

## 현재 예측된 루트
func get_predicted_route() -> String:
	return _predicted_route

## 예측 신뢰도
func get_prediction_confidence() -> float:
	return _prediction_confidence

## 추적 중인 변수 목록
func get_tracked_variables() -> Array[String]:
	return _tracked_variables.duplicate()

## 디버그 모드 여부
func is_debug_mode() -> bool:
	return _debug_mode
