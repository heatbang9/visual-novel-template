# 다국어 지원 가이드 (Localization Guide)

## 개요

이 비주얼 노벨 템플릿은 확장 가능한 다국어 지원 시스템을 제공합니다. 현재 한국어와 영어를 지원하며, 추가 언어를 쉽게 추가할 수 있습니다.

## 현재 지원 언어

| 언어 | 코드 | 상태 | 완성도 |
|------|------|------|--------|
| 한국어 | `ko` | ✅ 완료 | 100% |
| 영어 | `en` | ✅ 완료 | 100% |

## 다국어 시스템 구조

### 📁 파일 구조
```
localization/
├── localization_manager.gd    # 다국어 관리자
└── translations/              # 번역 파일들 (향후 확장용)
    ├── ko.json               # 한국어 번역
    ├── en.json               # 영어 번역
    └── template.json         # 새 언어 템플릿
```

### 🔧 LocalizationManager 클래스

#### 주요 기능
- 실시간 언어 전환
- 텍스트 키 기반 번역 시스템
- 폴백 메커니즘 (영어 → 키값)
- 언어 변경 이벤트 시스템

#### API 사용법
```gdscript
# 언어 설정
LocalizationManager.set_language("ko")    # 한국어
LocalizationManager.set_language("en")    # 영어

# 텍스트 가져오기
var text = localization_manager.get_text("score", "Score")

# 사용 가능한 언어 목록
var languages = localization_manager.get_available_languages()

# 언어 변경 이벤트 처리
localization_manager.language_changed.connect(_on_language_changed)
```

## 번역 키 규칙

### 🏷️ 키 네이밍 컨벤션

#### 1. UI 요소
```
ui_[컴포넌트]_[설명]
예: ui_button_back, ui_label_score, ui_panel_gameover
```

#### 2. 게임명과 설명
```
[게임명]_name    # 게임 이름
[게임명]_desc    # 게임 설명
예: reaction_game_name, card_battle_desc
```

#### 3. 시스템 메시지
```
system_[상황]
예: system_loading, system_error, system_success
```

#### 4. 게임 상태
```
game_[상태]
예: game_start, game_pause, game_victory, game_defeat
```

## 전체 번역 키 목록

### 🎮 기본 UI
| 키 | 한국어 | 영어 |
|----|--------|------|
| `back_button` | 뒤로 가기 | Back |
| `score` | 점수 | Score |
| `time` | 시간 | Time |
| `start` | 시작 | Start |
| `pause` | 일시정지 | Pause |
| `resume` | 계속 | Resume |
| `game_over` | 게임 오버 | Game Over |
| `success` | 성공 | Success |
| `failed` | 실패 | Failed |
| `try_again` | 다시 시도 | Try Again |
| `next` | 다음 | Next |

### 🎯 기본 미니게임 (V1)
| 키 | 한국어 | 영어 |
|----|--------|------|
| `reaction_game_name` | 반사신경 게임 | Reaction Game |
| `reaction_game_desc` | 버튼이 나타나면 빠르게 클릭하세요! | Click the button quickly when it appears! |
| `color_match_name` | 색깔 매칭 | Color Match |
| `color_match_desc` | 색상 순서를 기억하고 따라하세요! | Remember and follow the color sequence! |
| `puzzle_game_name` | 퍼즐 조각 맞추기 | Puzzle Game |
| `puzzle_game_desc` | 숫자를 올바른 순서로 배열하세요! | Arrange the numbers in correct order! |
| `word_guess_name` | 단어 맞히기 | Word Guess |
| `word_guess_desc` | 힌트를 보고 단어를 맞춰보세요! | Guess the word from the hint! |
| `memory_game_name` | 기억력 테스트 | Memory Game |
| `memory_game_desc` | 같은 그림의 카드 쌍을 찾으세요! | Find pairs of matching cards! |
| `maze_game_name` | 미로 탈출 | Maze Escape |
| `maze_game_desc` | 화살표 키로 미로를 탈출하세요! | Escape the maze using arrow keys! |
| `math_game_name` | 숫자 맞추기 | Math Game |
| `math_game_desc` | 수학 문제를 풀어보세요! | Solve math problems! |
| `pattern_game_name` | 패턴 따라하기 | Pattern Game |
| `pattern_game_desc` | 순서대로 버튼을 클릭하세요! | Click buttons in sequence! |
| `find_object_name` | 물건 찾기 | Find Objects |
| `find_object_desc` | 숨겨진 물건들을 찾으세요! | Find the hidden objects! |
| `balance_game_name` | 균형 맞추기 | Balance Game |
| `balance_game_desc` | 시소의 균형을 맞춰보세요! | Balance the seesaw! |

