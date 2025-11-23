# Development Guide

## 프로젝트 구조 및 개발 가이드

### 🏗️ 아키텍처 개요

```
visual-novel-template/
├── addons/                     # 핵심 시스템 애드온들
│   ├── audio_system/           # 🎵 오디오 & TTS 관리
│   ├── choice_system/          # 🎯 선택지 UI 시스템
│   ├── game_manager/           # 🎮 멀티게임 관리
│   ├── localization_system/    # 🌐 다국어 시스템
│   ├── scenario_system/        # 📜 시나리오 처리
│   ├── scene_system/           # 🎬 씬 로더
│   └── visual_effects/         # ✨ 시각 효과
├── games/                      # 🎲 게임 컨텐츠
│   ├── school_romance/         # 학교 로맨스 게임
│   ├── mystery_detective/      # 미스터리 탐정 게임
│   ├── space_adventure/        # SF 우주 모험 게임
│   └── games_config.json       # 게임 설정 파일
├── localization/               # 🗣️ 다국어 번역 파일
│   ├── ko/, en/, ja/           # 언어별 번역
├── scenes/ui/                  # 🖥️ UI 씬들
├── tools/                      # 🔧 개발 도구들
└── docs/                       # 📖 문서들
```

## 🎮 새 게임 추가하기

### 1. 게임 폴더 구조 생성

```bash
games/
└── your_game/
    ├── scenarios/
    │   └── main_story.xml      # 메인 시나리오
    ├── scenes/
    │   ├── opening.xml         # 개별 씬들
    │   └── ...
    ├── characters/             # 캐릭터 이미지
    ├── backgrounds/            # 배경 이미지
    └── audio/
        ├── bgm/                # 배경음악
        ├── sfx/                # 효과음
        └── voice/              # 음성 파일
```

### 2. games_config.json에 게임 등록

```json
{
  "games": {
    "your_game": {
      "id": "your_game",
      "title": "게임 제목",
      "title_en": "Game Title",
      "title_ja": "ゲームタイトル",
      "description": "게임 설명...",
      "version": "1.0.0",
      "author": "개발자명",
      "scenario_path": "res://games/your_game/scenarios/",
      "main_scenario": "main_story.xml",
      "estimated_playtime": 60,
      "genre": ["adventure", "fantasy"],
      "enabled": true,
      "featured": false
    }
  }
}
```

### 3. 시나리오 XML 작성

메인 시나리오 구조:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<scenario name="your_game_main" default_route="prologue">
    
    <route id="prologue" name="프롤로그">
        <scene id="opening" path="res://games/your_game/scenes/opening.xml">
            <condition type="variable" variable="game_started" value="false"/>
            <set_variable name="game_started" value="true"/>
            
            <choice id="first_choice" text="첫 번째 선택지">
                <effect variable="some_value" modifier="add" value="1"/>
            </choice>
        </scene>
    </route>
    
    <global_variables>
        <variable name="game_started" type="bool" default="false"/>
        <variable name="some_value" type="int" default="0"/>
    </global_variables>
    
</scenario>
```

## 🎨 고급 연출 기법

### 1. 캐릭터 애니메이션

```xml
<!-- 캐릭터 등장 -->
<action type="character_enter" target="character_id" duration="1.5" wait="true">
    <parameters animation="slide_left" position="center"/>
</action>

<!-- 감정 변화 -->
<action type="change_emotion" target="character_id" duration="0.5" wait="true">
    <parameters emotion="surprised" transition="fade"/>
</action>

<!-- 캐릭터 이동 -->
<action type="character_move" target="character_id" duration="2.0" wait="true">
    <parameters to_position="right" animation="ease_in_out"/>
</action>
```

### 2. 화면 효과

```xml
<!-- 화면 전환 -->
<action type="screen_effect" duration="1.0" wait="true">
    <parameters effect="fade_black"/>
</action>

<!-- 카메라 줌 -->
<action type="camera_zoom" target="camera" duration="2.0" wait="true">
    <parameters zoom_level="1.5" animation="ease_in_out"/>
