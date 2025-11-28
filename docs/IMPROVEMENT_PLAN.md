# 이준호 탐정 시리즈 개선 계획

## 📋 현재 상태 분석 (2024년 11월 28일)

### ✅ 완료된 구현
- **XML 시나리오 시스템**: docs 가이드라인 100% 준수
- **프로젝트 구조**: junho_detective_series 완전 정리
- **캐릭터 시스템**: 20명+ MBTI 기반 프로필 완성
- **다중 에피소드**: episode01~05 시나리오 파일 구비
- **Godot 4.3 호환성**: 스크립트 오류 해결 완료

### ⚠️ 개선이 필요한 부분
1. **리소스 파일 부족**: 실제 게임 에셋 없음
2. **미니게임 씬 누락**: 일부 미니게임 파일 부재
3. **통합 테스트 부족**: 전체 게임 흐름 검증 필요

---

## 🎯 개선 계획 세부사항

### Phase 1: 리소스 파일 시스템 구축 (우선순위: 높음)

#### 1.1 캐릭터 스프라이트 플레이스홀더 생성
**목표**: 게임 실행 가능한 기본 캐릭터 이미지 제공

**작업 내용**:
- `junho_detective_series/resources/characters/` 하위 폴더별 placeholder 이미지 생성
- 각 캐릭터별 감정 상태 이미지 (6개씩)
- 표준 해상도 400x600px PNG 형식

**예상 소요시간**: 2시간

#### 1.2 배경 이미지 플레이스홀더 생성
**목표**: 씬별 배경 이미지 기본 제공

**작업 내용**:
- `junho_detective_series/resources/backgrounds/` 배경 이미지 생성
- 학교 정문, 카페 내부/외부, 교실, 도서관 등 8개
- 표준 해상도 1920x1080px 형식

**예상 소요시간**: 1.5시간

#### 1.3 오디오 파일 플레이스홀더 생성
**목표**: 기본 사운드 시스템 구축

**작업 내용**:
- BGM: 6개 루프 음악 (일상, 카페, 미스터리, 수사, 긴장, 해결)
- SFX: 9개 효과음 (문종, 커피머신, 발걸음 등)
- 무료 라이센스 오디오 또는 임시 파일 사용

**예상 소요시간**: 3시간

### Phase 2: 미니게임 시스템 완성 (우선순위: 중간)

#### 2.1 누락된 미니게임 씬 파일 확인
**목표**: 모든 미니게임 정상 작동 보장

**작업 내용**:
```bash
# MinigameManager에 등록된 40개 미니게임 씬 존재 확인
find minigames/ -name "*.tscn" | wc -l
find minigames_v2/ -name "*.tscn" | wc -l
```

**누락 파일 생성**:
- 기본 MinigameBase 상속받은 템플릿 씬 생성
- 각 게임별 기본 UI 및 로직 구현
- 완료 시그널 시스템 연결

**예상 소요시간**: 4시간

#### 2.2 미니게임 통합 테스트
**목표**: 시나리오-미니게임 연동 검증

**작업 내용**:
- 각 미니게임별 호출/완료 테스트
- 시나리오 분기 로직 확인
- 성공/실패에 따른 스토리 진행 검증

**예상 소요시간**: 2시간

### Phase 3: 통합 테스트 시스템 구축 (우선순위: 중간)

#### 3.1 자동화된 게임 플로우 테스트
**목표**: 전체 에피소드 진행 자동 검증

**작업 내용**:
```gdscript
# tests/integration/
├── test_episode01_flow.gd
├── test_episode02_flow.gd
├── test_xml_loading.gd
└── test_character_interactions.gd
```

**테스트 시나리오**:
- XML 로딩 → 캐릭터 표시 → 대화 진행 → 선택지 → 엔딩
- 각 에피소드별 주요 루트 자동 플레이
- 변수 상태 일관성 검증

**예상 소요시간**: 3시간

#### 3.2 TDD 검증 시스템 확장
**목표**: 실시간 품질 보장 시스템

**작업 내용**:
```gdscript
# addons/mystery_validator_v2/
├── integration_validator.gd      # 통합 검증
├── resource_validator.gd         # 리소스 검증
├── scenario_flow_validator.gd    # 시나리오 흐름 검증
└── performance_validator.gd      # 성능 검증
```

**검증 항목**:
- [ ] 모든 XML 파일 구조 유효성
- [ ] 필수 리소스 파일 존재성
- [ ] 시나리오 변수 일관성
- [ ] 미니게임 연동 정상성
- [ ] 메모리 사용량 최적화

