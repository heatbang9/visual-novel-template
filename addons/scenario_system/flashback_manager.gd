extends Node

## 플래시백 관리 싱글톤
## 과거 회상 씬의 시작, 종료, 중첩, 효과 등을 관리

# class_name FlashbackManager

# ============================================================
# 시그널
# ============================================================
signal flashback_started(flashback_id: String, flashback_data: Dictionary)
signal flashback_ended(flashback_id: String, return_scene_id: String)
signal flashback_cancelled(flashback_id: String)
signal flashback_skipped(flashback_id: String)
signal flashback_failed(flashback_id: String, error: String)
signal flashback_depth_changed(new_depth: int)
signal fade_started(direction: String)  # "in" or "out"
signal fade_completed(direction: String)

# ============================================================
# 상수
# ============================================================
const MAX_FLASHBACK_DEPTH: int = 3  # 최대 중첩 깊이
const DEFAULT_FADE_DURATION: float = 0.5  # 기본 페이드 시간 (초)
const DEFAULT_TIMEOUT_SECONDS: float = 300.0  # 기본 타임아웃 (5분)
const SAVE_PATH := "user://flashback_state.save"

# ============================================================
# 변수
# ============================================================

# 플래시백 스택 (중첩 지원)
var _flashback_stack: Array[Dictionary] = []

# 플래시백 정의 데이터 (XML에서 로드)
var _flashback_definitions: Dictionary = {}

# 이미 본 플래시백 기록
var _seen_flashbacks: Dictionary = {}

# 플래시백 히스토리 (전체 기록)
var _flashback_history: Array[Dictionary] = []

# 플래시백 통계
var _flashback_stats: Dictionary = {
	"total_started": 0,
	"total_completed": 0,
	"total_cancelled": 0,
	"total_skipped": 0,
	"total_failed": 0,
	"by_id": {}  # 각 ID별 통계
}

# 현재 상태
var _is_fading: bool = false
var _fade_tween: Tween = null
var _timeout_timer: Timer = null
var _current_timeout_seconds: float = DEFAULT_TIMEOUT_SECONDS

# UI 레퍼런스
var _flashback_ui_layer: CanvasLayer = null
var _fade_overlay: ColorRect = null

# 디버그 모드
var _debug_mode: bool = false

# 로그 버퍼
var _log_buffer: Array[String] = []
const MAX_LOG_ENTRIES: int = 100

# 프리로딩 캐시
var _preload_cache: Dictionary = {}

# 플래시백 중 변수 백업 (원본 시나리오 변수 보존)
var _variable_backup_stack: Array[Dictionary] = []

# ============================================================
# 초기화
# ============================================================
func _ready() -> void:
	_load_flashback_state()
	_setup_timeout_timer()
	_log("FlashbackManager 초기화 완료")

func _setup_timeout_timer() -> void:
	_timeout_timer = Timer.new()
	_timeout_timer.one_shot = true
	_timeout_timer.timeout.connect(_on_flashback_timeout)
	add_child(_timeout_timer)

# ============================================================
# 플래시백 정의 등록
# ============================================================

## 플래시백 정의 등록 (XML 파싱 시 호출)
func register_flashback_definition(id: String, data: Dictionary) -> void:
	if _flashback_definitions.has(id):
		push_warning("이미 등록된 플래시백입니다: " + id)
		return
	
	_flashback_definitions[id] = {
		"id": id,
		"trigger_variable": data.get("trigger_variable", ""),
		"trigger_value": data.get("trigger_value", null),
		"trigger_operator": data.get("trigger_operator", "=="),
		"scene": data.get("scene", {}),
		"effects": data.get("effects", []),
		"return_to_scene": data.get("return_to_scene", {}),
		"bgm": data.get("bgm", ""),
		"fade_duration": data.get("fade_duration", DEFAULT_FADE_DURATION),
		"timeout": data.get("timeout", DEFAULT_TIMEOUT_SECONDS),
		"skippable": data.get("skippable", true),
		"auto_trigger": data.get("auto_trigger", false),
		"tags": data.get("tags", [])
	}
	
	_log("플래시백 정의 등록: " + id)
	
	# 통계 초기화
	if not _flashback_stats.by_id.has(id):
		_flashback_stats.by_id[id] = {
			"started": 0,
			"completed": 0,
			"cancelled": 0,
			"skipped": 0,
			"failed": 0
		}

