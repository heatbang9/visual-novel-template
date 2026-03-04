# 분기 통계 시스템 (Branch Stats System)

## 개요

분기 통계 시스템은 플레이어의 선택에 따른 게임 진행 상황을 추적하고, 엔딩을 예측하며, 가능한 대안 루트를 제안하는 시스템입니다.

## 구성 요소

### 1. BranchStatsManager (싱글톤)

분기 통계의 핵심 관리자입니다.

**주요 기능:**
- 통계 추적 및 업데이트
- 엔딩 예측
- 루트 대안 분석
- 캐싱을 통한 성능 최적화

**주요 메서드:**
```gdscript
# 통계 업데이트
func update_stats(variable: String, value: Variant) -> void
func increment_stat(variable: String, amount: Variant = 1) -> void
func decrement_stat(variable: String, amount: Variant = 1) -> void

# 분석
func analyze_branch_stats() -> Dictionary
func predict_ending(stats: Dictionary = {}) -> String
func get_route_alternatives() -> Array

# 요약
func get_stat_summary() -> String

# 저장/로드
func save_state() -> Dictionary
func load_state(state: Dictionary) -> void
func reset_stats() -> void
```

### 2. BranchStatsPanel (UI)

분기 통계를 시각화하는 UI 패널입니다.

**표시 요소:**
- 현재 통계 값
- 예측된 엔딩
- 신뢰도 바
- 루트 진행 상황
- 가능한 대안 엔딩

### 3. XML 태그

#### `<branch_stats>` 태그

분기 통계 정의의 루트 태그입니다.

**속성:**
- `id`: 통계 정의 ID (필수)
- `track_route_changes`: 루트 변경 추적 여부 (선택, 기본값: false)

**예시:**
```xml
<branch_stats id="story_analysis" track_route_changes="true">
    <!-- stat 및 branch_prediction 태그들 -->
</branch_stats>
```

#### `<stat>` 태그

개별 통계 정의입니다.

**속성:**
- `variable`: 통계 변수명 (필수)
- `operator`: 비교 연산자 (선택, 기본값: >)
- `value`: 임계값 (필수)
- `label`: 표시 이름 (선택)

**예시:**
```xml
<stat variable="hero_reputation" operator=">" value="50" label="영웅"/>
```

#### `<branch_prediction>` 태그

분기 예측 정의입니다.

**속성:**
- `based_on`: 기준 변수 (필수)
- `route`: 예측 루트 (필수)
- `threshold`: 임계값 (선택, 기본값: 50)
- `operator`: 비교 연산자 (선택, 기본값: >)

**예시:**
```xml
<branch_prediction based_on="hero_reputation" route="hero_ending" threshold="50" operator=">"/>
```

## 사용법

### 1. 시나리오 XML 작성

```xml
<scenario name="my_story" default_route="main">
    <branch_stats id="story_analysis" track_route_changes="true">
        <stat variable="hero_reputation" operator=">" value="50" label="영웅"/>
        <stat variable="villain_reputation" operator=">" value="50" label="악당"/>
        <branch_prediction based_on="hero_reputation" route="hero_ending"/>
        <branch_prediction based_on="villain_reputation" route="villain_ending"/>
    </branch_stats>
    
    <route id="main" name="메인">
        <scene id="scene1" path="res://scenes/scene1.tscn">
            <choice id="help" text="돕는다">
                <effect variable="hero_reputation" modifier="add" value="10"/>
            </choice>
            <choice id="ignore" text="무시한다">
                <effect variable="villain_reputation" modifier="add" value="10"/>
            </choice>
        </scene>
    </route>
</scenario>
```

### 2. 코드에서 사용

