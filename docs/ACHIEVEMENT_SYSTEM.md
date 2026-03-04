# 업적 시스템 (Achievement System)

## 개요

업적 시스템은 플레이어의 진행 상황을 추적하고 특정 조건 달성 시 업적을 잠금 해제하는 기능을 제공합니다.

## 구성 요소

### 1. AchievementManager (싱글톤)

`res://addons/scenario_system/achievement_manager.gd`

업적 데이터 관리, 잠금 해제, 저장/로드를 담당합니다.

#### 주요 함수

```gdscript
# 업적 잠금 해제
AchievementManager.unlock_achievement(id: String) -> bool

# 업적 정보 조회
AchievementManager.get_achievement(id: String) -> Dictionary
AchievementManager.get_all_achievements() -> Array
AchievementManager.get_unlocked_achievements() -> Array

# 업적 상태 확인
AchievementManager.is_achievement_unlocked(id: String) -> bool
AchievementManager.is_achievement_hidden(id: String) -> bool

# 진행도 관리
AchievementManager.set_achievement_progress(id: String, progress: float)
AchievementManager.get_achievement_progress(id: String) -> float
AchievementManager.get_total_progress() -> float

# 조건 확인 (자동 잠금 해제)
AchievementManager.check_and_unlock_achievement(id: String) -> bool
AchievementManager.check_all_achievements(variables: Dictionary) -> Array
```

### 2. ScenarioManager 확장

`res://addons/scenario_system/scenario_manager.gd`

XML 시나리오에서 `<achievement>` 태그를 파싱하고 AchievementManager에 등록합니다.

### 3. UI 알림 시스템

`res://scenes/ui/achievement_notification.tscn`
`res://scenes/ui/achievement_notification.gd`

업적 달성 시 화면에 팝업을 표시합니다.

## XML 포맷

### 기본 업적 정의

```xml
<achievement id="first_love" name="첫사랑" description="첫 키스 장면 완료">
    <achievement_condition type="variable" variable="kiss_count" operator=">=" value="1"/>
    <reward type="unlock" target="secret_ending"/>
</achievement>
```

### 업적 속성

| 속성 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | String | ✅ | 업적 고유 ID |
| name | String | ✅ | 업적 이름 |
| description | String | ❌ | 업적 설명 |
| icon | String | ❌ | 아이콘 경로 |
| hidden | bool | ❌ | 숨겨진 업적 여부 (기본값: false) |
| auto_unlock | bool | ❌ | 자동 잠금 해제 여부 (기본값: true) |

### 조건 타입

#### 1. 변수 조건 (variable)

```xml
<achievement_condition type="variable" variable="affection_level" operator=">=" value="10"/>
```

| 연산자 | 설명 |
|--------|------|
| ==, = | 같음 |
| != | 다름 |
| >= | 이상 |
| <= | 이하 |
| > | 초과 |
| < | 미만 |
| contains | 포함 |
| starts_with | 시작 문자열 |
| ends_with | 끝 문자열 |

#### 2. 플래그 조건 (flag)

```xml
<achievement_condition type="flag" flag="secret_route_discovered"/>
```

#### 3. 루트 완료 조건 (route_complete)

```xml
<achievement_condition type="route_complete" route="main"/>
```

### 보상 타입

#### 1. 콘텐츠 잠금 해제 (unlock)

```xml
<reward type="unlock" target="secret_ending"/>
```
`{target}_unlocked` 변수를 `true`로 설정합니다.

#### 2. 변수 설정 (variable)

```xml
<reward type="variable" target="bonus_points" value="100"/>
```

#### 3. 아이템 지급 (item)

```xml
<reward type="item" target="special_item"/>
```

#### 4. 연관 업적 잠금 해제 (achievement)

```xml
<reward type="achievement" target="completionist"/>
```

## 수동 업적 트리거

씬 내에서 수동으로 업적을 트리거할 수 있습니다:

```xml
<scene id="special_scene" path="res://scenes/special.tscn">
    <trigger_achievement id="special_moment"/>
</scene>
```

또는 코드에서 직접 호출:

```gdscript
AchievementManager.unlock_achievement("special_moment")
# 또는
ScenarioManager.trigger_achievement("special_moment")
```

## 시그널

### AchievementManager

```gdscript
# 업적 잠금 해제 시
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

# 업적 진행도 업데이트 시
signal achievement_progress_updated(achievement_id: String, progress: float)
```

### ScenarioManager

```gdscript
# 업적 트리거 시
signal achievement_triggered(achievement_id: String)
```

## UI 알림 연동

### 자동 알림

`AchievementNotification` 씬을 메인 씬에 추가하면 자동으로 알림이 표시됩니다:

```gdscript
# 메인 씬에 추가
var notification = preload("res://scenes/ui/achievement_notification.tscn").instantiate()
add_child(notification)
```

### 커스텀 알림

시그널을 직접 연결하여 커스텀 UI를 구현할 수 있습니다:

```gdscript
func _ready():
    AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(id: String, data: Dictionary):
    # 커스텀 UI 표시
    show_custom_notification(data.name, data.description)
```

## 저장 데이터

업적 데이터는 `user://achievements.save`에 저장됩니다:

```gdscript
{
    "unlocked": {
        "first_love": {
            "id": "first_love",
            "unlocked_at": "2024-01-15T14:30:00"
        }
    },
    "progress": {
        "first_love": 1.0,
        "popular": 0.5
    },
    "version": 1
}
```

## 테스트

테스트 시나리오: `res://test_scenarios/achievement_test.xml`

```bash
# Godot 에디터에서 테스트
1. 프로젝트 실행
2. 콘솔에서 다음 실행:
   ScenarioManager.load_scenario("res://test_scenarios/achievement_test.xml")
   ScenarioManager.set_variable("kiss_count", 1)
   # "first_love" 업적이 자동으로 잠금 해제됨
```

## 주의사항

1. **성능**: `check_all_achievements()`는 변수 변경 시마다 호출됩니다. 업적이 많을 경우 최적화가 필요할 수 있습니다.

2. **숨겨진 업적**: `hidden="true"`로 설정하면 UI에서 설명이 숨겨집니다.

3. **자동 vs 수동**: 
   - `auto_unlock="true"` (기본값): 조건 충족 시 자동 잠금 해제
   - `auto_unlock="false"`: `<trigger_achievement>`로 수동 트리거 필요

4. **저장 타이밍**: 업적 잠금 해제 시 즉시 저장됩니다.

## 확장 가능성

1. **스팀 업적 연동**: Steam API와 연동하여 Steam 업적 동기화
2. **클라우드 저장**: 업적 데이터 클라우드 동기화
3. **업적 갤러리**: 모든 업적을 보여주는 UI 화면
4. **진행도 표시**: 업적 달성 진행도 시각화
