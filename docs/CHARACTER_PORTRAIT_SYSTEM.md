# 캐릭터 초상화 시스템 (Character Portrait System)

## 개요

캐릭터 초상화(Portrait)의 표시, 위치 관리, 전환 효과를 담당하는 시스템입니다. 다양한 포지셔닝 옵션과 애니메이션 효과를 제공합니다.

## 주요 기능

### 1. 포지셔닝 시스템

#### 프리셋 포지션
- **left**: 화면 왼쪽 (15%)
- **center_left**: 중앙 왼쪽 (30%)
- **center**: 중앙 (50%)
- **center_right**: 중앙 오른쪽 (70%)
- **right**: 화면 오른쪽 (85%)
- **far_left**: 화면 끝 왼쪽 (5%)
- **far_right**: 화면 끝 오른쪽 (95%)

#### 커스텀 포지션
```gdscript
# "x,y" 형식으로 정의
show_portrait("alice", "res://characters/alice.png", "0.4,0.6")
```

### 2. 전환 효과

#### 진입 효과
- **NONE**: 즉시 표시
- **FADE**: 페이드 인
- **SLIDE_LEFT**: 왼쪽에서 슬라이드
- **SLIDE_RIGHT**: 오른쪽에서 슬라이드
- **SLIDE_UP**: 아래에서 위로 슬라이드
- **SLIDE_DOWN**: 위에서 아래로 슬라이드
- **ZOOM_IN**: 확대하며 나타남
- **ZOOM_OUT**: 축소하며 나타남 (미사용)
- **DISSOLVE**: 디졸브 효과

#### 퇴장 효과
동일한 전환 효과 사용 (반대 방향)

### 3. 특수 효과

#### 흔들기 (Shake)
```gdscript
shake_portrait("alice", 10.0, 0.5)  # 강도 10, 지속시간 0.5초
```

#### 바운스 (Bounce)
```gdscript
bounce_portrait("alice", 30.0, 0.5)  # 높이 30, 지속시간 0.5초
```

### 4. 레이어 관리

- 자동 레이어 할당 (0 ~ 9)
- 수동 레이어 설정
- 최대 10개 레이어

## API 레퍼런스

### 기본 조작

```gdscript
# 초상화 표시
func show_portrait(
    character_id: String, 
    texture_path: String, 
    position: String = "center", 
    transition: int = TransitionType.FADE, 
    duration: float = 0.5
) -> void

# 초상화 업데이트
func update_portrait(
    character_id: String, 
    texture_path: String, 
    position: String = "", 
    transition: int = TransitionType.FADE, 
    duration: float = 0.3
) -> void

# 초상화 이동
func move_portrait(
    character_id: String, 
    new_position: String, 
    duration: float = 0.5
) -> void

# 초상화 숨기기
func hide_portrait(
    character_id: String, 
    transition: int = TransitionType.FADE, 
    duration: float = 0.5
) -> void

# 초상화 제거 (즉시)
func remove_portrait(character_id: String) -> void

# 모든 초상화 숨기기
func hide_all_portraits(
    transition: int = TransitionType.FADE, 
    duration: float = 0.5
) -> void
```

### 특수 효과

```gdscript
# 흔들기
func shake_portrait(
    character_id: String, 
    intensity: float = 10.0, 
    duration: float = 0.5
) -> void

# 바운스
func bounce_portrait(
    character_id: String, 
    height: float = 30.0, 
    duration: float = 0.5
) -> void

# 레이어 설정
func set_portrait_layer(character_id: String, layer: int) -> void
```

### 정보 조회

```gdscript
# 초상화 정보
func get_portrait_info(character_id: String) -> Dictionary

# 활성 초상화 목록
func get_active_portraits() -> Array
```

## 시그널

| 시그널 | 매개변수 | 설명 |
|--------|----------|------|
| `portrait_shown` | character_id: String, position: String | 초상화 표시 시 |
| `portrait_hidden` | character_id: String | 초상화 숨김 시 |
| `portrait_moved` | character_id: String, new_position: String | 초상화 이동 시 |
| `transition_completed` | character_id: String | 전환 완료 시 |

## 코드에서 사용하기

### 초기화
```gdscript
# 씬에 추가
var portrait_system = preload("res://scripts/character/character_portrait_system.gd").new()
add_child(portrait_system)
```

### 기본 사용
```gdscript
# 캐릭터 표시
portrait_system.show_portrait("alice", "res://characters/alice_normal.png", "left")

# 캐릭터 이동
portrait_system.move_portrait("alice", "center", 1.0)

# 캐릭터 숨기기
portrait_system.hide_portrait("alice")
```

### 전환 효과
```gdscript
# 슬라이드로 등장
portrait_system.show_portrait(
    "alice", 
    "res://characters/alice_happy.png", 
    "center", 
    CharacterPortraitSystem.TransitionType.SLIDE_LEFT, 
    0.8
)

# 페이드 아웃으로 퇴장
portrait_system.hide_portrait(
    "alice", 
    CharacterPortraitSystem.TransitionType.FADE, 
    0.5
)
```

