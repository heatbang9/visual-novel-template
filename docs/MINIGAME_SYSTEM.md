# 미니게임 시스템 문서

## 개요

이 문서는 Godot 4.5 기반 비주얼 노벨 템플릿의 미니게임 시스템을 설명합니다. 동적 로딩, 비동기 리소스 관리, 메모리 최적화를 지원합니다.

## 시스템 구성

### 1. MinigameLoader (싱글톤)

미니게임의 동적 로딩과 관리를 담당하는 싱글톤 클래스입니다.

**경로:** `res://addons/minigames/minigame_loader.gd`

#### 주요 메서드

| 메서드 | 설명 | 반환값 |
|--------|------|--------|
| `load_minigame(id: String)` | 동기식 미니게임 로드 | MinigameBase |
| `load_minigame_async(id: String, callback: Callable)` | 비동기식 미니게임 로드 | void |
| `preload_minigames(ids: Array)` | 여러 미니게임 프리로드 | void |
| `unload_minigame(id: String)` | 미니게임 언로드 | void |
| `get_minigame_instance(id: String)` | 로드된 인스턴스 반환 | Node |
| `is_minigame_loaded(id: String)` | 로드 여부 확인 | bool |
| `is_minigame_loading(id: String)` | 로딩 중 여부 확인 | bool |
| `get_available_minigames()` | 사용 가능한 미니게임 목록 | Array |
| `get_minigame_info(id: String)` | 미니게임 정보 반환 | Dictionary |
| `scan_minigames()` | 미니게임 폴더 스캔 | void |
| `unload_all()` | 모든 미니게임 언로드 | void |

#### 시그널

| 시그널 | 매개변수 | 설명 |
|--------|----------|------|
| `minigame_loaded` | game_id: String | 미니게임 로드 완료 |
| `minigame_unloaded` | game_id: String | 미니게임 언로드 완료 |
| `minigame_load_failed` | game_id: String, error: String | 미니게임 로드 실패 |
| `loading_progress` | game_id: String, progress: float | 로딩 진행률 (0.0-1.0) |
| `preload_completed` | game_ids: Array | 프리로드 완료 |

#### 사용 예시

```gdscript
# 동기 로딩
var puzzle = MinigameLoader.load_minigame("test_puzzle")
if puzzle:
    add_child(puzzle)
    puzzle.start({"difficulty": 2})

# 비동기 로딩
MinigameLoader.loading_progress.connect(_on_loading_progress)
MinigameLoader.minigame_loaded.connect(_on_minigame_loaded)

MinigameLoader.load_minigame_async("test_puzzle", func(id, instance):
    add_child(instance)
    instance.start()
)

# 프리로딩
MinigameLoader.preload_minigames(["puzzle_maker", "color_flow", "chain_reaction"])

# 언로드
MinigameLoader.unload_minigame("test_puzzle")
```

### 2. MinigameBase (베이스 클래스)

모든 미니게임이 상속받아야 하는 기본 클래스입니다.

**경로:** `res://minigames/scripts/minigame_base.gd`

#### 주요 메서드

| 메서드 | 설명 | 반환값 |
|--------|------|--------|
| `start(data: Dictionary)` | 게임 시작 | void |
| `pause()` | 게임 일시정지 | void |
| `resume()` | 게임 재개 | void |
| `end()` | 게임 종료 | Dictionary |
| `get_score()` | 현재 점수 반환 | int |
| `is_completed()` | 완료 여부 반환 | bool |
| `update_score(new_score: int)` | 점수 업데이트 | void |
| `add_score(points: int)` | 점수 추가 | void |
| `get_game_data()` | 게임 데이터 반환 (저장용) | Dictionary |
| `load_game_data(data: Dictionary)` | 게임 데이터 로드 | void |

#### 가상 메서드 (오버라이드 가능)

| 메서드 | 설명 |
|--------|------|
| `setup_game()` | 게임 초기 설정 |
| `on_game_start()` | 게임 시작 시 호출 |
| `on_game_pause()` | 게임 일시정지 시 호출 |
| `on_game_resume()` | 게임 재개 시 호출 |
| `on_game_end(success: bool)` | 게임 종료 시 호출 |

#### 시그널

| 시그널 | 매개변수 | 설명 |
|--------|----------|------|
| `game_completed` | success: bool, score: int | 게임 완료 |
| `game_exited` | - | 게임 종료 |
| `game_paused` | - | 게임 일시정지 |
| `game_resumed` | - | 게임 재개 |
| `score_changed` | new_score: int | 점수 변경 |

#### 속성

| 속성 | 타입 | 설명 |
|------|------|------|
| `game_name_key` | String | 게임 이름 (현지화 키) |
| `game_desc_key` | String | 게임 설명 (현지화 키) |
| `time_limit` | float | 시간 제한 (초) |
| `difficulty` | int | 난이도 (1-5) |
| `is_game_active` | bool | 게임 활성화 여부 |
| `is_paused` | bool | 일시정지 여부 |
| `current_score` | int | 현재 점수 |

### 3. MinigameInterface (메타데이터)

미니게임 메타데이터를 관리하는 클래스입니다.

**경로:** `res://addons/minigames/minigame_interface.gd`

## 미니게임 폴더 구조