</action>

<!-- 화면 쉐이크 -->
<action type="screen_effect" duration="0.5" wait="false">
    <parameters effect="shake" intensity="3.0"/>
</action>
```

### 3. 오디오 제어

```xml
<!-- BGM 재생 -->
<action type="play_bgm" duration="2.0" wait="false">
    <parameters audio_path="res://games/your_game/audio/bgm/theme.ogg" 
               fade_in="true" loop="true"/>
</action>

<!-- 효과음 -->
<action type="play_sfx" wait="false">
    <parameters audio_path="res://games/your_game/audio/sfx/door.ogg" 
               volume="0.8" pitch="1.0"/>
</action>
```

## 🌐 다국어 지원

### 1. 번역 파일 구조

```
localization/
├── ko/
│   ├── general.json
│   ├── scenarios.json
│   └── characters.json
├── en/
│   └── ...
└── ja/
    └── ...
```

### 2. 번역 파일 예제 (scenarios.json)

```json
{
  "your_game": {
    "opening": {
      "title": "오프닝",
      "welcome_message": "게임에 오신 것을 환영합니다!"
    },
    "characters": {
      "hero_greeting": "안녕하세요, 저는 주인공입니다."
    }
  }
}
```

### 3. XML에서 다국어 사용

```xml
<!-- 방법 1: localization_key 사용 -->
<message speaker="hero" localization_key="your_game.characters.hero_greeting">
    안녕하세요, 저는 주인공입니다.
</message>

<!-- 방법 2: 직접 번역 포함 -->
<message speaker="hero">
    안녕하세요, 저는 주인공입니다.
    <translation lang="en">Hello, I'm the protagonist.</translation>
    <translation lang="ja">こんにちは、私は主人公です。</translation>
</message>
```

## 🔧 코드 개발 가이드

### 1. 새로운 시스템 추가

새로운 애드온 시스템을 추가할 때:

```gdscript
extends Node

class_name YourNewSystem

signal system_initialized()
signal system_event_occurred(event_data: Dictionary)

@export var config_data: Dictionary = {}
@export var enabled: bool = true

func _ready() -> void:
    _initialize_system()

func _initialize_system() -> void:
    # 시스템 초기화 로직
    print("YourNewSystem initialized")
    emit_signal("system_initialized")

# 다른 시스템과의 통합을 위한 표준 인터페이스
func get_system_info() -> Dictionary:
    return {
        "name": "YourNewSystem",
        "version": "1.0.0",
        "enabled": enabled,
        "status": "active"
    }
```

### 2. XML 파서 확장

XML 요소를 추가하려면 `enhanced_scene_loader.gd`의 `_parse_enhanced_scene_xml` 함수를 수정:

```gdscript
# enhanced_scene_loader.gd에 추가
match node_name:
    "your_new_element":
        var element_data = {
            "type": "your_new_element",
            "param1": parser.get_named_attribute_value("param1"),
            "param2": parser.get_named_attribute_value("param2")
        }
        current_scene.your_elements.append(element_data)
```

### 3. 게임 상태 관리

게임 저장/로드를 위한 표준 인터페이스:

```gdscript
# 저장할 상태 반환
func get_save_data() -> Dictionary:
    return {
        "system_name": get_system_name(),
        "data": your_system_data,
        "timestamp": Time.get_unix_time_from_system()
    }

# 상태 복원
func load_save_data(save_data: Dictionary) -> void:
    if save_data.has("data"):
        your_system_data = save_data["data"]
        _restore_system_state()
```

## 🧪 테스팅 가이드

### 1. 게임 테스트

```gdscript
# tests/test_your_game.gd
extends GutTest

func test_game_loading():
    var game_manager = GameProjectManager.new()
    var result = game_manager.select_game("your_game")
    assert_eq(result, OK)

