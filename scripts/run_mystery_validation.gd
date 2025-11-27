extends SceneTree
# Mystery Novel 검증 실행 스크립트
# 커맨드라인: godot -s scripts/run_mystery_validation.gd

func _init():
	print("=== Mystery Novel TDD Validation Runner ===")
	run_validation_suite()
	quit()

func run_validation_suite():
	var validator = preload("res://addons/mystery_validator/mystery_scenario_validator.gd").new()
	
	# 검증 완료 시그널 연결
	validator.validation_completed.connect(_on_validation_completed)
	validator.validation_failed.connect(_on_validation_failed)
	
	# 전체 검증 실행
	var success = validator.validate_complete_scenario()
	
	if success:
		print("\n🎉 모든 검증 통과! Mystery Novel이 준비되었습니다.")
		
		# 검증 리포트 생성 및 저장
		var report = validator.generate_validation_report()
		save_report(report)
		
		print("\n📋 검증 리포트가 validation_report.txt에 저장되었습니다.")
	else:
		print("\n⚠️  일부 검증 실패. 위 오류들을 수정해주세요.")
		set_quit_code(1)

func _on_validation_completed(results: Dictionary):
	print("\n✅ 검증 완료 - 모든 항목 통과")

func _on_validation_failed(error: String):
	print("\n❌ 검증 실패: %s" % error)

func save_report(report: String):
	var file = FileAccess.open("validation_report.txt", FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
	else:
		print("⚠️ 리포트 저장 실패")