## XML 데이터로부터 플래시백 정의 등록
func register_flashback_from_xml(xml_data: Dictionary) -> void:
	var id = xml_data.get("id", "")
	if id.is_empty():
		push_error("플래시백 ID가 없습니다")
		return
	
	register_flashback_definition(id, xml_data)

# ============================================================
# 플래시백 시작/종료
# ============================================================

## 플래시백 시작
func start_flashback(id: String) -> bool:
	_log("플래시백 시작 요청: " + id)
	
	# 존재 확인
	if not _flashback_definitions.has(id):
		var error = "존재하지 않는 플래시백입니다: " + id
		push_error(error)
		emit_signal("flashback_failed", id, error)
		_increment_stat(id, "failed")
		return false
	
	# 깊이 확인 (스택 오버플로우 방지)
	if _flashback_stack.size() >= MAX_FLASHBACK_DEPTH:
		var error = "최대 플래시백 깊이 초과 (%d)" % MAX_FLASHBACK_DEPTH
		push_error(error)
		emit_signal("flashback_failed", id, error)
		_increment_stat(id, "failed")
		return false
	
	# 재귀 방지 (동일 ID 중복)
	for flashback in _flashback_stack:
		if flashback.id == id:
			var error = "재귀적 플래시백은 허용되지 않습니다: " + id
			push_error(error)
			emit_signal("flashback_failed", id, error)
			_increment_stat(id, "failed")
			return false
	
	var flashback_def = _flashback_definitions[id]
	
	# 트리거 조건 확인
	if not _check_trigger_conditions(flashback_def):
		var error = "트리거 조건이 충족되지 않음: " + id
		push_warning(error)
		emit_signal("flashback_failed", id, error)
		_increment_stat(id, "failed")
		return false
	
	# 이미 본 플래시백 스킵 가능 여부 확인
	if _seen_flashbacks.has(id) and flashback_def.get("skippable", true):
		if _should_skip_flashback(id):
			_log("이미 본 플래시백 스킵: " + id)
			emit_signal("flashback_skipped", id)
			_increment_stat(id, "skipped")
			return true
	
	# 현재 변수 백업 (원본 시나리오 변수 보존)
	var current_variables = ScenarioManager.scenario_variables.duplicate()
	_variable_backup_stack.append(current_variables)
	
	# 플래시백 데이터 생성
	var flashback_data = {
		"id": id,
		"definition": flashback_def,
		"started_at": Time.get_datetime_string_from_system(),
		"scene_id": flashback_def.scene.get("id", ""),
		"scene_path": flashback_def.scene.get("path", ""),
		"return_scene_id": flashback_def.return_to_scene.get("id", ""),
		"depth": _flashback_stack.size() + 1
	}
	
	# 스택에 추가
	_flashback_stack.append(flashback_data)
	
	# 통계 업데이트
	_increment_stat(id, "started")
	_flashback_stats.total_started += 1
	
	# 히스토리에 추가
	_add_to_history(flashback_data)
	
	# 깊이 변경 시그널
	emit_signal("flashback_depth_changed", _flashback_stack.size())
	
	# 타임아웃 설정
	_current_timeout_seconds = flashback_def.get("timeout", DEFAULT_TIMEOUT_SECONDS)
	_timeout_timer.start(_current_timeout_seconds)
	
	# 페이드 아웃 -> 씬 전환 -> 페이드 인
	await _fade_out(flashback_def.get("fade_duration", DEFAULT_FADE_DURATION))
	
	# 씬 전환
	_load_flashback_scene(flashback_def.scene)
	
	# BGM 변경
	_play_flashback_bgm(flashback_def.get("bgm", ""))
	
	# 효과 적용
	_apply_flashback_effects(flashback_def.effects)
	
	await _fade_in(flashback_def.get("fade_duration", DEFAULT_FADE_DURATION))
	
	# 시그널 발생
	emit_signal("flashback_started", id, flashback_data)
	
	_log("플래시백 시작 완료: " + id + " (깊이: %d)" % _flashback_stack.size())
	
	return true

