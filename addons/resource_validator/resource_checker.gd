@tool
extends RefCounted

const REQUIRED_RESOURCES_PATH = "res://required_resources.json"
const BUILD_REPORT_DIR = "res://build_reports"
const BUILD_REPORT_FILE = "resource_validation.report.json"
var editor_interface: EditorInterface

func setup(ei: EditorInterface):
    editor_interface = ei

func validate_project_resources() -> bool:
    var required_resources = load_required_resources()
    if not required_resources:
        var error = "필수 리소스 정의 파일을 찾을 수 없습니다: " + REQUIRED_RESOURCES_PATH
        save_validation_report({"error": error, "missing_resources": []})
        push_error(error)
        return false
    
    var missing_resources = []
    var file_access = FileAccess.new()
    
    # 리소스 존재 여부 검사
    for category in required_resources:
        for resource_path in required_resources[category]:
            if not FileAccess.file_exists(resource_path):
                missing_resources.append({
                    "category": category,
                    "path": resource_path
                })
    
var validation_result = {
        "timestamp": Time.get_datetime_string_from_system(),
        "total_resources": _count_total_resources(),
        "missing_resources": missing_resources,
        "has_errors": missing_resources.size() > 0
    }
    
    save_validation_report(validation_result)
    
    if missing_resources.size() > 0:
        report_missing_resources(missing_resources)
        return false
        
    print("모든 필수 리소스가 존재합니다.")
    return true

func load_required_resources() -> Dictionary:
    if not FileAccess.file_exists(REQUIRED_RESOURCES_PATH):
        return {}
    
    var file = FileAccess.open(REQUIRED_RESOURCES_PATH, FileAccess.READ)
    if not file:
        push_error("필수 리소스 파일을 열 수 없습니다.")
        return {}
    
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    if error:
        push_error("JSON 파싱 오류: " + str(error))
        return {}
        
    return json.get_data()

func report_missing_resources(missing: Array):
    var report = "\n누락된 리소스 목록:\n"
    for item in missing:
        report += "\n[%s] %s" % [item.category, item.path]
    push_warning(report)

func save_validation_report(report: Dictionary) -> void:
    # 빌드 리포트 디렉토리 생성
    var dir = DirAccess.open("res://")
    if not dir.dir_exists(BUILD_REPORT_DIR.trim_prefix("res://")):
        dir.make_dir_recursive(BUILD_REPORT_DIR.trim_prefix("res://"))
    
    # 리포트 파일 저장
    var report_path = BUILD_REPORT_DIR.path_join(BUILD_REPORT_FILE)
    var file = FileAccess.open(report_path, FileAccess.WRITE)
    if not file:
        push_error("리포트 파일을 생성할 수 없습니다: " + report_path)
        return
        
    file.store_string(JSON.new().stringify(report, "    "))
    print("리소스 검증 리포트가 저장되었습니다: ", report_path)
    
    # TODO: 에디터에 경고 다이얼로그 표시
    var dialog = AcceptDialog.new()
    dialog.dialog_text = report
    dialog.title = "리소스 검증 실패"
    editor_interface.get_base_control().add_child(dialog)
    dialog.popup_centered()