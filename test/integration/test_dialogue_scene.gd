extends GutTest

# 대화 씬 통합 테스트

var dialogue_controller: Node
var character_manager: Node
var test_resources: Dictionary = {
    "background": "res://test/resources/test_background.png",
    "character1": "res://test/resources/test_character1.png",
    "character2": "res://test/resources/test_character2.png",
    "voice1": "res://test/resources/test_voice1.wav",
    "voice2": "res://test/resources/test_voice2.wav"
}
var test_xml: String = "res://test/resources/test_dialogue.xml"

func before_all():
    # 테스트 리소스 생성
    TestUtils.create_dummy_background_image(test_resources.background)
    TestUtils.create_dummy_character_image(test_resources.character1)
    TestUtils.create_dummy_character_image(test_resources.character2)
    TestUtils.create_dummy_audio_file(test_resources.voice1)
    TestUtils.create_dummy_audio_file(test_resources.voice2)
    
    # 테스트 XML 생성
    var xml_content = """
    <?xml version="1.0" encoding="UTF-8"?>
    <scene name="통합_테스트_씬">
        <background path="%s" transition="fade" duration="0.1"/>
        <characters>
            <character id="char1" name="캐릭터1" default_position="left">
                <emotion name="normal" path="%s"/>
                <voice name="greeting" path="%s"/>
            </character>
            <character id="char2" name="캐릭터2" default_position="right">
                <emotion name="normal" path="%s"/>
                <voice name="greeting" path="%s"/>
            </character>
        </characters>
        <dialogue>
            <message speaker="캐릭터1">안녕하세요!</message>
            <message speaker="캐릭터2">반갑습니다!</message>
            <choice text="선택지 테스트">
                <option id="opt1" text="첫 번째 선택지">
                    <message speaker="캐릭터1">첫 번째를 선택하셨네요.</message>
                </option>
                <option id="opt2" text="두 번째 선택지">
                    <message speaker="캐릭터2">두 번째를 선택하셨군요.</message>
                </option>
            </choice>
        </dialogue>
    </scene>
    """ % [
        test_resources.background,
        test_resources.character1,
        test_resources.voice1,
        test_resources.character2,
        test_resources.voice2
    ]
    TestUtils.create_test_xml(test_xml, xml_content)

func after_all():
    # 리소스 정리
    var paths = test_resources.values()
    paths.append(test_xml)
    TestUtils.cleanup_resources(paths)

func before_each():
    # 컨트롤러 설정
    dialogue_controller = preload("res://scripts/dialogue/dialogue_controller.gd").new()
    character_manager = preload("res://scripts/character/character_manager.gd").new()
    
    add_child_autofree(dialogue_controller)
    add_child_autofree(character_manager)
    
    await get_tree().process_frame

func test_scene_loading():
    # 씬 로드 시그널 감지
    watch_signals(dialogue_controller)
    watch_signals(character_manager)
    
    # 캐릭터 생성 테스트
    character_manager.create_character("char1", "캐릭터1", Vector2(100, 300))
    character_manager.create_character("char2", "캐릭터2", Vector2(700, 300))
    
    assert_eq(character_manager.characters.size(), 2, "캐릭터가 올바르게 생성되어야 함")
    assert_true(character_manager.characters.has("char1"), "첫 번째 캐릭터가 존재해야 함")
    assert_true(character_manager.characters.has("char2"), "두 번째 캐릭터가 존재해야 함")

func test_dialogue_sequence():
    # 대화 시퀀스 시그널 감지
    watch_signals(dialogue_controller)
    
    # 대화 시작
    dialogue_controller.start_dialogue([
        {"speaker": "캐릭터1", "text": "안녕하세요!"},
        {"speaker": "캐릭터2", "text": "반갑습니다!"}
    ])
    
    assert_signal_emitted(dialogue_controller, "dialogue_started")
    
    # 첫 번째 대사 확인
    assert_eq(dialogue_controller.current_speaker, "캐릭터1", "첫 번째 화자가 올바름")
    assert_eq(dialogue_controller.current_message, "안녕하세요!", "첫 번째 대사가 올바름")
    
    # 다음 대사로 진행
    dialogue_controller.skip_typing()
    await wait_seconds(0.1)
    
    assert_eq(dialogue_controller.current_speaker, "캐릭터2", "두 번째 화자가 올바름")
    assert_eq(dialogue_controller.current_message, "반갑습니다!", "두 번째 대사가 올바름")
    
    # 대화 완료
    dialogue_controller.skip_typing()
    await wait_seconds(0.1)
    
    assert_signal_emitted(dialogue_controller, "dialogue_completed")

func test_choice_handling():
    # 선택지 시그널 감지
    watch_signals(dialogue_controller)
    
    # 선택지 표시
    var choices = [
        {"id": "opt1", "text": "첫 번째 선택지"},
        {"id": "opt2", "text": "두 번째 선택지"}
    ]
    dialogue_controller.show_choices(choices)
    
    # 선택지 선택
    dialogue_controller.emit_signal("choice_made", "opt1")
    assert_signal_emitted(dialogue_controller, "choice_made", ["opt1"])
    
    # 선택지 제거 확인
    dialogue_controller.clear_choices()
    assert_eq(dialogue_controller.get_node("DialogueUI/ChoicesContainer").get_child_count(), 0,
        "선택지가 제거되어야 함")

func test_character_interactions():
    # 캐릭터 상호작용 테스트
    var char1 = character_manager.get_character("char1")
    var char2 = character_manager.get_character("char2")
    
    # 캐릭터 감정 변경
    char1.change_emotion("normal")
    char2.change_emotion("normal")
    
    # 말하기 상태 동기화
    character_manager.synchronize_speaking("char1")
    assert_true(char1.is_speaking, "첫 번째 캐릭터가 말하는 중이어야 함")
    assert_false(char2.is_speaking, "두 번째 캐릭터는 말하지 않아야 함")
    
    character_manager.stop_all_speaking()
    assert_false(char1.is_speaking, "모든 캐릭터가 말하기를 중지해야 함")
    assert_false(char2.is_speaking, "모든 캐릭터가 말하기를 중지해야 함")

func test_performance():
    # 성능 테스트
    var memory_before = TestUtils.get_memory_usage()
    
    # 대량의 대화 처리
    var messages = []
    for i in range(100):
        messages.append({
            "speaker": "캐릭터" + str(i % 2 + 1),
            "text": "테스트 대화 " + str(i)
        })
    
    var process_time = TestUtils.measure_performance(func():
        dialogue_controller.start_dialogue(messages)
        for i in range(100):
            dialogue_controller.skip_typing()
    )
    
    var memory_after = TestUtils.get_memory_usage()
    var memory_diff = memory_after - memory_before
    
    # 성능 기준 검증
    assert_lt(process_time, 1.0, "대화 처리는 1초 이내여야 함")
    assert_lt(memory_diff, 1024 * 1024, "메모리 사용량이 1MB 이하여야 함")  # 1MB