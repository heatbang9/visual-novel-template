extends Node

signal resource_load_failed(path: String, error: String)
signal resource_load_progress(current: int, total: int)

const REQUIRED_RESOURCES_PATH = "res://required_resources.json"
var _required_resources: Dictionary
var _loaded_resources: Dictionary = {}
var _loading_errors: Array = []

func _ready():
    _load_required_resources()

func _load_required_resources():
    if not FileAccess.file_exists(REQUIRED_RESOURCES_PATH):
        push_error("필수 리소스 정의 파일을 찾을 수 없습니다: " + REQUIRED_RESOURCES_PATH)
        return
    
    var file = FileAccess.open(REQUIRED_RESOURCES_PATH, FileAccess.READ)
    if not file:
        push_error("필수 리소스 파일을 열 수 없습니다.")
        return
    
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    if error:
        push_error("JSON 파싱 오류: " + str(error))
        return
        
    _required_resources = json.get_data()

func preload_all_resources():
    var total_resources = _count_total_resources()
    var current = 0
    _loading_errors.clear()
    
    for category in _required_resources:
        if _required_resources[category] is Array:
            for path in _required_resources[category]:
                var result = _load_resource(path)
                if result is String: # 에러 메시지
                    _loading_errors.append({"path": path, "error": result})
                current += 1
                emit_signal("resource_load_progress", current, total_resources)
        elif _required_resources[category] is Dictionary:
            for subcategory in _required_resources[category]:
                for path in _required_resources[category][subcategory]:
                    var result = _load_resource(path)
                    if result is String: # 에러 메시지
                        _loading_errors.append({"path": path, "error": result})
                    current += 1
                    emit_signal("resource_load_progress", current, total_resources)
    
    return _loading_errors.size() == 0

func _count_total_resources() -> int:
    var count = 0
    for category in _required_resources:
        if _required_resources[category] is Array:
            count += _required_resources[category].size()
        elif _required_resources[category] is Dictionary:
            for subcategory in _required_resources[category]:
                count += _required_resources[category][subcategory].size()
    return count

func _load_resource(path: String) -> Variant:
    if path in _loaded_resources:
        return _loaded_resources[path]
        
    if not FileAccess.file_exists(path):
        var error = "파일이 존재하지 않습니다: " + path
        emit_signal("resource_load_failed", path, error)
        return error
    
    var resource = load(path)
    if not resource:
        var error = "리소스 로드 실패: " + path
        emit_signal("resource_load_failed", path, error)
        return error
    
    _loaded_resources[path] = resource
    return resource

func get_resource(path: String) -> Resource:
    if not path in _loaded_resources:
        var result = _load_resource(path)
        if result is String: # 에러 발생
            return null
    return _loaded_resources[path]

func has_resource(path: String) -> bool:
    return path in _loaded_resources

func get_loading_errors() -> Array:
    return _loading_errors

func clear_cache():
    _loaded_resources.clear()