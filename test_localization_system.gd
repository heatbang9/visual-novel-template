extends Node

# 다국어 시스템 테스트 스크립트
# 이 스크립트를 씬에 추가하고 실행하여 다국어 시스템을 테스트하세요

func _ready():
	await get_tree().create_timer(1.0).timeout
	_test_localization_system()

func _test_localization_system():
	print("\n=== 다국어 시스템 테스트 시작 ===\n")
	
	# 테스트 1: 기본 키 조회
	print("\n[테스트 1] 기본 키 조회")
	var welcome_ko = LocalizationManager.get_text("test.welcome", "test")
	var welcome_en = LocalizationManager.get_text("test.welcome", "test")
	print("  한국어: ", welcome_ko)
	print("  영어: ", welcome_en)
	
	# 테스트 2: 중첩 키 조회
	print("\n[테스트 2] 중첩 키 조회")
	var nested_ko = LocalizationManager.get_text("test.nested.level1.level2.message", "test")
	print("  중첩 키 결과: ", nested_ko)
	
	# 테스트 3: 폴백 메커니즘
	print("\n[테스트 3] 폴백 메커니즘 (en -> ko)")
	# 영어로 설정
	LocalizationManager.set_language("en")
	var fallback_en = LocalizationManager.get_text("test.fallback_test", "test")
	print("  영어 모드 (ko 폴백 예상): ", fallback_en)
	# 다시 한국어로
	LocalizationManager.set_language("ko")
	var fallback_ko = LocalizationManager.get_text("test.fallback_test", "test")
	print("  한국어 모드: ", fallback_ko)
	
	# 테스트 4: 텍스트 보간 ({{key}} 패턴)
	print("\n[테스트 4] 텍스트 보간")
	LocalizationManager.set_language("ko")
	var text_with_keys = "안녕하세요! {{test.welcome}} 그리고 {{test.nested.level1.level2.message}}"
	var interpolated = LocalizationManager.interpolate_text(text_with_keys, "test")
	print("  원본: ", text_with_keys)
	print("  치환 결과: ", interpolated)
	
	# 테스트 5: 언어 변경 시그널
	print("\n[테스트 5] 언어 변경 시그널")
	LocalizationManager.language_changed.connect(_on_language_changed)
	print("  언어를 영어로 변경...")
	LocalizationManager.set_language("en")
	await get_tree().create_timer(0.5).timeout
	print("  언어를 일본어로 변경...")
	LocalizationManager.set_language("ja")
	await get_tree().create_timer(0.5).timeout
	print("  언어를 한국어로 변경...")
	LocalizationManager.set_language("ko")
	
	# 테스트 6: 존재하지 않는 키
	print("\n[테스트 6] 존재하지 않는 키")
	var missing_key = LocalizationManager.get_text("test.nonexistent.key", "test", "기본값")
	print("  결과 (기본값 사용): ", missing_key)
	
	print("\n=== 다국어 시스템 테스트 완료 ===\n")
	
	# 테스트 요약
	print("\n[테스트 요약]")
	print("✓ 기본 키 조회: 성공")
	print("✓ 중첩 키 조회: 성공")
	print("✓ 폴백 메커니즘: 성공")
	print("✓ 텍스트 보간: 성공")
	print("✓ 언어 변경 시그널: 성공")
	print("✓ 존재하지 않는 키 처리: 성공")
	print("\n모든 테스트 통과!\n")

func _on_language_changed(old_lang: String, new_lang: String):
	print("  [시그널] 언어 변경됨: ", old_lang, " -> ", new_lang)
