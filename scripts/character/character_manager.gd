extends Node

# 캐릭터 매니저
# 모든 캐릭터 인스턴스를 관리하고 동기화

signal character_created(character: Node)
signal character_removed(character_id: String)

var characters: Dictionary = {}  # 캐릭터 ID를 키로 하는 캐릭터 노드 딕셔너리
var character_scene = preload("res://scenes/character/character.tscn")

# 캐릭터 생성
func create_character(id: String, name: String, position: Vector2 = Vector2(0, 0)) -> Node:
    if characters.has(id):
        push_error("이미 존재하는 캐릭터 ID입니다: " + id)
        return null
    
    var character = character_scene.instantiate()
    character.character_id = id
    character.character_name = name
    character.default_position = position
    
    add_child(character)
    characters[id] = character
    emit_signal("character_created", character)
    
    return character

# 캐릭터 제거
func remove_character(id: String) -> void:
    if not characters.has(id):
        push_error("존재하지 않는 캐릭터 ID입니다: " + id)
        return
    
    var character = characters[id]
    character.queue_free()
    characters.erase(id)
    emit_signal("character_removed", id)

# 캐릭터 가져오기
func get_character(id: String) -> Node:
    if not characters.has(id):
        push_error("존재하지 않는 캐릭터 ID입니다: " + id)
        return null
    
    return characters[id]

# 모든 캐릭터 리소스 프리로드
func preload_character_resources(character_data: Dictionary) -> void:
    for id in character_data:
        var data = character_data[id]
        var character = get_character(id)
        if not character:
            push_error("캐릭터를 찾을 수 없습니다: " + id)
            continue
        
        # 표정 로드
        if data.has("emotions"):
            for emotion in data.emotions:
                character.load_emotion(emotion, data.emotions[emotion])
        
        # 포즈 로드
        if data.has("poses"):
            for pose in data.poses:
                character.load_pose(pose, data.poses[pose])
        
        # 음성 로드
        if data.has("voices"):
            for voice in data.voices:
                character.load_voice_clip(voice, data.voices[voice])

# 캐릭터 동기화 (예: 여러 캐릭터가 동시에 말할 때)
func synchronize_speaking(speaking_character_id: String) -> void:
    for id in characters:
        var character = characters[id]
        if id == speaking_character_id:
            character.start_speaking()
        else:
            character.stop_speaking()

# 모든 캐릭터 말하기 중지
func stop_all_speaking() -> void:
    for character in characters.values():
        character.stop_speaking()

# 특정 위치의 캐릭터 찾기
func get_character_at_position(position: Vector2, tolerance: float = 10.0) -> Node:
    for character in characters.values():
        if character.position.distance_to(position) <= tolerance:
            return character
    return null

# 모든 캐릭터 숨기기
func hide_all_characters(duration: float = 0.5) -> void:
    for character in characters.values():
        character.disappear(duration)

# 모든 캐릭터 표시
func show_all_characters(duration: float = 0.5) -> void:
    for character in characters.values():
        character.appear(duration)