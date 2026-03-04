# 플래시백 시스템 문서

## 개요

플래시백 시스템은 비주얼 노벨에서 과거 회상 씬을 관리하는 시스템입니다. 중첩 플래시백, 조건 기반 트리거, 페이드 효과, BGM 변경 등의 기능을 제공합니다.

## 주요 기능

### 1. 플래시백 시작/종료
- `FlashbackManager.start_flashback(id)` - 플래시백 시작
- `FlashbackManager.end_flashback()` - 현재 플래시백 종료
- `FlashbackManager.cancel_flashback()` - 플래시백 취소 (롤백)
- `FlashbackManager.skip_flashback()` - 플래시백 스킵

### 2. 상태 확인
- `FlashbackManager.is_in_flashback()` - 플래시백 중인지 확인
- `FlashbackManager.get_flashback_depth()` - 현재 중첩 깊이
- `FlashbackManager.get_current_flashback()` - 현재 플래시백 데이터
- `FlashbackManager.has_seen_flashback(id)` - 이미 본 플래시백인지 확인

### 3. 중첩 플래시백
- 최대 3개까지 중첩 가능
- 재귀적 플래시백 (동일 ID) 비허용
- 스택 오버플로우 방지

### 4. 조건 기반 트리거
- 변수 값 비교 (==, !=, >=, <=, >, <)
- 자동 트리거 모드
- 수동 트리거

### 5. 효과
- 페이드 인/아웃
- BGM 변경
- 변수 효과

## XML 포맷

### 기본 구조

```xml
<flashback id="childhood_memory" 
           trigger_variable="age" 
           trigger_value="5"
           trigger_operator="=="
           bgm="res://audio/flashback/nostalgic.mp3"
           fade_duration="0.5"
           timeout="300"
           skippable="true"
           auto_trigger="false">
    
    <!-- 플래시백 씬 -->
    <scene id="flashback_scene_01" path="res://scenes/flashback/childhood.tscn"/>
    
    <!-- 플래시백 효과 (종료 시 적용) -->
    <effect variable="flashback_unlocked" value="true"/>
    <effect variable="memory_count" value="1"/>
    
    <!-- 복귀 씬 -->
    <return_to_scene id="after_flashback"/>
</flashback>
```

### 속성 설명

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `id` | String | 필수 | 플래시백 고유 식별자 |
| `trigger_variable` | String | "" | 트리거 조건 변수명 |
| `trigger_value` | Any | null | 트리거 조건 값 |
| `trigger_operator` | String | "==" | 비교 연산자 |
| `bgm` | String | "" | 플래시백 BGM 경로 |
| `fade_duration` | float | 0.5 | 페이드 시간 (초) |
| `timeout` | float | 300.0 | 타임아웃 (초) |
| `skippable` | bool | true | 스킵 가능 여부 |
| `auto_trigger` | bool | false | 자동 트리거 여부 |

### 하위 태그

#### `<scene>`
플래시백 씬 정의

```xml
<scene id="flashback_scene_01" path="res://scenes/flashback/childhood.tscn"/>
```

#### `<effect>`
플래시백 종료 시 적용될 효과

```xml
<effect variable="flashback_unlocked" value="true"/>
```

#### `<return_to_scene>`
플래시백 종료 후 복귀할 씬

```xml
<return_to_scene id="after_flashback"/>
```

### 씬 내에서 트리거

```xml
<scene id="scene_02" path="res://scenes/main/trigger_test.tscn">
    <!-- 수동 플래시백 트리거 -->
    <trigger_flashback id="childhood_memory"/>
</scene>
```

## 코드에서 사용하기

### 기본 사용법

```gdscript
# 플래시백 시작
FlashbackManager.start_flashback("childhood_memory")

# 플래시백 종료
FlashbackManager.end_flashback()

# 플래시백 중인지 확인
if FlashbackManager.is_in_flashback():
    print("현재 플래시백 중")

# 현재 깊이 확인
var depth = FlashbackManager.get_flashback_depth()
print("깊이: %d" % depth)
```

### 신호 연결

```gdscript
func _ready():
    FlashbackManager.flashback_started.connect(_on_flashback_started)
    FlashbackManager.flashback_ended.connect(_on_flashback_ended)
    FlashbackManager.flashback_depth_changed.connect(_on_depth_changed)

func _on_flashback_started(id: String, data: Dictionary):
    print("플래시백 시작: " + id)

func _on_flashback_ended(id: String, return_scene: String):
    print("플래시백 종료, 복귀: " + return_scene)

func _on_depth_changed(new_depth: int):
    print("깊이 변경: %d" % new_depth)
```

### 프리로딩

```gdscript
# 씬 로드 전에 플래시백 프리로드
FlashbackManager.preload_flashback("childhood_memory")

# 여러 개 한 번에
FlashbackManager.preload_flashbacks(["flashback_1", "flashback_2", "flashback_3"])
```