## 플래시백 종료
func end_flashback() -> bool:
	if _flashback_stack.is_empty():
		push_warning("종료할 플래시백이 없습니다")
		return false
	
	# 타임아웃 타이머 정지
	_timeout_timer.stop()
	
	var current_flashback = _flashback_stack.pop_back()
	var flashback_id = current_flashback.id
	var flashback_def = current_flashback.definition
	var return_scene_id = current_flashback.return_scene_id
	
	_log("플래시백 종료: " + flashback_id)
	
	# 페이드 아웃
	await _fade_out(flashback_def.get("fade_duration", DEFAULT_FADE_DURATION))
	
	# 변수 복원 (원본 시나리오 변수로)
	if not _variable_backup_stack.is_empty():
		var backup_variables = _variable_backup_stack.pop_back()
		# 플래시백 중 변경된 변수는 무시하고 원본으로 복원
		ScenarioManager.scenario_variables = backup_variables
	
	# 복귀 씬 로드
	if not return_scene_id.is_empty():
		_load_return_scene(return_scene_id)
	
	# BGM 복원
	_restore_bgm()
	
	await _fade_in(flashback_def.get("fade_duration", DEFAULT_FADE_DURATION))
	
	# 이미 본 것으로 표시
	_seen_flashbacks[flashback_id] = {
		"seen_at": Time.get_datetime_string_from_system(),
		"times_seen": _seen_flashbacks.get(flashback_id, {}).get("times_seen", 0) + 1
	}
	
	# 통계 업데이트
	_increment_stat(flashback_id, "completed")
	_flashback_stats.total_completed += 1
	
	# 깊이 변경 시그널
	emit_signal("flashback_depth_changed", _flashback_stack.size())
	
	# 자동 저장
	_auto_save()
	
	# 시그널 발생
	emit_signal("flashback_ended", flashback_id, return_scene_id)
	
	# 다음 플래시백이 있으면 타임아웃 재설정
	if not _flashback_stack.is_empty():
		var next_flashback = _flashback_stack[-1]
		var remaining_time = next_flashback.definition.get("timeout", DEFAULT_TIMEOUT_SECONDS)
		_timeout_timer.start(remaining_time)
	
	return true

## 플래시백 취소
func cancel_flashback() -> bool:
	if _flashback_stack.is_empty():
		push_warning("취소할 플래시백이 없습니다")
		return false
	
	_timeout_timer.stop()
	
	var current_flashback = _flashback_stack.pop_back()
	var flashback_id = current_flashback.id
	var flashback_def = current_flashback.definition
	var return_scene_id = current_flashback.return_scene_id
	
	_log("플래시백 취소: " + flashback_id)
	
	# 변수 복원
	if not _variable_backup_stack.is_empty():
		var backup_variables = _variable_backup_stack.pop_back()
		ScenarioManager.scenario_variables = backup_variables
	
	# 복귀 씬 로드
	if not return_scene_id.is_empty():
		_load_return_scene(return_scene_id)
	
	# 통계 업데이트
	_increment_stat(flashback_id, "cancelled")
	_flashback_stats.total_cancelled += 1
	
	# 깊이 변경 시그널
	emit_signal("flashback_depth_changed", _flashback_stack.size())
	
	emit_signal("flashback_cancelled", flashback_id)
	
	return true

