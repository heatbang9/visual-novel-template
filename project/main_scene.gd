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
var minigame_manager: MinigameManager

func _ready() -> void:
    dialogue_scene_loader.configure_character_system(character_manager, character_layer)
    dialogue_scene_loader.set_background_target(background_sprite)
    dialogue_scene_loader.dialogue_started.connect(_on_dialogue_started)
    dialogue_scene_loader.dialogue_ended.connect(_on_dialogue_ended)
    
    minigame_manager = MinigameManager.new()
    minigame_manager.minigame_completed.connect(_on_minigame_completed)
    add_child(minigame_manager)
    
    load_first_scene()

func load_first_scene() -> void:
    var result = dialogue_scene_loader.load_scene_from_xml("res://scenes/dialogue/scene1.xml")
    if result == OK:
        _clear_current_scene()
        current_scene = dialogue_scene_loader.create_scene_node(background_sprite, character_layer)
        if current_scene.get_child_count() > 0:
            add_child(current_scene)
        show_next_dialogue()

func show_next_dialogue() -> void:
    var dialogue = dialogue_scene_loader.get_next_dialogue()
    if dialogue.is_empty():
        return

    match dialogue.type:
        "message":
            _show_message(dialogue)
        "choice":
            _show_choice(dialogue)

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