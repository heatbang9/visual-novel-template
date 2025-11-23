# LLM을 위한 비주얼 노벨 시나리오 생성 가이드

## 개요

이 가이드는 LLM(Large Language Model)이 텍스트 시나리오를 받아 Godot 비주얼 노벨 템플릿용 XML 파일을 자동 생성하는 방법을 설명합니다.

## 입력 형식 (텍스트 시나리오)

### 기본 형식

```
제목: [시나리오 제목]
설정: [배경 설정]

# 캐릭터
- [캐릭터명]: [설명]

# 시나리오
## 씬1: [씬 제목]
[대화 내용]

선택지:
1. [선택지1] → [결과/다음 씬]
2. [선택지2] → [결과/다음 씬]

## 씬2: [씬 제목]
...
```

### 예제 입력

```
제목: 학교 생활
설정: 고등학교 교실, 새 학기 첫날

# 캐릭터
- 유키: 조용하고 책을 좋아하는 학생, 창가 자리에 앉아 있음
- 플레이어: 새로 전학온 주인공

# 시나리오
## 씬1: 첫 만남
나레이터: 새 학기 첫날, 당신은 새로운 반에 배정되었습니다.
나레이터: 교실에 들어서자 눈에 띄는 학생이 한 명 있습니다.
유키: (창가 자리에서 책을 읽고 있는 학생이 당신을 힐끗 쳐다봅니다.)
나레이터: 그 학생과 어떻게 첫 만남을 시작할까요?

선택지:
1. 친근하게 인사한다 → 친구도+2, 다음: 점심시간 함께
2. 수줍게 고개만 끄덕인다 → 수줍음+1, 다음: 일반 진행
3. 자신감 있게 말을 건다 (자신감≥3 필요) → 애정도+1, 자신감+1, 다음: 특별한 순간

## 씬2: 점심시간 함께
유키: 같이 점심 먹을래요?
플레이어: 네, 좋아요!
...
```

## 출력 형식 (XML 생성 규칙)

### 1. 시나리오 구조 분석

LLM은 다음 요소들을 식별해야 합니다:

1. **기본 정보**
   - 시나리오 제목 → `<scenario name="">`
   - 캐릭터 목록 → `<character>` 요소들
   - 씬 구조 → `<scene>` 요소들

2. **선택지 분석**
   - 선택지 텍스트
   - 조건 (예: "자신감≥3 필요")
   - 효과 (예: "친구도+2")
   - 분기 경로 (예: "다음: 점심시간 함께")

3. **변수 추출**
   - 수치 변수 (친구도, 애정도, 자신감 등)
   - 플래그 변수 (씬 완료 상태 등)

### 2. XML 생성 템플릿

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scenario name="{시나리오명}" default_route="main">
    
    <!-- 메인 루트 -->
    <route id="main" name="메인 스토리">
        
        <!-- 각 씬 -->
        <scene id="{씬_id}" path="res://scenes/dialogue/{씬_id}.xml">
            <!-- 조건이 있는 경우 -->
            <condition type="variable" variable="{변수명}" value="{값}"/>
            
            <!-- 완료 플래그 설정 -->
            <set_variable name="{씬_id}_complete" value="true"/>
            
            <!-- 선택지들 -->
            <choice id="{선택지_id}" text="{선택지_텍스트}" target_route="{타겟_루트}">
                <!-- 요구사항 -->
                <requirement variable="{변수명}" operator="{연산자}" value="{값}"/>
                
                <!-- 효과 -->
                <effect variable="{변수명}" modifier="{수정방식}" value="{값}"/>
            </choice>
            
        </scene>
        
    </route>
    
    <!-- 분기 루트들 -->
    <route id="{루트_id}" name="{루트명}">
        <!-- 해당 루트의 씬들 -->
    </route>
    
    <!-- 글로벌 변수 정의 -->
    <global_variables>
        <variable name="{변수명}" type="{타입}" default="{기본값}"/>
    </global_variables>
    
