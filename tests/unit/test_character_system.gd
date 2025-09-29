extends GutTest

# 캐릭터 시스템 기본 테스트 클래스
var character: CharacterBase

func before_each():
    # 각 테스트 전에 실행되는 설정
    character = CharacterBase.new("test_id", "Test Character")

func after_each():
    # 각 테스트 후에 실행되는 정리
    character.free()

func test_character_creation():
    # 캐릭터 생성 테스트
    assert_not_null(character)
    assert_eq(character.get_id(), "test_id")
    assert_eq(character.get_name(), "Test Character")

func test_character_properties():
    # 캐릭터 속성 테스트
    character.set_stat("strength", 10)
    character.set_stat("intelligence", 15)
    
    assert_eq(character.get_stat("strength"), 10)
    assert_eq(character.get_stat("intelligence"), 15)
    assert_null(character.get_stat("non_existent_stat"))

func test_character_state_management():
    # 캐릭터 상태 관리 테스트
    assert_eq(character.get_state(), "idle")
    
    character.set_state("talking")
    assert_eq(character.get_state(), "talking")
    
    character.set_state("walking")
    assert_eq(character.get_state(), "walking")

func test_dialogue_history():
    # 대화 기록 테스트
    assert_eq(character.get_dialogue_history().size(), 0)
    
    character.add_dialogue("Hello!")
    character.add_dialogue("How are you?")
    
    var history = character.get_dialogue_history()
    assert_eq(history.size(), 2)
    assert_eq(history[0].text, "Hello!")
    assert_eq(history[1].text, "How are you?")
