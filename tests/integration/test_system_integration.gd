extends GutTest

# 시스템 통합 테스트 클래스
var character_manager: CharacterManager
var scene_loader: SceneLoader

# 테스트용 XML 데이터
var test_scene_xml = """
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<scene name=\"test_scene\">
    <object type=\"character\" id=\"test_char1\" name=\"Character 1\" />
    <object type=\"character\" id=\"test_char2\" name=\"Character 2\" />
    <object type=\"background\" id=\"bg1\" path=\"res://background.png\" />
</scene>
"""

func before_each():
    # 각 테스트 전에 실행되는 설정
    character_manager = CharacterManager.new()
    scene_loader = SceneLoader.new()
    add_child(character_manager)
    add_child(scene_loader)
    
    # 테스트용 XML 파일 생성
    var file = FileAccess.open("res://test_integration.xml", FileAccess.WRITE)
    file.store_string(test_scene_xml)
    file = null

func after_each():
    # 각 테스트 후에 실행되는 정리
    character_manager.free()
    scene_loader.free()
    DirAccess.remove_absolute("res://test_integration.xml")

func test_character_scene_interaction():
    # 캐릭터와 씬 상호작용 테스트
    var scene_loaded = false
    var char_objects = []
    
    scene_loader.connect("scene_loaded", func(name, data): scene_loaded = true)
    scene_loader.connect("object_created", func(obj):
        if obj.type == "character":
            char_objects.append(obj)
            character_manager.add_character(obj.id, obj.name)
    )
    
    # 씬 로딩
    var result = scene_loader.load_scene_from_xml("res://test_integration.xml")
    assert_eq(result, OK)
    assert_true(scene_loaded)
    
    # 캐릭터 객체 확인
    assert_eq(char_objects.size(), 2)
    var char1 = character_manager.get_character("test_char1")
    var char2 = character_manager.get_character("test_char2")
    assert_not_null(char1)
    assert_not_null(char2)

func test_scene_transition():
    # 씬 전환 테스트
    var transitions = []
    scene_loader.connect("scene_loaded", func(name, data): transitions.append(["load", name]))
    scene_loader.connect("scene_unloaded", func(name): transitions.append(["unload", name]))
    
    # 첫 번째 씬 로딩
    scene_loader.load_scene_from_xml("res://test_integration.xml")
    assert_eq(transitions.size(), 1)
    assert_eq(transitions[0], ["load", "test_scene"])
    
    # 씬 언로드
    scene_loader.unload_scene("test_scene")
    assert_eq(transitions.size(), 2)
    assert_eq(transitions[1], ["unload", "test_scene"])

func test_character_state_synchronization():
    # 캐릭터 상태 동기화 테스트
    scene_loader.load_scene_from_xml("res://test_integration.xml")
    
    var state_changes = []
    character_manager.connect("character_state_changed",
        func(character, new_state): state_changes.append([character.get_id(), new_state]))
    
    character_manager.set_character_state("test_char1", "talking")
    character_manager.set_character_state("test_char2", "listening")
    
    assert_eq(state_changes.size(), 2)
    assert_eq(state_changes[0], ["test_char1", "talking"])
    assert_eq(state_changes[1], ["test_char2", "listening"])
