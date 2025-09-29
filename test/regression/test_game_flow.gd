extends GutTest

# 게임 플로우 회귀 테스트
# 주요 기능의 전체 흐름 테스트

var game_data_manager: Node
var dialogue_controller: Node
var character_manager: Node
var background_controller: Node
var test_resources: Dictionary
var test_save_slot: int = 999  # 테스트용 세이브 슬롯

func before_all():
    _setup_test_resources()

func after_all():
    _cleanup_test_resources()

func before_each():
    _setup_controllers()
    await get_tree().process_frame

func after_each():
    _cleanup_save_data()

# 테스트 리소스 설정
func _setup_test_resources():
    test_resources = {
        "background": "res://test/resources/test_background.png",
        "character1": {
            "normal": "res://test/resources/char1_normal.png",
            "happy": "res://test/resources/char1_happy.png",
            "voice": "res://test/resources/char1_voice.wav"
        },
        "character2": {
            "normal": "res://test/resources/char2_normal.png",
            "sad": "res://test/resources/char2_sad.png",
            "voice": "res://test/resources/char2_voice.wav"
        }
    }
    
    # 리소스 생성
    TestUtils.create_dummy_background_image(test_resources.background)
    
    for char_resources in test_resources.values():
        if char_resources is Dictionary:
            for resource in char_resources.values():
                if resource.ends_with(".png"):
                    TestUtils.create_dummy_character_image(resource)
                elif resource.ends_with(".wav"):
                    TestUtils.create_dummy_audio_file(resource)

# 테스트 리소스 정리
func _cleanup_test_resources():
    var paths = []
    paths.append(test_resources.background)
    for char_resources in test_resources.values():
        if char_resources is Dictionary:
            paths.append_array(char_resources.values())
    TestUtils.cleanup_resources(paths)

# 컨트롤러 설정
func _setup_controllers():
    game_data_manager = preload("res://scripts/game/game_data_manager.gd").new()
    dialogue_controller = preload("res://scripts/dialogue/dialogue_controller.gd").new()
    character_manager = preload("res://scripts/character/character_manager.gd").new()
    background_controller = preload("res://scripts/background/background_controller.gd").new()
    
    add_child_autofree(game_data_manager)
    add_child_autofree(dialogue_controller)
    add_child_autofree(character_manager)
    add_child_autofree(background_controller)

# 세이브 데이터 정리
func _cleanup_save_data():
    var save_path = "user://saves/save_" + str(test_save_slot) + ".json"
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)

# 게임 초기 상태 테스트
func test_initial_state():
    assert_eq(dialogue_controller.current_message, "", "초기 대화 메시지는 비어있어야 함")
    assert_eq(character_manager.characters.size(), 0, "초기 캐릭터 수는 0이어야 함")
    assert_eq(background_controller.current_weather, 0, "초기 날씨는 맑음이어야 함")

# 전체 게임 플로우 테스트
func test_game_flow():
    # 1. 캐릭터 생성 및 설정
    var char1 = character_manager.create_character("char1", "캐릭터1", Vector2(200, 300))
    var char2 = character_manager.create_character("char2", "캐릭터2", Vector2(600, 300))
    
    assert_not_null(char1, "첫 번째 캐릭터가 생성되어야 함")
    assert_not_null(char2, "두 번째 캐릭터가 생성되어야 함")
    
    # 2. 배경 변경
    watch_signals(background_controller)
    background_controller.change_background(test_resources.background, "fade", 0.1)
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "transition_completed")
    
    # 3. 대화 시퀀스 실행
    watch_signals(dialogue_controller)
    dialogue_controller.start_dialogue([
        {"speaker": "캐릭터1", "text": "안녕하세요!"},
        {"speaker": "캐릭터2", "text": "반갑습니다!"}
    ])
    
    assert_signal_emitted(dialogue_controller, "dialogue_started")
    
    # 4. 캐릭터 상호작용
    char1.change_emotion("happy")
    char2.change_emotion("sad")
    
    # 5. 게임 상태 저장
    game_data_manager.set_variable("progress", 1)
    game_data_manager.set_flag("met_character1", true)
    game_data_manager.save_game(test_save_slot)
    
    # 6. 게임 상태 초기화
    game_data_manager.set_variable("progress", 0)
    game_data_manager.set_flag("met_character1", false)
    
    # 7. 게임 상태 로드
    var load_success = game_data_manager.load_game(test_save_slot)
    assert_true(load_success, "게임 데이터가 로드되어야 함")
    assert_eq(game_data_manager.get_variable("progress"), 1, "진행 상태가 복원되어야 함")
    assert_true(game_data_manager.has_flag("met_character1"), "플래그가 복원되어야 함")

# 실적 시스템 테스트
func test_achievements():
    # 실적 정의
    var achievements = {
        "first_dialogue": {
            "title": "첫 대화",
            "description": "첫 번째 대화를 완료했습니다.",
            "icon": "res://icons/first_dialogue.png"
        }
    }
    game_data_manager.define_achievements(achievements)
    
    # 실적 달성
    watch_signals(game_data_manager)
    game_data_manager.unlock_achievement("first_dialogue")
    
    assert_signal_emitted(game_data_manager, "achievement_unlocked", ["first_dialogue"])
    assert_true(game_data_manager.achievements["first_dialogue"].unlocked,
        "실적이 달성 상태로 변경되어야 함")

# 오류 복구 테스트
func test_error_recovery():
    # 잘못된 리소스 경로
    background_controller.change_background("invalid_path")
    assert_eq(background_controller.current_weather, 0, "오류 발생 시 기본 상태를 유지해야 함")
    
    # 존재하지 않는 캐릭터
    character_manager.remove_character("invalid_character")
    assert_eq(character_manager.characters.size(), 0, "오류 발생 시 기존 상태를 유지해야 함")
    
    # 잘못된 세이브 슬롯
    var load_result = game_data_manager.load_game(-1)
    assert_false(load_result, "잘못된 세이브 슬롯 로드는 실패해야 함")

# 성능 테스트
func test_performance_benchmarks():
    var results = {}
    
    # 대화 시스템 성능
    results.dialogue = TestUtils.measure_performance(func():
        for i in range(100):
            dialogue_controller.start_dialogue([
                {"speaker": "테스트", "text": "성능 테스트 " + str(i)}
            ])
            dialogue_controller.skip_typing()
    )
    
    # 캐릭터 시스템 성능
    results.character = TestUtils.measure_performance(func():
        for i in range(10):
            var char = character_manager.create_character(
                "char" + str(i),
                "캐릭터" + str(i),
                Vector2(100 * i, 300)
            )
            char.change_emotion("normal")
            char.change_emotion("happy")
            character_manager.remove_character("char" + str(i))
    )
    
    # 저장/로드 성능
    results.save_load = TestUtils.measure_performance(func():
        for i in range(5):
            game_data_manager.save_game(test_save_slot)
            game_data_manager.load_game(test_save_slot)
    )
    
    # 성능 기준 검증
    assert_lt(results.dialogue, 1.0, "대화 시스템은 1초 이내여야 함")
    assert_lt(results.character, 0.5, "캐릭터 시스템은 0.5초 이내여야 함")
    assert_lt(results.save_load, 0.5, "저장/로드는 0.5초 이내여야 함")