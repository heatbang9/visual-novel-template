@tool
extends Node

class_name DialogueSceneLoader

signal dialogue_started(scene_name: String)
signal dialogue_ended(scene_name: String)
signal choice_made(option_id: int)

@export var character_scene: PackedScene = preload("res://scenes/character/character.tscn")

var current_scene_data: Dictionary = {}
var current_message_index: int = 0
var characters: Dictionary = {}
var character_manager: CharacterManager = null
var character_parent: Node = null
var background_target: Sprite2D = null
var _dialogue_finished: bool = false

const DEFAULT_POSITIONS := {
    "far_left": Vector2(160, 600),
    "left": Vector2(320, 600),
    "center": Vector2(640, 600),
    "right": Vector2(960, 600),
    "far_right": Vector2(1120, 600)
}

func _exit_tree() -> void:
    _disconnect_character_manager()

func configure_character_system(manager: CharacterManager, parent: Node = null) -> void:
    _disconnect_character_manager()
    character_manager = manager
    character_parent = parent

    if character_manager:
        if not character_manager.character_state_changed.is_connected(_on_character_state_changed):
            character_manager.character_state_changed.connect(_on_character_state_changed)
        if not character_manager.character_removed.is_connected(_on_character_removed):
            character_manager.character_removed.connect(_on_character_removed)

func set_character_parent(parent: Node) -> void:
    character_parent = parent

func set_background_target(sprite: Sprite2D) -> void:
    background_target = sprite

func load_scene_from_xml(xml_path: String) -> Error:
    if not FileAccess.file_exists(xml_path):
        push_error("Scene file not found: " + xml_path)
        return Error.FAILED

    _clear_character_nodes()
    if character_manager:
        character_manager.clear_characters()
    current_message_index = 0
    _dialogue_finished = false
    current_scene_data = {
        "name": "",
        "characters": {},
        "dialogue": [],
        "background": {}
    }

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
    
    var scene_data = _parse_scene_xml(parser)
    if scene_data.has("name") and not scene_data.name.is_empty():
        current_scene_data = scene_data
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
    var current_character_id := ""

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
                        current_character_id = char_data.id
                        scene_data.characters[char_data.id] = char_data

                    "portrait":
                        var emotion = "normal"
                        if parser.has_attribute("emotion"):
                            emotion = parser.get_named_attribute_value("emotion")

                        var portrait_path = parser.get_named_attribute_value("path")
                        if current_character_id != "" and not portrait_path.is_empty():
                            scene_data.characters[current_character_id].portraits[emotion] = {
                                "path": portrait_path
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

            XMLParser.NODE_ELEMENT_END:
                var end_name = parser.get_node_name()
                if end_name == "character":
                    current_character_id = ""

    return scene_data

# 씬을 Godot 노드로 변환
func create_scene_node(background_override: Sprite2D = null, character_parent_override: Node = null) -> Node:
    var scene_root = Node.new()
    scene_root.name = current_scene_data.name

    _clear_character_nodes()

    if background_override:
        background_target = background_override

    var background_texture: Texture2D = null
    if current_scene_data.background.has("path") and not current_scene_data.background.path.is_empty():
        background_texture = load(current_scene_data.background.path)

    if background_target:
        background_target.texture = background_texture
    else:
        var background = Sprite2D.new()
        background.name = "Background"
        background.texture = background_texture
        scene_root.add_child(background)

    if character_parent_override:
        character_parent = character_parent_override

    var char_container: Node2D
    if character_parent:
        for child in character_parent.get_children():
            child.queue_free()
        char_container = character_parent
    else:
        char_container = Node2D.new()
        char_container.name = "Characters"
        scene_root.add_child(char_container)

    characters.clear()

    for char_id in current_scene_data.characters:
        var char_data = current_scene_data.characters[char_id]
        var char_node = _instantiate_character_node(char_data)
        char_container.add_child(char_node)
        characters[char_id] = char_node

    return scene_root

func get_next_dialogue() -> Dictionary:
    if _dialogue_finished or not current_scene_data.has("dialogue"):
        return {}

    if current_message_index >= len(current_scene_data.dialogue):
        _dialogue_finished = true
        if current_scene_data.has("name"):
            emit_signal("dialogue_ended", current_scene_data.name)
        return {}

    var dialogue = current_scene_data.dialogue[current_message_index]
    current_message_index += 1
    return dialogue

func get_character_node(character_id: String) -> Node:
    return characters.get(character_id)

func _instantiate_character_node(char_data: Dictionary) -> Node2D:
    var node: Node2D
    if character_scene:
        node = character_scene.instantiate()
    else:
        node = Node2D.new()

    var char_id = char_data.get("id", "")
    var char_name = char_data.get("name", char_id)
    var default_pos = _resolve_position(char_data.get("position", "center"))

    node.name = char_id
    node.position = default_pos
    node.set("character_id", char_id)
    node.set("character_name", char_name)
    node.set("default_position", default_pos)

    var portraits: Dictionary = char_data.get("portraits", {})
    if portraits and node.has_method("load_emotion"):
        for emotion in portraits.keys():
            var portrait = portraits[emotion]
            var path = portrait.get("path", "")
            if path.is_empty():
                continue
            node.load_emotion(emotion, path)

        var first_emotion = portraits.keys()[0]
        if node.has_method("change_emotion"):
            node.change_emotion(first_emotion, 0.0)

    if character_manager and not char_id.is_empty():
        character_manager.add_character(char_id, char_name)

    return node

func _resolve_position(position_label: String) -> Vector2:
    var key = position_label.to_lower()
    if DEFAULT_POSITIONS.has(key):
        return DEFAULT_POSITIONS[key]

    var parts = position_label.split(",")
    if parts.size() == 2:
        return Vector2(parts[0].to_float(), parts[1].to_float())

    return DEFAULT_POSITIONS["center"]

func _clear_character_nodes() -> void:
    for node in characters.values():
        if is_instance_valid(node):
            node.queue_free()
    characters.clear()

    if character_parent:
        for child in character_parent.get_children():
            child.queue_free()

func _disconnect_character_manager() -> void:
    if character_manager:
        if character_manager.character_state_changed.is_connected(_on_character_state_changed):
            character_manager.character_state_changed.disconnect(_on_character_state_changed)
        if character_manager.character_removed.is_connected(_on_character_removed):
            character_manager.character_removed.disconnect(_on_character_removed)
    character_manager = null

func _on_character_state_changed(character: CharacterBase, new_state: String) -> void:
    var node = characters.get(character.get_id())
    if node == null or not is_instance_valid(node):
        return

    match new_state:
        "talking":
            if node.has_method("start_speaking"):
                node.start_speaking()
        "idle":
            if node.has_method("stop_speaking"):
                node.stop_speaking()
        "hidden":
            if node.has_method("disappear"):
                node.disappear()
        "visible":
            if node.has_method("appear"):
                node.appear()

func _on_character_removed(character_id: String) -> void:
    var node = characters.get(character_id)
    if node and is_instance_valid(node):
        node.queue_free()
    characters.erase(character_id)
