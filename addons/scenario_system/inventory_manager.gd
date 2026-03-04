extends Node

## 인벤토리 관리 싱글톤
## 아이템 추가, 제거, 사용 및 저장/로드를 담당

# class_name InventoryManager

# 시그널
signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal item_used(item_id: String)
signal inventory_changed()
signal item_count_changed(item_id: String, new_count: int)

# 아이템 정의 데이터 (XML에서 로드)
var _item_definitions: Dictionary = {}

# 플레이어 인벤토리 (아이템 ID -> 수량)
var _inventory: Dictionary = {}

# 저장 경로
const SAVE_PATH := "user://inventory.save"

func _ready() -> void:
	_load_inventory()

## 아이템 정의 등록 (XML 파싱 시 호출)
func register_item_definition(id: String, data: Dictionary) -> void:
	if _item_definitions.has(id):
		push_warning("이미 등록된 아이템입니다: " + id)
		return
	
	_item_definitions[id] = {
		"id": id,
		"name": data.get("name", id),
		"description": data.get("description", ""),
		"icon": data.get("icon", ""),
		"stackable": data.get("stackable", true),
		"max_count": data.get("max_count", 99),
		"on_use": data.get("on_use", []),
		"consumable": data.get("consumable", true),
		"tags": data.get("tags", [])
	}

## 아이템 정보 가져오기
func get_item_definition(id: String) -> Dictionary:
	return _item_definitions.get(id, {})

## 모든 아이템 정의 가져오기
func get_all_item_definitions() -> Dictionary:
	return _item_definitions.duplicate()

## 아이템 추가
func add_item(id: String, count: int = 1) -> bool:
	if not _item_definitions.has(id):
		push_error("존재하지 않는 아이템입니다: " + id)
		return false
	
	if count <= 0:
		push_error("아이템 수량은 1 이상이어야 합니다")
		return false
	
	var item_def = _item_definitions[id]
	var max_count = item_def.get("max_count", 99)
	var stackable = item_def.get("stackable", true)
	
	if not stackable and _inventory.has(id):
		push_warning("중복 불가 아이템이 이미 있습니다: " + id)
		return false
	
	var current_count = _inventory.get(id, 0)
	var new_count = current_count + count
	
	# 최대 수량 제한
	if new_count > max_count:
		new_count = max_count
	
	_inventory[id] = new_count
	
	emit_signal("item_added", id, count)
	emit_signal("item_count_changed", id, new_count)
	emit_signal("inventory_changed")
	
	# 자동 저장
	_save_inventory()
	
	return true

## 아이템 제거
func remove_item(id: String, count: int = 1) -> bool:
	if not _inventory.has(id):
		push_error("인벤토리에 없는 아이템입니다: " + id)
		return false
	
	var current_count = _inventory[id]
	if current_count < count:
		push_error("아이템 수량이 부족합니다. 현재: %d, 요청: %d" % [current_count, count])
		return false
	
	var new_count = current_count - count
	
	if new_count <= 0:
		_inventory.erase(id)
		emit_signal("item_count_changed", id, 0)
	else:
		_inventory[id] = new_count
		emit_signal("item_count_changed", id, new_count)
	
	emit_signal("item_removed", id, count)
	emit_signal("inventory_changed")
	
	# 자동 저장
	_save_inventory()
	
	return true

## 아이템 사용
func use_item(id: String) -> bool:
	if not _inventory.has(id):
		push_error("인벤토리에 없는 아이템입니다: " + id)
		return false
	
	if not _item_definitions.has(id):
		push_error("아이템 정의가 없습니다: " + id)
		return false
	
	var item_def = _item_definitions[id]
	var on_use_effects = item_def.get("on_use", [])
	
	# 사용 효과 적용
	if not _apply_use_effects(on_use_effects):
		push_warning("아이템 사용 효과 적용 실패: " + id)
		return false
	
	emit_signal("item_used", id)
	
	# 소모성 아이템이면 수량 감소
	if item_def.get("consumable", true):
		remove_item(id, 1)
	else:
		emit_signal("inventory_changed")
		_save_inventory()
	
	return true