```gdscript
# 통계 업데이트
BranchStatsManager.update_stats("hero_reputation", 60)

# 통계 증가/감소
BranchStatsManager.increment_stat("hero_reputation", 10)
BranchStatsManager.decrement_stat("villain_reputation", 5)

# 분석
var analysis = BranchStatsManager.analyze_branch_stats()
print("예측 엔딩: ", analysis.prediction)
print("신뢰도: ", analysis.confidence)

# 엔딩 예측
var ending = BranchStatsManager.predict_ending()

# 대안 루트
var alternatives = BranchStatsManager.get_route_alternatives()
for alt in alternatives:
    print("대안: ", alt.route, " - 달성 가능: ", alt.achievable)

# 요약
print(BranchStatsManager.get_stat_summary())
```

### 3. UI 패널 사용

```gdscript
# 패널 생성
var panel = preload("res://addons/scenario_system/branch_stats_panel.gd").new()
add_child(panel)

# 표시 업데이트
panel.update_display()

# 디버그 모드
panel.set_debug_mode(true)

# 토글
panel.toggle_panel()
```

## 시그널

### BranchStatsManager

- `stats_updated(stat_id: String, new_value: Variant)`: 통계 업데이트 시
- `route_prediction_changed(predicted_route: String, confidence: float)`: 예측 변경 시
- `route_alternative_discovered(alternative_route: String, requirements: Dictionary)`: 대안 발견 시

### BranchStatsPanel

자동으로 BranchStatsManager의 시그널을 연결합니다.

## 제한사항

- 최대 10개의 통계 추적 가능
- 실시간 업데이트 지원
- 캐싱을 통한 성능 최적화

## 저장/로드

분기 통계는 ScenarioManager의 저장/로드에 자동으로 포함됩니다.

```gdscript
# 저장
var save_data = scenario_manager.save_state()

# 로드
scenario_manager.load_state(save_data)
```

## 디버그 모드

```gdscript
# BranchStatsManager 디버그 모드
BranchStatsManager.set_debug_mode(true)
BranchStatsManager.debug_print_stats()

# UI 패널 디버그 모드
panel.set_debug_mode(true)
```

## 테스트

`test_scenarios/branch_stats_test.xml` 파일을 사용하여 테스트할 수 있습니다.

## 예제

### 기본 사용

```xml
<branch_stats id="karma_system">
    <stat variable="good_karma" operator=">" value="100" label="선한 카르마"/>
    <stat variable="bad_karma" operator=">" value="100" label="악한 카르마"/>
    <branch_prediction based_on="good_karma" route="good_ending" threshold="100"/>
    <branch_prediction based_on="bad_karma" route="bad_ending" threshold="100"/>
</branch_stats>
```

### 복잡한 예측

```xml
<branch_stats id="complex_story" track_route_changes="true">
    <stat variable="courage" operator=">=" value="50" label="용기"/>
    <stat variable="wisdom" operator=">=" value="50" label="지혜"/>
    <stat variable="power" operator=">=" value="50" label="힘"/>
    
    <branch_prediction based_on="courage" route="brave_ending" threshold="50"/>
    <branch_prediction based_on="wisdom" route="wise_ending" threshold="50"/>
    <branch_prediction based_on="power" route="powerful_ending" threshold="50"/>
</branch_stats>
```

## 문제 해결

### 통계가 업데이트되지 않음
- `update_stats()` 또는 `increment_stat()` 호출 확인
- 변수명이 `<stat>` 태그의 `variable`과 일치하는지 확인

### 예측이 부정확함
- `<branch_prediction>` 태그의 임계값 확인
- `operator` 속성 확인 (>, >=, <, <=, ==)

### UI 패널이 표시되지 않음
- BranchStatsManager가 로드되었는지 확인
- 패널의 `visible` 속성 확인
- `update_display()` 호출 확인

## 업데이트 로그

### Phase 8 (2026-03-04)
- BranchStatsManager 싱글톤 구현
- `<branch_stats>` 태그 파싱 추가
- BranchStatsPanel UI 구현
- 저장/로드 기능 추가
- 캐싱 시스템 구현
- 디버그 모드 추가
- 테스트 시나리오 작성
- 문서화 완료
