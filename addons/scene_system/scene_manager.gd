extends Node

class_name SceneManager

signal scene_loaded(scene_name: String)
signal scene_unloaded(scene_name: String)
signal resource_loaded(resource_path: String)

var _current_scene: String = ""
var _loaded_resources: Dictionary = {}
var _scene_cache: Dictionary = {}

# XML 파싱 및 씬 로딩
func load_scene_from_xml(xml_path: String) -> Error:
    var file = FileAccess.open(xml_path, FileAccess.READ)
    if file == null:
        return Error.FAILED
    
    var content = file.get_as_text()
    var parser = XMLParser.new()
    var error = parser.open_buffer(content.to_utf8_buffer())
    
    if error != OK:
        return error
    
    var scene_data = _parse_scene_xml(parser)
    if scene_data.has("name"):
        _current_scene = scene_data.name
        _scene_cache[scene_data.name] = scene_data
        emit_signal("scene_loaded", scene_data.name)
        return OK
    
    return Error.FAILED

# 리소스 관리
func load_resource(path: String) -> Resource:
    if _loaded_resources.has(path):
        return _loaded_resources[path]
    
    var resource = load(path)
    if resource:
        _loaded_resources[path] = resource
        emit_signal("resource_loaded", path)
    
    return resource

func unload_resource(path: String) -> void:
    if _loaded_resources.has(path):
        _loaded_resources.erase(path)

# 씬 관리
func get_current_scene() -> String:
    return _current_scene

func get_scene_data(scene_name: String) -> Dictionary:
    return _scene_cache.get(scene_name, {})

func clear_scene() -> void:
    if _current_scene != "":
        emit_signal("scene_unloaded", _current_scene)
    _current_scene = ""

# 내부 헬퍼 메서드
func _parse_scene_xml(parser: XMLParser) -> Dictionary:
    var scene_data = {}
    
    while parser.read() == OK:
        match parser.get_node_type():
            XMLParser.NODE_ELEMENT:
                var node_name = parser.get_node_name()
                if node_name == "scene":
                    scene_data["name"] = parser.get_named_attribute_value("name")
                    scene_data["objects"] = []
                elif node_name == "object":
                    var obj = {
                        "type": parser.get_named_attribute_value("type"),
                        "id": parser.get_named_attribute_value("id")
                    }
                    scene_data["objects"].append(obj)
    
    return scene_data