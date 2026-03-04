extends Node

## 분기 통계 시스템 테스트
## Godot 4.5 호환

const TEST_SCENARIO_PATH = "res://test_scenarios/branch_stats_test.xml"

var _test_results: Array[String] = []
var _tests_passed: int = 0
var _tests_failed: int = 0

# BranchStatsManager 참조 (autoload로 로드될 때까지 대기)
var _branch_stats_manager: Node = null

func _ready() -> void:
	print("=== 분기 통계 시스템 테스트 시작 ===")
	
	# Autoload가 준비될 때까지 대기
	await get_tree().create_timer(0.5).timeout
	
	# BranchStatsManager autoload 확인
	_branch_stats_manager = _get_branch_stats_manager()
	if _branch_stats_manager == null:
		push_error("BranchStatsManager autoload를 찾을 수 없습니다")
		print("=== 테스트 실패: Autoload 미설정 ===")
		return
	
	# 테스트 실행
	await _run_all_tests()
	
	# 결과 출력
	_print_test_results()

## BranchStatsManager 가져오기
func _get_branch_stats_manager() -> Node:
	# Autoload 노드 확인
	if has_node("/root/BranchStatsManager"):
		return get_node("/root/BranchStatsManager")
	return null

## 모든 테스트 실행
func _run_all_tests() -> void:
	_test_branch_stats_manager_initialization()
	await get_tree().create_timer(0.1).timeout
	
	_test_stat_update()
	await get_tree().create_timer(0.1).timeout
	
	_test_stat_increment_decrement()
	await get_tree().create_timer(0.1).timeout
	
	_test_prediction()
	await get_tree().create_timer(0.1).timeout
	
	_test_alternatives()
	await get_tree().create_timer(0.1).timeout
	
	_test_save_load()
	await get_tree().create_timer(0.1).timeout
	
	_test_max_stats_limit()
	await get_tree().create_timer(0.1).timeout
	
	_test_realtime_update()
	await get_tree().create_timer(0.1).timeout

## ========== 테스트 케이스 ==========

## 테스트 1: BranchStatsManager 초기화
func _test_branch_stats_manager_initialization() -> void:
	_log_test_start("BranchStatsManager 초기화")
	
	if _branch_stats_manager == null:
		_fail_test("BranchStatsManager 인스턴스가 null입니다")
		return
	
	var stats = _branch_stats_manager.get_all_stats()
	if stats.is_empty():
		_fail_test("초기 통계가 비어있습니다")
		return
	
	_pass_test()

## 테스트 2: 통계 업데이트
func _test_stat_update() -> void:
	_log_test_start("통계 업데이트")
	
	_branch_stats_manager.update_stats("test_stat", 100)
	var value = _branch_stats_manager.get_stat("test_stat")
	
	if value != 100:
		_fail_test("통계 값이 올바르지 않습니다: 예상 100, 실제 %s" % str(value))
		return
	
	_pass_test()

## 테스트 3: 통계 증가/감소
func _test_stat_increment_decrement() -> void:
	_log_test_start("통계 증가/감소")
	
	_branch_stats_manager.update_stats("test_counter", 50)
	_branch_stats_manager.increment_stat("test_counter", 10)
	var incremented = _branch_stats_manager.get_stat("test_counter")
	
	if incremented != 60:
		_fail_test("증가 후 값이 올바르지 않습니다: 예상 60, 실제 %s" % str(incremented))
		return
	
	_branch_stats_manager.decrement_stat("test_counter", 5)
	var decremented = _branch_stats_manager.get_stat("test_counter")
	
	if decremented != 55:
		_fail_test("감소 후 값이 올바르지 않습니다: 예상 55, 실제 %s" % str(decremented))
		return
	
	_pass_test()

## 테스트 4: 엔딩 예측
func _test_prediction() -> void:
	_log_test_start("엔딩 예측")
	
	# 테스트용 예측 정의 등록
	var test_def = {
		"stats": [
			{"variable": "hero_reputation", "label": "영웅"}
		],
		"predictions": [
			{"based_on": "hero_reputation", "route": "hero_ending", "threshold": 50, "operator": ">"}
		]
	}
	_branch_stats_manager.register_branch_stats_definition("test_prediction", test_def)
	
	# 영웅 루트로 유도
	_branch_stats_manager.update_stats("hero_reputation", 60)
	
	var prediction = _branch_stats_manager.predict_ending()
	if prediction != "hero_ending":
		_fail_test("예측이 올바르지 않습니다: 예상 hero_ending, 실제 %s" % prediction)
		return
	
	var confidence = _branch_stats_manager.get_prediction_confidence()
	if confidence <= 0:
		_fail_test("신뢰도가 0 이하입니다: %f" % confidence)
		return
	
	_pass_test()

