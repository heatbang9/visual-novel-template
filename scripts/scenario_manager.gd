extends Node

class_name ScenarioManager

signal episode_loaded(episode_id: String)
signal episode_completed(episode_id: String)
signal minigame_required(game_type: String, difficulty: int, success_scene: String, failure_scene: String)

@onready var dialogue_scene_loader: DialogueSceneLoader
@onready var character_manager: CharacterManager
@onready var localization_manager: LocalizationManager

# 시나리오 데이터
var current_episode_data: Dictionary = {}
var loaded_characters: Dictionary = {}
var loaded_backgrounds: Dictionary = {}
var scenario_base_path: String = "res://scenarios/"

# 초기화
func _ready():
    # 로컬라이제이션 매니저 가져오기
    localization_manager = get_node("/root/LocalizationManager")
    if not localization_manager:
        push_error("LocalizationManager가 AutoLoad에 설정되어 있지 않습니다.")

# DialogueSceneLoader와 CharacterManager 설정
func configure(loader: DialogueSceneLoader, char_manager: CharacterManager):
    dialogue_scene_loader = loader
    character_manager = char_manager

# 에피소드 로드
func load_episode(episode_id: String) -> Error:
    var episode_path = scenario_base_path + episode_id
    var config_path = episode_path + "/episode_config.json"
    
    # 에피소드 설정 파일 확인
    if not FileAccess.file_exists(config_path):
        push_error("에피소드 설정 파일을 찾을 수 없습니다: " + config_path)
        return ERR_FILE_NOT_FOUND
    
    # 설정 파일 로드
    var config_data = _load_json_file(config_path)
    if config_data.is_empty():
        push_error("에피소드 설정 파일 파싱 실패: " + config_path)
        return ERR_PARSE_ERROR
    
    current_episode_data = config_data
    current_episode_data["base_path"] = episode_path
    
    # 캐릭터 로드
    var error = _load_episode_characters(episode_path)
    if error != OK:
        return error
    
    # 배경 로드
    error = _load_episode_backgrounds(episode_path)
    if error != OK:
        return error
    
    emit_signal("episode_loaded", episode_id)
    return OK

# 에피소드의 특정 씬 로드
func load_scene(scene_file: String) -> Error:
    if current_episode_data.is_empty():
        push_error("에피소드가 로드되지 않았습니다.")
        return ERR_UNCONFIGURED
    
    var scene_path = current_episode_data.base_path + "/dialogue/" + scene_file
    
    if not FileAccess.file_exists(scene_path):
        push_error("씬 파일을 찾을 수 없습니다: " + scene_path)
        return ERR_FILE_NOT_FOUND
    
    # 기존 XML 파서에 캐릭터 데이터를 포함하여 씬 로드
    return _load_scene_with_episode_data(scene_path)

# 에피소드 데이터를 포함하여 씬 로드
func _load_scene_with_episode_data(scene_path: String) -> Error:
    if not FileAccess.file_exists(scene_path):
        push_error("Scene file not found: " + scene_path)
        return ERR_FILE_NOT_FOUND

    # 기존 캐릭터 정리
    if character_manager:
        character_manager.clear_characters()
    
    # XML 파일 읽기 및 파싱
    var file = FileAccess.open(scene_path, FileAccess.READ)
    if not file:
        push_error("Failed to open scene file: " + scene_path)
        return ERR_FILE_CANT_OPEN
    
    var content = file.get_as_text()
    var parser = XMLParser.new()
    var error = parser.open_buffer(content.to_utf8_buffer())
    
    if error != OK:
        push_error("Failed to parse XML: " + scene_path)
        return error
    
    # 씬 데이터 파싱
    var scene_data = _parse_enhanced_scene_xml(parser)
    if scene_data.has("id") and not scene_data.id.is_empty():
        # DialogueSceneLoader의 current_scene_data 업데이트
        dialogue_scene_loader.current_scene_data = scene_data
        dialogue_scene_loader.current_message_index = 0
        dialogue_scene_loader._dialogue_finished = false
        
        emit_signal("dialogue_started", scene_data.id)
        return OK

    return ERR_PARSE_ERROR