**예상 소요시간**: 4시간

---

## 📅 구현 일정

### Week 1: 리소스 시스템 (Phase 1)
- **Day 1-2**: 캐릭터 스프라이트 플레이스홀더 생성
- **Day 3**: 배경 이미지 플레이스홀더 생성
- **Day 4-5**: 오디오 파일 시스템 구축

### Week 2: 미니게임 완성 (Phase 2)  
- **Day 1-2**: 누락 미니게임 씬 생성 및 구현
- **Day 3**: 미니게임 통합 테스트

### Week 3: 품질 보장 (Phase 3)
- **Day 1-2**: 통합 테스트 시스템 구축
- **Day 3**: TDD 검증 시스템 확장
- **Day 4**: 전체 시스템 검증 및 최적화

---

## 🛠️ 기술적 구현 방안

### 자동 플레이스홀더 생성 시스템
```gdscript
# tools/placeholder_generator.gd
extends EditorScript

func generate_character_placeholders():
    var characters = ["junho", "park_youngsu", "kang_minho", "soyeon"]
    var emotions = ["curious", "thoughtful", "determined", "polite", "observant", "concerned"]
    
    for character in characters:
        for emotion in emotions:
            create_placeholder_image(
                "res://mystery_novel/projects/junho_detective_series/resources/characters/" + 
                character + "/" + emotion + ".png",
                400, 600, get_character_color(character)
            )
```

### 통합 테스트 자동화
```gdscript
# tests/integration/automated_playthrough.gd
extends GutTest

func test_episode02_complete_playthrough():
    var scenario_manager = ScenarioManager.new()
    add_child(scenario_manager)
    
    # 에피소드 로드
    assert_eq(scenario_manager.load_episode("episode2_cafe_mystery"), OK)
    
    # 자동 선택지 진행
    var choices = [0, 1, 0, 2, 1]  # 미리 정의된 선택 경로
    simulate_playthrough(scenario_manager, choices)
    
    # 결과 검증
    assert_true(scenario_manager.get_variable("episode02_complete"))
```

---

## 📊 성공 기준 (KPI)

### 기능적 완성도
- [ ] **XML 시나리오 로딩**: 100% 성공률
- [ ] **캐릭터 표시**: 모든 감정 상태 정상 표시
- [ ] **미니게임 실행**: 40개 게임 모두 오류 없이 실행
- [ ] **에피소드 완주**: 각 에피소드 엔딩까지 진행 가능

### 품질 지표
- [ ] **메모리 사용량**: 512MB 이하 유지
- [ ] **로딩 시간**: 씬 전환 3초 이내
- [ ] **프레임률**: 안정적 60FPS 유지
- [ ] **자동 테스트**: 95% 이상 통과율

### 사용자 경험
- [ ] **직관적 UI**: 별도 설명 없이 조작 가능
- [ ] **부드러운 전환**: 끊김 없는 씬 전환
- [ ] **일관된 스타일**: 통일된 아트 및 UI 디자인
- [ ] **안정성**: 크래시 없는 안정적 실행

---

## 🔄 지속적 개선 계획

### 월간 업데이트 계획
- **Month 1**: 기본 시스템 안정화
- **Month 2**: 추가 에피소드 및 미니게임
- **Month 3**: 고급 기능 (음성, 애니메이션)
- **Month 4+**: 커뮤니티 피드백 반영

### 확장 로드맵
1. **추가 에피소드 제작** (Episode 6-10)
2. **음성 더빙 시스템** 구현
3. **모바일 플랫폼 지원**
4. **다국어 번역** (영어, 일본어)
5. **스팀 출시** 준비

---

## 📝 결론

현재 프로젝트는 **탄탄한 기반**을 가지고 있으며, 위 계획에 따라 체계적으로 개선하면 **상용 수준의 비주얼 노벨**로 완성할 수 있습니다. 

특히 **XML 기반 시나리오 시스템**과 **TDD 방식의 검증 체계**는 다른 비주얼 노벨 프로젝트와 차별화되는 강력한 장점입니다.

**다음 단계**: Phase 1부터 순차적으로 진행하여 3주 내 완전한 게임 시스템 구축을 목표로 합니다.

---

*작성일: 2024년 11월 28일*  
*작성자: Claude Code Assistant*  
*프로젝트: 이준호 탐정 시리즈 비주얼 노벨*