## 플래시백 스킵
func skip_flashback() -> bool:
	if _flashback_stack.is_empty():
		push_warning("스킵할 플래시백이 없습니다")
		return false
	
	var current_flashback = _flashback_stack[-1]
	var flashback_id = current_flashback.id
	var flashback_def = current_flashback.definition
	
	if not flashback_def.get("skippable", true):
		push_warning("스킵할 수 없는 플래시백입니다: " + flashback_id)
		return false
	
	_log("플래시백 스킵: " + flashback_id)
	
	# 통계 업데이트
	_increment_stat(flashback_id, "skipped")
	_flashback_stats.total_skipped += 1
	
	emit_signal("flashback_skipped", flashback_id)
	
	# 종료 처리
	return await end_flashback()

# ============================================================
# 상태 확인
# ============================================================

## 현재 플래시백 중인지 확인
func is_in_flashback() -> bool:
	return not _flashback_stack.is_empty()

## 현재 플래시백 깊이 반환
func get_flashback_depth() -> int:
	return _flashback_stack.size()

## 최대 깊이 도달 여부
func is_at_max_depth() -> bool:
	return _flashback_stack.size() >= MAX_FLASHBACK_DEPTH

## 플래시백 데이터 가져오기
func get_flashback_data(id: String) -> Dictionary:
	if _flashback_definitions.has(id):
		return _flashback_definitions[id].duplicate()
	return {}

## 현재 플래시백 데이터 가져오기
func get_current_flashback() -> Dictionary:
	if _flashback_stack.is_empty():
		return {}
	return _flashback_stack[-1].duplicate()

## 플래시백 정의 존재 확인
func has_flashback_definition(id: String) -> bool:
	return _flashback_definitions.has(id)

## 이미 본 플래시백인지 확인
func has_seen_flashback(id: String) -> bool:
	return _seen_flashbacks.has(id)

## 트리거 조건 확인
func check_trigger_conditions(id: String) -> bool:
	if not _flashback_definitions.has(id):
		return false
	return _check_trigger_conditions(_flashback_definitions[id])

## 자동 트리거 플래시백 확인 및 실행
func check_auto_trigger_flashbacks() -> Array:
	var triggered := []
	for id in _flashback_definitions:
		var def = _flashback_definitions[id]
		if def.get("auto_trigger", false) and _check_trigger_conditions(def):
			if await start_flashback(id):
				triggered.append(id)
	return triggered

# ============================================================
# 내부 함수
# ============================================================

## 트리거 조건 확인 (내부)
func _check_trigger_conditions(flashback_def: Dictionary) -> bool:
	var trigger_variable = flashback_def.get("trigger_variable", "")
	var trigger_value = flashback_def.get("trigger_value", null)
	var trigger_operator = flashback_def.get("trigger_operator", "==")
	
	if trigger_variable.is_empty():
		return true  # 트리거 조건 없음
	
	var current_value = ScenarioManager.get_variable(trigger_variable)
	
	return _compare_values(current_value, trigger_operator, trigger_value)

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
		"has":
			if current is Array:
				return expected in current
			return false
	return false

## 스킵 여부 확인
func _should_skip_flashback(id: String) -> bool:
	# TODO: 사용자 설정에 따라 스킵 여부 결정
	# 현재는 기본적으로 false (설정 UI에서 변경 가능)
	return false

## 씬 로드
func _load_flashback_scene(scene_data: Dictionary) -> void:
	var scene_path = scene_data.get("path", "")
	if scene_path.is_empty():
		push_error("플래시백 씬 경로가 없습니다")
		return
	
	_log("플래시백 씬 로드: " + scene_path)
	
	# TODO: SceneManager를 통한 씬 전환
	# 현재는 기본적인 씬 전환만 구현
	if ResourceLoader.exists(scene_path):
		var scene_resource = load(scene_path)
		if scene_resource:
			get_tree().change_scene_to_packed(scene_resource)
	else:
		push_error("플래시백 씬을 찾을 수 없습니다: " + scene_path)

## 복귀 씬 로드
func _load_return_scene(scene_id: String) -> void:
	_log("복귀 씬 로드: " + scene_id)
	# TODO: SceneManager를 통한 씬 전환
	# 현재는 ScenarioManager에 씬 ID로 복귀하도록 요청
	ScenarioManager.set_variable("_return_to_scene", scene_id)

