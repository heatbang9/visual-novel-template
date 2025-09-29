extends Node

# 캐릭터 XML 파서
# XML에서 캐릭터 관련 태그를 파싱하고 처리

var character_manager: Node
const Vector2 = preload("res://scripts/utils/vector2.gd")

func _init(manager: Node):
    character_manager = manager

# 캐릭터 정의 파싱
func parse_character_definition(char_elem: XMLNode) -> void:
    var id = char_elem.get_attribute("id", "")
    var name = char_elem.get_attribute("name", "")
    var pos = _parse_position(char_elem.get_attribute("default_position", "center"))
    
    if id.is_empty() or name.is_empty():
        push_error("캐릭터 ID와 이름은 필수입니다.")
        return
    
    var character = character_manager.create_character(id, name, pos)
    if not character:
        return
    
    # 리소스 로드
    for child in char_elem.get_children():
        match child.tag_name:
            "emotion":
                _parse_emotion(child, character)
            "pose":
                _parse_pose(child, character)
            "voice":
                _parse_voice(child, character)

# 캐릭터 액션 파싱
func parse_character_action(action_elem: XMLNode) -> void:
    var character_id = action_elem.get_attribute("character", "")
    if character_id.is_empty():
        push_error("캐릭터 ID가 필요합니다.")
        return
    
    var character = character_manager.get_character(character_id)
    if not character:
        return
    
    var action_type = action_elem.get_attribute("type", "")
    var duration = action_elem.get_attribute("duration", "0.5").to_float()
    
    match action_type:
        "appear":
            character.appear(duration)
        "disappear":
            character.disappear(duration)
        "move":
            var target_pos = _parse_position(action_elem.get_attribute("position", ""))
            var ease_type = _parse_ease_type(action_elem.get_attribute("ease", "in_out"))
            character.move_to(target_pos, duration, ease_type)
        "emotion":
            var emotion = action_elem.get_attribute("name", "")
            if not emotion.is_empty():
                character.change_emotion(emotion, duration)
        "pose":
            var pose = action_elem.get_attribute("name", "")
            if not pose.is_empty():
                character.change_pose(pose, duration)
        "speak":
            var voice_clip = action_elem.get_attribute("voice", "")
            character.start_speaking(voice_clip)
        "stop":
            character.stop_speaking()
        _:
            push_error("알 수 없는 캐릭터 액션 타입: " + action_type)

# 표정 파싱
func _parse_emotion(emotion_elem: XMLNode, character: Node) -> void:
    var name = emotion_elem.get_attribute("name", "")
    var path = emotion_elem.get_attribute("path", "")
    
    if name.is_empty() or path.is_empty():
        push_error("표정 이름과 경로는 필수입니다.")
        return
    
    character.load_emotion(name, path)

# 포즈 파싱
func _parse_pose(pose_elem: XMLNode, character: Node) -> void:
    var name = pose_elem.get_attribute("name", "")
    var path = pose_elem.get_attribute("path", "")
    
    if name.is_empty() or path.is_empty():
        push_error("포즈 이름과 경로는 필수입니다.")
        return
    
    character.load_pose(name, path)

# 음성 파싱
func _parse_voice(voice_elem: XMLNode, character: Node) -> void:
    var name = voice_elem.get_attribute("name", "")
    var path = voice_elem.get_attribute("path", "")
    
    if name.is_empty() or path.is_empty():
        push_error("음성 이름과 경로는 필수입니다.")
        return
    
    character.load_voice_clip(name, path)

# 위치 문자열을 Vector2로 변환
func _parse_position(pos_str: String) -> Vector2:
    # 미리 정의된 위치
    var predefined = {
        "left": Vector2(200, 300),
        "center": Vector2(400, 300),
        "right": Vector2(600, 300),
        "far_left": Vector2(100, 300),
        "far_right": Vector2(700, 300)
    }
    
    if predefined.has(pos_str.to_lower()):
        return predefined[pos_str.to_lower()]
    
    # x,y 좌표로 된 문자열 파싱
    var coords = pos_str.split(",")
    if coords.size() == 2:
        return Vector2(coords[0].to_float(), coords[1].to_float())
    
    # 기본값
    return Vector2(400, 300)

# 이징 타입 파싱
func _parse_ease_type(ease_str: String) -> int:
    match ease_str:
        "in":
            return Tween.EASE_IN
        "out":
            return Tween.EASE_OUT
        "in_out":
            return Tween.EASE_IN_OUT
        _:
            return Tween.EASE_IN_OUT