# 향상된 XML 파싱 (새로운 포맷 지원)
func _parse_enhanced_scene_xml(parser: XMLParser) -> Dictionary:
    var scene_data = {
        "id": "",
        "episode": "",
        "title": "",
        "description": "",
        "characters": {},
        "backgrounds": {},
        "dialogue": []
    }
    
    var current_character_id := ""
    
    while parser.read() == OK:
        match parser.get_node_type():
            XMLParser.NODE_ELEMENT:
                var node_name = parser.get_node_name()
                
                match node_name:
                    "scene":
                        scene_data.id = parser.get_named_attribute_value("id")
                        scene_data.episode = parser.get_named_attribute_value("episode")
                    
                    "metadata":
                        # 메타데이터는 다음 TEXT 노드들에서 처리
                        pass
                    
                    "title":
                        if parser.read() == OK and parser.get_node_type() == XMLParser.NODE_TEXT:
                            scene_data.title = parser.get_node_data().strip_edges()
                    
                    "description":
                        if parser.read() == OK and parser.get_node_type() == XMLParser.NODE_TEXT:
                            scene_data.description = parser.get_node_data().strip_edges()
                    
                    "character":
                        var char_id = parser.get_named_attribute_value("id")
                        var char_name = parser.get_named_attribute_value("name")
                        var char_position = parser.get_named_attribute_value("position")
                        
                        # 에피소드에서 로드한 캐릭터 데이터와 결합
                        if loaded_characters.has(char_id):
                            var char_data = loaded_characters[char_id].duplicate()
                            char_data["position"] = char_position if char_position else "center"
                            scene_data.characters[char_id] = char_data
                        else:
                            # 기본 캐릭터 데이터
                            scene_data.characters[char_id] = {
                                "id": char_id,
                                "name": char_name,
                                "position": char_position if char_position else "center",
                                "sprites": {},
                                "color": "#FFFFFF"
                            }
                    
                    "background":
                        var bg_id = parser.get_named_attribute_value("id")
                        var bg_src = parser.get_named_attribute_value("src")
                        scene_data.backgrounds[bg_id] = {
                            "id": bg_id,
                            "path": bg_src
                        }
                    
                    "set_background":
                        var bg_id = parser.get_named_attribute_value("id")
                        scene_data.dialogue.append({
                            "type": "set_background",
                            "background_id": bg_id
                        })
                    
                    "show_character":
                        var char_id = parser.get_named_attribute_value("id")
                        var emotion = parser.get_named_attribute_value("emotion")
                        var position = parser.get_named_attribute_value("position")
                        
                        scene_data.dialogue.append({
                            "type": "show_character",
                            "character_id": char_id,
                            "emotion": emotion if emotion else "normal",
                            "position": position
                        })
                    
                    "hide_character":
                        var char_id = parser.get_named_attribute_value("id")
                        scene_data.dialogue.append({
                            "type": "hide_character",
                            "character_id": char_id
                        })
                    
                    "message":
                        var speaker = parser.get_named_attribute_value("speaker")
                        var message = {
                            "type": "message",
                            "speaker": speaker,
                            "text": ""
                        }
                        
                        # text 태그 찾기
                        while parser.read() == OK:
                            if parser.get_node_type() == XMLParser.NODE_ELEMENT:
                                if parser.get_node_name() == "text":
                                    if parser.read() == OK and parser.get_node_type() == XMLParser.NODE_TEXT:
                                        message.text = parser.get_node_data().strip_edges()
                                        # 로컬라이제이션 처리
                                        if localization_manager:
                                            message.text = localization_manager.get_text(message.text, message.text)
                                    break
                            elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
                                if parser.get_node_name() == "message":
                                    break
                        
                        scene_data.dialogue.append(message)
                    
                    "minigame":
                        var game_type = parser.get_named_attribute_value("type")
                        var difficulty = parser.get_named_attribute_value("difficulty").to_int()
                        var required = parser.get_named_attribute_value("required").to_lower() == "true"
                        var success_scene = parser.get_named_attribute_value("success_scene")
                        var failure_scene = parser.get_named_attribute_value("failure_scene")
                        
                        scene_data.dialogue.append({
                            "type": "minigame",
                            "game_type": game_type,
                            "difficulty": difficulty,
                            "required": required,
                            "success_scene": success_scene,
                            "failure_scene": failure_scene
                        })
                    
                    "end_scene":
                        scene_data.dialogue.append({
                            "type": "end_scene"
                        })
    
    return scene_data

# 에피소드의 캐릭터들 로드
func _load_episode_characters(episode_path: String) -> Error:
    var characters_path = episode_path + "/characters/"
    loaded_characters.clear()
    
    if not DirAccess.dir_exists_absolute(characters_path):
        push_warning("캐릭터 폴더가 없습니다: " + characters_path)
        return OK
    
    var dir = DirAccess.open(characters_path)
    if not dir:
        push_error("캐릭터 폴더를 열 수 없습니다: " + characters_path)
        return ERR_FILE_CANT_OPEN
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".json"):
            var char_data = _load_json_file(characters_path + file_name)
            if not char_data.is_empty():
                var char_id = char_data.get("id", "")
                if not char_id.is_empty():
                    loaded_characters[char_id] = char_data
        file_name = dir.get_next()
    
    return OK

# 에피소드의 배경들 로드
func _load_episode_backgrounds(episode_path: String) -> Error:
    # 배경 정보는 현재 XML에서 직접 처리되므로 향후 확장용
    loaded_backgrounds.clear()
    return OK

# JSON 파일 로드 유틸리티
func _load_json_file(file_path: String) -> Dictionary:
    if not FileAccess.file_exists(file_path):
        return {}
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        return {}
    
    var json = JSON.new()
    var parse_result = json.parse(file.get_as_text())
    
    if parse_result != OK:
        push_error("JSON 파싱 오류: " + file_path + " - " + json.get_error_message())
        return {}
    
    return json.get_data()

# 현재 로드된 에피소드 정보 반환
func get_current_episode_data() -> Dictionary:
    return current_episode_data

# 현재 로드된 캐릭터 정보 반환
func get_character_data(character_id: String) -> Dictionary:
    return loaded_characters.get(character_id, {})

# 사용 가능한 에피소드 목록 가져오기
func get_available_episodes() -> Array:
    var episodes = []
    var dir = DirAccess.open(scenario_base_path)
    
    if not dir:
        return episodes
    
    dir.list_dir_begin()
    var folder_name = dir.get_next()
    
    while folder_name != "":
        if dir.current_is_dir() and folder_name.begins_with("episode"):
            var config_path = scenario_base_path + folder_name + "/episode_config.json"
            if FileAccess.file_exists(config_path):
                var config_data = _load_json_file(config_path)
                if not config_data.is_empty():
                    episodes.append({
                        "id": folder_name,
                        "title": config_data.get("title", ""),
                        "description": config_data.get("description", "")
                    })
        folder_name = dir.get_next()
    
    return episodes