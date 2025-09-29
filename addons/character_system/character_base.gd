extends Node

class_name CharacterBase

# 캐릭터 기본 속성
var _id: String
var _name: String
var _stats: Dictionary = {}
var _state: String = "idle"
var _dialogue_history: Array = []

# 초기화
func _init(character_id: String, character_name: String):
    _id = character_id
    _name = character_name

# 기본 속성 접근자
func get_id() -> String:
    return _id

func get_name() -> String:
    return _name

func get_state() -> String:
    return _state

# 상태 관리
func set_state(new_state: String) -> void:
    _state = new_state
    _on_state_changed()

# 속성 관리
func set_stat(stat_name: String, value) -> void:
    _stats[stat_name] = value

func get_stat(stat_name: String):
    return _stats.get(stat_name)

# 대화 기록 관리
func add_dialogue(text: String) -> void:
    _dialogue_history.append({
        "text": text,
        "timestamp": Time.get_ticks_msec()
    })

func get_dialogue_history() -> Array:
    return _dialogue_history

# 가상 메서드
func _on_state_changed() -> void:
    # 상태 변경 시 호출되는 가상 메서드
    pass