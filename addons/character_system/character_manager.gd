extends Node

class_name CharacterManager

signal character_added(character: CharacterBase)
signal character_removed(character_id: String)
signal character_state_changed(character: CharacterBase, new_state: String)

var _characters: Dictionary = {}

# 캐릭터 관리
func add_character(id: String, name: String) -> CharacterBase:
    if _characters.has(id):
        return _characters[id]
        
    var character = CharacterBase.new(id, name)
    _characters[id] = character
    emit_signal("character_added", character)
    return character

func remove_character(id: String) -> void:
    if _characters.has(id):
        var character = _characters[id]
        character.free()
        _characters.erase(id)
        emit_signal("character_removed", id)

func get_character(id: String) -> CharacterBase:
    return _characters.get(id)

func get_all_characters() -> Array:
    return _characters.values()

# 캐릭터 상태 관리
func set_character_state(id: String, state: String) -> void:
    var character = get_character(id)
    if character:
        character.set_state(state)
        emit_signal("character_state_changed", character, state)

func get_character_state(id: String) -> String:
    var character = get_character(id)
    if character:
        return character.get_state()
    return ""

# 대화 시스템 통합
func add_character_dialogue(id: String, text: String) -> void:
    var character = get_character(id)
    if character:
        character.add_dialogue(text)

func get_character_dialogue_history(id: String) -> Array:
    var character = get_character(id)
    if character:
        return character.get_dialogue_history()
    return []

# 캐릭터 속성 관리
func set_character_stat(id: String, stat_name: String, value) -> void:
    var character = get_character(id)
    if character:
        character.set_stat(stat_name, value)

func get_character_stat(id: String, stat_name: String):
    var character = get_character(id)
    if character:
        return character.get_stat(stat_name)
    return null