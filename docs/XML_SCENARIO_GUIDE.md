# Visual Novel XML 시나리오 가이드

## 개요

이 가이드는 Godot 4.5 기반 비주얼 노벨 템플릿에서 사용하는 XML 시나리오 형식을 설명합니다. XML을 사용하여 대화, 선택지, 루트 분기가 있는 복잡한 스토리를 작성할 수 있습니다.

## 파일 구조

```
project/
├── scenes/
│   ├── example_scenario.xml          # 메인 시나리오 파일
│   └── dialogue/
│       ├── first_meeting.xml         # 개별 씬 파일
│       ├── lunch_together.xml
│       └── ...
└── docs/
    ├── XML_SCENARIO_GUIDE.md         # 이 가이드
    └── LLM_SCENARIO_CREATION.md      # LLM용 생성 가이드
```

## XML 구조

### 1. 메인 시나리오 파일 (`scenario`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scenario name="school_life" default_route="main">
    <!-- 루트 정의 -->
    <route id="main" name="메인 스토리">
        <!-- 씬들 -->
    </route>
    
    <!-- 글로벌 변수 -->
    <global_variables>
        <!-- 변수 정의 -->
    </global_variables>
</scenario>
```

#### 속성
- `name`: 시나리오 이름 (고유 식별자)
- `default_route`: 시작 루트 ID

### 2. 루트 (`route`)

```xml
<route id="friendship" name="친구 루트">
    <scene id="lunch_together" path="res://scenes/dialogue/lunch_together.xml">
        <!-- 씬 설정 -->
    </scene>
</route>
```

#### 속성
- `id`: 루트 고유 ID
- `name`: 루트 표시 이름

### 3. 씬 (`scene`)

```xml
<scene id="first_meeting" path="res://scenes/dialogue/first_meeting.xml">
    <!-- 조건 -->
    <condition type="variable" variable="first_meeting_complete" value="false"/>
    
    <!-- 액션 -->
    <set_variable name="first_meeting_complete" value="true"/>
    
    <!-- 선택지 -->
    <choice id="friendly_approach" text="친근하게 인사한다" target_route="friendship">
        <effect variable="friendship_level" modifier="add" value="2"/>
    </choice>
</scene>
```

#### 속성
- `id`: 씬 고유 ID (선택적)
- `path`: 대화 XML 파일 경로

### 4. 조건 (`condition`)

```xml
<!-- 변수 조건 -->
<condition type="variable" variable="friendship_level" value="5"/>

<!-- 요구사항 조건 -->
<condition type="requirement" requires="first_meeting_complete" value="true"/>
```

#### 속성
- `type`: 조건 타입 (`variable`, `requirement`)
- `variable`/`requires`: 확인할 변수명
- `value`: 기대값

### 5. 선택지 (`choice`)

```xml
<choice id="confession" text="고백한다" target_route="romance">
    <!-- 요구사항 -->
    <requirement variable="affection_level" operator=">=" value="5"/>
    
    <!-- 효과 -->
    <effect variable="romance_flag" modifier="set" value="true"/>
</choice>
```

#### 속성
- `id`: 선택지 고유 ID
- `text`: 화면에 표시될 텍스트
- `target_route`: 선택 후 이동할 루트 (선택적)

### 6. 요구사항 (`requirement`)

```xml
<requirement variable="confidence_level" operator=">=" value="3"/>
```

#### 속성
- `variable`: 확인할 변수명
- `operator`: 비교 연산자 (`==`, `>=`, `<=`, `>`, `<`)
- `value`: 비교값

### 7. 효과 (`effect`)

```xml
<!-- 값 설정 -->
<effect variable="romance_flag" modifier="set" value="true"/>

<!-- 값 증가 -->
<effect variable="friendship_level" modifier="add" value="2"/>

<!-- 값 감소 -->
<effect variable="stress_level" modifier="subtract" value="1"/>

<!-- 값 곱하기 -->
<effect variable="money" modifier="multiply" value="2"/>
```

#### 속성
- `variable`: 수정할 변수명
- `modifier`: 수정 방식 (`set`, `add`, `subtract`, `multiply`)
- `value`: 적용할 값

### 8. 글로벌 변수 (`global_variables`)

```xml
<global_variables>
    <variable name="friendship_level" type="int" default="0"/>
    <variable name="romance_flag" type="bool" default="false"/>
    <variable name="player_name" type="string" default="플레이어"/>
</global_variables>
```

#### 속성
- `name`: 변수명
- `type`: 데이터 타입 (`int`, `bool`, `string`, `float`)
- `default`: 초기값

## 개별 씬 파일 구조

### 씬 파일 (`scene`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene name="first_meeting">
    <!-- 배경 -->
    <background type="image" path="res://scenes/background/classroom.png"/>
    
    <!-- 캐릭터 -->
    <character id="yuki" name="유키" default_position="right">
        <portrait emotion="normal" path="res://characters/yuki/normal.png"/>
        <portrait emotion="happy" path="res://characters/yuki/happy.png"/>
    </character>
    
    <!-- 대화 -->
    <message speaker="yuki" emotion="normal">안녕하세요!</message>
    <message speaker="narrator">나레이션 텍스트입니다.</message>
    
    <!-- 선택지 포인트 -->
    <choice_point id="first_meeting_choice"/>
</scene>
```

### 배경 (`background`)

```xml
<background type="image" path="res://scenes/background/school_classroom.png"/>
```

