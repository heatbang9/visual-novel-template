extends Node

@onready var dialogue_scene_loader = $DialogueSceneLoader
@onready var character_manager = $CharacterManager
@onready var background_sprite = $SceneRoot/Background
@onready var character_layer = $SceneRoot/Characters
@onready var dialogue_text = $UI/DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UI/DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var choice_container = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer
@onready var choice_label = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer/ChoiceLabel
@onready var options_container = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer/Options

var current_scene: Node = null
var minigame_manager: Node
var scenario_manager: Node

func _ready() -> void:
    # 시나리오 매니저 초기화
    var scenario_script = load("res://scripts/scenario_manager.gd")
    scenario_manager = scenario_script.new()
    add_child(scenario_manager)
    scenario_manager.configure(dialogue_scene_loader, character_manager)
    scenario_manager.minigame_required.connect(_on_minigame_required)
    
    # 기존 초기화
    dialogue_scene_loader.configure_character_system(character_manager, character_layer)
    dialogue_scene_loader.set_background_target(background_sprite)
    dialogue_scene_loader.dialogue_started.connect(_on_dialogue_started)
    dialogue_scene_loader.dialogue_ended.connect(_on_dialogue_ended)
    
    var minigame_script = load("res://minigames/scripts/minigame_manager.gd")
    minigame_manager = minigame_script.new()
    minigame_manager.minigame_completed.connect(_on_minigame_completed)
    add_child(minigame_manager)
    
    load_first_scene()

func load_first_scene() -> void:
    # 기본 에피소드 로드 (에피소드 1)
    var result = scenario_manager.load_episode("episode1_school_life")
    if result == OK:
        result = scenario_manager.load_scene("scene1_introduction.xml")
        if result == OK:
            _clear_current_scene()
            current_scene = dialogue_scene_loader.create_scene_node(background_sprite, character_layer)
            if current_scene and current_scene.get_child_count() > 0:
                add_child(current_scene)
            show_next_dialogue()
        else:
            push_error("첫 번째 씬 로드 실패")
    else:
        push_error("첫 번째 에피소드 로드 실패")

# 에피소드 변경 함수 추가
func load_episode_scene(episode_id: String, scene_file: String) -> void:
    var result = scenario_manager.load_episode(episode_id)
    if result == OK:
        result = scenario_manager.load_scene(scene_file)
        if result == OK:
            _clear_current_scene()
            current_scene = dialogue_scene_loader.create_scene_node(background_sprite, character_layer)
            if current_scene and current_scene.get_child_count() > 0:
                add_child(current_scene)
            show_next_dialogue()
        else:
            push_error("씬 로드 실패: " + scene_file)
    else:
        push_error("에피소드 로드 실패: " + episode_id)

func show_next_dialogue() -> void:
    var dialogue = dialogue_scene_loader.get_next_dialogue()
    if dialogue.is_empty():
        return

    match dialogue.type:
        "message":
            _show_message(dialogue)
        "choice":
            _show_choice(dialogue)
        "minigame":
            _handle_minigame(dialogue)
        "set_background":
            _handle_set_background(dialogue)
            show_next_dialogue()  # 즉시 다음 대화로 진행
        "show_character":
            _handle_show_character(dialogue)
            show_next_dialogue()  # 즉시 다음 대화로 진행
        "hide_character":
            _handle_hide_character(dialogue)
            show_next_dialogue()  # 즉시 다음 대화로 진행
        "end_scene":
            _handle_end_scene(dialogue)
        _:
            push_warning("알 수 없는 대화 타입: " + str(dialogue.type))
            show_next_dialogue()

func _show_message(message: Dictionary) -> void:
    choice_container.hide()
    var speaker_id = message.get("speaker", "")
    if speaker_id == "narrator" or speaker_id.is_empty():
        speaker_label.text = "내레이터"
    else:
        var char_data = dialogue_scene_loader.current_scene_data.characters.get(speaker_id)
        speaker_label.text = char_data.name if char_data and char_data.has("name") else speaker_id
        _update_character_focus(speaker_id, message.get("emotion", ""))

    dialogue_text.text = message.get("text", "")

func _show_choice(choice: Dictionary) -> void:
    speaker_label.text = ""
    dialogue_text.text = ""
    choice_container.show()
    choice_label.text = choice.text
    
    # 기존 옵션 버튼들 제거
    for child in options_container.get_children():
        child.queue_free()
    
    # 새 옵션 버튼들 추가
    for i in range(len(choice.options)):
        var option = choice.options[i]
        var button = Button.new()
        button.text = option.text
        button.custom_minimum_size = Vector2(0, 40)
        options_container.add_child(button)
        button.pressed.connect(_on_option_selected.bind(i))

func _on_option_selected(option_index: int) -> void:
    dialogue_scene_loader.choice_made.emit(option_index)
    choice_container.hide()
    show_next_dialogue()

func _update_character_focus(speaker_id: String, emotion: String) -> void:
    if character_manager and character_manager.has_character(speaker_id):
        character_manager.set_character_state(speaker_id, "talking")
        for char_id in dialogue_scene_loader.current_scene_data.characters.keys():
            if char_id != speaker_id and character_manager.has_character(char_id):
                character_manager.set_character_state(char_id, "idle")

    var character_node = dialogue_scene_loader.get_character_node(speaker_id)
    if character_node and character_node.has_method("change_emotion") and not emotion.is_empty():
        character_node.change_emotion(emotion, 0.2)

