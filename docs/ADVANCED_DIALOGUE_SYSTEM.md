# 고급 대화 시스템 (Advanced Dialogue System)

## 개요

분기, 조건, 효과, 변수 관리를 포함한 종합적인 대화 시스템입니다. XML 기반 시나리오와 완전히 통합되어 복잡한 스토리텔링이 가능합니다.

## 주요 기능

### 1. 분기 대화 시스템

- **선택지 기반 분기**: 플레이어의 선택에 따라 다른 경로로 진행
- **조건부 선택지**: 변수, 관계, 플래그에 따른 선택지 표시/숨김
- **자동 진행**: 조건에 따른 자동 씬 전환

### 2. 조건 시스템

다양한 조건을 지원합니다:

#### 변수 조건
```xml
<condition type="variable" variable="gold" operator=">=" value="100"/>
```

#### 관계 조건
```xml
<condition type="relationship" 
        character1="player" 
        character2="alice" 
        relationship_type="affection" 
        operator=">=" 
        value="50"/>
```

#### 플래그 조건
```xml
<condition type="flag" flag="talked_to_alice"/>
```

#### 방문 조건
```xml
<condition type="visited" scene="intro_scene"/>
```

### 3. 효과 시스템

#### 변수 효과
```xml
<effect type="variable" variable="gold" operation="add" value="50"/>
```

#### 관계 효과
```xml
<effect type="relationship" 
       character1="player" 
       character2="alice" 
       relationship_type="affection" 
       operation="add" 
       value="10"/>
```

#### 감정 효과
```xml
<effect type="emotion" character="alice" emotion="happy"/>
```

#### 루트 변경
```xml
<effect type="route" route="bad_ending"/>
```

### 4. 변수 관리

- **설정**: `set_variable(name, value)`
- **조회**: `get_variable(name, default)`
- **수정**: `modify_variable(name, operation, value)`
  - 지원 연산: add, subtract, multiply, divide, set

### 5. 대화 이력

모든 대화가 자동으로 이력에 저장됩니다:
```gdscript
{
    "speaker": "Alice",
    "text": "Hello!",
    "emotion": "happy",
    "timestamp": "2024-03-04T10:30:00"
}
```

### 6. 방문한 씬 추적

플레이어가 방문한 모든 씬이 기록되어 중복 방문 방지 및 엔딩 확인에 사용됩니다.

## XML 시나리오 구조

### 기본 구조
```xml
<scenario id="main_story" default_route="main">
    <routes>
        <route id="main">
            <scenes>
                <scene id="intro">
                    <!-- 대화들 -->
                </scene>
            </scenes>
        </route>
    </routes>
    
    <scenes>
        <scene id="intro">
            <dialogues>
                <dialogue speaker="alice" emotion="happy">
                    <text>Hello, player!</text>
                </dialogue>
            </dialogues>
            
            <choices>
                <choice id="greet" text="Hello!">
                    <effects>
                        <effect type="variable" variable="affection_alice" operation="add" value="5"/>
                    </effects>
                    <next_scene>scene2</next_scene>
                </choice>
                
                <choice id="ignore" text="...">
                    <effects>
                        <effect type="variable" variable="affection_alice" operation="add" value="-5"/>
                    </effects>
                    <next_scene>scene3</next_scene>
                </choice>
            </choices>
        </scene>
    </scenes>
</scenario>
```

### 씬 속성
```xml
<scene id="scene_id">
    <!-- 진입 액션 -->
    <on_enter>
        <effect type="flag" flag="entered_scene" value="true"/>
    </on_enter>
    
    <!-- 대화들 -->
    <dialogues>
        <dialogue speaker="character_id" emotion="emotion_id">
            <text>Dialogue text with {variable_name}</text>
            <conditions>
                <condition type="variable" variable="flag" operator="==" value="true"/>
            </conditions>
            <effects>
                <effect type="variable" variable="counter" operation="add" value="1"/>
            </effects>
        </dialogue>
    </dialogues>
    
    <!-- 선택지들 -->
    <choices>
        <choice id="choice_id" text="Choice text">
            <conditions>
                <condition type="variable" variable="gold" operator=">=" value="50"/>
            </conditions>
            <effects>
                <effect type="relationship" 
                       character1="player" 
                       character2="alice" 
                       relationship_type="affection" 
                       operation="add" 
                       value="10"/>
            </effects>
            <next_scene>next_scene_id</next_scene>
        </choice>
    </choices>
    
    <!-- 퇴장 액션 -->
    <on_exit>
        <effect type="flag" flag="exited_scene" value="true"/>
    </on_exit>
    
    <!-- 다음 씬 (자동 진행) -->
    <next_scene>auto_next_scene</next_scene>
</scene>
```

