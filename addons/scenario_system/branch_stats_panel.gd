extends Control

## 분기 통계 표시 패널
## 플레이어의 선택에 따른 분기 통계와 엔딩 예측을 시각화

class_name BranchStatsPanel

## 노드 참조
@onready var stats_container: VBoxContainer = $StatsContainer
@onready var prediction_container: VBoxContainer = $PredictionContainer
@onready var alternatives_container: VBoxContainer = $AlternativesContainer
@onready var progress_bars_container: VBoxContainer = $ProgressBarsContainer
@onready var debug_label: Label = $DebugLabel

## 설정
@export var show_prediction: bool = true
@export var show_alternatives: bool = true
@export var show_progress_bars: bool = true
@export var debug_mode: bool = false

## 통계 바 프리팹 (동적 생성)
var stat_bar_scene: PackedScene

## 진행 상황 바 프리팹 (동적 생성)
var progress_bar_scene: PackedScene

## 현재 표시 중인 통계
var _displayed_stats: Dictionary = {}

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	
	if debug_mode:
		_show_debug_info()

## UI 초기화
func _setup_ui() -> void:
	# 컨테이너들 생성
	if not stats_container:
		stats_container = VBoxContainer.new()
		stats_container.name = "StatsContainer"
		add_child(stats_container)
	
	if not prediction_container:
		prediction_container = VBoxContainer.new()
		prediction_container.name = "PredictionContainer"
		add_child(prediction_container)
	
	if not alternatives_container:
		alternatives_container = VBoxContainer.new()
		alternatives_container.name = "AlternativesContainer"
		add_child(alternatives_container)
	
	if not progress_bars_container:
		progress_bars_container = VBoxContainer.new()
		progress_bars_container.name = "ProgressBarsContainer"
		add_child(progress_bars_container)
	
	if not debug_label:
		debug_label = Label.new()
		debug_label.name = "DebugLabel"
		debug_label.visible = debug_mode
		add_child(debug_label)
	
	# 스타일 적용
	_apply_style()

## 스타일 적용
func _apply_style() -> void:
	# 패널 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	panel_style.border_color = Color(0.3, 0.3, 0.4)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(10)
	
	add_theme_stylebox_override("panel", panel_style)

## 시그널 연결
func _connect_signals() -> void:
	# BranchStatsManager 시그널 연결
	var manager = _get_branch_stats_manager()
	if manager:
		if manager.has_signal("stats_updated"):
			manager.stats_updated.connect(_on_stats_updated)
		if manager.has_signal("route_prediction_changed"):
			manager.route_prediction_changed.connect(_on_route_prediction_changed)
		if manager.has_signal("route_alternative_discovered"):
			manager.route_alternative_discovered.connect(_on_route_alternative_discovered)

## BranchStatsManager 가져오기
func _get_branch_stats_manager() -> Node:
	if has_node("/root/BranchStatsManager"):
		return get_node("/root/BranchStatsManager")
	
	# 싱글톤 메서드로 접근
	if ClassDB.class_exists("BranchStatsManager"):
		return callv("BranchStatsManager.get_instance", [])
	
	# 직접 접근
	var script = load("res://addons/scenario_system/branch_stats_manager.gd")
	if script:
		return script.get_instance()
	
	return null

## 통계 업데이트
func _on_stats_updated(stat_id: String, new_value: Variant) -> void:
	update_display()
	
	if debug_mode:
		_show_debug_info("Stats updated: %s = %s" % [stat_id, str(new_value)])

## 루트 예측 변경
func _on_route_prediction_changed(predicted_route: String, confidence: float) -> void:
	update_prediction_display(predicted_route, confidence)
	
	if debug_mode:
		_show_debug_info("Route prediction changed: %s (%.1f%%)" % [predicted_route, confidence * 100])

## 루트 대안 발견
func _on_route_alternative_discovered(alternative_route: String, requirements: Dictionary) -> void:
	update_alternatives_display()
	
	if debug_mode:
		_show_debug_info("Route alternative discovered: %s" % alternative_route)

## ========== 표시 업데이트 ==========

## 전체 표시 업데이트
func update_display() -> void:
	_clear_containers()
	
	var manager = _get_branch_stats_manager()
	if not manager:
		return
	
	# 통계 표시
	var all_stats = manager.get_all_stats()
	_display_stats(all_stats)
	
	# 예측 표시
	if show_prediction:
		var prediction = manager.get_predicted_route()
		var confidence = manager.get_prediction_confidence()
		update_prediction_display(prediction, confidence)
	
	# 진행 상황 표시
	if show_progress_bars:
		var analysis = manager.analyze_branch_stats()
		_display_progress_bars(analysis.get("route_progress", {}))
	
	# 대안 표시
	if show_alternatives:
		update_alternatives_display()

## 통계 표시
func _display_stats(stats: Dictionary) -> void:
	for variable in stats:
		var value = stats[variable]
		
		# 레이블 생성
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = "%s: %s" % [variable, str(value)]
		label.add_theme_color_override("font_color", Color.WHITE)
		hbox.add_child(label)
		
		stats_container.add_child(hbox)
		_displayed_stats[variable] = hbox

