extends Control

## 인벤토리 UI 패널
## 아이템 목록 표시, 사용 버튼, 수량 표시

# class_name InventoryPanel

# 시그널
signal item_selected(item_id: String)
signal item_used(item_id: String)
signal panel_closed()

# 노드 참조
@onready var item_list: ItemList = $VBoxContainer/ItemList
@onready var item_info: RichTextLabel = $VBoxContainer/ItemInfo
@onready var use_button: Button = $VBoxContainer/ButtonContainer/UseButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton
@onready var count_label: Label = $VBoxContainer/CountContainer/CountLabel

# 현재 선택된 아이템
var _selected_item_id: String = ""
var _selected_item_index: int = -1

func _ready() -> void:
	# 버튼 시그널 연결
	if use_button:
		use_button.pressed.connect(_on_use_button_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	if item_list:
		item_list.item_selected.connect(_on_item_selected)
	
	# 인벤토리 변경 시그널 연결
	InventoryManager.inventory_changed.connect(_refresh_inventory)
	InventoryManager.item_count_changed.connect(_on_item_count_changed)
	
	# 초기화
	_refresh_inventory()
	_update_use_button()
	
	# 기본적으로 숨김
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

## 패널 열기
func open() -> void:
	visible = true
	_refresh_inventory()
	
	# 첫 번째 아이템 자동 선택
	if item_list and item_list.item_count > 0:
		item_list.select(0)
		_on_item_selected(0)

## 패널 닫기
func close() -> void:
	visible = false
	_selected_item_id = ""
	_selected_item_index = -1
	emit_signal("panel_closed")

## 토글
func toggle() -> void:
	if visible:
		close()
	else:
		open()

## 인벤토리 새로고침
func _refresh_inventory() -> void:
	if not item_list:
		return
	
	item_list.clear()
	
	var items = InventoryManager.get_all_items()
	
	for item in items:
		var id = item.get("id", "")
		var name = item.get("name", id)
		var count = item.get("count", 1)
		var icon_path = item.get("icon", "")
		
		var display_text = name
		if count > 1:
			display_text += " (x%d)" % count
		
		# 아이콘 로드 시도
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			var icon = load(icon_path)
			item_list.add_item(display_text, icon)
		else:
			item_list.add_item(display_text)
		
		# 메타데이터 저장
		var last_index = item_list.item_count - 1
		item_list.set_item_metadata(last_index, id)
	
	# 총 아이템 수 업데이트
	_update_count_label()
	
	# 선택 상태 복원
	if _selected_item_index >= 0 and _selected_item_index < item_list.item_count:
		item_list.select(_selected_item_index)
	else:
		_clear_item_info()

## 아이템 선택 시
func _on_item_selected(index: int) -> void:
	_selected_item_index = index
	
	if not item_list:
		return
	
	var item_id = item_list.get_item_metadata(index)
	if item_id == null:
		return
	
	_selected_item_id = str(item_id)
	
	# 아이템 정보 표시
	_display_item_info(_selected_item_id)
	
	# 사용 버튼 업데이트
	_update_use_button()
	
	emit_signal("item_selected", _selected_item_id)

## 아이템 정보 표시
func _display_item_info(item_id: String) -> void:
	if not item_info:
		return
	
	var item = InventoryManager.get_item(item_id)
	if item.is_empty():
		_clear_item_info()
		return
	
	var name = item.get("name", item_id)
	var description = item.get("description", "")
	var count = item.get("count", 1)
	var stackable = item.get("stackable", true)
	var max_count = item.get("max_count", 99)
	
	var info_text = "[b]%s[/b]\n\n" % name
	info_text += "%s\n\n" % description
	info_text += "[color=gray]수량: %d[/color]\n" % count
	
	if stackable:
		info_text += "[color=gray]최대: %d[/color]" % max_count
	
	item_info.text = info_text

## 아이템 정보 초기화
func _clear_item_info() -> void:
	if item_info:
		item_info.text = "[color=gray]아이템을 선택하세요[/color]"
	
	_selected_item_id = ""
	_selected_item_index = -1
	_update_use_button()

## 사용 버튼 업데이트
func _update_use_button() -> void:
	if not use_button:
		return
	
	if _selected_item_id.is_empty():
		use_button.disabled = true
		use_button.text = "사용"
	else:
		use_button.disabled = false
		use_button.text = "사용"

## 수량 라벨 업데이트
func _update_count_label() -> void:
	if not count_label:
		return
	
	var total_count = InventoryManager.get_total_item_count()
	var unique_count = InventoryManager.get_all_items().size()
	
	count_label.text = "아이템: %d종류 / 총 %d개" % [unique_count, total_count]

## 아이템 수량 변경 시
func _on_item_count_changed(item_id: String, new_count: int) -> void:
	# 현재 선택된 아이템이 변경된 경우 정보 업데이트
	if item_id == _selected_item_id:
		if new_count <= 0:
			_clear_item_info()
		else:
			_display_item_info(_selected_item_id)

## 사용 버튼 클릭
func _on_use_button_pressed() -> void:
	if _selected_item_id.is_empty():
		return
	
	var success = InventoryManager.use_item(_selected_item_id)
	
	if success:
		emit_signal("item_used", _selected_item_id)
		_refresh_inventory()
		
		# 사용 후 다음 아이템 선택
		if item_list and item_list.item_count > 0:
			var next_index = clamp(_selected_item_index, 0, item_list.item_count - 1)
			item_list.select(next_index)
			_on_item_selected(next_index)

## 닫기 버튼 클릭
func _on_close_button_pressed() -> void:
	close()