## 사용 효과 적용
func _apply_use_effects(effects: Array) -> bool:
	for effect in effects:
		var type = effect.get("type", "")
		
		match type:
			"variable":
				var variable = effect.get("variable", "")
				var modifier = effect.get("modifier", "set")
				var value = effect.get("value", 0)
				
				if variable.is_empty():
					push_error("변수명이 비어있습니다")
					continue
				
				_apply_variable_effect(variable, modifier, value)
			
			"trigger_achievement":
				var achievement_id = effect.get("id", "")
				if not achievement_id.is_empty():
					AchievementManager.unlock_achievement(achievement_id)
			
			"give_item":
				var item_id = effect.get("item_id", "")
				var count = effect.get("count", 1)
				if not item_id.is_empty():
					add_item(item_id, count)
			
			"remove_item":
				var item_id = effect.get("item_id", "")
				var count = effect.get("count", 1)
				if not item_id.is_empty():
					remove_item(item_id, count)
			
			"custom":
				# 커스텀 효과는 시그널로 외부에서 처리
				push_warning("커스텀 아이템 효과: " + str(effect))
	
	return true

## 변수 효과 적용
func _apply_variable_effect(variable: String, modifier: String, value) -> void:
	var current_value = ScenarioManager.get_variable(variable)
	
	match modifier:
		"set":
			ScenarioManager.set_variable(variable, value)
		"add":
			ScenarioManager.set_variable(variable, current_value + value)
		"subtract":
			ScenarioManager.set_variable(variable, current_value - value)
		"multiply":
			ScenarioManager.set_variable(variable, current_value * value)
		"divide":
			if value != 0:
				ScenarioManager.set_variable(variable, current_value / value)
		_:
			push_warning("알 수 없는 modifier: " + modifier)

## 아이템 수량 가져오기
func get_item_count(id: String) -> int:
	return _inventory.get(id, 0)

## 아이템이 있는지 확인
func has_item(id: String) -> bool:
	return _inventory.has(id) and _inventory[id] > 0

## 아이템 전체 정보 가져오기 (정의 + 수량)
func get_item(id: String) -> Dictionary:
	var def = get_item_definition(id)
	if def.is_empty():
		return {}
	
	var result = def.duplicate()
	result["count"] = get_item_count(id)
	return result

## 인벤토리 전체 가져오기
func get_all_items() -> Array:
	var result := []
	for id in _inventory:
		result.append(get_item(id))
	return result

## 인벤토리 비어있는지 확인
func is_inventory_empty() -> bool:
	return _inventory.is_empty()

## 인벤토리 아이템 총 개수
func get_total_item_count() -> int:
	var total := 0
	for id in _inventory:
		total += _inventory[id]
	return total

## 아이템 정의 존재 확인
func has_item_definition(id: String) -> bool:
	return _item_definitions.has(id)

## 태그로 아이템 필터링
func get_items_by_tag(tag: String) -> Array:
	var result := []
	for id in _inventory:
		var def = _item_definitions.get(id, {})
		var tags = def.get("tags", [])
		if tag in tags:
			result.append(get_item(id))
	return result

## 인벤토리 초기화 (개발용)
func reset_inventory() -> void:
	_inventory.clear()
	emit_signal("inventory_changed")
	_save_inventory()

## 아이템 정의 초기화 (개발용)
func reset_definitions() -> void:
	_item_definitions.clear()

## 저장
func _save_inventory() -> void:
	var save_data := {
		"inventory": _inventory,
		"version": 1
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

## 로드
func _load_inventory() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if typeof(save_data) == TYPE_DICTIONARY:
			_inventory = save_data.get("inventory", {})

## 명시적 저장 (외부 호출용)
func save() -> void:
	_save_inventory()

## 명시적 로드 (외부 호출용)
func load() -> void:
	_load_inventory()