## BGM 재생
func _play_flashback_bgm(bgm_path: String) -> void:
	if bgm_path.is_empty():
		return
	
	_log("플래시백 BGM 재생: " + bgm_path)
	# TODO: AudioManager를 통한 BGM 재생
	# AudioManager.play_bgm(bgm_path, "flashback")

## BGM 복원
func _restore_bgm() -> void:
	_log("BGM 복원")
	# TODO: AudioManager를 통한 BGM 복원
	# AudioManager.restore_previous_bgm()

## 플래시백 효과 적용
func _apply_flashback_effects(effects: Array) -> void:
	for effect in effects:
		var variable = effect.get("variable", "")
		var value = effect.get("value", null)
		
		if not variable.is_empty():
			# 주의: 플래시백 중 변수 변경은 원본에 영향 없음
			# (종료 시 복원됨)
			ScenarioManager.set_variable(variable, value)
			_log("플래시백 효과 적용: %s = %s" % [variable, str(value)])

# ============================================================
# 페이드 효과
# ============================================================

## 페이드 아웃
func _fade_out(duration: float = DEFAULT_FADE_DURATION) -> void:
	if _is_fading:
		await fade_completed
	
	_is_fading = true
	emit_signal("fade_started", "out")
	
	_log("페이드 아웃 시작 (%.2f초)" % duration)
	
	# TODO: 실제 페이드 효과 구현
	# 현재는 대기만
	await get_tree().create_timer(duration).timeout
	
	_is_fading = false
	emit_signal("fade_completed", "out")

## 페이드 인
func _fade_in(duration: float = DEFAULT_FADE_DURATION) -> void:
	if _is_fading:
		await fade_completed
	
	_is_fading = true
	emit_signal("fade_started", "in")
	
	_log("페이드 인 시작 (%.2f초)" % duration)
	
	await get_tree().create_timer(duration).timeout
	
	_is_fading = false
	emit_signal("fade_completed", "in")

## 페이드 레이어 설정 (외부에서 호출)
func set_fade_layer(overlay: ColorRect) -> void:
	_fade_overlay = overlay

## UI 레이어 설정 (외부에서 호출)
func set_ui_layer(layer: CanvasLayer) -> void:
	_flashback_ui_layer = layer

# ============================================================
# 타임아웃
# ============================================================

func _on_flashback_timeout() -> void:
	if _flashback_stack.is_empty():
		return
	
	var current_flashback = _flashback_stack[-1]
	var flashback_id = current_flashback.id
	
	_log("플래시백 타임아웃: " + flashback_id)
	push_warning("플래시백 타임아웃: " + flashback_id)
	
	# 자동 종료
	await end_flashback()

## 타임아웃 시간 설정
func set_timeout_seconds(seconds: float) -> void:
	_current_timeout_seconds = seconds
	if _timeout_timer and not _timeout_timer.is_stopped():
		_timeout_timer.stop()
		_timeout_timer.start(seconds)

## 남은 타임아웃 시간
func get_remaining_timeout() -> float:
	if _timeout_timer:
		return _timeout_timer.time_left
	return 0.0

# ============================================================
# 히스토리
# ============================================================

func _add_to_history(flashback_data: Dictionary) -> void:
	var history_entry = {
		"id": flashback_data.id,
		"started_at": flashback_data.started_at,
		"depth": flashback_data.depth
	}
	_flashback_history.append(history_entry)

## 플래시백 히스토리 가져오기
func get_flashback_history() -> Array:
	return _flashback_history.duplicate()

## 히스토리 초기화
func clear_history() -> void:
	_flashback_history.clear()

# ============================================================
# 통계
# ============================================================

func _increment_stat(id: String, stat_type: String) -> void:
	if _flashback_stats.by_id.has(id):
		_flashback_stats.by_id[id][stat_type] += 1

## 전체 통계 가져오기
func get_statistics() -> Dictionary:
	return _flashback_stats.duplicate()