func _clear_current_scene() -> void:
    if current_scene and is_instance_valid(current_scene):
        if current_scene.get_parent() == self:
            remove_child(current_scene)
        current_scene.queue_free()
    current_scene = null

func _on_dialogue_started(scene_name: String) -> void:
    print("Dialogue started: ", scene_name)

func _on_dialogue_ended(scene_name: String) -> void:
    print("Dialogue ended: ", scene_name)

func start_minigame(game_name: String, difficulty: int = 1) -> void:
    minigame_manager.start_minigame(game_name, difficulty)

func _on_minigame_completed(game_name: String, success: bool, score: int) -> void:
    print("미니게임 완료: %s, 성공: %s, 점수: %d" % [game_name, success, score])
    show_next_dialogue()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if not choice_container.visible:
                show_next_dialogue()
    
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1:
                start_minigame("reaction", 1)
            KEY_2:
                start_minigame("color_match", 1)
            KEY_3:
                start_minigame("puzzle", 1)
            KEY_4:
                start_minigame("memory", 1)
            KEY_5:
                start_minigame("math", 1)
            KEY_ESCAPE:
                # 에피소드 테스트를 위한 핫키
                pass

# 새로운 대화 타입 처리 함수들
func _handle_minigame(dialogue: Dictionary) -> void:
    var game_type = dialogue.get("game_type", "")
    var difficulty = dialogue.get("difficulty", 1)
    var required = dialogue.get("required", false)
    var success_scene = dialogue.get("success_scene", "")
    var failure_scene = dialogue.get("failure_scene", "")
    
    if required and not success_scene.is_empty() and not failure_scene.is_empty():
        # 필수 미니게임 - 결과에 따라 다른 씬 로드
        scenario_manager.emit_signal("minigame_required", game_type, difficulty, success_scene, failure_scene)
    else:
        # 선택적 미니게임 - 바로 시작
        start_minigame(game_type, difficulty)

func _handle_set_background(dialogue: Dictionary) -> void:
    var background_id = dialogue.get("background_id", "")
    if background_id.is_empty():
        return
    
    # 시나리오 매니저에서 로드된 배경 데이터 확인
    var scene_data = dialogue_scene_loader.current_scene_data
    if scene_data.has("backgrounds") and scene_data.backgrounds.has(background_id):
        var bg_data = scene_data.backgrounds[background_id]
        var bg_path = bg_data.get("path", "")
        if not bg_path.is_empty():
            var texture = load(bg_path)
            if texture and background_sprite:
                background_sprite.texture = texture

func _handle_show_character(dialogue: Dictionary) -> void:
    var char_id = dialogue.get("character_id", "")
    var emotion = dialogue.get("emotion", "normal")
    var position = dialogue.get("position", "")
    
    if char_id.is_empty():
        return
    
    # 캐릭터 매니저를 통해 캐릭터 표시
    if character_manager and character_manager.has_character(char_id):
        character_manager.set_character_state(char_id, "visible")
        # 감정 변경
        var char_node = dialogue_scene_loader.get_character_node(char_id)
        if char_node and char_node.has_method("change_emotion"):
            char_node.change_emotion(emotion, 0.3)

func _handle_hide_character(dialogue: Dictionary) -> void:
    var char_id = dialogue.get("character_id", "")
    
    if char_id.is_empty():
        return
    
    # 캐릭터 매니저를 통해 캐릭터 숨기기
    if character_manager and character_manager.has_character(char_id):
        character_manager.set_character_state(char_id, "hidden")

func _handle_end_scene(dialogue: Dictionary) -> void:
    print("씬 완료")
    # 여기서 씬 완료 후 처리를 할 수 있음 (메뉴로 돌아가기 등)

func _on_minigame_required(game_type: String, difficulty: int, success_scene: String, failure_scene: String) -> void:
    print("필수 미니게임 시작: %s (난이도: %d)" % [game_type, difficulty])
    # 미니게임 완료 후 결과에 따라 다른 씬으로 이동하는 로직
    minigame_manager.minigame_completed.disconnect(_on_minigame_completed)
    minigame_manager.minigame_completed.connect(_on_required_minigame_completed.bind(success_scene, failure_scene))
    start_minigame(game_type, difficulty)

func _on_required_minigame_completed(success_scene: String, failure_scene: String, game_name: String, success: bool, score: int) -> void:
    print("필수 미니게임 완료: %s, 성공: %s, 점수: %d" % [game_name, success, score])
    
    # 원래 연결로 복원
    minigame_manager.minigame_completed.disconnect(_on_required_minigame_completed)
    minigame_manager.minigame_completed.connect(_on_minigame_completed)
    
    # 결과에 따라 다른 씬 로드
    var next_scene = success_scene if success else failure_scene
    if not next_scene.is_empty():
        var result = scenario_manager.load_scene(next_scene)
        if result == OK:
            _clear_current_scene()
            current_scene = dialogue_scene_loader.create_scene_node(background_sprite, character_layer)
            if current_scene and current_scene.get_child_count() > 0:
                add_child(current_scene)
            show_next_dialogue()
        else:
            push_error("다음 씬 로드 실패: " + next_scene)