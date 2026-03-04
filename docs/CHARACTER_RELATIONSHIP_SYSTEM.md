# 캐릭터 관계 시스템 (Character Relationship System)

## 개요

캐릭터 간의 관계를 추적하고 관리하는 종합적인 시스템입니다. 호감도, 신뢰도, 우정, 로맨스 등 다양한 관계 타입을 지원하며, 관계 이정표와 자동 저장 기능을 제공합니다.

## 주요 기능

### 1. 다양한 관계 타입

- **호감도 (Affection)**: -100 ~ 100 사이의 값
- **신뢰도 (Trust)**: 0 ~ 100 사이의 값
- **우정 (Friendship)**: 0 ~ 100 사이의 값
- **로맨스 (Romance)**: 0 ~ 100 사이의 값
- **존경 (Respect)**: 0 ~ 100 사이의 값
- **라이벌 (Rivalry)**: 0 ~ 100 사이의 값

### 2. 관계 이정표 (Milestones)

특정 관계 수치에 도달하면 자동으로 이정표가 달성됩니다:

- **Stranger**: 호감도 -100 ~ -50 (낯선 사람)
- **Acquaintance**: 호감도 -50 ~ 0 (아는 사이)
- **Friend**: 호감도 0 ~ 30 (친구)
- **Close Friend**: 호감도 30 ~ 60 (절친)
- **Best Friend**: 호감도 60 ~ 80 (가장 친한 친구)
- **Soulmate**: 호감도 80 ~ 100 (영혼의 반려)
- **Enemy**: 호감도 -100 ~ -80 (적)
- **Rival**: 라이벌 50 ~ 100 (라이벌)
- **Lover**: 로맨스 70 ~ 100 (연인)

### 3. 자동 저장

모든 관계 변경 사항은 `user://relationships.save`에 자동으로 저장됩니다.

## 사용법

### 기본 사용

```gdscript
# 관계 초기화
CharacterRelationshipManager.initialize_relationship("player", "alice", {
    "affection": 10.0,
    "trust": 20.0,
    "friendship": 15.0
})

# 관계 값 변경
CharacterRelationshipManager.modify_relationship("player", "alice", "affection", 5.0)

# 관계 값 설정
CharacterRelationshipManager.set_relationship("player", "alice", "trust", 50.0)

# 관계 값 조회
var affection = CharacterRelationshipManager.get_relationship("player", "alice", "affection")
print("호감도: ", affection)

# 관계 설명 가져오기
var description = CharacterRelationshipManager.get_relationship_description("player", "alice")
print("관계: ", description)  # 예: "친구"
```

### 조건 확인

```gdscript
# 호감도 조건 확인
if CharacterRelationshipManager.check_relationship_requirement("player", "alice", "affection", ">=", 30):
    print("Alice와 친구 이상의 관계")

# 이정표 달성 확인
if CharacterRelationshipManager.has_milestone("player", "alice", "friend"):
    print("친구 이정표 달성")
```

### 통계 조회

```gdscript
# 캐릭터의 관계 통계
var stats = CharacterRelationshipManager.get_relationship_stats("player")
print("총 관계 수: ", stats.total_relationships)
print("평균 호감도: ", stats.average_affection)
print("가장 높은 호감도: ", stats.highest_affection)
```

### 시그널 연결

```gdscript
func _ready():
    CharacterRelationshipManager.relationship_changed.connect(_on_relationship_changed)
    CharacterRelationshipManager.relationship_milestone_reached.connect(_on_milestone_reached)

func _on_relationship_changed(char1: String, char2: String, type: String, value: float):
    print("%s와 %s의 %s가 %.1f로 변경됨" % [char1, char2, type, value])

func _on_milestone_reached(char1: String, char2: String, milestone: String):
    print("%s와 %s가 %s 이정표 달성!" % [char1, char2, milestone])
```

## 시그널

| 시그널 | 매개변수 | 설명 |
|--------|----------|------|
| `relationship_changed` | char1_id, char2_id, relationship_type, new_value | 관계 값 변경 시 |
| `relationship_milestone_reached` | char1_id, char2_id, milestone | 이정표 달성 시 |
| `relationship_unlocked` | char1_id, char2_id, unlock_type | 관계 잠금 해제 시 |

## API 레퍼런스

### 초기화

```gdscript
func initialize_relationship(char1_id: String, char2_id: String, initial_values: Dictionary = {}) -> void
```

### 관리

```gdscript
func modify_relationship(char1_id: String, char2_id: String, relationship_type: String, amount: float) -> void
func set_relationship(char1_id: String, char2_id: String, relationship_type: String, value: float) -> void
func get_relationship(char1_id: String, char2_id: String, relationship_type: String) -> float
func get_all_relationships(char_id: String) -> Dictionary
```

### 확인

```gdscript
func check_relationship_requirement(char1_id: String, char2_id: String, relationship_type: String, operator: String, value: float) -> bool
func has_milestone(char1_id: String, char2_id: String, milestone_id: String) -> bool
func is_relationship_unlocked(char1_id: String, char2_id: String) -> bool
func get_relationship_description(char1_id: String, char2_id: String) -> String
```

### 통계

```gdscript
func get_relationship_stats(char_id: String) -> Dictionary
```

### 저장/로드

```gdscript
func save_relationships() -> void
func load_relationships() -> void
func reset_relationships() -> void
```

## XML 통합

시나리오 XML에서 관계 효과를 사용할 수 있습니다:

```xml
<scene id="romantic_moment">
    <dialogue speaker="alice" text="나랑 같이 갈래?">
        <effect type="relationship" 
                character1="player" 
                character2="alice" 
                relationship_type="affection" 
                operation="add" 
                value="10"/>
        <effect type="relationship" 
                character1="player" 
                character2="alice" 
                relationship_type="romance" 
                operation="add" 
                value="5"/>
    </dialogue>
    
    <choice id="accept" text="그래, 같이 가자">
        <condition type="relationship" 
                   character1="player" 
                   character2="alice" 
                   relationship_type="affection" 
                   operator=">=" 
                   value="20"/>
        <effect type="relationship" 
                character1="player" 
                character2="alice" 
                relationship_type="romance" 
                operation="add" 
                value="15"/>
    </choice>
</scene>
```

## 베스트 프랙티스

1. **초기화**: 게임 시작 시 주요 캐릭터들의 관계를 초기화하세요
2. **균형**: 호감도 변화는 작은 값(5~10)부터 시작하세요
3. **피드백**: 관계 변화 시 플레이어에게 시각적 피드백을 제공하세요
4. **저장**: 중요한 장면 후에는 자동 저장을 권장합니다
5. **테스트**: 다양한 관계 수치에서 분기가 올바르게 작동하는지 테스트하세요

## 주의사항

1. **성능**: `check_relationship_requirement()`는 자주 호출될 수 있으므로 캐싱을 고려하세요
2. **범위**: 각 관계 타입의 범위를 초과하는 값은 자동으로 clamp됩니다
3. **양방향**: 호감도만 양방향으로 업데이트됩니다 (A→B 변경 시 B→A도 변경)
4. **저장**: 관계 변경 시마다 자동 저장되므로 성능이 중요한 경우 배치 업데이트를 고려하세요

## 업데이트 로그

### v1.0.0 (2026-03-04)
- 초기 구현
- 6가지 관계 타입 지원
- 관계 이정표 시스템
- 자동 저장/로드
- 통계 시스템
- 시그널 기반 이벤트
