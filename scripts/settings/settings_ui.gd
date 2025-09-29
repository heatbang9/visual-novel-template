extends Control

# 설정 UI 컨트롤러
# 게임 설정을 UI를 통해 관리

signal settings_saved
signal settings_cancelled

@onready var text_speed_slider = $ScrollContainer/VBoxContainer/TextSpeedSection/HSlider
@onready var auto_delay_slider = $ScrollContainer/VBoxContainer/AutoDelaySection/HSlider
@onready var master_volume_slider = $ScrollContainer/VBoxContainer/VolumeSection/MasterVolume/HSlider
@onready var bgm_volume_slider = $ScrollContainer/VBoxContainer/VolumeSection/BGMVolume/HSlider
@onready var sfx_volume_slider = $ScrollContainer/VBoxContainer/VolumeSection/SFXVolume/HSlider
@onready var voice_volume_slider = $ScrollContainer/VBoxContainer/VolumeSection/VoiceVolume/HSlider
@onready var fullscreen_checkbox = $ScrollContainer/VBoxContainer/DisplaySection/FullscreenCheckBox
@onready var skip_read_checkbox = $ScrollContainer/VBoxContainer/OtherSection/SkipReadCheckBox
@onready var save_button = $ScrollContainer/VBoxContainer/Buttons/SaveButton
@onready var cancel_button = $ScrollContainer/VBoxContainer/Buttons/CancelButton

var game_data_manager: Node

func _ready():
    game_data_manager = get_node("/root/GameDataManager")
    _connect_signals()
    _load_settings()

# 시그널 연결
func _connect_signals():
    save_button.pressed.connect(_on_save_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
    
    # 볼륨 슬라이더 실시간 적용
    master_volume_slider.value_changed.connect(
        func(value): _apply_volume("master_volume", value))
    bgm_volume_slider.value_changed.connect(
        func(value): _apply_volume("bgm_volume", value))
    sfx_volume_slider.value_changed.connect(
        func(value): _apply_volume("sfx_volume", value))
    voice_volume_slider.value_changed.connect(
        func(value): _apply_volume("voice_volume", value))
    
    # 전체화면 실시간 적용
    fullscreen_checkbox.toggled.connect(_apply_fullscreen)

# 설정 불러오기
func _load_settings():
    text_speed_slider.value = game_data_manager.settings.text_speed
    auto_delay_slider.value = game_data_manager.settings.auto_delay
    master_volume_slider.value = game_data_manager.settings.master_volume
    bgm_volume_slider.value = game_data_manager.settings.bgm_volume
    sfx_volume_slider.value = game_data_manager.settings.sfx_volume
    voice_volume_slider.value = game_data_manager.settings.voice_volume
    fullscreen_checkbox.button_pressed = game_data_manager.settings.fullscreen
    skip_read_checkbox.button_pressed = game_data_manager.settings.skip_read

# 설정 저장
func _save_settings():
    var new_settings = {
        "text_speed": text_speed_slider.value,
        "auto_delay": auto_delay_slider.value,
        "master_volume": master_volume_slider.value,
        "bgm_volume": bgm_volume_slider.value,
        "sfx_volume": sfx_volume_slider.value,
        "voice_volume": voice_volume_slider.value,
        "fullscreen": fullscreen_checkbox.button_pressed,
        "skip_read": skip_read_checkbox.button_pressed
    }
    
    # 설정 적용
    for key in new_settings:
        game_data_manager.set_setting(key, new_settings[key])

# 저장 버튼 처리
func _on_save_pressed():
    _save_settings()
    emit_signal("settings_saved")
    hide()

# 취소 버튼 처리
func _on_cancel_pressed():
    _load_settings()  # 이전 설정으로 복원
    emit_signal("settings_cancelled")
    hide()

# 볼륨 실시간 적용
func _apply_volume(volume_type: String, value: float):
    match volume_type:
        "master_volume":
            AudioServer.set_bus_volume_db(0, linear_to_db(value))
        "bgm_volume":
            AudioServer.set_bus_volume_db(1, linear_to_db(value))
        "sfx_volume":
            AudioServer.set_bus_volume_db(2, linear_to_db(value))
        "voice_volume":
            AudioServer.set_bus_volume_db(3, linear_to_db(value))

# 전체화면 실시간 적용
func _apply_fullscreen(enabled: bool):
    if enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)