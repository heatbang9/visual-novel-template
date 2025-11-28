extends SceneTree

# 범용 Godot 프로젝트 검증기
# 어떤 Godot 프로젝트든 기본적인 품질과 구조를 검증

func _ready():
    print("=== 범용 Godot 프로젝트 검증기 V1.0 ===")
    print("검증 대상: ", ProjectSettings.globalize_path("res://"))
    print("Godot 버전: ", Engine.get_version_info())
    print()
    
    var total_score = 0
    var max_score = 100
    
    # 각 검증 단계별 점수 계산
    total_score += validate_project_settings()    # 20점
    total_score += validate_scenes()             # 20점  
    total_score += validate_scripts()            # 30점
    total_score += validate_resources()          # 15점
    total_score += validate_plugins()            # 15점
    
    print_final_report(total_score, max_score)
    
    quit()

func validate_project_settings() -> int:
    print("1. 📋 프로젝트 설정 검증:")
    var score = 0
    
    # project.godot 파일 존재 확인 (5점)
    if FileAccess.file_exists("res://project.godot"):
        print("  ✓ project.godot 파일 존재 (+5점)")
        score += 5
    else:
        print("  ✗ project.godot 파일 없음 (-5점)")
        return score
    
    # 프로젝트 이름 확인 (5점)
    var project_name = ProjectSettings.get_setting("application/config/name", "")
    if not project_name.is_empty():
        print("  📋 프로젝트명: '", project_name, "' (+5점)")
        score += 5
    else:
        print("  ⚠️  프로젝트명이 설정되지 않음")
    
    # 메인 씬 설정 확인 (10점)
    var main_scene = ProjectSettings.get_setting("application/run/main_scene", "")
    if not main_scene.is_empty():
        print("  🎬 메인 씬: ", main_scene)
        if FileAccess.file_exists(main_scene):
            print("    ✓ 메인 씬 파일 존재 (+10점)")
            score += 10
        else:
            print("    ✗ 메인 씬 파일 없음 (-5점)")
            score -= 5
    else:
        print("  ⚠️  메인 씬이 설정되지 않음")
    
    print("  📊 프로젝트 설정 점수: ", score, "/20")
    return score

func validate_scenes() -> int:
    print("\n2. 🎭 씬 파일 검증:")
    var score = 0
    
    var scene_count = count_files_with_extension("res://", ".tscn")
    print("  📄 총 씬 파일 개수: ", scene_count)
    
    if scene_count == 0:
        print("  ✗ 씬 파일이 없습니다 (0점)")
        return 0
    elif scene_count >= 1 and scene_count <= 5:
        print("  ✓ 기본적인 씬 구조 (+10점)")
        score += 10
    elif scene_count >= 6 and scene_count <= 20:
        print("  ✓ 충분한 씬 구조 (+15점)")  
        score += 15
    else:
        print("  ✓ 복잡한 씬 구조 (+20점)")
        score += 20
    
    # 씬 파일 유효성 검사
    var valid_scenes = validate_scene_files()
    var scene_validity_ratio = float(valid_scenes) / float(scene_count) if scene_count > 0 else 0
    
    if scene_validity_ratio >= 0.9:
        print("  ✓ 씬 파일 유효성 높음 (", valid_scenes, "/", scene_count, ") (+0점 보너스)")
    elif scene_validity_ratio >= 0.7:
        print("  ⚠️  일부 씬 파일 문제 (", valid_scenes, "/", scene_count, ")")
    else:
        print("  ✗ 많은 씬 파일 문제 (", valid_scenes, "/", scene_count, ") (-5점)")
        score -= 5
    
    print("  📊 씬 시스템 점수: ", score, "/20")
    return score

func validate_scripts() -> int:
    print("\n3. 📜 스크립트 검증:")
    var score = 0
    
    var script_count = count_files_with_extension("res://", ".gd")
    print("  💾 총 GDScript 파일 개수: ", script_count)
    
    if script_count == 0:
        print("  ⚠️  GDScript 파일이 없습니다 (10점)")
        score += 10  # 스크립트가 없어도 된다면 기본 점수
    elif script_count >= 1 and script_count <= 10:
        print("  ✓ 기본적인 스크립트 구조 (+20점)")
        score += 20
    elif script_count >= 11 and script_count <= 50:
        print("  ✓ 체계적인 스크립트 구조 (+25점)")
        score += 25
    else:
        print("  ✓ 복잡한 스크립트 구조 (+30점)")
        score += 30
    
    # class_name 사용 여부 확인 (좋은 코딩 practice)
    var class_names = find_class_definitions()
    if class_names.size() > 0:
        print("  🏷️  클래스 정의 발견: ", class_names.size(), "개")
        for class_name in class_names:
            print("    - ", class_name)
    
    print("  📊 스크립트 시스템 점수: ", score, "/30")
    return score