## 테스트 5: 대안 루트
func _test_alternatives() -> void:
	_log_test_start("대안 루트")
	
	var alternatives = _branch_stats_manager.get_route_alternatives()
	
	# 대안이 있어야 함
	if alternatives.is_empty():
		_fail_test("대안 루트가 없습니다")
		return
	
	# 각 대안에 필수 필드가 있는지 확인
	for alt in alternatives:
		if not alt.has("route"):
			_fail_test("대안에 route 필드가 없습니다")
			return
		if not alt.has("achievable"):
			_fail_test("대안에 achievable 필드가 없습니다")
			return
	
	_pass_test()

## 테스트 6: 저장/로드
func _test_save_load() -> void:
	_log_test_start("저장/로드")
	
	# 테스트 데이터 설정
	_branch_stats_manager.update_stats("save_test_stat", 123)
	var original_value = _branch_stats_manager.get_stat("save_test_stat")
	
	# 저장
	var save_data = _branch_stats_manager.save_state()
	if not save_data.has("branch_stats"):
		_fail_test("저장 데이터에 branch_stats가 없습니다")
		return
	
	# 리셋
	_branch_stats_manager.reset_stats()
	var reset_value = _branch_stats_manager.get_stat("save_test_stat")
	if reset_value == original_value:
		_fail_test("리셋 후에도 값이 동일합니다")
		return
	
	# 로드
	_branch_stats_manager.load_state(save_data)
	var loaded_value = _branch_stats_manager.get_stat("save_test_stat")
	
	if loaded_value != original_value:
		_fail_test("로드 후 값이 다릅니다: 예상 %s, 실제 %s" % [str(original_value), str(loaded_value)])
		return
	
	_pass_test()

## 테스트 7: 최대 통계 개수 제한
func _test_max_stats_limit() -> void:
	_log_test_start("최대 통계 개수 제한 (최대 10개)")
	
	# 리셋
	_branch_stats_manager.reset_stats()
	
	# 10개 추가 (최대치)
	for i in range(10):
		_branch_stats_manager.update_stats("stat_%d" % i, i)
	
	var tracked = _branch_stats_manager.get_tracked_variables()
	if tracked.size() > 10:
		_fail_test("최대 통계 개수를 초과했습니다: %d" % tracked.size())
		return
	
	_pass_test()

## 테스트 8: 실시간 업데이트
func _test_realtime_update() -> void:
	_log_test_start("실시간 업데이트")
	
	var update_received = false
	
	# 시그널 연결
	_branch_stats_manager.stats_updated.connect(func(stat_id, new_value):
		if stat_id == "realtime_test":
			update_received = true
	)
	
	# 업데이트
	_branch_stats_manager.update_stats("realtime_test", 42)
	
	# 시그널 수신 확인 (약간의 대기)
	await get_tree().create_timer(0.1).timeout
	
	if not update_received:
		_fail_test("실시간 업데이트 시그널을 받지 못했습니다")
		return
	
	_pass_test()

## ========== 유틸리티 ==========

func _log_test_start(test_name: String) -> void:
	print("테스트 시작: %s" % test_name)

func _pass_test() -> void:
	_tests_passed += 1
	_test_results.append("✅ 통과")

func _fail_test(reason: String) -> void:
	_tests_failed += 1
	_test_results.append("❌ 실패: %s" % reason)
	push_error(reason)

func _print_test_results() -> void:
	print("\n=== 테스트 결과 ===")
	for i in range(_test_results.size()):
		print("테스트 %d: %s" % [i + 1, _test_results[i]])
	
	print("\n총계: %d 통과, %d 실패" % [_tests_passed, _tests_failed])
	
	if _tests_failed == 0:
		print("🎉 모든 테스트 통과!")
	else:
		print("⚠️ 일부 테스트 실패")
	
	print("=== 분기 통계 시스템 테스트 완료 ===")