</scenario>
```

### 3. 개별 씬 XML 생성

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene name="{씬명}">
    
    <!-- 배경 (추론 또는 기본값) -->
    <background type="image" path="res://scenes/background/{배경이미지}.png"/>
    
    <!-- 캐릭터 정의 -->
    <character id="{캐릭터_id}" name="{캐릭터명}" default_position="{위치}">
        <portrait emotion="normal" path="res://characters/{캐릭터_id}/normal.png"/>
        <portrait emotion="happy" path="res://characters/{캐릭터_id}/happy.png"/>
        <!-- 필요한 감정 상태들 추가 -->
    </character>
    
    <!-- 대화 메시지들 -->
    <message speaker="{화자}" emotion="{감정}">{대사}</message>
    
    <!-- 선택지 지점 -->
    <choice_point id="{선택지_포인트_id}"/>
    
</scene>
```

## LLM 처리 가이드라인

### 1. 입력 파싱 단계

1. **메타데이터 추출**
   ```
   제목: → scenario.name
   설정: → 배경 정보, background path 추론
   ```

2. **캐릭터 분석**
   ```
   캐릭터명: 설명 → character 요소 생성
   성격/특징 → emotion 상태 추론
   ```

3. **대화 분석**
   ```
   화자: 대사 → message 요소
   나레이터: → speaker="narrator"
   감정 표현 → emotion 속성 추론
   ```

4. **선택지 분석**
   ```
   1. 텍스트 → choice.text
   조건 (변수≥값) → requirement
   효과 (변수+값) → effect
   분기 → target_route
   ```

### 2. 변수 명명 규칙

| 입력 패턴 | 변수명 | 타입 | 설명 |
|-----------|--------|------|------|
| 친구도+N | friendship_level | int | 우정 수치 |
| 애정도+N | affection_level | int | 연애 수치 |
| 자신감+N | confidence_level | int | 자신감 수치 |
| 스트레스+N | stress_level | int | 스트레스 수치 |
| 체력+N | health_level | int | 체력 수치 |
| 돈+N | money | int | 소지금 |
| ~완료 | {event}_complete | bool | 이벤트 완료 플래그 |
| ~발생 | {event}_triggered | bool | 이벤트 발생 플래그 |

### 3. 조건 변환 규칙

| 입력 형식 | XML 출력 |
|-----------|----------|
| "자신감≥3 필요" | `<requirement variable="confidence_level" operator=">=" value="3"/>` |
| "친구도>5" | `<requirement variable="friendship_level" operator=">" value="5"/>` |
| "첫만남 완료" | `<requirement variable="first_meeting_complete" operator="==" value="true"/>` |

### 4. 효과 변환 규칙

| 입력 형식 | XML 출력 |
|-----------|----------|
| "친구도+2" | `<effect variable="friendship_level" modifier="add" value="2"/>` |
| "돈-100" | `<effect variable="money" modifier="subtract" value="100"/>` |
| "연애플래그 활성화" | `<effect variable="romance_flag" modifier="set" value="true"/>` |

### 5. 루트 분기 로직

```python
# 의사코드
if 선택지에서 "다음: X"가 지정된 경우:
    if X가 기존 씬의 연속이면:
        target_route = "main"
    elif X가 새로운 스토리 라인이면:
        target_route = generate_route_id(X)
        새 루트 생성
```

## 실제 변환 예제

### 입력 텍스트
```
제목: 카페에서의 만남
설정: 작은 카페, 오후 시간

# 캐릭터
- 사라: 친근한 바리스타, 항상 미소를 띤다
- 플레이어: 단골 손님

# 시나리오
## 씬1: 주문
사라: 어서오세요! 오늘은 뭘 드릴까요?
플레이어: 음... 뭐가 좋을까요?
사라: 오늘 특별히 새로운 블렌드를 만들어봤는데 한 번 드셔보시겠어요?

선택지:
1. 새로운 블렌드를 주문한다 → 호기심+1, 사라 호감도+2
2. 평소 마시던 아메리카노를 주문한다 → 안정감+1
3. 사라에게 추천을 부탁한다 → 사라 호감도+1, 신뢰도+1
```