## 코드에서 사용하기

### 시나리오 로드 및 시작
```gdscript
# 싱글톤 등록 (project.godot)
autoload/AdvancedDialogueManager 	= "*res://scripts/dialogue/advanced_dialogue_manager.gd"

# 시나리오 로드
AdvancedDialogueManager.load_scenario("res://scenarios/my_story.xml")

# 대화 시작
AdvancedDialogueManager.start_dialogue()
```

### 시그널 연결
```gdscript
func _ready():
    AdvancedDialogueManager.message_displayed.connect(_on_message)
    AdvancedDialogueManager.choice_presented.connect(_on_choices)
    AdvancedDialogueManager.choice_selected.connect(_on_choice)
    AdvancedDialogueManager.variable_changed.connect(_on_variable)

func _on_message(speaker: String, text: String):
    print("%s: %s" % [speaker, text])
    # UI 업데이트

func _on_choices(choices: Array):
    # 선택지 UI 표시
    for choice in choices:
        print("- %s" % choice.text)

func _on_choice(choice_id: String):
    print("선택됨: %s" % choice_id)

func _on_variable(name: String, value: Variant):
    print("%s = %s" % [name, value])
```

### 선택지 선택
```gdscript
# 플레이어가 선택지를 클릭했을 때
AdvancedDialogueManager.select_choice("choice_id")
```

### 변수 관리
```gdscript
# 변수 설정
AdvancedDialogueManager.set_variable("player_name", "Alice")

# 변수 조회
var name = AdvancedDialogueManager.get_variable("player_name", "Unknown")

# 변수 수정
AdvancedDialogueManager.modify_variable("gold", "add", 50)
```

### 상태 저장/로드
```gdscript
# 저장
var save_data = AdvancedDialogueManager.save_dialogue_state()

# 로드
AdvancedDialogueManager.load_dialogue_state(save_data)
```

## 시그널

| 시그널 | 매개변수 | 설명 |
|--------|----------|------|
| `dialogue_started` | scenario_id: String | 대화 시작 시 |
| `dialogue_ended` | scenario_id: String | 대화 종료 시 |
| `message_displayed` | speaker: String, text: String | 메시지 표시 시 |
| `choice_presented` | choices: Array | 선택지 표시 시 |
| `choice_selected` | choice_id: String | 선택지 선택 시 |
| `variable_changed` | variable_name: String, new_value: Variant | 변수 변경 시 |
| `emotion_changed` | character_id: String, emotion: String | 감정 변경 시 |
| `route_changed` | new_route: String | 루트 변경 시 |

## 연산자

### 조건 연산자
- `==`, `=`: 같음
- `!=`: 다름
- `>`: 초과
- `>=`: 이상
- `<`: 미만
- `<=`: 이하
- `contains`: 포함
- `starts_with`: 시작 문자열
- `ends_with`: 끝 문자열

### 변수 연산
- `add`, `+`: 더하기
- `subtract`, `-`: 빼기
- `multiply`, `*`: 곱하기
- `divide`, `/`: 나누기
- `set`, `=`: 설정

## 베스트 프랙티스

1. **변수 명명**: 명확한 변수명 사용 (예: `affection_alice` 대신 `relationship_alice_affection`)
2. **조건 검증**: 복잡한 조건은 여러 개의 조건으로 분리
3. **테스트**: 모든 분기 경로 테스트
4. **밸런스**: 선택지 효과의 균형 유지
5. **백업**: 중요한 결정 전에 자동 저장

## 주의사항

1. **성능**: 많은 조건과 효과는 성능에 영향을 줄 수 있음
2. **저장**: 대화 상태는 자동 저장되지 않으므로 수동 저장 필요
3. **순서**: 효과는 정의된 순서대로 실행됨
4. **조건**: 조건이 실패하면 해당 대화/선택지는 건너뜀

## 통합

CharacterRelationshipManager, CharacterPortraitSystem과 완전히 통합되어 있습니다:

```gdscript
# 관계 조건
<condition type="relationship" 
           character1="player" 
           character2="alice" 
           relationship_type="affection" 
           operator=">=" 
           value="50"/>

# 관계 효과
<effect type="relationship" 
        character1="player" 
        character2="alice" 
        relationship_type="affection" 
        operation="add" 
        value="10"/>

# 감정 효과
<effect type="emotion" character="alice" emotion="happy"/>
```

## 업데이트 로그

### v1.0.0 (2026-03-04)
- 분기 대화 시스템
- 조건 기반 선택지
- 다양한 효과 타입
- 변수 관리
- 대화 이력
- 방문 씬 추적
- 상태 저장/로드
- 관계 및 초상화 시스템 통합
