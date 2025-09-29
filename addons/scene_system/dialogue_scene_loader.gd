@tool
extends Node

class_name DialogueSceneLoader

signal dialogue_started(scene_name: String)
signal dialogue_ended(scene_name: String)
signal choice_made(option_id: int)

var current_scene_data: Dictionary = {}
var current_message_index: int = 0
var characters: Dictionary = {}

func load_scene_from_xml(xml_path: String) -> Error:
    if not FileAccess.file_exists(xml_path):
        push_error("Scene file not found: " + xml_path)
        return Error.FAILED
    
    var file = FileAccess.open(xml_path, FileAccess.READ)
    if not file:
        push_error("Failed to open scene file: " + xml_path)
        return Error.FAILED
    
    var content = file.get_as_text()
    var parser = XMLParser.new()
    var error = parser.open_buffer(content.to_utf8_buffer())
    
    if error != OK:
        push_error("Failed to parse XML: " + xml_path)
        return error
    
    current_scene_data = _parse_scene_xml(parser)
    if current_scene_data.has("name"):
        emit_signal("dialogue_started", current_scene_data.name)
        return OK
    
    return Error.FAILED

func _parse_scene_xml(parser: XMLParser) -> Dictionary:
    var scene_data = {
        "name": "",
        "characters": {},
        "dialogue": [],
        "background": {}
    }
    
    while parser.read() == OK:
        match parser.get_node_type():
            XMLParser.NODE_ELEMENT:
                var node_name = parser.get_node_name()
                
                match node_name:
                    "scene":
                        scene_data.name = parser.get_named_attribute_value("name")
                    
                    "background":
                        scene_data.background = {
                            "type": parser.get_named_attribute_value("type"),
                            "path": parser.get_named_attribute_value("path")
                        }
                    
                    "character":
                        var char_data = {
                            "id": parser.get_named_attribute_value("id"),
                            "name": parser.get_named_attribute_value("name"),
                            "position": parser.get_named_attribute_value("default_position"),
                            "portraits": {}
                        }
                        scene_data.characters[char_data.id] = char_data
                    
                    "portrait":
                        var char_id = scene_data.characters.keys()[-1]
                        scene_data.characters[char_id].portraits["normal"] = {
                            "path": parser.get_named_attribute_value("path")
                        }
                    
                    "message":
                        # 메시지 속성들 읽기
                        var speaker = parser.get_named_attribute_value("speaker")
                        var emotion = parser.get_named_attribute_value("emotion") if parser.has_attribute("emotion") else "normal"
                        var message = {
                            "type": "message",
                            "speaker": speaker,
                            "emotion": emotion,
                            "text": ""
                        }
                        # 텍스트 내용 읽기
                        if parser.read() == OK:
                            if parser.get_node_type() == XMLParser.NODE_TEXT:
                                message.text = parser.get_node_data().strip_edges()
                        scene_data.dialogue.append(message)
                    
                    "choice":
                        var choice = {
                            "type": "choice",
                            "text": parser.get_named_attribute_value("text"),
                            "options": []
                        }
                        scene_data.dialogue.append(choice)
                    
                    "option":
                        var option = {
                            "text": parser.get_named_attribute_value("text"),
                            "messages": []
                        }
                        var choice = scene_data.dialogue[-1]
                        if choice.type == "choice":
                            choice.options.append(option)
    
    return scene_data

# 씬을 Godot 노드로 변환
func create_scene_node() -> Node:
    var scene_root = Node.new()
    scene_root.name = current_scene_data.name
    
    # 배경 추가
    var background = Sprite2D.new()
    background.name = "Background"
    if current_scene_data.background.has("path"):
        var texture = load(current_scene_data.background.path)
        if texture:
            background.texture = texture
    scene_root.add_child(background)
    
    # 캐릭터 컨테이너 추가
    var char_container = Node2D.new()
    char_container.name = "Characters"
    scene_root.add_child(char_container)
    
    # 캐릭터들 추가
    for char_id in current_scene_data.characters:
        var char_data = current_scene_data.characters[char_id]
        var char_sprite = Sprite2D.new()
        char_sprite.name = char_id
        
        # 위치 설정
        match char_data.position:
            "left":
                char_sprite.position.x = 300
            "right":
                char_sprite.position.x = 980
            _:
                char_sprite.position.x = 640
        
        char_sprite.position.y = 600
        
        # 초기 포트레이트 설정
        if char_data.portraits.has("normal"):
            var texture = load(char_data.portraits.normal.path)
            if texture:
                char_sprite.texture = texture
        
        char_container.add_child(char_sprite)
        characters[char_id] = char_sprite
    
    return scene_root

func get_next_dialogue() -> Dictionary:
    if current_message_index >= len(current_scene_data.dialogue):
        return {}
    
    var dialogue = current_scene_data.dialogue[current_message_index]
    current_message_index += 1
    return dialogue