### 출력 XML (시나리오)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scenario name="cafe_meeting" default_route="main">
    <route id="main" name="메인 스토리">
        <scene id="order_scene" path="res://scenes/dialogue/order_scene.xml">
            <set_variable name="order_scene_complete" value="true"/>
            
            <choice id="try_new_blend" text="새로운 블렌드를 주문한다">
                <effect variable="curiosity_level" modifier="add" value="1"/>
                <effect variable="sara_affection" modifier="add" value="2"/>
            </choice>
            
            <choice id="order_americano" text="평소 마시던 아메리카노를 주문한다">
                <effect variable="stability_level" modifier="add" value="1"/>
            </choice>
            
            <choice id="ask_recommendation" text="사라에게 추천을 부탁한다">
                <effect variable="sara_affection" modifier="add" value="1"/>
                <effect variable="trust_level" modifier="add" value="1"/>
            </choice>
        </scene>
    </route>
    
    <global_variables>
        <variable name="order_scene_complete" type="bool" default="false"/>
        <variable name="curiosity_level" type="int" default="0"/>
        <variable name="sara_affection" type="int" default="0"/>
        <variable name="stability_level" type="int" default="0"/>
        <variable name="trust_level" type="int" default="0"/>
    </global_variables>
</scenario>
```

### 출력 XML (씬)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene name="order_scene">
    <background type="image" path="res://scenes/background/cafe_interior.png"/>
    
    <character id="sara" name="사라" default_position="right">
        <portrait emotion="normal" path="res://characters/sara/normal.png"/>
        <portrait emotion="happy" path="res://characters/sara/happy.png"/>
        <portrait emotion="welcoming" path="res://characters/sara/welcoming.png"/>
    </character>
    
    <character id="player" name="플레이어" default_position="left">
        <portrait emotion="normal" path="res://characters/player/normal.png"/>
        <portrait emotion="thinking" path="res://characters/player/thinking.png"/>
    </character>
    
    <message speaker="sara" emotion="welcoming">어서오세요! 오늘은 뭘 드릴까요?</message>
    <message speaker="player" emotion="thinking">음... 뭐가 좋을까요?</message>
    <message speaker="sara" emotion="happy">오늘 특별히 새로운 블렌드를 만들어봤는데 한 번 드셔보시겠어요?</message>
    
    <choice_point id="order_choice"/>
</scene>
```

## LLM 프롬프트 템플릿

```
당신은 비주얼 노벨 시나리오를 XML 형식으로 변환하는 전문가입니다.

다음 텍스트 시나리오를 Godot 4.5용 XML 형식으로 변환하세요:

[입력 텍스트]

변환 규칙:
1. 시나리오 제목을 scenario name으로 사용
2. 캐릭터들을 character 요소로 정의
3. 대화를 message 요소로 변환
4. 선택지를 choice 요소로 변환하고 효과/조건 분석
5. 변수는 일관된 명명 규칙 사용 (friendship_level, affection_level 등)
6. 모든 변수를 global_variables에 정의
7. 시나리오 XML과 개별 씬 XML 모두 생성

출력:
1. 메인 시나리오 XML 파일
2. 각 씬에 대한 개별 XML 파일들
3. 사용된 변수 목록과 설명
```

## 품질 검증 체크리스트

LLM 생성 결과 검증 시 확인할 사항:

### XML 구문 검증
- [ ] 올바른 XML 헤더
- [ ] 모든 태그가 올바르게 닫힘
- [ ] 속성값이 인용부호로 감싸짐
- [ ] 특수문자가 올바르게 이스케이프됨

### 내용 일관성 검증
- [ ] 모든 캐릭터가 정의됨
- [ ] 선택지 효과가 올바르게 매핑됨
- [ ] 변수명이 일관됨
- [ ] 파일 경로가 유효함

### 게임플레이 로직 검증
- [ ] 선택지 조건이 논리적임
- [ ] 효과가 균형있음
- [ ] 루트 분기가 명확함
- [ ] 변수 초기값이 적절함

이 가이드를 따라 LLM이 텍스트 시나리오를 XML 형식으로 안정적으로 변환할 수 있습니다.