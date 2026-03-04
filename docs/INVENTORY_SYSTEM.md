# 인벤토리 시스템 문서

## 개요

Phase 3에서 추가된 인벤토리 시스템은 XML 시나리오 내에서 아이템 정의, 획득, 사용을 관리합니다.

## 구성 요소

### 1. InventoryManager (싱글톤)
- **파일:** `addons/scenario_system/inventory_manager.gd`
- **역할:** 아이템 정의, 인벤토리 상태, 저장/로드 관리

### 2. ScenarioManager 확장
- **파일:** `addons/scenario_system/scenario_manager.gd`
- **추가 기능:** `<inventory>` 태그 파싱, 아이템 관련 액션 처리

### 3. UI 인벤토리 패널
- **파일:** `scenes/ui/inventory/inventory_panel.tscn`
- **스크립트:** `scenes/ui/inventory/inventory_panel.gd`
- **기능:** 아이템 목록 표시, 정보 확인, 아이템 사용

---

## XML 태그

### `<inventory>` - 아이템 정의

시나리오 내에서 사용 가능한 아이템을 정의합니다.

```xml
<inventory id="아이템_ID" name="표시 이름" description="아이템 설명">
    <icon>res://path/to/icon.png</icon>
    <stackable>true</stackable>
    <max_count>99</max_count>
    <consumable>true</consumable>
    <tag value="태그명"/>
    <on_use>
        <on_use_effect type="효과타입" ... />
    </on_use>
</inventory>
```

#### 속성

| 속성 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| id | String | ✓ | - | 아이템 고유 식별자 |
| name | String | | id | 표시 이름 |
| description | String | | "" | 아이템 설명 |

#### 하위 태그

| 태그 | 설명 |
|------|------|
| `<icon>` | 아이콘 리소스 경로 |
| `<stackable>` | 중복 가능 여부 (true/false) |
| `<max_count>` | 최대 보유 수량 |
| `<consumable>` | 사용 시 소모 여부 |
| `<tag>` | 분류용 태그 (여러 개 가능) |
| `<on_use>` | 사용 시 효과 목록 |

### `<give_item>` - 아이템 지급

씬 내에서 플레이어에게 아이템을 지급합니다.

```xml
<give_item id="아이템_ID" count="수량"/>
```

### `<take_item>` - 아이템 제거

씬 내에서 플레이어의 아이템을 제거합니다.

```xml
<take_item id="아이템_ID" count="수량"/>
```

### 선택지 요구사항 - 아이템 확인

```xml
<requirement variable="아이템_ID" operator="has_item"/>
```

---

## 사용 효과 (on_use_effect)

### 변수 변경
```xml
<on_use_effect type="variable" variable="변수명" modifier="add|set|subtract|multiply|divide" value="값"/>
```

### 업적 트리거
```xml
<on_use_effect type="trigger_achievement" id="업적_ID"/>
```

### 다른 아이템 지급
```xml
<on_use_effect type="give_item" item_id="아이템_ID" count="수량"/>
```

### 다른 아이템 제거
```xml
<on_use_effect type="remove_item" item_id="아이템_ID" count="수량"/>
```

---

## API 레퍼런스

### InventoryManager

#### 시그널

```gdscript
signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal item_used(item_id: String)
signal inventory_changed()
signal item_count_changed(item_id: String, new_count: int)
```

#### 주요 함수

```gdscript
# 아이템 추가
func add_item(id: String, count: int = 1) -> bool

# 아이템 제거
func remove_item(id: String, count: int = 1) -> bool

# 아이템 사용
func use_item(id: String) -> bool

# 아이템 보유 확인
func has_item(id: String) -> bool

# 아이템 수량 확인
func get_item_count(id: String) -> int

# 아이템 정보 (정의 + 수량)
func get_item(id: String) -> Dictionary

# 전체 인벤토리
func get_all_items() -> Array

# 태그로 필터링
func get_items_by_tag(tag: String) -> Array

# 저장/로드
func save() -> void
func load() -> void

# 초기화 (개발용)
func reset_inventory() -> void
```