#### 속성
- `type`: 배경 타입 (`image`, `color`)
- `path`: 이미지 파일 경로

### 캐릭터 (`character`)

```xml
<character id="yuki" name="유키" default_position="right">
    <portrait emotion="normal" path="res://characters/yuki/normal.png"/>
    <portrait emotion="happy" path="res://characters/yuki/happy.png"/>
</character>
```

#### 속성
- `id`: 캐릭터 고유 ID
- `name`: 표시될 이름
- `default_position`: 기본 위치 (`left`, `center`, `right`, `far_left`, `far_right` 또는 좌표)

### 초상화 (`portrait`)

```xml
<portrait emotion="happy" path="res://characters/yuki/happy.png"/>
```

#### 속성
- `emotion`: 감정 상태 (예: `normal`, `happy`, `sad`, `angry`, `surprised`)
- `path`: 이미지 파일 경로

### 메시지 (`message`)

```xml
<!-- 캐릭터 대사 -->
<message speaker="yuki" emotion="happy">안녕하세요! 만나서 반가워요!</message>

<!-- 나레이션 -->
<message speaker="narrator">그날은 맑은 봄날이었다.</message>

<!-- 플레이어 대사 -->
<message speaker="player" emotion="determined">네, 저도 반갑습니다!</message>
```

#### 속성
- `speaker`: 발화자 (`캐릭터 ID`, `narrator`, `player`)
- `emotion`: 표정 (캐릭터의 경우에만)

### 선택지 포인트 (`choice_point`)

```xml
<choice_point id="first_meeting_choice"/>
```

선택지는 메인 시나리오 파일에서 정의되며, `choice_point`는 해당 위치를 표시합니다.

## 변수 시스템

### 기본 변수 타입

1. **bool**: true/false 값
   ```xml
   <variable name="is_friend" type="bool" default="false"/>
   ```

2. **int**: 정수 값
   ```xml
   <variable name="friendship_level" type="int" default="0"/>
   ```

3. **string**: 문자열 값
   ```xml
   <variable name="ending_type" type="string" default="normal"/>
   ```

4. **float**: 실수 값
   ```xml
   <variable name="affection_rate" type="float" default="1.0"/>
   ```

### 권장 변수 명명 규칙

- **완료 플래그**: `{이벤트}_complete` (예: `first_meeting_complete`)
- **레벨/점수**: `{항목}_level` (예: `friendship_level`, `affection_level`)
- **상태 플래그**: `{상태}_flag` (예: `romance_flag`, `confession_flag`)
- **설정값**: `{항목}_setting` (예: `difficulty_setting`)

## 예제 시나리오

### 간단한 분기 시나리오

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scenario name="simple_choice" default_route="main">
    <route id="main" name="메인">
        <scene id="meeting" path="res://scenes/dialogue/meeting.xml">
            <choice id="be_nice" text="친절하게 대한다">
                <effect variable="karma" modifier="add" value="1"/>
            </choice>
            <choice id="be_rude" text="무례하게 대한다">
                <effect variable="karma" modifier="subtract" value="1"/>
            </choice>
        </scene>
        
        <scene id="result" path="res://scenes/dialogue/result.xml">
            <condition type="variable" variable="karma" value=">=1"/>
            <!-- karma가 1 이상일 때만 실행 -->
        </scene>
    </route>
    
    <global_variables>
        <variable name="karma" type="int" default="0"/>
    </global_variables>
</scenario>
```

## 모범 사례

### 1. 파일 구조
- 시나리오는 논리적 단위로 분할
- 씬 파일은 `/scenes/dialogue/` 폴더에 정리
- 이미지는 `/characters/`, `/scenes/background/` 폴더에 정리

### 2. 변수 관리
- 명확하고 일관된 변수명 사용
- 글로벌 변수에 모든 사용할 변수 미리 정의
- 불필요한 변수 생성 방지

### 3. 선택지 설계
- 각 선택지는 의미있는 결과를 가져야 함
- 요구사항이 있는 선택지는 플레이어가 조건을 알 수 있도록 힌트 제공
- 선택지는 3-4개를 넘지 않는 것이 좋음

### 4. 루트 분기
- 명확한 루트 구분과 이름 설정
- 루트 간 교차는 최소화
- 각 루트는 독립적인 완결성을 가져야 함

## 디버깅 팁

### 1. XML 유효성 검사
```bash
# XML 문법 검사
xmllint --noout scenarios/example_scenario.xml
```

### 2. 일반적인 오류
- **닫히지 않은 태그**: 모든 태그는 올바르게 닫혀야 함
- **특수 문자**: `<`, `>`, `&`는 `&lt;`, `&gt;`, `&amp;`로 이스케이프
- **경로 오류**: 파일 경로는 `res://`로 시작하는 Godot 경로 사용
- **변수 오타**: 변수명은 대소문자 구분하므로 정확히 입력

### 3. 테스트 방법
- 각 루트를 개별적으로 테스트
- 변수 상태를 확인하며 진행
- 경계 값(최대/최소)에서 동작 확인

## 확장 가능성

이 XML 구조는 다음과 같은 확장이 가능합니다:

- **음악/효과음 시스템**
- **화면 효과 (전환, 필터)**
- **아이템/인벤토리 시스템**
- **미니게임 통합**
- **다국어 지원**

자세한 확장 방법은 개별 가이드를 참조하세요.