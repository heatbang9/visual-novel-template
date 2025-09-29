extends Control

# 실적 UI 컨트롤러
# 실적 목록 표시 및 알림 관리

@onready var achievement_list = $VBoxContainer/ScrollContainer/AchievementList
@onready var unlocked_count_label = $VBoxContainer/Stats/UnlockedCount
@onready var close_button = $VBoxContainer/CloseButton
@onready var unlock_popup = $UnlockPopup
@onready var popup_icon = $UnlockPopup/Panel/VBoxContainer/Icon
@onready var popup_name = $UnlockPopup/Panel/VBoxContainer/AchievementName
@onready var popup_description = $UnlockPopup/Panel/VBoxContainer/Description
@onready var popup_ok_button = $UnlockPopup/Panel/VBoxContainer/OKButton

var game_data_manager: Node
var achievement_items: Dictionary = {}

func _ready():
    game_data_manager = get_node("/root/GameDataManager")
    _connect_signals()
    _load_achievements()

# 시그널 연결
func _connect_signals():
    close_button.pressed.connect(func(): hide())
    popup_ok_button.pressed.connect(func(): unlock_popup.hide())
    game_data_manager.achievement_unlocked.connect(_on_achievement_unlocked)

# 실적 로드 및 표시
func _load_achievements():
    # 기존 목록 클리어
    for child in achievement_list.get_children():
        child.queue_free()
    achievement_items.clear()
    
    # 실적 정보 로드
    var achievements = game_data_manager.achievements
    var unlocked_count = 0
    var total_count = achievements.size()
    
    for id in achievements:
        var achievement = achievements[id]
        var item = _create_achievement_item(achievement)
        achievement_list.add_child(item)
        achievement_items[id] = item
        
        if achievement.unlocked:
            unlocked_count += 1
    
    # 달성률 업데이트
    unlocked_count_label.text = "달성: %d/%d" % [unlocked_count, total_count]

# 실적 항목 생성
func _create_achievement_item(achievement: Dictionary) -> Control:
    var item = Panel.new()
    item.custom_minimum_size = Vector2(0, 80)
    
    var hbox = HBoxContainer.new()
    hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    hbox.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
    item.add_child(hbox)
    
    # 아이콘
    var icon = TextureRect.new()
    icon.custom_minimum_size = Vector2(60, 60)
    icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    if achievement.icon:
        icon.texture = load(achievement.icon)
    hbox.add_child(icon)
    
    # 텍스트 컨테이너
    var text_container = VBoxContainer.new()
    text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(text_container)
    
    # 이름
    var name_label = Label.new()
    name_label.text = achievement.title
    name_label.add_theme_font_size_override("font_size", 18)
    text_container.add_child(name_label)
    
    # 설명
    var description_label = Label.new()
    description_label.text = achievement.description
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
    text_container.add_child(description_label)
    
    # 달성 시간
    if achievement.unlocked:
        var time_label = Label.new()
        time_label.text = "달성: " + achievement.unlock_time
        time_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
        text_container.add_child(time_label)
        item.modulate = Color(1, 1, 1, 1)
    else:
        item.modulate = Color(0.5, 0.5, 0.5, 1)
    
    return item

# 실적 달성 처리
func _on_achievement_unlocked(achievement_id: String):
    var achievement = game_data_manager.achievements[achievement_id]
    
    # UI 업데이트
    if achievement_items.has(achievement_id):
        var old_item = achievement_items[achievement_id]
        var new_item = _create_achievement_item(achievement)
        achievement_list.remove_child(old_item)
        old_item.queue_free()
        achievement_list.add_child(new_item)
        achievement_items[achievement_id] = new_item
    
    # 달성률 업데이트
    var unlocked = game_data_manager.achievements.values().filter(func(a): return a.unlocked).size()
    var total = game_data_manager.achievements.size()
    unlocked_count_label.text = "달성: %d/%d" % [unlocked, total]
    
    # 팝업 표시
    _show_unlock_popup(achievement)

# 달성 팝업 표시
func _show_unlock_popup(achievement: Dictionary):
    if achievement.icon:
        popup_icon.texture = load(achievement.icon)
    popup_name.text = achievement.title
    popup_description.text = achievement.description
    unlock_popup.show()