### 특수 효과
```gdscript
# 충격 효과
portrait_system.shake_portrait("alice", 15.0, 0.3)

# 기쁨 효과
portrait_system.bounce_portrait("alice", 40.0, 0.6)
```

### 시그널 연결
```gdscript
func _ready():
    portrait_system.portrait_shown.connect(_on_portrait_shown)
    portrait_system.portrait_hidden.connect(_on_portrait_hidden)
    portrait_system.transition_completed.connect(_on_transition_completed)

func _on_portrait_shown(character_id: String, position: String):
    print("%s이(가) %s에 표시됨" % [character_id, position])

func _on_portrait_hidden(character_id: String):
    print("%s이(가) 숨겨짐" % character_id)

func _on_transition_completed(character_id: String):
    print("%s 전환 완료" % character_id)
```

## XML 시나리오와 통합

### 캐릭터 액션
```xml
<action type="show_portrait" 
        character="alice" 
        texture="res://characters/alice_happy.png" 
        position="left" 
        transition="fade" 
        duration="0.5"/>
```

### 대화 중 감정 변경
```xml
<dialogue speaker="alice" emotion="happy">
    <text>I'm so happy to see you!</text>
    <effects>
        <effect type="change_portrait" 
                character="alice" 
                texture="res://characters/alice_very_happy.png" 
                transition="fade" 
                duration="0.3"/>
    </effects>
</dialogue>
```

### 선택지에 따른 이동
```xml
<choice id="approach" text="Approach Alice">
    <effects>
        <effect type="move_portrait" 
                character="alice" 
                position="center" 
                duration="1.0"/>
    </effects>
</choice>
```

## 레이아우팅 예시

### 기본 대화 씬
```
CanvasLayer (PortraitSystem)
├── PortraitContainer (Control)
    ├── alice (TextureRect) - z_index: 0
    ├── bob (TextureRect) - z_index: 1
    └── charlie (TextureRect) - z_index: 2
```

### 다중 캐릭터 배치
```gdscript
# 왼쪽: Alice
portrait_system.show_portrait("alice", "alice.png", "left")

# 중앙: Player
portrait_system.show_portrait("player", "player.png", "center")

# 오른쪽: Bob
portrait_system.show_portrait("bob", "bob.png", "right")

# 레이어 조정 (player가 앞으로)
portrait_system.set_portrait_layer("player", 5)
```

## 베스트 프랙티스

1. **리소스 관리**: 자주 사용하는 텍스처는 미리 로드
2. **성능**: 동시에 너무 많은 전환 효과 피하기
3. **타이밍**: 대화 속도에 맞춰 전환 지속시간 조정
4. **일관성**: 같은 상황에서는 같은 전환 효과 사용
5. **접근성**: 전환 효과 옵션 제공 (빠른 전환, 생략 등)

## 주의사항

1. **메모리**: 많은 초상화를 동시에 표시하면 메모리 사용량 증가
2. **해상도**: 고해상도 텍스처는 로딩 시간에 영향
3. **앵커**: 포지션은 앵커 기반 (0.0 ~ 1.0)
4. **레이어**: 최대 10개 레이어 (0 ~ 9)
5. **자동 정리**: 씬 전환 시 `hide_all_portraits()` 호출 권장

## 통합 예시

### 완전한 대화 씬
```gdscript
func start_scene():
    # 캐릭터 등장
    portrait_system.show_portrait("alice", "alice_normal.png", "left", TransitionType.SLIDE_RIGHT)
    
    # 관계 초기화
    CharacterRelationshipManager.initialize_relationship("player", "alice", {"affection": 0.0})
    
    # 대화 시작
    AdvancedDialogueManager.start_dialogue("intro_scene")

func _on_message_displayed(speaker: String, text: String):
    # 화자 하이라이트
    for char_id in portrait_system.get_active_portraits():
        if char_id == speaker:
            portrait_system.bounce_portrait(char_id, 20.0, 0.3)
        else:
            # 다른 캐릭터는 약간 어둡게
            pass

func _on_choice_selected(choice_id: String):
    # 선택에 따른 관계 변화
    if choice_id == "friendly":
        CharacterRelationshipManager.modify_relationship("player", "alice", "affection", 10.0)
        portrait_system.show_portrait("alice", "alice_happy.png", "left", TransitionType.FADE, 0.3)
    elif choice_id == "rude":
        CharacterRelationshipManager.modify_relationship("player", "alice", "affection", -10.0)
        portrait_system.show_portrait("alice", "alice_angry.png", "left", TransitionType.FADE, 0.3)
```

## 업데이트 로그

### v1.0.0 (2026-03-04)
- 포지셔닝 시스템
- 전환 효과 (8가지)
- 특수 효과 (흔들기, 바운스)
- 레이어 관리
- 텍스처 크로스페이드
- 시그널 기반 이벤트
- XML 시나리오 통합