func test_scenario_parsing():
    var scenario_manager = ScenarioManager.new()
    var result = scenario_manager.load_scenario("res://games/your_game/scenarios/main_story.xml")
    assert_eq(result, OK)
    assert_true(scenario_manager.current_scenario.has("name"))
```

### 2. 다국어 테스트

```bash
# 모든 언어로 게임 테스트
godot --headless -s tests/test_localization.gd
```

### 3. 빌드 테스트

```bash
# 각 빌드 타입 테스트
tools/build_configurator.gd quick_dev_build
tools/build_configurator.gd quick_prod_build ["your_game"]
tools/build_configurator.gd quick_single_build "your_game"
```

## 📈 성능 최적화

### 1. 리소스 관리

```gdscript
# 리소스 프리로딩
func preload_game_resources(game_id: String) -> void:
    var resource_list = [
        "res://games/%s/audio/bgm/" % game_id,
        "res://games/%s/characters/" % game_id,
        "res://games/%s/backgrounds/" % game_id
    ]
    
    for path in resource_list:
        ResourceLoader.load_threaded_request(path)
```

### 2. 메모리 최적화

```gdscript
# 사용하지 않는 게임 리소스 정리
func cleanup_unused_game_resources() -> void:
    for game_id in loaded_games:
        if game_id != current_game_id:
            _unload_game_resources(game_id)
```

### 3. XML 파싱 최적화

```gdscript
# XML 캐싱
var xml_cache: Dictionary = {}

func parse_xml_with_cache(xml_path: String) -> Dictionary:
    if xml_cache.has(xml_path):
        return xml_cache[xml_path]
    
    var parsed_data = _parse_xml_file(xml_path)
    xml_cache[xml_path] = parsed_data
    return parsed_data
```

## 🚀 배포 가이드

### 1. 빌드 설정

```gdscript
# build_configurator.gd 사용
var configurator = BuildConfigurator.new()

# 개발 빌드
configurator.configure_development_build()

# 프로덕션 빌드 (특정 게임만)
configurator.configure_production_build(["school_romance", "mystery_detective"])

# 단일 게임 빌드
configurator.configure_single_game_build("your_game")
```

### 2. 플랫폼별 빌드

```bash
# Windows
godot --headless --export-release "Windows Desktop" "builds/windows/game.exe"

# macOS
godot --headless --export-release "macOS" "builds/macos/game.zip"

# Linux
godot --headless --export-release "Linux/X11" "builds/linux/game.x86_64"
```

### 3. 배포 검증

배포 전 체크리스트:
- [ ] 모든 게임이 정상적으로 로드됨
- [ ] 다국어 전환이 올바르게 작동함
- [ ] 음성 및 음향이 정상 재생됨
- [ ] 저장/로드 기능이 작동함
- [ ] 설정 변경이 유지됨

## 🔍 디버깅 팁

### 1. XML 검증

```bash
# XML 문법 검사
xmllint --noout games/your_game/scenarios/main_story.xml
```

### 2. 로그 분석

```gdscript
# 디버그 로그 활성화
func _ready():
    if OS.is_debug_build():
        set_debug_logging(true)

func set_debug_logging(enabled: bool):
    ProjectSettings.set_setting("debug/verbose_logging", enabled)
```

### 3. 성능 프로파일링

```gdscript
# 프레임 타이밍 측정
func _process(_delta):
    if OS.is_debug_build():
        var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
        if frame_time > 16.67:  # 60 FPS 기준
            print("Frame drop detected: ", frame_time, "ms")
```

## 📚 추가 리소스

- [Godot 4.5 Documentation](https://docs.godotengine.org/en/stable/)
- [Dialogic Documentation](https://dialogic.coppolaemilio.com/)
- [XML Processing Best Practices](docs/XML_SCENARIO_GUIDE.md)
- [LLM Integration Guide](docs/LLM_SCENARIO_CREATION.md)

---

**💡 팁**: 개발 중 문제가 발생하면 `codex.md` 파일의 개발 플로우를 참조하고, 테스트 주도 개발(TDD) 접근법을 사용하세요.