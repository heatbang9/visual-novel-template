# 기본 미니게임 (V1) 상세 문서

## 1. 반사신경 게임 (Reaction Game)

### 📝 게임 설명
플레이어가 화면에 나타나는 버튼을 빠르게 클릭하는 게임입니다.

### 🎮 게임 플레이
- 랜덤한 위치에 버튼이 나타남
- 빠르게 클릭할수록 높은 점수
- 목표: 정해진 횟수만큼 성공적으로 클릭

### 🎯 난이도별 변화
- **난이도 1**: 3번 클릭, 느린 속도
- **난이도 5**: 13번 클릭, 빠른 속도

### 🎨 필요 리소스
```
assets/sounds/
  ├── button_click.ogg (버튼 클릭 소리)
  └── success.ogg (성공 소리)

assets/textures/
  ├── button_normal.png (일반 버튼)
  └── button_highlight.png (하이라이트 버튼)
```

---

## 2. 색깔 매칭 (Color Match Game)

### 📝 게임 설명
플레이어가 표시된 색상 순서를 기억하고 따라하는 게임입니다.

### 🎮 게임 플레이
- 색상 시퀀스가 순차적으로 표시
- 플레이어가 같은 순서로 색상 버튼 클릭
- 순서가 틀리면 게임 오버

### 🎯 난이도별 변화
- **난이도 1**: 4개 색상
- **난이도 5**: 8개 색상

### 🎨 필요 리소스
```
assets/sounds/
  ├── color_beep_red.ogg
  ├── color_beep_blue.ogg
  ├── color_beep_green.ogg
  └── color_beep_yellow.ogg

assets/textures/
  ├── color_button_red.png
  ├── color_button_blue.png
  ├── color_button_green.png
  └── color_button_yellow.png
```

---

## 3. 퍼즐 조각 맞추기 (Puzzle Game)

### 📝 게임 설명
숫자가 적힌 퍼즐 조각을 올바른 순서로 배열하는 슬라이딩 퍼즐 게임입니다.

### 🎮 게임 플레이
- 3x3 또는 4x4 그리드의 숫자 퍼즐
- 빈 공간을 이용해 조각들을 이동
- 1부터 순서대로 배열하면 승리

### 🎯 난이도별 변화
- **난이도 1-2**: 3x3 그리드 (9조각)
- **난이도 3-5**: 4x4 그리드 (16조각)

### 🎨 필요 리소스
```
assets/sounds/
  ├── puzzle_move.ogg (조각 이동 소리)
  └── puzzle_complete.ogg (완성 소리)

assets/textures/
  ├── puzzle_piece.png (퍼즐 조각)
  ├── puzzle_empty.png (빈 공간)
  └── puzzle_background.png (배경)
```

---

## 4. 단어 맞히기 (Word Guess Game)

### 📝 게임 설명
힌트를 보고 정답 단어를 추측하는 게임입니다.

### 🎮 게임 플레이
- 힌트가 주어짐
- 텍스트 입력으로 답 제출
- 제한된 시도 횟수 내에 정답 맞히기

### 🎯 난이도별 변화
- **난이도 1**: 시도 횟수 5번
- **난이도 5**: 시도 횟수 1번

### 🎨 필요 리소스
```
assets/sounds/
  ├── keyboard_type.ogg (타이핑 소리)
  ├── correct_answer.ogg (정답 소리)
  └── wrong_answer.ogg (오답 소리)

assets/textures/
  ├── textbox_background.png
  └── submit_button.png

assets/data/
  └── word_hints.json (단어-힌트 데이터)
```

---

## 5. 기억력 테스트 (Memory Game)

### 📝 게임 설명
뒤집힌 카드들 중에서 같은 그림의 쌍을 찾는 게임입니다.

### 🎮 게임 플레이
- 카드들이 뒤집혀 있음
- 두 장씩 뒤집어서 같은 그림 찾기
- 모든 쌍을 찾으면 승리

