extends Node

signal error_reported(error: Dictionary)

const ERROR_LOG_PATH = "user://error_log.json"
var _errors: Array = []

func _ready():
    load_error_log()

func report_error(error_type: String, message: String, details: Dictionary = {}):
    var error = {
        "type": error_type,
        "message": message,
        "details": details,
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    _errors.append(error)
    save_error_log()
    emit_signal("error_reported", error)
    
    # 콘솔에도 출력
    push_error("[%s] %s" % [error_type, message])
    if details:
        print_debug("Error details: ", details)

func report_resource_error(resource_path: String, error_message: String):
    report_error("RESOURCE_ERROR", error_message, {
        "resource_path": resource_path
    })

func get_errors() -> Array:
    return _errors

func clear_errors():
    _errors.clear()
    save_error_log()

func load_error_log():
    if not FileAccess.file_exists(ERROR_LOG_PATH):
        return
        
    var file = FileAccess.open(ERROR_LOG_PATH, FileAccess.READ)
    if not file:
        push_error("에러 로그 파일을 열 수 없습니다.")
        return
        
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    if error:
        push_error("에러 로그 JSON 파싱 오류: " + str(error))
        return
        
    _errors = json.get_data()

func save_error_log():
    var file = FileAccess.open(ERROR_LOG_PATH, FileAccess.WRITE)
    if not file:
        push_error("에러 로그 파일을 저장할 수 없습니다.")
        return
        
    file.store_string(JSON.new().stringify(_errors, "    "))