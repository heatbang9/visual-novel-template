extends Node

class_name SceneLoader

signal scene_loaded(scene_name: String, scene_data: Dictionary)
signal scene_unloaded(scene_name: String)
signal object_created(object_data: Dictionary)
signal object_removed(object_id: String)

# 씬 데이터 캐시
var _loaded_scenes: Dictionary = {}
var _current_scene: String = ""

# XML 씬 로딩
func load_scene_from_xml(file_path: String) -> Error:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("Failed to open scene file: " + file_path)
        return Error.FAILED
    
    var content = file.get_as_text()
    var parser = XMLParser.new()
    var error = parser.open_buffer(content.to_utf8_buffer())
    
    if error != OK:
        push_error("Failed to parse XML: " + file_path)
        return error
    
    var scene_data = _parse_scene_xml(parser)
    if not scene_data.has("name"):
        push_error("Invalid scene format: missing name attribute")
        return Error.FAILED
    
    _current_scene = scene_data.name
    _loaded_scenes[scene_data.name] = scene_data
    emit_signal("scene_loaded", scene_data.name, scene_data)
    
    return OK

# XML 파싱 및 객체 생성
func _parse_scene_xml(parser: XMLParser) -> Dictionary:
    var scene_data = {
        "objects": []
    }
    
    while parser.read() == OK:
        match parser.get_node_type():
            XMLParser.NODE_ELEMENT:
                var node_name = parser.get_node_name()
                
                match node_name:
                    "scene":
                        scene_data.name = parser.get_named_attribute_value("name")
                        
                    "object":
                        var object_data = {
                            "id": parser.get_named_attribute_value("id"),
                            "type": parser.get_named_attribute_value("type"),
                            "properties": {}
                        }
                        
                        # 객체의 추가 속성 파싱
                        var attr_count = parser.get_attribute_count()
                        for i in range(attr_count):
                            var attr_name = parser.get_attribute_name(i)
                            if attr_name != "id" and attr_name != "type":
                                object_data.properties[attr_name] = parser.get_attribute_value(i)
                        
                        scene_data.objects.append(object_data)
                        emit_signal("object_created", object_data)
    
    return scene_data

# 씬 관리
func get_current_scene() -> String:
    return _current_scene

func get_scene_data(scene_name: String) -> Dictionary:
    return _loaded_scenes.get(scene_name, {})

func get_object_by_id(scene_name: String, object_id: String) -> Dictionary:
    var scene = get_scene_data(scene_name)
    for obj in scene.get("objects", []):
        if obj.id == object_id:
            return obj
    return {}

func unload_scene(scene_name: String) -> void:
    if _loaded_scenes.has(scene_name):
        var scene_data = _loaded_scenes[scene_name]
        for obj in scene_data.get("objects", []):
            emit_signal("object_removed", obj.id)
        
        _loaded_scenes.erase(scene_name)
        if _current_scene == scene_name:
            _current_scene = ""
        
        emit_signal("scene_unloaded", scene_name)

# 유틸리티 메서드
func get_objects_by_type(scene_name: String, type: String) -> Array:
    var scene = get_scene_data(scene_name)
    var result = []
    for obj in scene.get("objects", []):
        if obj.type == type:
            result.append(obj)
    return result

func is_scene_loaded(scene_name: String) -> bool:
    return _loaded_scenes.has(scene_name)