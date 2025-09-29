# Visual Novel XML 포맷 가이드

## 개요
이 문서는 비주얼 노벨 템플릿의 XML 파일 포맷을 설명합니다. 두 가지 주요 XML 타입이 있습니다:
1. 씬 시퀀스 XML (게임의 전체 흐름 정의)
2. 대화 씬 XML (개별 씬의 내용 정의)

## 씬 시퀀스 XML
시퀀스 XML은 게임의 전체적인 흐름을 정의합니다.

### 기본 구조
```xml
<?xml version="1.0" encoding="UTF-8"?>
<sequence name="시퀀스_이름">
    <scenes>
        <scene path="씬_파일_경로.xml">
            <condition type="조건_타입" variable="변수_이름" value="값"/>
            <on_complete>
                <set_variable name="변수_이름" value="값"/>
                <trigger_event name="이벤트_이름"/>
            </on_complete>
        </scene>
    </scenes>
</sequence>
```

### 주요 요소
- `sequence`: 최상위 요소, `name` 속성으로 시퀀스 이름 지정
- `scenes`: 모든 씬을 포함하는 컨테이너
- `scene`: 개별 씬, `path` 속성으로 씬 파일 경로 지정
  - `condition`: 씬 진입 조건 (`variable`, `requirement` 타입)
  - `on_complete`: 씬 완료 시 실행할 액션

## 대화 씬 XML
대화 씬 XML은 개별 씬의 내용을 정의합니다.

### 기본 구조
```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene name="씬_이름">
    <background type="이미지_타입" path="배경_이미지_경로"/>
    <characters>
        <character id="캐릭터_ID" name="캐릭터_이름" default_position="위치">
            <portrait path="초상화_경로"/>
        </character>
    </characters>
    <dialogue>
        <message speaker="화자_ID" emotion="감정_상태">대사 내용</message>
        <choice text="선택지_설명">
            <option text="옵션_텍스트">
                <message speaker="화자_ID">대사 내용</message>
            </option>
        </choice>
    </dialogue>
</scene>
```

### 주요 요소
- `scene`: 최상위 요소, `name` 속성으로 씬 이름 지정
- `background`: 배경 이미지 정의
- `characters`: 등장 캐릭터 정의
  - `character`: 개별 캐릭터 정의
  - `portrait`: 캐릭터 초상화
- `dialogue`: 대화 내용 정의
  - `message`: 개별 대사
  - `choice`: 선택지
  - `option`: 선택지의 개별 옵션

## 예정된 기능
앞으로 추가될 예정인 기능들입니다:

1. 배경 효과
   - 페이드 인/아웃
   - 날씨 효과
   - 시간 변화 효과

2. 캐릭터 기능
   - 다중 포즈/표정
   - 애니메이션 효과
   - 음성 지원

3. 대화 시스템
   - 자동 진행
   - 대화 속도 조절
   - 대화 이력 조회

4. 게임 시스템
   - 세이브/로드
   - 환경 설정
   - 실적 시스템

5. UI/UX
   - 커스텀 테마
   - 다국어 지원
   - 접근성 향상