## 예측 표시 업데이트
func update_prediction_display(predicted_route: String, confidence: float) -> void:
	_clear_container(prediction_container)
	
	# 제목
	var title = Label.new()
	title.text = "예상 엔딩"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.YELLOW)
	prediction_container.add_child(title)
	
	# 예측 루트
	var route_label = Label.new()
	route_label.text = predicted_route
	route_label.add_theme_font_size_override("font_size", 14)
	route_label.add_theme_color_override("font_color", _get_prediction_color(confidence))
	prediction_container.add_child(route_label)
	
	# 신뢰도
	var confidence_label = Label.new()
	confidence_label.text = "확률: %.1f%%" % (confidence * 100)
	confidence_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	prediction_container.add_child(confidence_label)
	
	# 신뢰도 바
	var confidence_bar = ProgressBar.new()
	confidence_bar.value = confidence * 100
	confidence_bar.max_value = 100
	confidence_bar.show_percentage = false
	prediction_container.add_child(confidence_bar)

## 예측 색상 가져오기
func _get_prediction_color(confidence: float) -> Color:
	if confidence >= 0.8:
		return Color.GREEN
	elif confidence >= 0.5:
		return Color.YELLOW
	else:
		return Color.RED

## 진행 상황 바 표시
func _display_progress_bars(route_progress: Dictionary) -> void:
	_clear_container(progress_bars_container)
	
	if route_progress.is_empty():
		return
	
	# 제목
	var title = Label.new()
	title.text = "루트 진행 상황"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color.CYAN)
	progress_bars_container.add_child(title)
	
	# 각 루트별 진행 상황
	for route in route_progress:
		var progress_data = route_progress[route]
		
		var vbox = VBoxContainer.new()
		
		# 루트 이름
		var route_label = Label.new()
		route_label.text = route
		route_label.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(route_label)
		
		# 진행 바
		var progress_bar = ProgressBar.new()
		progress_bar.value = progress_data.get("percentage", 0)
		progress_bar.max_value = 100
		progress_bar.show_percentage = true
		vbox.add_child(progress_bar)
		
		# 현재/목표
		var detail_label = Label.new()
		detail_label.text = "%d / %d" % [progress_data.get("current", 0), progress_data.get("required", 0)]
		detail_label.add_theme_font_size_override("font_size", 10)
		detail_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		vbox.add_child(detail_label)
		
		progress_bars_container.add_child(vbox)

## 대안 표시 업데이트
func update_alternatives_display() -> void:
	_clear_container(alternatives_container)
	
	var manager = _get_branch_stats_manager()
	if not manager:
		return
	
	var alternatives = manager.get_route_alternatives()
	if alternatives.is_empty():
		return
	
	# 제목
	var title = Label.new()
	title.text = "가능한 다른 엔딩"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color.MAGENTA)
	alternatives_container.add_child(title)
	
	# 각 대안 표시
	for alt in alternatives:
		var vbox = VBoxContainer.new()
		
		# 루트 이름
		var route_label = Label.new()
		route_label.text = alt.get("route", "")
		route_label.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(route_label)
		
		# 요구사항
		var req_label = Label.new()
		req_label.text = "%s %s %d (현재: %d)" % [
			alt.get("based_on", ""),
			alt.get("operator", ">"),
			alt.get("threshold", 0),
			alt.get("current_value", 0)
		]
		req_label.add_theme_font_size_override("font_size", 10)
		req_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		vbox.add_child(req_label)
		
		# 달성 가능 여부
		var achievable_label = Label.new()
		achievable_label.text = "달성 가능" if alt.get("achievable", false) else "달성 불가"
		achievable_label.add_theme_color_override(
			"font_color",
			Color.GREEN if alt.get("achievable", false) else Color.RED
		)
		vbox.add_child(achievable_label)
		
		alternatives_container.add_child(vbox)

## ========== 유틸리티 ==========

## 컨테이너 클리어
func _clear_container(container: Node) -> void:
	if not container:
		return
	
	for child in container.get_children():
		child.queue_free()

## 모든 컨테이너 클리어
func _clear_containers() -> void:
	_clear_container(stats_container)
	_clear_container(prediction_container)
	_clear_container(alternatives_container)
	_clear_container(progress_bars_container)
	_displayed_stats.clear()

## 디버그 정보 표시
func _show_debug_info(message: String = "") -> void:
	if not debug_label:
		return
	
	var manager = _get_branch_stats_manager()
	if not manager:
		debug_label.text = "BranchStatsManager not found"
		return
	
	var info = "=== Debug Info ===\n"
	if not message.is_empty():
		info += message + "\n"
	
	info += "Tracked Variables: %s\n" % str(manager.get_tracked_variables())
	info += "Current Stats: %s\n" % str(manager.get_all_stats())
	info += "Predicted Route: %s (%.1f%%)\n" % [manager.get_predicted_route(), manager.get_prediction_confidence() * 100]
	
	debug_label.text = info
	debug_label.visible = debug_mode

## ========== 설정 ==========

## 디버그 모드 설정
func set_debug_mode(enabled: bool) -> void:
	debug_mode = enabled
	if debug_label:
		debug_label.visible = enabled
		if enabled:
			_show_debug_info()

## 표시 설정
func set_display_options(show_pred: bool, show_alts: bool, show_progress: bool) -> void:
	show_prediction = show_pred
	show_alternatives = show_alts
	show_progress_bars = show_progress
	update_display()

## ========== 토글 ==========

## 패널 토글
func toggle_panel() -> void:
	visible = not visible
	if visible:
		update_display()

## 통계 토글
func toggle_stats() -> void:
	stats_container.visible = not stats_container.visible

## 예측 토글
func toggle_prediction() -> void:
	prediction_container.visible = not prediction_container.visible

## 대안 토글
func toggle_alternatives() -> void:
	alternatives_container.visible = not alternatives_container.visible

## 진행 상황 토글
func toggle_progress() -> void:
	progress_bars_container.visible = not progress_bars_container.visible
