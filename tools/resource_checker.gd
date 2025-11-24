#!/usr/bin/env -S godot --headless -s
extends SceneTree

# 리소스 체크 도구
# 모든 시나리오에서 참조되는 리소스 파일들이 존재하는지 확인

var missing_resources: Array = []
var found_resources: Array = []

func _ready():
    print("=== 리소스 체크 도구 ===")
    print()
    
    check_character_resources()
    check_background_resources()
    
    print_results()
    quit()

func check_character_resources():
    print("캐릭터 리소스 확인 중...")
    
    var episodes = ["episode1_school_life", "episode2_magic_school", "episode3_school_club"]
    
    for episode in episodes:
        var char_dir = "res://scenarios/%s/characters/" % episode
        
        if not DirAccess.dir_exists_absolute(char_dir):
            continue
            
        var dir = DirAccess.open(char_dir)
        if not dir:
            continue
            
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".json"):
                check_character_file(char_dir + file_name)
            file_name = dir.get_next()

func check_character_file(json_path: String):
    var file = FileAccess.open(json_path, FileAccess.READ)
    if not file:
        return
        
    var json = JSON.new()
    var parse_result = json.parse(file.get_as_text())
    
    if parse_result != OK:
        return
        
    var char_data = json.get_data()
    var char_id = char_data.get("id", "")
    var sprites = char_data.get("sprites", {})
    
    if char_id.is_empty() or sprites.is_empty():
        return
        
    for emotion in sprites:
        var sprite_path = sprites[emotion]
        check_resource_file(sprite_path, "캐릭터 스프라이트")

func check_background_resources():
    print("배경 리소스 확인 중...")
    
    # XML 파일들에서 배경 리소스 체크
    var episodes = ["episode1_school_life", "episode2_magic_school", "episode3_school_club"]
    
    for episode in episodes:
        var dialogue_dir = "res://scenarios/%s/dialogue/" % episode
        
        if not DirAccess.dir_exists_absolute(dialogue_dir):
            continue
            
        var dir = DirAccess.open(dialogue_dir)
        if not dir:
            continue
            
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".xml"):
                check_xml_backgrounds(dialogue_dir + file_name)
            file_name = dir.get_next()

func check_xml_backgrounds(xml_path: String):
    var file = FileAccess.open(xml_path, FileAccess.READ)
    if not file:
        return
        
    var content = file.get_as_text()
    
    # 간단한 정규식으로 background src 속성 찾기
    var regex = RegEx.new()
    regex.compile('src="([^"]+)"')
    
    for result in regex.search_all(content):
        var bg_path = result.get_string(1)
        if bg_path.begins_with("res://backgrounds/"):
            check_resource_file(bg_path, "배경 이미지")

func check_resource_file(resource_path: String, resource_type: String):
    if FileAccess.file_exists(resource_path):
        found_resources.append({
            "path": resource_path,
            "type": resource_type,
            "status": "존재"
        })
    else:
        missing_resources.append({
            "path": resource_path,
            "type": resource_type,
            "status": "누락"
        })

func print_results():
    print()
    print("=== 체크 결과 ===")
    print("총 확인된 리소스: %d개" % (found_resources.size() + missing_resources.size()))
    print("존재하는 리소스: %d개" % found_resources.size())
    print("누락된 리소스: %d개" % missing_resources.size())
    print()
    
    if missing_resources.size() > 0:
        print("❌ 누락된 리소스들:")
        for resource in missing_resources:
            print("  - [%s] %s" % [resource.type, resource.path])
        print()
    
    if found_resources.size() > 0:
        print("✅ 존재하는 리소스 요약:")
        var type_counts = {}
        for resource in found_resources:
            var type = resource.type
            if type_counts.has(type):
                type_counts[type] += 1
            else:
                type_counts[type] = 1
        
        for type in type_counts:
            print("  - %s: %d개" % [type, type_counts[type]])
        print()
    
    if missing_resources.size() == 0:
        print("🎉 모든 리소스가 존재합니다!")
    else:
        print("⚠️  누락된 리소스들을 추가해주세요.")
    
    print()
    print("자세한 리소스 요구사항은 docs/resource_requirements.md를 참고하세요.")