```
res://
├── addons/
│   └── minigames/
│       ├── minigame_loader.gd      # 싱글톤 로더
│       ├── minigame_interface.gd   # 메타데이터 클래스
│       └── minigames_config.json   # 설정 파일
├── minigames/
│   ├── scripts/
│   │   └── minigame_base.gd        # 베이스 클래스
│   └── scenes/                      # 미니게임 씬
├── minigames_v2/
│   ├── scripts/                     # 미니게임 스크립트
│   └── scenes/                      # 미니게임 씬
└── scenes/
    └── minigames/                   # 추가 미니게임
```

## 새 미니게임 만들기

### 1. 스크립트 작성

```gdscript
# res://scripts/minigames/my_game.gd
extends MinigameBase
class_name MyGame

func _ready() -> void:
    super._ready()
    game_name_key = "my_game_name"
    game_desc_key = "my_game_desc"
    time_limit = 60.0

func setup_game() -> void:
    # 게임 초기화
    pass

func on_game_start() -> void:
    super.on_game_start()
    # 게임 시작 로직
```

### 2. 씬 생성

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/minigames/my_game.gd" id="1"]

[node name="MyGame" type="Control"]
script = ExtResource("1")

[node name="UILayer" type="Control" parent="."]

[node name="GameLayer" type="Control" parent="."]
```

### 3. 자동 등록

미니게임은 자동으로 스캔되어 등록됩니다. 수동으로 등록하려면 `minigames_config.json`을 수정하세요.

## 비동기 로딩

ResourceLoader를 사용한 비동기 로딩을 지원합니다:

```gdscript
# 로딩 진행률 표시
MinigameLoader.loading_progress.connect(func(id, progress):
    print("로딩 중: %s (%.0f%%)" % [id, progress * 100])
)

# 로딩 완료 후 실행
MinigameLoader.load_minigame_async("test_puzzle", func(id, instance):
    get_tree().current_scene.add_child(instance)
    instance.start()
)
```

## 메모리 관리

### LRU 캐시

- 최대 10개 씬 리소스 캐시
- 자동으로 가장 오래된 리소스 제거
- `unload_scene_cache(id)`로 수동 해제 가능

### 자동 언로드

- 5분(300초) 비활성 시 자동 언로드 예약
- 1분마다 체크

### 수동 관리

```gdscript
# 특정 미니게임 언로드
MinigameLoader.unload_minigame("test_puzzle")

# 씬 리소스만 언로드 (인스턴스 유지)
MinigameLoader.unload_scene_cache("test_puzzle")

# 모든 미니게임 언로드
MinigameLoader.unload_all()
```

## 테스트 미니게임

### TestPuzzle

슬라이딩 퍼즐 게임입니다.

**경로:**
- 씬: `res://scenes/minigames/test_puzzle.tscn`
- 스크립트: `res://scripts/minigames/test_puzzle.gd`

**특징:**
- 난이도에 따른 그리드 크기 조정 (3x3 ~ 7x7)
- 해결 가능한 퍼즐만 생성
- 이동 횟수 기반 점수
- 시간 보너스

**실행:**
```gdscript
var puzzle = MinigameLoader.load_minigame("test_puzzle")
add_child(puzzle)
puzzle.start({"difficulty": 2, "time_limit": 90.0})
```

## 에러 처리

### 로드 실패

```gdscript
MinigameLoader.minigame_load_failed.connect(func(id, error):
    push_error("미니게임 로드 실패: %s - %s" % [id, error])
)
```

### 유효성 검사

```gdscript
# 미니게임 존재 확인
if MinigameLoader.has_minigame("test_puzzle"):
    # 로드 가능
    pass

# 로드 여부 확인
if MinigameLoader.is_minigame_loaded("test_puzzle"):
    var instance = MinigameLoader.get_minigame_instance("test_puzzle")
    # 인스턴스 사용
    pass
```

## 카테고리 및 태그

### 카테고리

- `action` - 액션 게임
- `puzzle` - 퍼즐 게임
- `strategy` - 전략 게임
- `adventure` - 어드벤처 게임
- `casual` - 캐주얼 게임
- `general` - 기타

### 검색

```gdscript
# 카테고리로 검색
var puzzle_games = MinigameLoader.get_minigames_by_category("puzzle")

# 태그로 검색
var timed_games = MinigameLoader.get_minigames_by_tag("timed")
```

## Godot 4.5 호환성

- ResourceLoader 비동기 API 사용
- 타입 힌트 적용
- 한국어 주석 유지
- Callable 시그널 연결 방식 사용

## 문제 해결

### 미니게임이 로드되지 않음

1. `minigames_config.json` 확인
2. 씬 경로가 올바른지 확인
3. `MinigameLoader.scan_minigames()` 호출

### 메모리 누수

1. `unload_minigame()` 명시적 호출
2. 인스턴스 `queue_free()` 확인
3. `_scene_cache` 크기 확인

### 비동기 로딩이 완료되지 않음

1. `loading_progress` 시그널 연결 확인
2. 리소스 경로 유효성 확인
3. Godot 콘솔 에러 확인

## 업데이트 로그

### v1.1.0 (2024-03-04)
- 비동기 로딩 지원 추가
- LRU 캐시 시스템 구현
- 자동 언로드 기능 추가
- MinigameBase 인터페이스 확장
- 테스트 미니게임 추가

### v1.0.0
- 기본 미니게임 로딩 시스템
- 카테고리/태그 분류
- 설정 파일 기반 관리