### ScenarioManager (확장)

```gdscript
# 아이템 지급
func give_item(item_id: String, count: int = 1) -> bool

# 아이템 제거
func take_item(item_id: String, count: int = 1) -> bool

# 아이템 사용
func use_inventory_item(item_id: String) -> bool

# 확인 함수
func has_inventory_item(item_id: String) -> bool
func get_inventory_item_count(item_id: String) -> int
func get_all_inventory_items() -> Array
```

---

## UI 패널 사용법

### 인벤토리 패널 열기

```gdscript
# 방법 1: 직접 인스턴스화
var inventory_panel = preload("res://scenes/ui/inventory/inventory_panel.tscn").instantiate()
add_child(inventory_panel)
inventory_panel.open()

# 방법 2: 씬에 미리 배치된 경우
$InventoryPanel.open()
$InventoryPanel.toggle()  # 열기/닫기 토글
```

### 시그널 연결

```gdscript
inventory_panel.item_selected.connect(_on_inventory_item_selected)
inventory_panel.item_used.connect(_on_inventory_item_used)
inventory_panel.panel_closed.connect(_on_inventory_closed)

func _on_inventory_item_selected(item_id: String):
    print("선택된 아이템: ", item_id)

func _on_inventory_item_used(item_id: String):
    print("아이템 사용: ", item_id)
```

---

## 완전한 예제

### 아이템 정의

```xml
<inventory id="health_potion" name="체력 포션" description="HP를 50 회복">
    <icon>res://assets/items/potion.png</icon>
    <stackable>true</stackable>
    <max_count>99</max_count>
    <consumable>true</consumable>
    <tag value="consumable"/>
    <tag value="healing"/>
    <on_use>
        <on_use_effect type="variable" variable="hp" modifier="add" value="50"/>
    </on_use>
</inventory>
```

### 씬에서 아이템 지급

```xml
<scene id="treasure_room" path="res://scenes/treasure.tscn">
    <give_item id="health_potion" count="3"/>
    <give_item id="gold_coin" count="100"/>
    
    <choice id="drink_potion" text="포션 마시기">
        <requirement variable="health_potion" operator="has_item"/>
    </choice>
</scene>
```

### 코드에서 사용

```gdscript
# 아이템 지급
InventoryManager.add_item("health_potion", 5)

# 아이템 사용
InventoryManager.use_item("health_potion")

# 확인
if InventoryManager.has_item("health_potion"):
    var count = InventoryManager.get_item_count("health_potion")
    print("체력 포션: %d개" % count)
```

---

## 저장 데이터

인벤토리는 `user://inventory.save`에 자동 저장됩니다.

```gdscript
# 수동 저장/로드
InventoryManager.save()
InventoryManager.load()

# 개발용 초기화
InventoryManager.reset_inventory()
```

---

## 주의사항

1. **아이템 정의 필수**: `<give_item>` 사용 전 반드시 `<inventory>`로 아이템 정의 필요
2. **아이콘 경로**: 존재하지 않는 아이콘 경로는 무시됨 (에러 없음)
3. **자동 저장**: 아이템 추가/제거/사용 시 자동 저장됨
4. **Phase 1, 2 호환**: 기존 업적, 변수, 선택지 시스템과 완전 호환

---

## 테스트

테스트 시나리오: `test_scenarios/inventory_test.xml`

```bash
# Godot 에디터에서 테스트
# 1. project.godot에 autoload 등록 확인
# 2. test_scenarios/inventory_test.xml 로드
# 3. 인벤토리 패널로 아이템 확인
```

---

## 업데이트 내역

- **Phase 3 (2024-03-04)**
  - `<inventory>` 태그 파싱
  - InventoryManager 싱글톤
  - UI 인벤토리 패널
  - 아이템 사용 효과 시스템
  - 저장/로드 기능