func validate_resources() -> int:
    print("\n4. 🎨 리소스 검증:")
    var score = 0
    
    # 이미지 리소스
    var image_count = count_files_with_extension("res://", ".png") + count_files_with_extension("res://", ".jpg")
    print("  🖼️  이미지 파일: ", image_count, "개")
    
    # 오디오 리소스  
    var audio_count = count_files_with_extension("res://", ".ogg") + count_files_with_extension("res://", ".wav")
    print("  🔊 오디오 파일: ", audio_count, "개")
    
    # 리소스 점수 계산
    if image_count > 0:
        score += 8
        print("  ✓ 이미지 리소스 존재 (+8점)")
    
    if audio_count > 0:
        score += 7
        print("  ✓ 오디오 리소스 존재 (+7점)")
    
    if image_count == 0 and audio_count == 0:
        print("  ⚠️  멀티미디어 리소스 없음 (기본 점수)")
        score += 5
    
    print("  📊 리소스 시스템 점수: ", score, "/15")
    return score

func validate_plugins() -> int:
    print("\n5. 🔌 플러그인 검증:")
    var score = 10  # 기본 점수 (플러그인 없어도 됨)
    
    if DirAccess.dir_exists_absolute("res://addons/"):
        var addon_folders = get_addon_folders()
        if addon_folders.size() > 0:
            print("  📦 발견된 플러그인: ", addon_folders.size(), "개")
            score += 5
            
            for addon in addon_folders:
                print("    - ", addon)
                
                # plugin.cfg 파일 확인
                if FileAccess.file_exists("res://addons/" + addon + "/plugin.cfg"):
                    print("      ✓ 설정 파일 정상")
                else:
                    print("      ⚠️  설정 파일 없음")
                    score -= 2
        else:
            print("  📦 addons 폴더 존재하지만 플러그인 없음")
    else:
        print("  📦 플러그인 없음 (기본 점수)")
    
    print("  📊 플러그인 시스템 점수: ", score, "/15")
    return score

func count_files_with_extension(dir_path: String, extension: String) -> int:
    var count = 0
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and not file_name.begins_with("."):
                count += count_files_with_extension(dir_path + "/" + file_name, extension)
            elif file_name.ends_with(extension):
                count += 1
            file_name = dir.get_next()
    
    return count

func validate_scene_files() -> int:
    """씬 파일들의 유효성 검증"""
    var valid_count = 0
    var scene_files = find_all_files("res://", ".tscn")
    
    for scene_file in scene_files:
        if FileAccess.file_exists(scene_file):
            valid_count += 1
    
    return valid_count

func find_class_definitions() -> Array:
    """class_name 정의들 찾기"""
    var class_names = []
    var script_files = find_all_files("res://", ".gd")
    
    for script_file in script_files:
        var file = FileAccess.open(script_file, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            var lines = content.split("\n")
            for line in lines:
                if line.strip_edges().begins_with("class_name "):
                    var class_name = line.strip_edges().replace("class_name ", "").split(" ")[0]
                    class_names.append(class_name)
    
    return class_names

func get_addon_folders() -> Array:
    """addons 폴더 내 플러그인들 목록"""
    var addons = []
    var dir = DirAccess.open("res://addons/")
    
    if dir:
        dir.list_dir_begin()
        var folder_name = dir.get_next()
        
        while folder_name != "":
            if dir.current_is_dir() and not folder_name.begins_with("."):
                addons.append(folder_name)
            folder_name = dir.get_next()
    
    return addons

func find_all_files(dir_path: String, extension: String) -> Array:
    """특정 확장자의 모든 파일 경로 반환"""
    var files = []
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and not file_name.begins_with("."):
                files += find_all_files(dir_path + "/" + file_name, extension)
            elif file_name.ends_with(extension):
                files.append(dir_path + "/" + file_name)
            file_name = dir.get_next()
    
    return files

func print_final_report(score: int, max_score: int):
    """최종 검증 결과 출력"""
    print("\n" + "=" * 50)
    print("📊 최종 검증 결과")
    print("=" * 50)
    
    var percentage = float(score) / float(max_score) * 100.0
    print("총점: ", score, "/", max_score, " (", "%.1f" % percentage, "%)")
    
    var grade = ""
    var status = ""
    
    if percentage >= 90:
        grade = "A+"
        status = "우수한 품질의 프로젝트"
    elif percentage >= 80:
        grade = "A"
        status = "좋은 품질의 프로젝트"
    elif percentage >= 70:
        grade = "B+"
        status = "양호한 프로젝트"
    elif percentage >= 60:
        grade = "B"
        status = "평균적인 프로젝트"
    elif percentage >= 50:
        grade = "C"
        status = "개선이 필요한 프로젝트"
    else:
        grade = "D"
        status = "많은 문제가 있는 프로젝트"
    
    print("등급: ", grade)
    print("상태: ", status)
    
    # 개선 권장사항
    print("\n💡 권장사항:")
    
    if percentage < 60:
        print("  • 기본적인 프로젝트 설정과 구조 점검 필요")
    if percentage < 80:
        print("  • 리소스 파일 구성과 코드 품질 개선 검토")
    if percentage >= 80:
        print("  • 현재 상태를 유지하며 기능 확장 권장")
    
    print("  • 정기적인 백업과 버전 관리 권장")
    print("  • Godot 문서를 참조하여 베스트 프랙티스 적용")
    
    print("\n검증 완료 시각:", Time.get_datetime_string_from_system())
    print("=" * 50)