### 🎯 난이도별 변화
- **난이도 1-2**: 4x4 그리드 (8쌍)
- **난이도 3-5**: 6x6 그리드 (18쌍)

### 🎨 필요 리소스
```
assets/sounds/
  ├── card_flip.ogg (카드 뒤집기)
  ├── match_found.ogg (쌍 발견)
  └── no_match.ogg (쌍 실패)

assets/textures/cards/
  ├── card_back.png (카드 뒷면)
  ├── symbol_01.png ~ symbol_18.png (카드 그림들)
  └── card_frame.png (카드 테두리)
```

---

## 6. 미로 탈출 (Maze Game)

### 📝 게임 설명
랜덤 생성된 미로에서 출구를 찾아 탈출하는 게임입니다.

### 🎮 게임 플레이
- WASD 또는 화살표 키로 이동
- 무작위 생성되는 미로 구조
- 출구에 도달하면 승리

### 🎯 난이도별 변화
- **난이도 1**: 13x13 미로
- **난이도 5**: 21x21 미로

### 🎨 필요 리소스
```
assets/sounds/
  ├── footstep.ogg (발걸음 소리)
  ├── wall_bump.ogg (벽 충돌)
  └── exit_found.ogg (출구 발견)

assets/textures/maze/
  ├── wall_tile.png (벽 타일)
  ├── floor_tile.png (바닥 타일)
  ├── player_sprite.png (플레이어)
  └── exit_tile.png (출구)
```

---

## 7. 숫자 맞추기 (Math Game)

### 📝 게임 설명
수학 문제를 풀어 정답을 선택하는 게임입니다.

### 🎮 게임 플레이
- 덧셈, 뺄셈, 곱셈 문제 출제
- 4개의 선택지 중 정답 선택
- 연속으로 문제를 해결

### 🎯 난이도별 변화
- **난이도 1**: 3문제, 작은 수
- **난이도 5**: 13문제, 큰 수

### 🎨 필요 리소스
```
assets/sounds/
  ├── correct_math.ogg (정답)
  ├── wrong_math.ogg (오답)
  └── calculator.ogg (계산기 소리)

assets/textures/ui/
  ├── math_background.png
  ├── answer_button_normal.png
  ├── answer_button_hover.png
  └── math_symbols.png (연산 기호들)
```

## 공통 UI 리소스

### 🎨 모든 게임에서 공통으로 사용되는 리소스
```
assets/ui/common/
  ├── back_button.png (뒤로가기 버튼)
  ├── timer_background.png (타이머 배경)
  ├── score_background.png (점수 배경)
  ├── game_over_panel.png (게임오버 패널)
  ├── victory_panel.png (승리 패널)
  └── pause_button.png (일시정지 버튼)

assets/fonts/
  ├── game_font_regular.ttf (기본 폰트)
  ├── game_font_bold.ttf (굵은 폰트)
  └── game_font_mono.ttf (고정폭 폰트)

assets/sounds/ui/
  ├── ui_click.ogg (UI 클릭)
  ├── game_start.ogg (게임 시작)
  ├── game_end_success.ogg (성공)
  ├── game_end_fail.ogg (실패)
  └── timer_tick.ogg (타이머 틱)
```

## 성능 최적화 팁

### 🚀 리소스 로딩 최적화
- 텍스처 크기를 적절히 압축 (512x512 이하 권장)
- 오디오 파일을 OGG Vorbis 형식으로 압축
- 사용하지 않는 리소스는 즉시 해제

### 🎮 게임 성능 팁
- 오브젝트 풀링 사용으로 메모리 할당 최소화
- 물리 시뮬레이션이 필요하지 않은 경우 Node2D 사용
- 애니메이션은 Tween 대신 AnimationPlayer 사용 권장

## 접근성 고려사항

### ♿ 접근성 개선
- 색상 외에 모양이나 패턴으로도 구분 가능하게 설계
- 키보드만으로도 플레이 가능하도록 구현
- 시각 장애인을 위한 음성 피드백 지원
- 텍스트 크기 조절 기능 제공