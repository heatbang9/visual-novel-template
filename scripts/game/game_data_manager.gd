extends Node

# 게임 데이터 관리자
# 게임 상태, 설정, 실적 등을 관리하고 저장/로드 기능 제공

signal save_completed
signal load_completed
signal achievement_unlocked(achievement_id: String)
signal setting_changed(setting_name: String, value: Variant)

# 상수
const SAVE_DIR = "user://saves/"
const SETTINGS_FILE = "user://settings.json"
const ACHIEVEMENTS_FILE = "user://achievements.json"

# 게임 데이터
var game_state: Dictionary = {
    "current_scene": "",
    "variables": {},
    "flags": {},
    "character_states": {},
    "dialogue_history": [],
    "play_time": 0
}

# 게임 설정
var settings: Dictionary = {
    "text_speed": 1.0,
    "auto_delay": 2.0,
    "master_volume": 1.0,
    "bgm_volume": 1.0,
    "sfx_volume": 1.0,
    "voice_volume": 1.0,
    "language": "ko",
    "skip_read": true,
    "fullscreen": false
}

# 실적 데이터
var achievements: Dictionary = {}

# 자동 저장 설정
var auto_save_enabled: bool = false
var auto_save_interval: float = 300.0  # 5분
var auto_save_timer: Timer
var last_auto_save_time: float = 0.0


# 초기화
func _ready():
    _initialize()

func _initialize():
    # 저장 디렉토리 생성
    if not DirAccess.dir_exists_absolute(SAVE_DIR):
        DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    
    # 설정 로드
    _load_settings()
    # 실적 로드
    _load_achievements()

# 게임 데이터 저장
func save_game(slot: int) -> void: {
    # 썸네일 추가
    game_state["thumbnail"] = _capture_thumbnail()

    # 자동 저장 데이터 추가
    game_state["auto_save"] = {
        "enabled": auto_save_enabled,
        "last_save_time": last_auto_save_time
    }

func save_game(slot: int) -> void:
    # 현재 시간 추가
    game_state["save_time"] = Time.get_datetime_string_from_system()
    
    # 파일에 저장
    var save_path = SAVE_DIR + "save_" + str(slot) + ".json"
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(game_state))
        emit_signal("save_completed")
    else:
        push_error("세이브 파일을 생성할 수 없습니다: " + save_path)

# 게임 데이터 로드
func load_game(slot: int) -> bool:
    var save_path = SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(save_path):
        push_error("세이브 파일이 존재하지 않습니다: " + save_path)
        return false
    
    var file = FileAccess.open(save_path, FileAccess.READ)
    if not file:
        push_error("세이브 파일을 읽을 수 없습니다: " + save_path)
        return false
    
    var json = JSON.parse_string(file.get_as_text())
    if json:
        game_state = json
        emit_signal("load_completed")
        return true
    
    push_error("세이브 파일이 손상되었습니다: " + save_path)
    return false

# 모든 세이브 슬롯 정보 가져오기
func get_save_slots() -> Array:
    var slots = []
    var dir = DirAccess.open(SAVE_DIR)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.begins_with("save_") and file_name.ends_with(".json"):
                var slot = file_name.split("_")[1].split(".")[0].to_int()
                var file = FileAccess.open(SAVE_DIR + file_name, FileAccess.READ)
                if file:
                    var data = JSON.parse_string(file.get_as_text())
                    if data:
                        slots.append({
                            "slot": slot,
                            "save_time": data.save_time,
                            "scene": data.current_scene,
                            "play_time": data.play_time
                        })
            file_name = dir.get_next()
    return slots

# 설정 저장
func save_settings() -> void:
    var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(settings))
    else:
        push_error("설정 파일을 저장할 수 없습니다.")

# 설정 로드
func _load_settings() -> void:
    if FileAccess.file_exists(SETTINGS_FILE):
        var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
        if file:
            var json = JSON.parse_string(file.get_as_text())
            if json:
                settings = json