### 디버그 모드

```gdscript
# 디버그 모드 활성화
FlashbackManager.set_debug_mode(true)

# 로그 확인
var logs = FlashbackManager.get_logs()
for log in logs:
    print(log)
```

## 제약 사항

### 중첩 깊이 제한
- 최대 3개까지 중첩 가능
- 깊이 제한 초과 시 `flashback_failed` 시그널 발생

### 재귀 방지
- 동일 ID의 플래시백은 중첩될 수 없음
- 재귀 시도 시 `flashback_failed` 시그널 발생

### 플래시백 중 제한
- 선택지 비활성화
- 변수 변경은 원본 시나리오에만 적용 (종료 시 복원됨)

### 타임아웃
- 기본 5분 (300초)
- 타임아웃 시 자동 종료

## 저장/로드

플래시백 상태는 자동으로 저장됩니다:

```gdscript
# 수동 저장
FlashbackManager.save()

# 수동 로드
FlashbackManager.load()

# 상태 가져오기
var state = FlashbackManager.save_state()
```

### ScenarioManager 통합

```gdscript
# 시나리오 상태에 플래시백 상태 포함
var save_data = ScenarioManager.save_state()
# save_data["flashback_state"]에 플래시백 상태 포함

# 로드 시 자동 복원
ScenarioManager.load_state(save_data)
```

## 통계

```gdscript
# 전체 통계
var stats = FlashbackManager.get_statistics()
print("시작: %d, 완료: %d" % [stats.total_started, stats.total_completed])

# 특정 플래시백 통계
var fb_stats = FlashbackManager.get_flashback_statistics("childhood_memory")
```

## UI 레이어

플래시백 UI는 별도 레이어로 표시됩니다:

```gdscript
# UI 레이어 설정
var ui_layer = CanvasLayer.new()
FlashbackManager.set_ui_layer(ui_layer)

# 페이드 오버레이 설정
var fade_overlay = ColorRect.new()
fade_overlay.color = Color.BLACK
FlashbackManager.set_fade_layer(fade_overlay)
```

## 테스트

테스트 시나리오: `test_scenarios/flashback_test.xml`

### 테스트 케이스

1. **기본 플래시백**: `childhood_memory`
2. **중첩 플래시백**: `parent_flashback` → `child_flashback` → `grandchild_flashback`
3. **자동 트리거**: `auto_trigger_flashback`
4. **조건 기반**: `adult_memory` (나이 >= 30)
5. **스킵 불가**: `critical_memory`

## 이벤트 플로우

```
1. start_flashback() 호출
   ↓
2. 트리거 조건 확인
   ↓
3. 깊이/재귀 검사
   ↓
4. 변수 백업
   ↓
5. 페이드 아웃
   ↓
6. 씬 전환
   ↓
7. BGM 변경
   ↓
8. 페이드 인
   ↓
9. flashback_started 시그널
   ↓
10. ... 플레이 ...
   ↓
11. end_flashback() 호출
   ↓
12. 페이드 아웃
   ↓
13. 변수 복원
   ↓
14. 복귀 씬 로드
   ↓
15. BGM 복원
   ↓
16. 페이드 인
   ↓
17. 자동 저장
   ↓
18. flashback_ended 시그널
```

## 에러 처리

### 실패 시나리오

| 상황 | 동작 | 시그널 |
|------|------|--------|
| 존재하지 않는 ID | 실패 반환 | `flashback_failed` |
| 최대 깊이 초과 | 실패 반환 | `flashback_failed` |
| 재귀 시도 | 실패 반환 | `flashback_failed` |
| 트리거 조건 불충족 | 실패 반환 | `flashback_failed` |
| 타임아웃 | 자동 종료 | `flashback_ended` |

## 베스트 프랙티스

1. **프리로딩**: 자주 사용하는 플래시백은 미리 로드
2. **타임아웃 설정**: 긴 플래시백은 적절한 타임아웃 설정
3. **스킵 기능**: 선택적 플래시백은 스킵 허용
4. **테스트**: 중첩 플래시백은 철저히 테스트
5. **디버그**: 개발 중 디버그 모드 활성화

## 문제 해결

### 플래시백이 시작되지 않음
1. ID가 올바른지 확인
2. 트리거 조건 확인 (`check_trigger_conditions`)
3. 깊이 제한 확인 (`is_at_max_depth`)

### 중첩이 작동하지 않음
1. 동일 ID 사용 여부 확인
2. 최대 깊이 (3) 확인

### 변수가 복원되지 않음
1. `end_flashback()` 호출 확인
2. 저장/로드 상태 확인

## 업데이트 로그

### v1.0.0 (Phase 7)
- 초기 구현
- 기본 플래시백 기능
- 중첩 플래시백 (최대 3개)
- 조건 기반 트리거
- 페이드 효과
- BGM 지원
- 저장/로드
- 통계 수집
- 프리로딩
- 디버그 모드
