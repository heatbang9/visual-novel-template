extends Node

@onready var dialogue_scene_loader = $DialogueSceneLoader
@onready var dialogue_text = $UI/DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UI/DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var choice_container = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer
@onready var choice_label = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer/ChoiceLabel
@onready var options_container = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoiceContainer/Options

var current_scene: Node = null

func _ready() -> void:
    dialogue_scene_loader.dialogue_started.connect(_on_dialogue_started)
    dialogue_scene_loader.dialogue_ended.connect(_on_dialogue_ended)
    load_first_scene()

func load_first_scene() -> void:
    var result = dialogue_scene_loader.load_scene_from_xml("res://scenes/dialogue/scene1.xml")
    if result == OK:
        current_scene = dialogue_scene_loader.create_scene_node()
        add_child(current_scene)
        show_next_dialogue()

func show_next_dialogue() -> void:
    var dialogue = dialogue_scene_loader.get_next_dialogue()
    if dialogue.is_empty():
        _on_dialogue_ended(dialogue_scene_loader.current_scene_data.name)
        return
    
    match dialogue.type:
        "message":
            _show_message(dialogue)
        "choice":
            _show_choice(dialogue)

func _show_message(message: Dictionary) -> void:
    choice_container.hide()
    speaker_label.text = dialogue_scene_loader.current_scene_data.characters[message.speaker].name if message.speaker != "narrator" else "내레이터"
    dialogue_text.text = message.text

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

func _on_dialogue_started(scene_name: String) -> void:
    print("Dialogue started: ", scene_name)

func _on_dialogue_ended(scene_name: String) -> void:
    print("Dialogue ended: ", scene_name)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if not choice_container.visible:
                show_next_dialogue()