# 설정 변경
func set_setting(name: String, value: Variant) -> void:
    if settings.has(name) and settings[name] != value:
        settings[name] = value
        save_settings()
        emit_signal("setting_changed", name, value)

# 실적 정의
func define_achievements(achievements_data: Dictionary) -> void:
    for id in achievements_data:
        if not achievements.has(id):
            achievements[id] = {
                "id": id,
                "title": achievements_data[id].title,
                "description": achievements_data[id].description,
                "icon": achievements_data[id].icon,
                "unlocked": false,
                "unlock_time": ""
            }
    _save_achievements()

# 실적 달성
func unlock_achievement(achievement_id: String) -> void:
    if achievements.has(achievement_id) and not achievements[achievement_id].unlocked:
        achievements[achievement_id].unlocked = true
        achievements[achievement_id].unlock_time = Time.get_datetime_string_from_system()
        _save_achievements()
        emit_signal("achievement_unlocked", achievement_id)

# 실적 저장
func _save_achievements() -> void:
    var file = FileAccess.open(ACHIEVEMENTS_FILE, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(achievements))
    else:
        push_error("실적 파일을 저장할 수 없습니다.")

# 실적 로드
func _load_achievements() -> void:
    if FileAccess.file_exists(ACHIEVEMENTS_FILE):
        var file = FileAccess.open(ACHIEVEMENTS_FILE, FileAccess.READ)
        if file:
            var json = JSON.parse_string(file.get_as_text())
            if json:
                achievements = json

# 게임 변수 설정
func set_variable(name: String, value: Variant) -> void:
    game_state.variables[name] = value

# 게임 변수 가져오기
func get_variable(name: String, default_value: Variant = null) -> Variant:
    return game_state.variables.get(name, default_value)

# 플래그 설정
func set_flag(name: String, value: bool = true) -> void:
    game_state.flags[name] = value

# 플래그 확인
func has_flag(name: String) -> bool:
    return game_state.flags.get(name, false)

# 캐릭터 상태 저장
func save_character_state(character_id: String, state: Dictionary) -> void:
    game_state.character_states[character_id] = state

# 캐릭터 상태 로드
func load_character_state(character_id: String) -> Dictionary:
    return game_state.character_states.get(character_id, {})

# 자동 저장 시작
func start_auto_save_timer() -> void:
    auto_save_enabled = true
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = auto_save_interval
    auto_save_timer.one_shot = false
    auto_save_timer.timeout.connect(_on_auto_save_timeout)
    add_child(auto_save_timer)
    auto_save_timer.start()

func _on_auto_save_timeout() -> void:
    if auto_save_enabled:
        auto_save(0)  # 슬롯 0번에 자동 저장
        last_auto_save_time = Time.get_ticks_msec() / 1000.0
        emit_signal("auto_save_triggered")

# 자동 저장 정지
func stop_auto_save_timer() -> void:
    auto_save_enabled = false
    if auto_save_timer:
        auto_save_timer.stop()
        auto_save_timer.queue_free()
        auto_save_timer = null

# 자동 저장 활성화/비활성화
func enable_auto_save(enabled: bool) -> void:
    if enabled and not auto_save_enabled:
        start_auto_save_timer()
    elif not enabled and auto_save_enabled:
        stop_auto_save_timer()

# 자동 저장 여부 확인
func is_auto_save_enabled() -> bool:
    return auto_save_enabled

# 수동 자동 저장 트리거
func trigger_auto_save() -> void:
    if auto_save_enabled:
        _on_auto_save_timeout()

# 체크포인트 설정 (자동 저장 트리거용)
func set_checkpoint(checkpoint_id: String) -> void:
    set_flag("checkpoint_" + checkpoint_id, true)
    if auto_save_enabled:
        trigger_auto_save()

# 썸네일 캡처 (플레이스홀더)
func _capture_thumbnail() -> String:
    # TODO: 실제 구현에서는 스크린샷 캡처
    # 여기서는 빈 문자열 반환
    return ""
