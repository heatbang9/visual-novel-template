# Mystery Novel: 도서관의 시간 캡슐 미스터리

고등학교 1학년 이준호가 주인공인 미스터리 비주얼 노벨 시리즈의 첫 번째 에피소드입니다.

## 📖 스토리 개요

세인트 아카데미아 고등학교 1학년 이준호는 도서관 리모델링 중 발견된 의문의 시간 캡슐을 통해 50년 전에 일어난 학생 사망 사건의 진실을 추적합니다. 하지만 조사를 진행할수록 현재도 지속되는 위험한 음모에 휘말리게 됩니다.

## 🎮 게임 특징

### TDD 기반 개발
- **테스트 우선 개발**: 모든 게임 로직이 테스트로 검증됨
- **실시간 검증**: 플레이 중 상태 일관성 자동 체크
- **품질 보장**: 버그 최소화와 안정적인 게임플레이

### 다양한 선택과 결과
- **능력치 기반 선택지**: 호기심, 용기, 관찰력 등에 따른 분기
- **다중 엔딩**: 4가지 서로 다른 결말
- **단서 수집 시스템**: 플레이어의 조사 방식에 따른 진행

### 현실적인 고1 주인공
- 완벽하지 않은 16세 소년의 성장기
- 동급생들과의 협력과 갈등
- 어른 세계의 복잡함을 배워가는 과정

## 🛠️ 기술적 구현

### XML 시나리오 시스템
```xml
<!-- 예시: 선택지와 능력치 요구사항 -->
<choice id="decode_message" text="암호 메시지를 해독한다">
    <requirement variable="curiosity_level" operator=">=" value="3"/>
    <effect variable="cipher_clues" modifier="add" value="3"/>
    <effect variable="logic_skill" modifier="add" value="2"/>
</choice>
```

### 검증 시스템
```gdscript
# 실시간 상태 검증
func validate_current_state(current_state: Dictionary):
    # 논리적 일관성 체크
    # 변수 범위 검증
    # 진행 조건 확인
```

## 📁 파일 구조

```
mystery_novel/
├── characters/          # 캐릭터 설정
│   ├── protagonist.md
│   └── supporting_characters.md
├── scenario/           # 스토리 구조
│   └── mystery_plot.md
└── analysis/          # 프로젝트 분석
    └── project_overview.md

scenes/
├── mystery_novel_scenario.xml    # 메인 시나리오
└── dialogue/mystery/            # 개별 씬들
    ├── prologue_discovery.xml
    ├── chapter1_contents.xml
    └── ...

tests/mystery_novel/
└── test_mystery_scenario.gd     # TDD 테스트 슈트

addons/mystery_validator/
├── mystery_scenario_validator.gd # 검증 시스템
├── plugin.gd
└── plugin.cfg
```

## 🧪 검증 실행 방법

### 1. 자동 검증 (추천)
```bash
# Godot 엔진을 통한 전체 검증
godot -s scripts/run_mystery_validation.gd
```

### 2. 수동 테스트
```bash
# GUT 프레임워크를 통한 단위 테스트
godot -s addons/gut/gut_cmdln.gd
```

### 3. 에디터 내 검증
```gdscript
# 게임 내에서 검증기 호출
var validator = MysteryValidator.new()
validator.validate_complete_scenario()
```

## 📊 검증 항목

### ✅ XML 구조 검증
- 시나리오 파일 구문 정확성
- 필수 요소 존재 확인
- 캐릭터/배경 경로 유효성

### ✅ 게임 로직 검증
- 변수 초기화 상태
- 선택지 요구사항 로직
- 능력치 증감 계산

### ✅ 진행 흐름 검증
- 챕터 간 전환 조건
- 단서 수집 시스템
- 엔딩 분기 로직

### ✅ 상태 일관성 검증
- 실시간 변수 범위 체크
- 논리적 모순 감지
- 진행 불가능한 상태 방지

## 🎯 핵심 변수 시스템

### 능력치
- `curiosity_level`: 호기심 (선택지 해금)
- `courage_level`: 용기 (위험한 선택 가능)
- `observation_skill`: 관찰력 (단서 발견)
- `logic_skill`: 논리력 (추리 정확도)

### 진행 상태
- `evidence_strength`: 증거 강도 (엔딩 결정)
- `investigation_progress`: 조사 진행도
- `danger_level`: 위험도 ("low", "medium", "high")

### 관계 및 접근
- `investigation_approach`: 조사 방식 ("collaborative", "aggressive", "official")
- `teamwork_level`: 팀워크 정도
- `adult_support`: 어른 도움 정도

## 🎭 캐릭터

### 주인공
- **이준호** (16세, 고1): 순수한 정의감을 가진 미래의 명탐정

### 조력자
- **김서연** (16세, 고1): 준호의 반친구, 뛰어난 관찰력
- **박민수** (16세, 고1): 도서부 소속, 연구에 특화
- **최하늘** (16세, 고1): 학생회 간부, 사교적

## 🏆 달성 가능한 엔딩

### A. 완전한 진실 (True Ending)
- 조건: 증거 강도 10+, 용기 5+
- 결과: 50년 전 사건 완전 해결, 정의 실현

### B. 부분적 해결
- 조건: 증거 강도 7+
- 결과: 범인 처벌, 하지만 일부 진실은 미궁

### C. 실패 엔딩
- 조건: 증거 부족
- 결과: 미해결, 하지만 소중한 우정 획득

### D. 특별 엔딩 (숨겨진 조건)
- 조건: 특정 선택지 조합
- 결과: 준호와 50년 전 사건의 운명적 연결 발견

## 🔄 개발 워크플로우

### 1. 테스트 작성 (Red)
```gdscript
func test_new_feature():
    assert_false(feature_exists(), "Feature should not exist yet")
```

### 2. 기능 구현 (Green)
```gdscript
func implement_feature():
    # 테스트를 통과하는 최소한의 구현
```

### 3. 리팩토링 (Refactor)
```gdscript
func optimize_feature():
    # 코드 품질 향상, 테스트는 계속 통과
```

## 📈 확장 계획

### 시리즈화
- **2학년 에피소드**: 더 복잡한 범죄 수사
- **3학년 에피소드**: 진로 결정과 마지막 미스터리
- **졸업 후**: 전문 탐정으로서의 첫 사건

### 시스템 확장
- **미니게임**: 암호 해독, 단서 조합
- **다국어 지원**: 영어, 일본어 등
- **음성 추가**: 캐릭터별 성우 더빙

## 🤝 기여 방법

1. **테스트 추가**: 새로운 기능에 대한 테스트 작성
2. **시나리오 확장**: 추가 분기나 선택지 제안
3. **버그 리포트**: 검증 시스템을 통한 이슈 발견
4. **번역 기여**: 다국어 지원 확장

## 📞 문의

- **개발**: Claude Code Assistant
- **검증**: TDD 자동화 시스템
- **QA**: 실시간 상태 검증기

---

*"진실은 항상 복잡하지만, 그것을 찾아가는 과정에서 우리는 성장한다." - 이준호*