### 🏆 고급 미니게임 (V2)
| 키 | 한국어 | 영어 |
|----|--------|------|
| `card_battle_name` | 카드 배틀 | Card Battle |
| `card_battle_desc` | 전략적으로 카드를 사용해 적을 물리치세요! | Use cards strategically to defeat enemies! |
| `dungeon_crawler_name` | 던전 크롤러 | Dungeon Crawler |
| `dungeon_crawler_desc` | 랜덤 던전을 탐험하며 보물을 찾으세요! | Explore random dungeons for treasure! |
| `tower_defense_name` | 타워 디펜스 | Tower Defense |
| `tower_defense_desc` | 적의 침입을 막아내세요! | Defend against incoming enemies! |
| `log_adventure_name` | 로그 어드벤처 | Log Adventure |
| `log_adventure_desc` | 선택을 통해 모험을 진행하세요! | Progress through choices in your adventure! |
| `stack_management_name` | 스택 매니지먼트 | Stack Management |
| `stack_management_desc` | 리소스를 효율적으로 관리하세요! | Manage resources efficiently! |

## 새로운 언어 추가하기

### 1️⃣ 언어 등록
```gdscript
# localization_manager.gd의 available_languages에 추가
var available_languages: Array[String] = ["ko", "en", "ja"]  # 일본어 추가
```

### 2️⃣ 번역 데이터 추가
```gdscript
# localization_manager.gd의 translations에 추가
"ja": {
    "back_button": "戻る",
    "score": "スコア",
    "time": "時間",
    # ... 모든 키에 대한 번역
}
```

### 3️⃣ 폰트 지원 확인
```gdscript
# 새로운 언어의 글자가 포함된 폰트 사용
# 예: 일본어의 경우 한자, 히라가나, 가타가나 지원 폰트 필요
```

## 언어별 특수 고려사항

### 🇰🇷 한국어 (Korean)
- **텍스트 길이**: 영어보다 20-30% 짧을 수 있음
- **폰트**: 한글 완성형 지원 폰트 필요
- **줄바꿈**: 단어 단위보다 글자 단위 줄바꿈 선호

### 🇺🇸 영어 (English)
- **텍스트 길이**: 기준 언어로 사용
- **폰트**: 기본 라틴 문자 지원으로 충분
- **줄바꿈**: 단어 단위 줄바꿈 필수

### 🇯🇵 일본어 (Japanese) - 향후 지원 예정
- **텍스트 길이**: 한국어와 비슷하거나 약간 길 수 있음
- **폰트**: 히라가나, 가타가나, 한자 지원 필요
- **줄바꿈**: 문자 단위 줄바꿈, 금칙 문자 고려

### 🇨🇳 중국어 (Chinese) - 향후 지원 예정
- **텍스트 길이**: 영어보다 짧을 수 있음
- **폰트**: 간체 또는 번체 한자 지원 필요
- **줄바꿈**: 문자 단위 줄바꿈

## 번역 품질 관리

### ✅ 번역 체크리스트
- [ ] 모든 키에 대한 번역 완료
- [ ] 컨텍스트에 맞는 적절한 번역
- [ ] UI에서 텍스트 길이 확인
- [ ] 폰트 렌더링 확인
- [ ] 문화적 적절성 검토

### 🔍 테스트 방법
```gdscript
# 모든 언어로 전환하여 테스트
func test_all_languages():
    for lang in localization_manager.get_available_languages():
        localization_manager.set_language(lang)
        # UI 요소들이 올바르게 표시되는지 확인
        await get_tree().process_frame
```

### 📏 텍스트 길이 테스트
```gdscript
# 긴 텍스트가 UI를 벗어나지 않는지 확인
func check_text_overflow():
    var test_keys = ["card_battle_desc", "dungeon_crawler_desc"]
    for key in test_keys:
        var text = localization_manager.get_text(key)
        if text.length() > MAX_TEXT_LENGTH:
            push_warning("Text too long for key: " + key)
```

## 모범 사례 (Best Practices)

### 💡 번역 팁
1. **컨텍스트 제공**: 번역자에게 텍스트가 사용되는 상황 설명
2. **일관성 유지**: 같은 의미의 단어는 항상 같은 번역 사용
3. **간결성**: UI 공간 제약을 고려한 간결한 번역
4. **문화적 적응**: 단순 직역보다는 문화적으로 적절한 의역

### 🎯 개발 팁
```gdscript
# 하드코딩된 텍스트 대신 항상 번역 키 사용
# ❌ 잘못된 예
button.text = "시작"

# ✅ 올바른 예
button.text = localization_manager.get_text("start", "Start")
```

### 🔧 성능 최적화
```gdscript
# 자주 사용되는 텍스트는 캐싱
var cached_texts: Dictionary = {}

func get_cached_text(key: String) -> String:
    if key not in cached_texts:
        cached_texts[key] = localization_manager.get_text(key)
    return cached_texts[key]
```

## 향후 계획

### 🚀 계획된 기능
- [ ] JSON 파일 기반 번역 데이터 분리
- [ ] 실시간 번역 편집기
- [ ] 번역 진행률 추적 시스템
- [ ] 자동 번역 API 연동
- [ ] 복수형 처리 시스템
- [ ] 날짜/시간 형식 지역화

### 🌍 추가 언어 계획
- [ ] 일본어 (ja)
- [ ] 중국어 간체 (zh-CN)
- [ ] 스페인어 (es)
- [ ] 프랑스어 (fr)
- [ ] 독일어 (de)