extends GutTest

# XML 씬 관리 시스템 기본 테스트 클래스
var scene_manager: SceneManager
var test_scene_xml = """
<?xml version="1.0" encoding="UTF-8"?>
<scene name="test_scene">
    <object type="character" id="char1" />
    <object type="background" id="bg1" />
</scene>
"""

func before_each():
    # 각 테스트 전에 실행되는 설정
    scene_manager = SceneManager.new()
    add_child(scene_manager)
    
    # 테스트용 XML 파일 생성
    var file = FileAccess.open("res://test_scene.xml", FileAccess.WRITE)
    file.store_string(test_scene_xml)
    file = null

func after_each():
    # 각 테스트 후에 실행되는 정리
    scene_manager.free()
    DirAccess.remove_absolute("res://test_scene.xml")

func test_scene_loading_and_parsing():
    # 씬 로딩 및 XML 파싱 테스트
    var result = scene_manager.load_scene_from_xml("res://test_scene.xml")
    assert_eq(result, OK)
    assert_eq(scene_manager.get_current_scene(), "test_scene")
    
    var scene_data = scene_manager.get_scene_data("test_scene")
    assert_not_null(scene_data)
    assert_eq(scene_data.name, "test_scene")
    assert_eq(scene_data.objects.size(), 2)

func test_invalid_scene_loading():
    # 잘못된 씬 로딩 테스트
    var result = scene_manager.load_scene_from_xml("non_existent.xml")
    assert_eq(result, Error.FAILED)

func test_resource_loading():
    # 리소스 로딩 테스트
    var resource_loaded_signal_emitted = false
    scene_manager.connect("resource_loaded", func(path): resource_loaded_signal_emitted = true)
    
    # 리소스 로딩 테스트 (리소스 경로는 프로젝트에 맞게 수정 필요)
    var resource = scene_manager.load_resource("res://icon.png")
    assert_not_null(resource)
    assert_true(resource_loaded_signal_emitted)

func test_scene_signals():
    # 씬 관련 시그널 테스트
    var scene_loaded_signal_emitted = false
    var scene_unloaded_signal_emitted = false
    
    scene_manager.connect("scene_loaded", func(name): scene_loaded_signal_emitted = true)
    scene_manager.connect("scene_unloaded", func(name): scene_unloaded_signal_emitted = true)
    
    scene_manager.load_scene_from_xml("res://test_scene.xml")
    assert_true(scene_loaded_signal_emitted)
    
    scene_manager.clear_scene()
    assert_true(scene_unloaded_signal_emitted)
