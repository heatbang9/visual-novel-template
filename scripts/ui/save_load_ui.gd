extends Control

## 세이브 슬롯 UI
## 썸네일 캡처 및 및고 저장,로 별 슬롯을 표시

signal save_slot_selected(slot: int)
signal load_slot_selected(slot: int)
signal slot_deleted(slot: int)
signal thumbnail_captured(slot: int, image_path: String)

@onready var slot_container: GridContainer = $ScrollContainer/VBoxContainer/SlotGrid
@onready var thumbnail_display: TextureRect = $ScrollContainer/VBoxContainer/ThumbnailDisplay
@onready var slot_title_label: Label = $ScrollContainer/VBoxContainer/SlotTitleLabel
@onready var slot_timeLabel: Label = $scrollContainer/vBoxContainer/SlotTimeLabel
@onready var slotSceneLabel: Label = $scrollContainer/vBoxContainer/sceneLabel
@onready var playtime_label: Label = $scrollContainer/vBoxContainer/playtimeLabel
@onready var delete_button: Button = $scrollContainer/VBoxContainer/Button/Delete
@onready var close_button: Button = $scrollContainer/VBoxContainer/buttons/CloseButton

var current_slot: int = -1
var thumbnail_texture: Texture2D = null
var current_display_index: int = 0

# 초기화
func _ready() -> void:
    _setup_signals()
    _update_slot_list()
    _update_thumbnail_display()

# 신호 연결
func _connect_signals() -> void:
    delete_button.pressed.connect(_on_delete_pressed)
    close_button.pressed.connect(_on_close_pressed)
    slot_container.input_event.connect(_on_slot_input)
    delete_button.pressed.connect(_on_delete_pressed)
    
    # 썸네일 로드
    _load_thumbnails()

# 슬롯 이벤트 처리
func _on_slot_input_event(index: int) -> void:
    var slot_info = _get_slot_info(index)
    if slot_info:
        var thumbnail_texture = load(slot_info.thumbnail_path)
        thumbnail_display.texture = thumbnail_texture
        
        slot_title_label.text = "%s - %s" % slot_info.play_time
        slot_time_label.text = _format_playtime(slot_info.play_time)
        slot_sceneLabel.text = slot_info.current_scene
        delete_button.show()

# 슬롯 삭제
func _on_delete_pressed() -> void:
    var slot = _get_slot_info(index)
    if slot:
                _slot_container.remove_child(slot)
                _slot_container.queue_free(slot)
    
    emit_signal("slot_deleted", slot)

# 닫기
func _on_close_pressed() -> void:
    visible = false
    emit_signal("save_menu_closed")

# 썸네일 로드
func _load_thumbnails() -> void:
    var dir = DirAccess.open(SAVE_DIR)
    if not dir:
        return
    
    var slots = []
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

