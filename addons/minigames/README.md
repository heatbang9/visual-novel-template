# 미니게임 동적 로딩 시스템

## 개요

이 시스템은 Godot 4.5 기반 비주얼 노벨 템플릿에서 미니게임을 동적으로 로드하고 관리하는 플러그인 아키텍처를 제공합니다.

## 주요 기능

- **동적 로딩**: 런타임에 미니게임을 로드하고 언로드
- **폴더 스캔**: 자동으로 미니게임 폴더를 스캔하여 사용 가능한 게임 목록 생성
- **설정 파일**: JSON 기반 설정 파일로 미니게임 메타데이터 관리
- **카테고리/태그**: 미니게임 분류 및 검색 지원
- **의존성 관리**: 미니게임 간 의존성 체크

## 파일 구조

```
addons/minigames/
├── minigame_interface.gd      # 미니게임 인터페이스 정의
├── minigame_loader.gd         # 동적 로딩 싱글톤
├── minigame_plugin.gd         # 에디터 플러그인
├── minigames_config.json      # 미니게임 설정 파일
├── plugin.cfg                 # 플러그인 설정
├── tests/                     # 테스트 코드
│   └── test_minigame_loader.gd
└── README.md                  # 이 문서
```

## 사용법

### 1. 미니게임 로드

```gdscript
# 싱글톤으로 접근
var interface = MinigameLoader.load_minigame("puzzle")
if interface:
    print("로드된 게임: ", interface.game_id)
```

### 2. 미니게임 언로드

```gdscript
MinigameLoader.unload_minigame("puzzle")
```

### 3. 사용 가능한 미니게임 목록

```gdscript
var games = MinigameLoader.get_available_minigames()
for game_id in games:
    print(game_id)
```

### 4. 카테고리별 조회

```gdscript
var puzzle_games = MinigameLoader.get_minigames_by_category("puzzle")
var action_games = MinigameLoader.get_minigames_by_category("action")
```

### 5. 태그로 검색

```gdscript
var casual_games = MinigameLoader.get_minigames_by_tag("casual")
```

## MinigameInterface

모든 미니게임은 `MinigameInterface`를 통해 메타데이터를 관리합니다.

### 속성

| 속성 | 타입 | 설명 |
|------|------|------|
| game_id | String | 미니게임 고유 ID |
| game_name_key | String | 현지화된 이름 키 |
| game_desc_key | String | 현지화된 설명 키 |
| scene_path | String | 씬 파일 경로 |
| time_limit | float | 시간 제한 (초) |
| difficulty | int | 난이도 (1-5) |
| category | String | 카테고리 |
| tags | Array[String] | 태그 목록 |
| dependencies | Array[String] | 의존성 목록 |

### 시그널

- `game_completed(success: bool, score: int)`: 게임 완료 시
- `game_exited`: 게임 종료 시

## 설정 파일 (minigames_config.json)

```json
{
  "version": "1.0",
  "minigames": [
    {
      "game_id": "puzzle",
      "game_name_key": "minigame_puzzle_name",
      "game_desc_key": "minigame_puzzle_desc",
      "scene_path": "res://minigames/scenes/puzzle_game.tscn",
      "time_limit": 60.0,
      "difficulty": 2,
      "category": "puzzle",
      "tags": ["puzzle", "logic"],
      "dependencies": []
    }
  ]
}
```

## 카테고리

| 카테고리 | 설명 |
|----------|------|
| action | 액션/반응 기반 게임 |
| puzzle | 퍼즐/논리 게임 |
| strategy | 전략/계획 게임 |
| adventure | 모험/탐험 게임 |
| casual | 캐주얼/편안한 게임 |
| general | 기타 게임 |

## 새 미니게임 추가

1. 미니게임 씬 파일을 적절한 폴더에 배치
   - `res://minigames/scenes/` 또는 `res://minigames_v2/scenes/`

2. `minigames_config.json`에 메타데이터 추가:
   ```json
   {
     "game_id": "my_new_game",
     "game_name_key": "minigame_my_new_game_name",
     "game_desc_key": "minigame_my_new_game_desc",
     "scene_path": "res://minigames/scenes/my_new_game.tscn",
     "time_limit": 60.0,
     "difficulty": 2,
     "category": "puzzle",
     "tags": ["new", "custom"],
     "dependencies": []
   }
   ```

3. 또는 자동 스캔 사용:
   ```gdscript
   MinigameLoader.scan_minigames()
   ```

## 기존 MinigameManager와의 호환성

이 시스템은 기존 `MinigameManager`와 함께 작동합니다:
- `MinigameLoader`: 메타데이터 관리 및 동적 로딩
- `MinigameManager`: 게임 인스턴스 실행 및 수명 관리

## 테스트

GUT(Go Unit Test) 프레임워크를 사용한 테스트:
```bash
# Godot 에디터에서 GUT 플러그인 설치 후 실행
```

## Godot 4.5 호환성

- 타입 힌트 사용 (`: String`, `: int`, `: Array`)
- `FileAccess` 클래스 사용
- `JSON` 클래스 사용
- 시그널 연결 방식 준수

## 라이선스

MIT License