## 특정 플래시백 통계 가져오기
func get_flashback_statistics(id: String) -> Dictionary:
	return _flashback_stats.by_id.get(id, {})

## 통계 초기화
func reset_statistics() -> void:
	_flashback_stats = {
		"total_started": 0,
		"total_completed": 0,
		"total_cancelled": 0,
		"total_skipped": 0,
		"total_failed": 0,
		"by_id": {}
	}

# ============================================================
# 프리로딩 / 캐싱
# ============================================================

## 플래시백 프리로드
func preload_flashback(id: String) -> bool:
	if not _flashback_definitions.has(id):
		push_error("프리로드할 플래시백이 없습니다: " + id)
		return false
	
	if _preload_cache.has(id):
		return true  # 이미 로드됨
	
	var flashback_def = _flashback_definitions[id]
	var scene_path = flashback_def.scene.get("path", "")
	
	if scene_path.is_empty():
		return false
	
	# 씬 리소스 프리로드
	if ResourceLoader.exists(scene_path):
		var resource = ResourceLoader.load(scene_path)
		if resource:
			_preload_cache[id] = {
				"scene": resource,
				"loaded_at": Time.get_ticks_msec()
			}
			_log("플래시백 프리로드 완료: " + id)
			return true
	
	return false

## 여러 플래시백 프리로드
func preload_flashbacks(ids: Array) -> Dictionary:
	var results := {}
	for id in ids:
		results[id] = preload_flashback(id)
	return results

## 캐시에서 제거
func unload_flashback(id: String) -> void:
	_preload_cache.erase(id)
	_log("플래시백 언로드: " + id)

## 전체 캐시 클리어
func clear_cache() -> void:
	_preload_cache.clear()
	_log("플래시백 캐시 클리어")

# ============================================================
# 로그 시스템
# ============================================================

func _log(message: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s" % [timestamp, message]
	_log_buffer.append(log_entry)
	
	# 버퍼 크기 제한
	if _log_buffer.size() > MAX_LOG_ENTRIES:
		_log_buffer.pop_front()
	
	if _debug_mode:
		print("[FlashbackManager] " + message)

## 로그 가져오기
func get_logs() -> Array:
	return _log_buffer.duplicate()

## 로그 클리어
func clear_logs() -> void:
	_log_buffer.clear()

## 디버그 모드 설정
func set_debug_mode(enabled: bool) -> void:
	_debug_mode = enabled
	_log("디버그 모드: " + ("활성화" if enabled else "비활성화"))

## 디버그 모드 확인
func is_debug_mode() -> bool:
	return _debug_mode

# ============================================================
# 저장 / 로드
# ============================================================

## 상태 저장
func save_state() -> Dictionary:
	return {
		"seen_flashbacks": _seen_flashbacks,
		"flashback_history": _flashback_history,
		"flashback_stats": _flashback_stats,
		"current_stack": _flashback_stack,
		"version": 1
	}

## 상태 로드
func load_state(state: Dictionary) -> void:
	_seen_flashbacks = state.get("seen_flashbacks", {})
	_flashback_history = state.get("flashback_history", [])
	_flashback_stats = state.get("flashback_stats", _flashback_stats)
	_flashback_stack = state.get("current_stack", [])

## 자동 저장
func _auto_save() -> void:
	var save_data := save_state()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

## 파일에서 로드
func _load_flashback_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if typeof(save_data) == TYPE_DICTIONARY:
			load_state(save_data)

## 명시적 저장
func save() -> void:
	_auto_save()

## 명시적 로드
func load() -> void:
	_load_flashback_state()

## 초기화 (개발용)
func reset() -> void:
	_flashback_stack.clear()
	_variable_backup_stack.clear()
	_seen_flashbacks.clear()
	_flashback_history.clear()
	_preload_cache.clear()
	reset_statistics()
	clear_logs()
	_auto_save()
	_log("FlashbackManager 초기화 완료")

## 플래시백 정의 초기화 (개발용)
func reset_definitions() -> void:
	_flashback_definitions.clear()
	_log("플래시백 정의 초기화")
