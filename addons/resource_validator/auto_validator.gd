extends SceneTree

# 이 스크립트는 'Project -> Editor -> Run' 메뉴에서 실행할 수 있습니다.
# 또는 터미널에서 다음 명령으로 실행할 수 있습니다:
# godot --headless --script res://addons/resource_validator/auto_validator.gd

const BUILD_REPORT_DIR = "res://build_reports"
const BUILD_REPORT_FILE = "resource_validation.report.json"
const REQUIRED_RESOURCES_PATH = "res://required_resources.json"

func _initialize():
    print("리소스 검증 시작...")
    var report = validate_resources()
    save_report(report)
    if report.has_errors:
        push_error("\n경고: 누락된 리소스가 있습니다. build_reports/resource_validation.report.json 파일을 확인하세요.")
    else:
        print("\n성공: 모든 리소스가 존재합니다.")
    
    # 프로그램 종료
    quit()

func validate_resources() -> Dictionary:
    var required = load_required_resources()
    if not required:
        return {
            "error": "필수 리소스 정의 파일을 찾을 수 없습니다: " + REQUIRED_RESOURCES_PATH,
            "has_errors": true,
            "missing_resources": [],
            "timestamp": Time.get_datetime_string_from_system()
        }
    
    var missing = []
    for category in required:
        if required[category] is Array:
            for path in required[category]:
                if not FileAccess.file_exists(path):
                    missing.append({"category": category, "path": path})
        elif required[category] is Dictionary:
            for subcategory in required[category]:
                for path in required[category][subcategory]:
                    if not FileAccess.file_exists(path):
                        missing.append({
                            "category": category + "/" + subcategory,
                            "path": path
                        })
    
    return {
        "timestamp": Time.get_datetime_string_from_system(),
        "total_resources": count_total_resources(required),
        "missing_resources": missing,
        "has_errors": missing.size() > 0
    }

func load_required_resources() -> Dictionary:
    if not FileAccess.file_exists(REQUIRED_RESOURCES_PATH):
        push_error("필수 리소스 정의 파일을 찾을 수 없습니다: " + REQUIRED_RESOURCES_PATH)
        return {}
    
    var file = FileAccess.open(REQUIRED_RESOURCES_PATH, FileAccess.READ)
    var content = file.get_as_text()
    var json = JSON.new()
    var error = json.parse(content)
    
    if error != OK:
        push_error("JSON 파싱 오류: " + str(error))
        return {}
    
    return json.get_data()

func count_total_resources(required: Dictionary) -> int:
    var count = 0
    for category in required:
        if required[category] is Array:
            count += required[category].size()
        elif required[category] is Dictionary:
            for subcategory in required[category]:
                count += required[category][subcategory].size()
    return count

func save_report(report: Dictionary) -> void:
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
    
    # 누락된 리소스 출력
    if report.get("missing_resources", []).size() > 0:
        print("\n누락된 리소스 목록:")
        for item in report.missing_resources:
            print("[%s] %s" % [item.category, item.path])