@tool
extends EditorPlugin

# Mystery Novel Validator V2 플러그인

var validator: Node
var dock_instance: Control

func _enter_tree():
	# 검증 시스템 초기화
	validator = preload("res://addons/mystery_validator_v2/integration_validator.gd").new()
	add_child(validator)
	
	# 에디터 독 추가 (선택사항)
	# dock_instance = preload("res://addons/mystery_validator_v2/validator_dock.tscn").instantiate()
	# add_control_to_dock(DOCK_SLOT_LEFT_UL, dock_instance)
	
	# 메뉴에 검증 옵션 추가
	add_tool_menu_item("Mystery Novel 전체 검증", _run_full_validation)
	add_tool_menu_item("Mystery Novel 빠른 검증", _run_quick_validation)
	
	print("Mystery Novel Validator V2 플러그인이 활성화되었습니다.")

func _exit_tree():
	# 정리
	if validator:
		validator.queue_free()
	
	# if dock_instance:
	#     remove_control_from_docks(dock_instance)
	
	remove_tool_menu_item("Mystery Novel 전체 검증")
	remove_tool_menu_item("Mystery Novel 빠른 검증")
	
	print("Mystery Novel Validator V2 플러그인이 비활성화되었습니다.")

func _run_full_validation():
	"""전체 검증 실행"""
	
	print("Mystery Novel 전체 검증을 시작합니다...")
	
	if validator:
		validator.validation_progress.connect(_on_validation_progress)
		validator.validation_completed.connect(_on_validation_completed)
		
		var result = await validator.validate_complete_system()
		validator.print_validation_summary()
		validator.save_validation_report("user://mystery_validation_full.json")
	else:
		push_error("검증 시스템을 초기화할 수 없습니다.")

func _run_quick_validation():
	"""빠른 검증 실행 (핵심 요소만)"""
	
	print("Mystery Novel 빠른 검증을 시작합니다...")
	
	# 간단한 XML 파일 존재 확인
	var xml_files = [
		"res://mystery_novel/projects/junho_detective_series/scenarios/episode02/cafe_mystery_scenario.xml",
		"res://mystery_novel/projects/junho_detective_series/scenes/dialogue/episode02/cafe_discovery.xml",
		"res://mystery_novel/projects/junho_detective_series/scenes/dialogue/episode02/meet_park_youngsu.xml"
	]
	
	var valid_count = 0
	for xml_file in xml_files:
		if FileAccess.file_exists(xml_file):
			valid_count += 1
			print("✓ ", xml_file)
		else:
			print("✗ ", xml_file)
	
	print("빠른 검증 완료: ", valid_count, "/", xml_files.size(), " 파일 유효")

func _on_validation_progress(current_step: String, progress: float):
	"""검증 진행 상황 업데이트"""
	print("검증 진행: ", current_step, " (", int(progress * 100), "%)")

func _on_validation_completed(success: bool, report: Dictionary):
	"""검증 완료 처리"""
	var status = "성공" if success else "실패"
	print("Mystery Novel 검증 ", status, ": ", report.overall_status)
	
	# 에디터에 결과 표시
	if success:
		print_rich("[color=green]✓ 전체 검증이 성공적으로 완료되었습니다![/color]")
	else:
		print_rich("[color=red]✗ 검증 중 문제가 발견되었습니다. 리포트를 확인하세요.[/color]")