extends GutTest

const TEST_XML_DIR := "user://tmp_dialogue_scene_loader"
const TEST_XML_PATH := TEST_XML_DIR + "/test_dialogue_scene_loader.xml"
const TEST_XML_CONTENT := """<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<scene name=\"test_scene\">
    <background type=\"image\" path=\"res://icon.png\" />
    <character id=\"hero\" name=\"Hero\" default_position=\"left\">
        <portrait emotion=\"normal\" path=\"res://icon.png\" />
    </character>
    <message speaker=\"hero\" emotion=\"happy\">Hello!</message>
</scene>
"""

var loader: DialogueSceneLoader
var manager: CharacterManager
var character_root: Node2D
var background_sprite: Sprite2D

func before_each():
    loader = DialogueSceneLoader.new()
    manager = CharacterManager.new()
    character_root = Node2D.new()
    background_sprite = Sprite2D.new()

    add_child(loader)
    add_child(manager)
    add_child(character_root)
    add_child(background_sprite)

    loader.configure_character_system(manager, character_root)
    loader.set_background_target(background_sprite)

    DirAccess.make_dir_recursive_absolute(TEST_XML_DIR)
    var file = FileAccess.open(TEST_XML_PATH, FileAccess.WRITE)
    file.store_string(TEST_XML_CONTENT)
    file = null

func after_each():
    if FileAccess.file_exists(TEST_XML_PATH):
        DirAccess.remove_absolute(TEST_XML_PATH)
    if DirAccess.dir_exists_absolute(TEST_XML_DIR):
        DirAccess.remove_absolute(TEST_XML_DIR)

    if loader:
        loader.queue_free()
    if manager:
        manager.queue_free()
    if character_root:
        character_root.queue_free()
    if background_sprite:
        background_sprite.queue_free()

func test_scene_loading_populates_layers():
    var result = loader.load_scene_from_xml(TEST_XML_PATH)
    assert_eq(result, OK, "XML 씬이 성공적으로 로드되어야 함")

    loader.create_scene_node(background_sprite, character_root)

    assert_not_null(background_sprite.texture, "배경 텍스처가 로드되어야 함")
    assert_eq(character_root.get_child_count(), 1, "캐릭터 노드가 하나 생성되어야 함")
    assert_true(manager.has_character("hero"), "캐릭터 매니저에 hero가 등록되어야 함")

    var character_node = loader.get_character_node("hero")
    assert_not_null(character_node, "캐릭터 노드를 가져올 수 있어야 함")
    assert_eq(character_node.get("character_id"), "hero", "노드에 올바른 캐릭터 ID가 설정되어야 함")

func test_character_state_updates_drive_node_animation():
    loader.load_scene_from_xml(TEST_XML_PATH)
    loader.create_scene_node(background_sprite, character_root)

    var character_node = loader.get_character_node("hero")
    assert_not_null(character_node)

    await get_tree().process_frame

    manager.set_character_state("hero", "talking")

    if character_node.has_method("start_speaking"):
        var speaking_state = character_node.get("is_speaking")
        assert_true(speaking_state, "말하기 상태가 true여야 함")

    await get_tree().process_frame

    manager.set_character_state("hero", "idle")

    if character_node.has_method("stop_speaking"):
        var idle_state = character_node.get("is_speaking")
        assert_false(idle_state, "말하기 상태가 false여야 함")
